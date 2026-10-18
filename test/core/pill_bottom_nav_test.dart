import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/navigation/pill_bottom_nav.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double _kBarHeight = 72.0;
const double _kSafeArea = 34.0;
const Size _kScreen = Size(400, 800);

Future<ThemeData> _readTheme() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
  );
  final theme = createAppTheme(
    Brightness.light,
    container.read(appSettingsProvider),
  );
  container.dispose();
  return theme;
}

/// Records the bottom inset the shell hands to the page body.
double _bodyInset = -1;

Widget _shell(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      extendBody: true,
      body: Builder(
        builder: (context) {
          _bodyInset = MediaQuery.paddingOf(context).bottom;
          return const SizedBox.expand();
        },
      ),
      bottomNavigationBar: PillBottomNav(
        child: NavigationBar(
          height: _kBarHeight,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'Chats'),
          ],
        ),
      ),
    ),
  );
}

/// The painted capsule: the surface's own [DecoratedBox], which is the first
/// one — the controls inside it come after.
Rect _capsule(WidgetTester tester) => tester.getRect(
  find
      .descendant(
        of: find.byType(PillSurface),
        matching: find.byType(DecoratedBox),
      )
      .first,
);

BoxDecoration _capsuleDecoration(WidgetTester tester) =>
    tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(PillSurface),
                matching: find.byType(DecoratedBox),
              ),
            )
            .first
            .decoration
        as BoxDecoration;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// A phone with a home indicator, so the safe-area term is exercised.
  Future<void> pumpShell(
    WidgetTester tester, {
    double bottomInset = _kSafeArea,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = _kScreen;
    final inset = FakeViewPadding(top: 44, bottom: bottomInset);
    tester.view.padding = inset;
    tester.view.viewPadding = inset;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_shell(await _readTheme()));
    await tester.pumpAndSettle();
  }

  testWidgets('the tab bar floats clear of the screen edges', (tester) async {
    await pumpShell(tester);

    final capsule = _capsule(tester);
    final band = tester.getRect(find.byType(PillBottomNav));

    // Detached on the three free sides, like the header pills, instead of
    // being welded to the bottom edge of the display.
    expect(capsule.left, kPillSideGutter);
    expect(_kScreen.width - capsule.right, kPillSideGutter);
    expect(capsule.top - band.top, kBottomNavGutter);
    // The home indicator is spent *outside* the capsule.
    expect(_kScreen.height - capsule.bottom, kBottomNavGutter + _kSafeArea);
  });

  testWidgets('the capsule keeps the header pills\' radius', (tester) async {
    await pumpShell(tester);

    // The two bars read as one family: same capsule shape, same end caps.
    expect(
      _capsuleDecoration(tester).borderRadius,
      SolRadius.pillRadius,
    );
    final capsule = _capsule(tester);
    expect(capsule.height, _kBarHeight);
  });

  testWidgets('the controls keep a full gutter inside the capsule', (
    tester,
  ) async {
    await pumpShell(tester);

    final capsule = _capsule(tester);
    final controls = tester.getRect(find.byType(NavigationBar));

    // The capsule's end caps bite into the bar, so the destinations never sit
    // flush against the rounded edge.
    expect(controls.left - capsule.left, greaterThan(kPillSideGutter));
    expect(capsule.right - controls.right, greaterThan(kPillSideGutter));
  });

  testWidgets('the slot reserves the pill, and so does the page inset', (
    tester,
  ) async {
    await pumpShell(tester);

    final slot = tester.getRect(find.byType(PillBottomNav));
    // The scaffold hands the whole slot to the page; a page that clears
    // `kBottomNavHeight + kBottomNavPillInset + safe area` therefore clears
    // the bar rather than sitting under it.
    expect(slot.height, _kBarHeight + kBottomNavPillInset + _kSafeArea);
    expect(_bodyInset, slot.height);
  });

  testWidgets('a device without a home indicator costs no extra height', (
    tester,
  ) async {
    await pumpShell(tester, bottomInset: 0);

    final slot = tester.getRect(find.byType(PillBottomNav));
    expect(slot.height, _kBarHeight + kBottomNavPillInset);
    expect(_bodyInset, slot.height);
  });
}