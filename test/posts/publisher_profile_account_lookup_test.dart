import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _accountName = 'alice';
const _publisherName = 'alice-arts';

final _account = SnAccount.fromJson({
  'id': 'account-1',
  'name': _accountName,
  'nick': 'Alice',
  'language': 'en-US',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': 'profile-1',
    'bio': 'hello',
    'experience': 0,
    'level': 0,
    'leveling_progress': 0.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'perk_subscription': null,
  'activated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

/// Individual publisher whose handle differs from the owning account's name:
/// the server checks publisher-name uniqueness only against other publishers,
/// never against account names, so the two are free to diverge.
SnPublisher _individualPublisher() => SnPublisher.fromJson({
  'id': 'publisher-1',
  'type': 0,
  'name': _publisherName,
  'nick': 'Alice Arts',
  'bio': 'Publisher bio',
  'account': _account.toJson(),
});

/// Organization publisher: no owning account at all.
SnPublisher _organizationPublisher() => SnPublisher.fromJson({
  'id': 'publisher-2',
  'type': 1,
  'name': 'studio',
  'nick': 'Studio',
  'bio': 'Studio bio',
});

/// The routed page that records which account name the profile navigated to.
class _AccountPageStub extends StatelessWidget {
  final String name;

  const _AccountPageStub({required this.name});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text('account-page:$name'));
}

/// Minimal router whose `AccountProfileRoute` target records its own path
/// parameter, so a tap on the origin chip proves which name was pushed.
class _StubRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PageInfo.builder(
        'publisher',
        builder: (context, data) =>
            const Scaffold(body: PublisherProfileContent(name: _publisherName)),
      ),
      path: '/publishers/:name',
      initial: true,
    ),
    AutoRoute(
      page: PageInfo.builder(
        'AccountProfileRoute',
        builder: (context, data) =>
            _AccountPageStub(name: data.inheritedPathParams.getString('name')),
      ),
      path: '/accounts/:name',
    ),
  ];
}

/// Riverpod 3 does not export `Override`, so the list is built inside the
/// widget that consumes it rather than named in a signature.
Widget _scoped(
  SharedPreferences prefs,
  SnPublisher publisher,
  Widget page, {
  required List<String> accountStatusCalls,
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    sharedPreferencesProvider.overrideWith((ref) => prefs),
    // Plain client: the app one retries the failed image probe of a
    // headerless publisher, leaving timers pending at teardown.
    apiClientProvider.overrideWith((ref) => Dio()),
    publisherProvider(publisher.name).overrideWith((ref) async => publisher),
    publisherSubscriptionStatusProvider(
      publisher.name,
    ).overrideWith((ref) async => null),
    publisherHeatmapProvider(publisher.name).overrideWith((ref) async => null),
    publisherRatingOverviewProvider(
      publisher.name,
    ).overrideWith((ref) async => null),
    publisherBadgesProvider(
      publisher.name,
    ).overrideWith((ref) async => <SnAccountBadge>[]),
    accountProvider(_accountName).overrideWith((ref) async => _account),
    accountStatusProvider.overrideWith((ref, uname) async {
      accountStatusCalls.add(uname);
      return null;
    }),
  ],
  child: page,
);

/// The wide layout keeps the collapsing app-bar header (and the router scope
/// it needs) out of the tree; the basis card is identical in both layouts.
Future<void> _pump(
  WidgetTester tester,
  SnPublisher publisher, {
  required List<String> accountStatusCalls,
  required Widget Function(BuildContext context) page,
}) async {
  // The test font (Ahem) draws every glyph as a full-width square, so the
  // four icon+label tabs and the profile's own rows need a wider pane than
  // they do under a real font.
  tester.view.physicalSize = const Size(2400, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final prefs = await SharedPreferences.getInstance();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/i18n',
        saveLocale: false,
        child: Builder(
          builder: (context) => _scoped(
            prefs,
            publisher,
            page(context),
            accountStatusCalls: accountStatusCalls,
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));
  });
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
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
    // UniversalImage probes flutter_cache_manager, which resolves its cache
    // directory through path_provider — a plugin widget tests do not have.
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final cacheDir = Directory.systemTemp.createTempSync('solar_cache_test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => cacheDir.path);
    addTearDown(() {
      messenger.setMockMethodCallHandler(channel, null);
      if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
    });
  });

  // Regression: the origin chip rendered and linked `SnPublisher.name`, which
  // is the publisher handle, not the account name. The chip showed a handle
  // that resolves to no account, and its tap pushed an account profile route
  // for that same non-existent name.
  testWidgets('an individual publisher chips the owning account', (
    tester,
  ) async {
    final publisher = _individualPublisher();
    final accountStatusCalls = <String>[];
    await _pump(
      tester,
      publisher,
      accountStatusCalls: accountStatusCalls,
      page: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(body: PublisherProfileContent(name: publisher.name)),
      ),
    );

    expect(find.text('Belongs to @$_accountName'), findsOneWidget);
    expect(
      find.textContaining('Belongs to @$_publisherName'),
      findsNothing,
      reason: 'the origin chip must not fall back to the publisher handle',
    );
    expect(
      accountStatusCalls,
      everyElement(_accountName),
      reason: 'the status row must query the account, not the publisher handle',
    );
    expect(tester.takeException(), isNull);

    await _teardown(tester);
  });

  testWidgets('the origin chip opens the owning account profile', (
    tester,
  ) async {
    final publisher = _individualPublisher();
    await _pump(
      tester,
      publisher,
      accountStatusCalls: <String>[],
      page: (context) => MaterialApp.router(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        routerConfig: _StubRouter().config(),
      ),
    );

    await tester.tap(find.text('Belongs to @$_accountName'));
    await tester.pumpAndSettle();

    expect(
      find.text('account-page:$_accountName'),
      findsOneWidget,
      reason: 'the chip must push the account, not the publisher handle',
    );
    expect(find.textContaining('account-page:$_publisherName'), findsNothing);
    expect(tester.takeException(), isNull);

    await _teardown(tester);
  });

  // An organization publisher has no owning account: the account row and its
  // status request must both be absent rather than falling back to the
  // publisher handle.
  testWidgets('an organization publisher draws no account origin row', (
    tester,
  ) async {
    final publisher = _organizationPublisher();
    final accountStatusCalls = <String>[];
    await _pump(
      tester,
      publisher,
      accountStatusCalls: accountStatusCalls,
      page: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(body: PublisherProfileContent(name: publisher.name)),
      ),
    );

    expect(find.textContaining('Belongs to'), findsNothing);
    expect(find.byIcon(Symbols.person), findsNothing);
    expect(
      accountStatusCalls,
      isEmpty,
      reason: 'no owning account, so no status request may be fired',
    );
    expect(tester.takeException(), isNull);

    await _teardown(tester);
  });
}
