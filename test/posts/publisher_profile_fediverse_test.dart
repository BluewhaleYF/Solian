import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:island/posts/widgets/fediverse_publisher_info.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _actorId = 'f1bd2951-d320-430f-af22-3038ff291ea9';
const _actorDomain = 'sc.littlesheep.me';
const _actorUsername = 'littlesheep';

/// Mirrored remote actor: no `account`, so the account link and the account
/// status row of a local publisher must not be rendered for it.
SnPublisher _remoteActor() {
  return SnPublisher.fromJson({
    'id': _actorId,
    'type': 2,
    'username': _actorUsername,
    'nick': 'LittleSheep',
    'display_name': 'LittleSheep',
    'bio': 'Remote actor bio',
    'full_handle': '$_actorUsername@$_actorDomain',
    'instance': {'id': 'instance-1', 'domain': _actorDomain},
  });
}

class _EmptyActorPosts extends FediverseActorPostsNotifier {
  _EmptyActorPosts(super.actorId);

  @override
  Future<PaginationState<SnPost>> build() async {
    return const PaginationState<SnPost>(
      items: <SnPost>[],
      isLoading: false,
      isReloading: false,
      totalCount: 0,
      hasMore: false,
      cursor: null,
    );
  }
}

/// Records every request and answers 404: the endpoints under test must never
/// be reached for a remote actor.
class _RecordingHttpAdapter implements HttpClientAdapter {
  final List<String> requestedPaths = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedPaths.add(options.path);
    return ResponseBody.fromString(
      '{"message":"Not Found"}',
      404,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // flutter_cache_manager stores its index through sqflite, whose plugin is
    // not registered under `flutter test`.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    // UniversalImage probes flutter_cache_manager, which resolves the cache
    // directory through path_provider — a plugin widget tests do not have.
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final cacheDir = Directory.systemTemp.createTempSync('solar_cache_test');
    final messenger = TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => cacheDir.path);
    addTearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
    });
  });

  testWidgets('remote actor profile chips the username and its instance', (
    tester,
  ) async {
    // Wide layout: on narrow viewports the profile pins its header into an app
    // bar, which needs an AutoRouter, so the two-pane layout renders the same
    // basis card on its own.
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final actor = _remoteActor();
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => mui.MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: mui.Material(
                child: ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWith((ref) => prefs),
                    // Plain client: the app one retries the failed image probe
                    // of a headerless actor, leaving timers pending.
                    apiClientProvider.overrideWith((ref) => Dio()),
                    publisherProvider(
                      _actorId,
                    ).overrideWith((ref) async => actor),
                    fediverseActorRelationshipProvider(
                      _actorId,
                    ).overrideWith((ref) async => null),
                    fediverseActorPostsProvider(
                      _actorId,
                    ).overrideWith(() => _EmptyActorPosts(_actorId)),
                  ],
                  child: const mui.Scaffold(
                    body: PublisherProfileContent(name: _actorId),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    // The visibility debounce of PaginationList is scheduled in the real async
    // zone while the tree builds, so it has to be drained on the real clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 700)),
    );

    // Username only: a full remote handle overflows the identity row.
    expect(find.text('@$_actorUsername'), findsOneWidget);
    expect(find.text('@$_actorUsername@$_actorDomain'), findsNothing);
    // The instance takes the place of the account link.
    expect(find.text('Belongs to instance $_actorDomain'), findsOneWidget);
    expect(find.textContaining('Belongs to @'), findsNothing);
    expect(tester.takeException(), isNull);

    // The pagination visibility debounce re-arms on every paint, so it has to
    // be drained down to a settled tree.
    await tester.pumpWidget(const mui.SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });

  test('every locale defines the instance origin label', () {
    final files = Directory('assets/i18n')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    expect(files, isNotEmpty, reason: 'no locale files found');

    for (final file in files) {
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(
        (data['publisherBelongsToInstance'] as String?)?.isNotEmpty,
        isTrue,
        reason: '${file.path} is missing publisherBelongsToInstance',
      );
    }
  });

  testWidgets('handle chip copies the override payload', (tester) async {
    final clipboard = <String?>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard.add((call.arguments as Map)['text'] as String?);
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      mui.MaterialApp(
        home: mui.Scaffold(
          body: HandleChip(
            handle: _actorUsername,
            copyText: '@$_actorUsername@$_actorDomain',
            isRemote: true,
            allowCopy: true,
          ),
        ),
      ),
    );

    expect(find.text('@$_actorUsername'), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.content_copy));
    await tester.pump();
    expect(clipboard, ['@$_actorUsername@$_actorDomain']);

    // Let the copy snackbar dismiss before the tree is torn down.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('a remote actor fires no publisher-name requests', () async {
    final adapter = _RecordingHttpAdapter();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        apiClientProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
        publisherProvider(_actorId).overrideWith((ref) async => _remoteActor()),
      ],
    );
    addTearDown(container.dispose);

    // The profile opens by name before the actor payload resolves, so the
    // local-publisher endpoints have to drop a remote actor on their own.
    expect(
      await container.read(publisherRatingOverviewProvider(_actorId).future),
      isNull,
    );
    expect(
      adapter.requestedPaths,
      isEmpty,
      reason: 'rating overview requested for a remote actor',
    );

    expect(
      await container.read(publisherHeatmapProvider(_actorId).future),
      isNull,
    );
    expect(
      adapter.requestedPaths,
      isEmpty,
      reason: 'heatmap requested for a remote actor',
    );

    expect(
      await container.read(
        publisherSubscriptionStatusProvider(_actorId).future,
      ),
      isNull,
    );
    expect(adapter.requestedPaths, isEmpty);
  });
}
