import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/discovery/explore.dart';
import 'package:island/misc/dashboard/dash.dart';
import 'package:island/route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Signed-out stub: the real notifier reads the token store and hits the
/// network, which these landing-screen checks must not depend on.
class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

late AppRouter _router;
late ProviderContainer _container;

/// Boots the real router at `/` with a real `SharedPreferences` store, so the
/// dashboard settings are read exactly as the app reads them.
Future<void> _pumpApp(
  WidgetTester tester,
  Map<String, Object> prefsValues,
) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();

  _container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      userInfoProvider.overrideWith(_SignedOutUserInfo.new),
    ],
  );
  addTearDown(_container.dispose);

  final router = _container.read(routerProvider);
  _router = router;
  final config = router.config();

  // Real async room so EasyLocalization's file-backed load completes.
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
        RouteInformation(uri: Uri.parse('/')),
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

  group('app settings', () {
    Future<(ProviderContainer, SharedPreferences)> makeContainer(
      Map<String, Object> values,
    ) async {
      SharedPreferences.setMockInitialValues(values);
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return (container, prefs);
    }

    test('the dashboard is enabled unless turned off', () async {
      final (container, _) = await makeContainer(const {});
      expect(container.read(appSettingsProvider).dashboardEnabled, isTrue);

      final (offContainer, _) = await makeContainer(const {
        kAppDashboardEnabled: false,
      });
      expect(offContainer.read(appSettingsProvider).dashboardEnabled, isFalse);
    });

    test(
      'turning the dashboard off never leaves it as the start screen',
      () async {
        final (container, prefs) = await makeContainer(const {
          kAppDefaultScreen: 'dashboard',
        });

        container.read(appSettingsProvider.notifier).setDashboardEnabled(false);

        expect(prefs.getBool(kAppDashboardEnabled), isFalse);
        expect(prefs.getString(kAppDefaultScreen), 'explore');
        expect(container.read(appSettingsProvider).defaultScreen, 'explore');
      },
    );

    test('turning the dashboard off keeps an unrelated start screen', () async {
      final (container, prefs) = await makeContainer(const {
        kAppDefaultScreen: 'chat',
      });

      container.read(appSettingsProvider.notifier).setDashboardEnabled(false);

      expect(prefs.getString(kAppDefaultScreen), 'chat');
      expect(container.read(appSettingsProvider).defaultScreen, 'chat');
    });
  });

  testWidgets('dashboard on by default: / renders the dashboard', (
    tester,
  ) async {
    await _pumpApp(tester, const {});

    expect(tester.takeException(), isNull);
    expect(find.byType(DashboardGrid), findsOneWidget);
    expect(find.byType(ExploreScreen), findsNothing);
    // The dashboard is one of the eight navigation destinations.
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations.length, 8);

    await _teardown(tester);
  });

  testWidgets('dashboard disabled: / lands on explore and drops the tab', (
    tester,
  ) async {
    await _pumpApp(tester, const {'app_dashboard_enabled': false});

    expect(tester.takeException(), isNull);
    expect(find.byType(DashboardGrid), findsNothing);
    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(_router.currentPath, '/explore');
    // One fewer navigation destination: the dashboard is not reachable.
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.destinations.length, 7);

    await _teardown(tester);
  });
}
