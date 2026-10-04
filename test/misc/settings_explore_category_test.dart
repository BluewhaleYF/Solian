import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Signed-out stub: the real notifier reads the token store and hits the
/// network, which these settings-screen checks must not depend on.
class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Answers timeline requests with an empty page and everything else with an
/// empty list, so no request leaves the test.
class _StubAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final payload = options.path.contains('/timeline')
        ? jsonEncode({'items': const [], 'next_cursor': null})
        : jsonEncode(const <dynamic>[]);
    return ResponseBody.fromString(
      payload,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

late AppRouter _router;
late ProviderContainer _container;

/// Boots the real router at `/settings` with a real `SharedPreferences` store,
/// so the explore preferences are read exactly as the app reads them.
Future<void> _pumpSettings(
  WidgetTester tester,
  Map<String, Object> prefsValues,
) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    pathProviderChannel,
    (call) async => '/tmp/solian-settings-test',
  );
  addTearDown(
    () => messenger.setMockMethodCallHandler(pathProviderChannel, null),
  );

  _container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      userInfoProvider.overrideWith(_SignedOutUserInfo.new),
      apiClientProvider.overrideWithValue(
        Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..httpClientAdapter = _StubAdapter(),
      ),
    ],
  );
  addTearDown(_container.dispose);

  final router = _container.read(routerProvider);
  _router = router;
  final config = router.config();

  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: _container,
        child: EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp.router(
              routerConfig: config,
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              // The app root supplies a legacy Material ancestor for packages
              // that still read Flutter's material library (dropdown_button2).
              builder: (context, child) => legacy_material.Material(
                type: legacy_material.MaterialType.transparency,
                child: child ?? const SizedBox.shrink(),
              ),
              localizationsDelegates: [
                ...context.localizationDelegates,
                ...GlobalMaterialLocalizations.delegates,
                flutter_localizations.GlobalMaterialLocalizations.delegate,
                flutter_localizations.GlobalCupertinoLocalizations.delegate,
              ],
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();

  final state = await config.routeInformationParser!
      .parseRouteInformationWithDependencies(
        RouteInformation(uri: Uri.parse('/settings')),
        tester.element(find.byType(MaterialApp)),
      );
  await config.routerDelegate.setNewRoutePath(state);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

/// Tears the tree down and lets provider-scheduled timers fire, so the binding
/// sees none pending.
Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  _container.dispose();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('the explore category carries the timeline algorithm', (
    tester,
  ) async {
    await _pumpSettings(tester, const {});
    expect(_router.currentPath, '/settings');

    // The migration target: the algorithm controls moved out of the explore
    // sheet and into a settings category of their own.
    expect(find.text('Explore'), findsOneWidget);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Timeline section'), findsOneWidget);
    expect(find.text('Preferred'), findsOneWidget);
    expect(find.text('Aggressive Mode'), findsOneWidget);
    // The only remaining entry point for the persisted category/tag filters.
    expect(find.byType(PostCategoryTagFilterSection), findsOneWidget);

    // The section picker keeps the "Explore" (null) option and persists the
    // section the explore screen opens on.
    await tester.tap(find.byType(DropdownButton2<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Friends').last);
    await tester.pumpAndSettle();
    expect(_container.read(appSettingsProvider).exploreSettings.filter, 'friends');

    await _teardown(tester);
  });

  testWidgets('the ranking and aggressive controls persist their selection', (
    tester,
  ) async {
    await _pumpSettings(tester, const {});
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Personalized'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Top').last);
    await tester.pumpAndSettle();
    expect(_container.read(appSettingsProvider).exploreSettings.mode, 'top');

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      _container.read(appSettingsProvider).exploreSettings.aggressiveMode,
      isFalse,
    );

    // The timeline picks the change up on its own: the stored preference is
    // not enough, the explore feed has to re-rank without a restart.
    final timeline = _container.read(activityListProvider.notifier);
    _container
        .read(appSettingsProvider.notifier)
        .setExploreSettings(
          _container
              .read(appSettingsProvider)
              .exploreSettings
              .copyWith(mode: 'latest'),
        );
    expect(timeline.currentMode, 'latest');

    // Let the reload the change kicked off finish before the tree goes away.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    await _teardown(tester);
  });
}
