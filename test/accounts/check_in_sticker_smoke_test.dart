import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

SnCheckInResult _result({int level = 3, DateTime? createdAt}) {
  final now = createdAt ?? DateTime.now();
  return SnCheckInResult(
    id: 'test',
    level: level,
    tips: const [],
    fortuneReport: null,
    accountId: 'me',
    account: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

SnEventCalendarEntry _entry(DateTime date, int level) => SnEventCalendarEntry(
  date: date,
  checkInResult: _result(level: level, createdAt: date),
  statuses: const [],
  userEvents: const [],
  notableDays: const [],
  mergedEvents: null,
);

class _L10nApp extends StatelessWidget {
  const _L10nApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) => EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(body: home),
      ),
    ),
  );
}

/// Mounts [home] on a fresh tree; earlier mounts are torn down first, because
/// easy_localization keeps a device locale that a widget update would re-read
/// before it is set.
Future<void> _mount(
  WidgetTester tester,
  Widget home, {
  SnCheckInResult? Function()? todayResult,
  List<SnEventCalendarEntry> calendar = const [],
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          if (todayResult != null)
            checkInResultTodayProvider.overrideWith(
              (ref) async => todayResult(),
            ),
          eventCalendarProvider.overrideWith(
            (ref, EventCalendarQuery query) async => calendar,
          ),
        ],
        child: _L10nApp(home: home),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}

final _stamps = find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName.contains('check-in/'),
);

String _asset(Finder finder, WidgetTester tester) =>
    ((tester.widget<Image>(finder)).image as AssetImage).assetName;

/// The nearest tile layer above [node].
Element _tileLayer(Element node) {
  Element? found;
  node.visitAncestorElements((element) {
    if (element.widget is Stack) {
      found = element;
      return false;
    }
    return true;
  });
  if (found == null) fail('no tile layer above the node');
  return found!;
}

/// The tile layer a stamp rides on, reached from the stamp's own subtree.
Rect _layerRect(WidgetTester tester, Element stamp) =>
    tester.getRect(find.byElementPredicate((e) => e == _tileLayer(stamp)));

/// The rail's viewport box: the strip clips anything painted past it.
Rect _railRect(WidgetTester tester) => tester.getRect(
  find.byWidgetPredicate(
    (widget) => widget is SizedBox && widget.height == 170,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('dashboard leads with the stamp of the drawn tier', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _mount(
      tester,
      const CheckInWidget(),
      todayResult: () => _result(level: 2),
    );
    expect(_stamps, findsOneWidget);
    expect(_asset(_stamps, tester), 'assets/images/check-in/t2.webp');
    expect(
      tester.getSize(_stamps),
      const Size(60, 60),
      reason: '1:1 leading badge',
    );
    expect(
      find.descendant(of: find.byType(IconButton), matching: _stamps),
      findsNothing,
      reason: 'the draw button keeps its own icon',
    );

    await _mount(tester, const CheckInWidget(), todayResult: () => null);
    expect(_stamps, findsNothing);
  });

  testWidgets('rail tiles wear their tier stamp, hung off the edge', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = _day(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    await _mount(
      tester,
      const CheckInScreen(),
      todayResult: () => _result(level: 4, createdAt: today),
      calendar: [_entry(today, 4), _entry(yesterday, 1)],
    );

    expect(
      tester
          .widgetList<Image>(_stamps)
          .map((image) => (image.image as AssetImage).assetName)
          .toSet(),
      {'assets/images/check-in/t4.webp', 'assets/images/check-in/t1.webp'},
    );

    for (final element in _stamps.evaluate()) {
      final finder = find.byElementPredicate(
        (candidate) => candidate == element,
      );
      final size = tester.getSize(finder);
      // The selected day's stamp is measured on its own below.
      if (size == const Size(108, 108)) continue;

      final layer = _layerRect(tester, element);
      final stampRect = tester.getRect(finder);
      expect(
        size,
        const Size(64, 64),
        reason: 'a corner stamp is 1:1 and bigger than a plain icon',
      );
      expect(
        layer.contains(stampRect.topLeft) &&
            layer.contains(stampRect.bottomRight),
        isFalse,
        reason: 'the stamp hangs past the tile edge, not inside it',
      );

      // A tile whole inside the strip must show its stamp whole: the viewport
      // would shave a stamp that hung further. (Tiles half scrolled off an end
      // are cut by the strip itself, so they are not measured.)
      final rail = _railRect(tester);
      if (rail.contains(layer.topLeft) && rail.contains(layer.bottomRight)) {
        expect(
          rail.contains(stampRect.topLeft) &&
              rail.contains(stampRect.bottomRight),
          isTrue,
          reason: 'a visible tile keeps its whole stamp',
        );
      }
    }

    // The day the visitor landed on wears its stamp over the date instead.
    final todayText = find.text('TODAY');
    final layerFinder = find.byElementPredicate(
      (candidate) => candidate == _tileLayer(todayText.evaluate().single),
    );
    final todayStamp = find
        .descendant(of: layerFinder, matching: _stamps)
        .first;
    expect(tester.getSize(todayStamp), const Size(108, 108));
    final stampRect = tester.getRect(todayStamp);
    final textRect = tester.getRect(todayText);
    expect(
      stampRect.contains(textRect.topLeft) &&
          stampRect.contains(textRect.bottomRight),
      isTrue,
      reason: 'the selected stamp covers the date',
    );
    expect(
      // The tile's 1px border insets the layer the stamp is centred in.
      (stampRect.center - tester.getRect(layerFinder).center).distance,
      lessThan(2),
      reason: 'the selected stamp parks in the middle of its tile',
    );
  });

  testWidgets('preview rail and dashboard', (tester) async {
    final today = _day(DateTime.now());

    await tester.binding.setSurfaceSize(const Size(420, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _mount(
      tester,
      const CheckInScreen(),
      todayResult: () => _result(level: 4, createdAt: today),
      calendar: [
        _entry(today, 4),
        _entry(today.subtract(const Duration(days: 1)), 1),
        _entry(today.subtract(const Duration(days: 2)), 0),
        _entry(today.subtract(const Duration(days: 3)), 2),
      ],
    );
    await tester.runAsync(() async {
      for (final element in _stamps.evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CheckInScreen),
      matchesGoldenFile('goldens/check_in_rail.png'),
    );

    await tester.binding.setSurfaceSize(const Size(420, 160));
    await _mount(
      tester,
      const CheckInWidget(),
      todayResult: () => _result(level: 2),
    );
    await tester.runAsync(() async {
      for (final element in _stamps.evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CheckInWidget),
      matchesGoldenFile('goldens/check_in_dashboard.png'),
    );
  });
}
