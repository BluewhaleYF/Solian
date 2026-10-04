import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

/// The client checks in for a past day through the same endpoint as today's
/// draw, carrying `backdated` as the UTC midnight of the day picked.
///
/// The report is filled in so the sheet does not start polling for it, which
/// would add requests the assertions would have to filter out.
Map<String, dynamic> _resultJson(DateTime day, {DateTime? backdatedFrom}) => {
  'id': 'backdated',
  'level': 3,
  'tips': const <Map<String, dynamic>>[],
  'account_id': 'me',
  'account': null,
  'created_at': DateTime.utc(day.year, day.month, day.day).toIso8601String(),
  'updated_at': DateTime.utc(day.year, day.month, day.day).toIso8601String(),
  'deleted_at': null,
  'backdated_from': backdatedFrom?.toIso8601String(),
  'fortune_report': {
    'version': 2,
    'poem': 'Rain on the old eaves.',
    'summary': 'A steady day.',
    'summary_detail': null,
    'wish': 'Ask plainly.',
    'love': 'Patience.',
    'study': 'Two quiet hours.',
    'career': 'Hold the thread.',
    'health': 'Stretch.',
    'lost_item': 'Under the second thing.',
    'lucky_color': 'Ink blue',
    'lucky_direction': 'Southwest',
    'lucky_time': 'Late afternoon',
    'lucky_item': 'A notebook',
    'lucky_action': 'Write it down.',
    'avoid_action': 'Reopening it.',
    'ritual': 'Pour the first cup.',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('a past day can be filled in, and the draw targets that day', (
    tester,
  ) async {
    final yesterday = _day(DateTime.now().subtract(const Duration(days: 1)));
    final requests = <RequestOptions>[];

    final dio = Dio(BaseOptions(baseUrl: 'https://checkin.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method != 'POST' ||
              !options.path.endsWith('/accounts/me/check-in')) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 404),
              ),
            );
            return;
          }
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: _resultJson(yesterday, backdatedFrom: DateTime.now()),
            ),
          );
        },
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => prefs),
            solarNetworkClientProvider.overrideWithValue(
              SolarNetworkClient.fromDio(dio),
            ),
            checkInResultTodayProvider.overrideWith((ref) async => null),
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
                home: const Scaffold(body: CheckInScreen()),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    // Yesterday picked in the strip. The strip shows a handful of days at a
    // time, so it has to be scrolled back before the tap can land.
    await tester.scrollUntilVisible(
      find.text('${yesterday.day}'),
      240,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('${yesterday.day}'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Draw for this day'), findsOneWidget);

    // The prompt sits below the rail, so it has to be scrolled into reach
    // before the tap lands on it.
    await tester.ensureVisible(find.text('Draw for this day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draw for this day'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(requests, hasLength(1));
    expect(
      requests.single.queryParameters['backdated'],
      DateTime.utc(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      ).toIso8601String(),
    );
    // The draw landed on the picked day; today is still undrawn.
    expect(find.byType(FortuneCard), findsOneWidget);
    expect(find.text('Draw for this day'), findsNothing);
    expect(find.text("Draw today's sign"), findsOneWidget);
  });

  testWidgets('today keeps drawing without a backdated parameter', (
    tester,
  ) async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://checkin.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method != 'POST' ||
              !options.path.endsWith('/accounts/me/check-in')) {
            // The draw refreshes the account afterwards; it is not what this
            // test is about, so it gets an empty answer.
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: {}),
            );
            return;
          }
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: _resultJson(_day(DateTime.now())),
            ),
          );
        },
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => prefs),
            solarNetworkClientProvider.overrideWithValue(
              SolarNetworkClient.fromDio(dio),
            ),
            checkInResultTodayProvider.overrideWith((ref) async => null),
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
                home: const Scaffold(body: CheckInScreen()),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text("Draw today's sign"));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(requests, hasLength(1));
    expect(requests.single.queryParameters.containsKey('backdated'), isFalse);
    expect(find.text("Draw today's sign"), findsNothing);
    expect(find.byType(FortuneCard), findsOneWidget);
  });
}
