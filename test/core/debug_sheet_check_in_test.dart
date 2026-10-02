import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/config.dart';
import 'package:island/core/debug_sheet.dart';
import 'package:island/main.dart' show globalOverlay;
import 'package:island/route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Drives the debug panel the way the app does: `showDebugOverlay()` inserts the
/// floating panel into [globalOverlay], which lives *above* the navigator (the
/// `MaterialApp.builder` overlay in `main.dart`), and the entries are tapped
/// through that tree. The panel therefore has to resolve a navigator context
/// from the router, not from its own context.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GlobalKey<OverlayState> previousOverlayKey;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    previousOverlayKey = globalOverlay;
  });

  tearDown(() {
    globalOverlay = previousOverlayKey;
  });

  testWidgets('debug panel replays the check-in draw without any request', (
    tester,
  ) async {
    var todayFetched = false;
    var calendarFetched = false;
    final prefs = await SharedPreferences.getInstance();
    final overlayKey = GlobalKey<OverlayState>();
    final router = AppRouter();
    globalOverlay = overlayKey;

    await tester.binding.setSurfaceSize(const Size(500, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // EasyLocalization resolves its assets asynchronously, so the tree needs a
    // real event-loop turn before the overlay key is attached.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => prefs),
            routerProvider.overrideWithValue(router),
            checkInResultTodayProvider.overrideWith((ref) async {
              todayFetched = true;
              return null;
            }),
            eventCalendarProvider.overrideWith((
              ref,
              EventCalendarQuery query,
            ) async {
              calendarFetched = true;
              return const <SnEventCalendarEntry>[];
            }),
          ],
          child: EasyLocalization(
            supportedLocales: const [Locale('en', 'US')],
            path: 'assets/i18n',
            saveLocale: false,
            child: Builder(
              builder: (context) => MaterialApp(
                navigatorKey: router.navigatorKey,
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                // Same shape as main.dart: the overlay wraps the navigator.
                builder: (context, child) => Overlay(
                  key: overlayKey,
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => child ?? const SizedBox.shrink(),
                    ),
                  ],
                ),
                home: const Scaffold(body: SizedBox.shrink()),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    showDebugOverlay();
    await tester.pumpAndSettle();

    final entry = find.text('Test check-in draw (manual)');
    await tester.scrollUntilVisible(
      entry,
      200,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(entry);
    await tester.pumpAndSettle();

    // The sheet opened on the simulated past draw, today still undrawn.
    expect(tester.takeException(), isNull);
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(find.text("Draw today's sign"), findsOneWidget);

    await tester.tap(find.text("Draw today's sign"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text("Draw today's sign"), findsNothing);
    expect(find.byType(FortuneCard), findsOneWidget);
    // Nothing behind the replay ever asked the server.
    expect(todayFetched, isFalse);
    expect(calendarFetched, isFalse);

    hideDebugOverlay();
  });
}
