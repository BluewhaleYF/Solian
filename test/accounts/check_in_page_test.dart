import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

SnCheckInFortuneReport _report() => const SnCheckInFortuneReport(
  version: 1,
  poem: 'Clouds part over the ridge, a quiet road opens.',
  summary: 'A steady day: keep your promises small and your pace even.',
  summaryDetail:
      'The morning favours unfinished work. Finish one thing before noon, '
      'then let the afternoon carry you.',
  wish: 'Ask for help before you need it.',
  love: 'Say the plain thing out loud.',
  study: 'Re-read the last page you skimmed.',
  career: 'Ship the small fix instead of the big plan.',
  health: 'Walk after eating, even briefly.',
  lostItem: 'Under the second layer of your bag.',
  luckyColor: 'Deep indigo',
  luckyDirection: 'North-east',
  luckyTime: 'Between 15:00 and 17:00',
  luckyItem: 'A pen that still writes',
  luckyAction: 'Start the thing you keep postponing',
  avoidAction: 'Making promises you cannot keep this week',
  ritual: 'Write one sentence about today before you sleep.',
);

SnCheckInResult _result({
  int level = 3,
  DateTime? createdAt,
  SnCheckInFortuneReport? report,
  List<SnFortuneTip> tips = const [],
}) {
  final now = createdAt ?? DateTime.now();
  return SnCheckInResult(
    id: 'test',
    level: level,
    tips: tips,
    fortuneReport: report,
    accountId: 'me',
    account: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

SnEventCalendarEntry _entry(DateTime date, {int level = 4}) =>
    SnEventCalendarEntry(
      date: date,
      checkInResult: _result(level: level, createdAt: date),
      statuses: const [],
      userEvents: const [],
      notableDays: const [],
      mergedEvents: null,
    );

Future<void> _pump(
  WidgetTester tester, {
  required SnCheckInResult? Function() readTodayResult,
  Size size = const Size(420, 900),
  List<SnEventCalendarEntry> calendar = const [],
  CheckInDebugOptions? debugOptions,
  VoidCallback? onCalendarQuery,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          checkInResultTodayProvider.overrideWith(
            (ref) async => readTodayResult(),
          ),
          eventCalendarProvider.overrideWith((
            ref,
            EventCalendarQuery query,
          ) async {
            onCalendarQuery?.call();
            return calendar;
          }),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(body: CheckInScreen(debugOptions: debugOptions)),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}

/// Stands in for the draw landing: the today result appears and the page
/// rebuilds the same way it does after a real check-in.
Future<void> _deliverTodayResult(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(CheckInScreen)),
  );
  // The overridden provider is a real async future, so it needs a real turn of
  // the event loop before the page can rebuild with the new value.
  await tester.runAsync(() async {
    container.invalidate(checkInResultTodayProvider);
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('lays out in a single viewport without a nested scrollable', (
    tester,
  ) async {
    await _pump(tester, readTodayResult: () => null);
    expect(tester.takeException(), isNull);
    // A nested CustomScrollView used to explode with "Vertical viewport was
    // given unbounded height"; the page owns exactly one viewport now.
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });
  testWidgets('opens on the last check-in instead of an empty today', (
    tester,
  ) async {
    final yesterday = _day(DateTime.now().subtract(const Duration(days: 1)));
    await _pump(
      tester,
      readTodayResult: () => null,
      calendar: [_entry(yesterday, level: 4)],
    );

    // The previous draw is on screen, not the "nothing here" placeholder.
    expect(tester.takeException(), isNull);
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(find.text('No check-in that day'), findsNothing);
    // Today is still undrawn, so the draw action stays reachable.
    expect(find.text("Draw today's sign"), findsOneWidget);
  });

  testWidgets('a landed draw slides the rail onto today', (tester) async {
    final yesterday = _day(DateTime.now().subtract(const Duration(days: 1)));
    SnCheckInResult? todayResult;
    await _pump(
      tester,
      readTodayResult: () => todayResult,
      calendar: [_entry(yesterday, level: 4)],
    );
    expect(find.text("Draw today's sign"), findsOneWidget);

    todayResult = _result(level: 2);
    await _deliverTodayResult(tester);

    expect(tester.takeException(), isNull);
    expect(find.text("Draw today's sign"), findsNothing);
    expect(find.byType(FortuneCard), findsOneWidget);
  });

  testWidgets('rail pages older days as it is dragged towards them', (
    tester,
  ) async {
    final today = _day(DateTime.now());
    await _pump(
      tester,
      readTodayResult: () => null,
      size: const Size(420, 900),
    );

    final rail = find.byType(ListView);
    int cardCount() => find
        .descendant(of: rail, matching: find.byType(AnimatedScale))
        .evaluate()
        .length;

    // The rail loads the week around today and nothing behind it yet.
    final behind = find.text('${today.subtract(const Duration(days: 4)).day}');
    expect(tester.takeException(), isNull);
    expect(behind, findsNothing);
    final before = cardCount();

    // Dragging towards older days past the loaded week pulls in another week,
    // and keeps pulling for as long as the visitor keeps going.
    await tester.drag(rail, const Offset(240, 0));
    await tester.pumpAndSettle();
    await tester.drag(rail, const Offset(240, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(behind, findsOneWidget);
    expect(cardCount(), greaterThan(before));
  });

  testWidgets('result card drops the artwork but keeps the seal', (
    tester,
  ) async {
    await _pump(tester, readTodayResult: () => _result());
    expect(tester.takeException(), isNull);
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FortuneCard),
        matching: find.byType(Image),
      ),
      findsNothing,
    );
    expect(find.byType(FortuneSealHeader), findsOneWidget);
  });

  testWidgets('narrow phones render a full report without overflow', (
    tester,
  ) async {
    await _pump(
      tester,
      readTodayResult: () => _result(
        level: 2,
        report: _report(),
        tips: const [
          SnFortuneTip(
            isPositive: true,
            title: 'Morning',
            content: 'Good light for careful work.',
          ),
        ],
      ),
      size: const Size(360, 780),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(find.byType(FortuneGuidanceCard), findsOneWidget);
    expect(find.byType(FortuneLuckyGrid), findsOneWidget);
    expect(find.byType(FortuneActionCard), findsOneWidget);
  });

  testWidgets('every fortune level fits a phone-width card', (tester) async {
    for (final level in [0, 1, 2, 3, 4, 5]) {
      await _pump(
        tester,
        readTodayResult: () => _result(level: level),
        size: const Size(360, 780),
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'level \$level overflowed',
      );
    }
  });

  testWidgets('wide layout stays a single viewport', (tester) async {
    await _pump(
      tester,
      readTodayResult: () => _result(level: 4),
      size: const Size(1200, 800),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(CustomScrollView), findsOneWidget);
  });

  testWidgets('debug options draw offline and run the same transition', (
    tester,
  ) async {
    var todayFetched = false;
    var calendarFetched = false;

    await _pump(
      tester,
      readTodayResult: () {
        todayFetched = true;
        return null;
      },
      onCalendarQuery: () => calendarFetched = true,
      debugOptions: CheckInDebugOptions.simulated(autoDraw: false),
    );

    // Opens on the simulated past draw with today still undrawn, the state a
    // real draw animates away from.
    expect(tester.takeException(), isNull);
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(find.text("Draw today's sign"), findsOneWidget);

    await tester.tap(find.text("Draw today's sign"));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text("Draw today's sign"), findsNothing);
    expect(find.byType(FortuneCard), findsOneWidget);
    // Neither the today result nor the calendar was ever requested.
    expect(todayFetched, isFalse);
    expect(calendarFetched, isFalse);
  });

  testWidgets('debug auto-draw replays on open, still offline', (tester) async {
    var todayFetched = false;
    var calendarFetched = false;

    await _pump(
      tester,
      readTodayResult: () {
        todayFetched = true;
        return null;
      },
      onCalendarQuery: () => calendarFetched = true,
      debugOptions: CheckInDebugOptions.simulated(),
    );

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text("Draw today's sign"), findsNothing);
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(todayFetched, isFalse);
    expect(calendarFetched, isFalse);
  });
}
