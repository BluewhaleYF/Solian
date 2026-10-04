import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/check_in_debug.dart';
import 'package:island/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _stamps = find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName.contains('check-in/'),
);

/// The two scales the stamp itself wears: the paste is the only thing that
/// moves them off 1, and the nearest transform keeps the tile's own scaling
/// out of it.
({double wide, double tall}) _stampAxes(WidgetTester tester) {
  Matrix4? matrix;
  _stamps.evaluate().single.visitAncestorElements((element) {
    if (element.widget is Transform) {
      matrix = (element.widget as Transform).transform;
      return false;
    }
    return true;
  });
  return (wide: matrix!.storage[0].abs(), tall: matrix!.storage[5].abs());
}

Future<void> _mount(
  WidgetTester tester, {
  required SnCheckInResult? todayResult,
  CheckInDebugOptions? debugOptions,
}) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          checkInResultTodayProvider.overrideWith((ref) async => todayResult),
          eventCalendarProvider.overrideWith(
            (ref, EventCalendarQuery query) async =>
                const <SnEventCalendarEntry>[],
          ),
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('a landed draw pastes its stamp on, then rests flat', (
    tester,
  ) async {
    await _mount(
      tester,
      todayResult: null,
      debugOptions: const CheckInDebugOptions(
        level: 3,
        drawDelay: Duration(milliseconds: 300),
        autoDraw: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(_stamps, findsNothing, reason: 'nothing drawn yet');

    await tester.tap(find.text("Draw today's sign"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(_stamps, findsOneWidget);
    final samples = <({double wide, double tall})>[_stampAxes(tester)];
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      samples.add(_stampAxes(tester));
    }
    expect(
      samples.first.wide,
      greaterThan(1.05),
      reason: 'the stamp arrives cocked and oversized',
    );
    expect(
      samples.map((sample) => sample.tall).reduce((a, b) => a < b ? a : b),
      lessThan(1),
      reason: 'it presses down past flat and springs back',
    );

    await tester.pumpAndSettle();
    final rested = _stampAxes(tester);
    expect(rested.wide, closeTo(1.0, .001), reason: 'and settles');
    expect(rested.tall, closeTo(1.0, .001));
  });

  testWidgets('a draw already on the sheet opens with its stamp at rest', (
    tester,
  ) async {
    final now = DateTime.now();
    await _mount(
      tester,
      todayResult: SnCheckInResult(
        id: 'test',
        level: 2,
        tips: const [],
        fortuneReport: null,
        accountId: 'me',
        account: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
    );

    var peak = 0.0;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (_stamps.evaluate().isEmpty) continue;
      final axes = _stampAxes(tester);
      for (final scale in [axes.wide, axes.tall]) {
        if (scale > peak) peak = scale;
      }
    }
    expect(_stamps, findsOneWidget);
    expect(
      peak,
      closeTo(1.0, .001),
      reason: 'a stamp that was already there is never pasted on',
    );
  });
}
