import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/creators/models/pub_quota_info.dart';
import 'package:island/creators/screens/hub.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/core/config.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Height of the app's floating tab bar on a device with a home indicator:
/// `NavigationBar(height: 56)` plus a 34px bottom safe area. The tab shell
/// runs `Scaffold(extendBody: true)` with the bar in `bottomNavigationBar`, so
/// Flutter injects exactly this value as the page's `MediaQuery.padding.bottom`
/// (see `_BodyBuilder` in the framework's `scaffold.dart`).
const double _tabBarHeight = 90;

Widget _wrap({required double bottomBarHeight}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: [
          ...context.localizationDelegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: legacy_material.Material(
          type: legacy_material.MaterialType.transparency,
          // Legacy packages (dropdown_button2 and friends) look for Flutter's
          // own Material ancestor, which the app supplies through
          // `MaterialUiCompatibilityBridge` in lib/main.dart.
          child: Scaffold(
            extendBody: true,
            // Stand-in for `ConditionalBottomNav(child: NavigationBar(...))`:
            // what matters is the height Flutter hands to the page body.
            bottomNavigationBar: SizedBox(height: bottomBarHeight),
            body: const CreatorHubContentWidget(),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpHub(
  WidgetTester tester, {
  required double bottomBarHeight,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          // Signed-out stub: publisher management is empty, so the screen
          // renders its "no publisher selected" body without hitting the API.
          publishersManagedProvider.overrideWith(
            (ref) async => const <SnPublisher>[],
          ),
          publisherInvitesProvider.overrideWith(
            (ref) async => const <SnPublisherMember>[],
          ),
          publisherQuotaInfoProvider.overrideWith(
            (ref) async => const PublisherQuotaInfo(
              total: 5,
              used: 1,
              remaining: 4,
              level: 1,
              perkLevel: 1,
              records: [],
            ),
          ),
        ],
        child: _wrap(bottomBarHeight: bottomBarHeight),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'creator hub reserves the floating tab bar so its last card stays visible',
    (tester) async {
      await _pumpHub(tester, bottomBarHeight: _tabBarHeight);

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      final scrollPadding = scrollView.padding! as EdgeInsets;
      final pageContext = tester.element(find.byType(CreatorHubContentWidget));
      final injectedInset = MediaQuery.paddingOf(pageContext).bottom;

      // Precondition: the shell really did inject the bar's height.
      expect(injectedInset, _tabBarHeight);
      // The body must clear the bar, otherwise the last card (and the "create
      // publisher" tile) ends up underneath it and cannot be tapped.
      expect(scrollPadding.bottom, greaterThanOrEqualTo(injectedInset));
    },
  );

  testWidgets('creator hub does not pad for a bar that is not on screen', (
    tester,
  ) async {
    await _pumpHub(tester, bottomBarHeight: 0);

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );

    // The bar is collapsed on routes it does not cover, so the page only keeps
    // its own breathing room instead of reserving phantom space.
    expect((scrollView.padding! as EdgeInsets).bottom, 24);
  });

  testWidgets('creator hub renders its empty state without errors', (
    tester,
  ) async {
    await _pumpHub(tester, bottomBarHeight: _tabBarHeight);

    expect(tester.takeException(), isNull);
    // Rendered from the catalog, not the raw key.
    expect(
      find.text('Pick / create a publisher to get started.'),
      findsOneWidget,
    );
    expect(find.byIcon(Symbols.add), findsWidgets);
  });
}
