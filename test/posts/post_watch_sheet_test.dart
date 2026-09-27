import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/post_watch_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Stands in for `GET|PUT /sphere/posts/watch`, keeping the same merge
/// semantics as the server: a write only touches the flags it carries.
class _WatchBackend {
  _WatchBackend({this.failWrites = false});

  final bool failWrites;
  final List<Map<String, dynamic>> writes = [];

  final Map<String, Map<String, dynamic>> _state = {
    'bookmark': {
      'notify_reactions': true,
      'notify_replies': true,
      'notify_chains': true,
      'notify_forwards': true,
      'notify_edits': true,
    },
    'reaction': {
      'notify_reactions': false,
      'notify_replies': false,
      'notify_chains': true,
      'notify_forwards': false,
      'notify_edits': true,
    },
    'reply': {
      'notify_reactions': false,
      'notify_replies': false,
      'notify_chains': true,
      'notify_forwards': false,
      'notify_edits': true,
    },
  };

  List<Map<String, dynamic>> get _response => [
    for (final entry in _state.entries) {'source': entry.key, ...entry.value},
  ];

  SolarNetworkClient client() {
    final dio = Dio(BaseOptions(baseUrl: 'https://watch.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path != '/sphere/posts/watch') {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 404),
              ),
            );
            return;
          }

          if (options.method == 'PUT') {
            final body = Map<String, dynamic>.from(options.data as Map);
            writes.add(body);
            if (failWrites) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(requestOptions: options, statusCode: 500),
                  type: DioExceptionType.badResponse,
                ),
              );
              return;
            }
            for (final entry in body.entries) {
              final target = _state[entry.key]!;
              for (final flag in (entry.value as Map).entries) {
                target['notify_${flag.key}'] = flag.value;
              }
            }
          }

          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: _response),
          );
        },
      ),
    );
    return SolarNetworkClient.fromDio(dio);
  }
}

Widget _app({required SolarNetworkClient client, required Widget child}) {
  return ProviderScope(
    retry: (count, error) => null,
    overrides: [solarNetworkClientProvider.overrideWithValue(client)],
    child: EasyLocalization(
      supportedLocales: const [Locale('en', 'US')],
      path: 'assets/i18n',
      saveLocale: false,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(body: child),
        ),
      ),
    ),
  );
}

List<bool> _values(WidgetTester tester) => tester
    .widgetList<SwitchListTile>(find.byType(SwitchListTile))
    .map((tile) => tile.value)
    .toList();

/// Pumps with a real async window so EasyLocalization's file-backed load
/// finishes before the tree settles.
Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(app);
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('shows the effective filters of all three sources', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final backend = _WatchBackend();
    await _pumpApp(
      tester,
      _app(client: backend.client(), child: const PostWatchSheet()),
    );

    expect(find.text('Bookmarked posts'), findsOneWidget);
    expect(find.text('Posts you reacted to'), findsOneWidget);
    expect(find.text('Posts you replied to'), findsOneWidget);

    final values = _values(tester);
    expect(values.length, 15);
    expect(values.sublist(0, 5), [true, true, true, true, true]);
    expect(values.sublist(5, 10), [false, false, true, false, true]);
    expect(values.sublist(10, 15), [false, false, true, false, true]);
  });

  testWidgets('writes only the toggled source and follows the reply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final backend = _WatchBackend();
    await _pumpApp(
      tester,
      _app(client: backend.client(), child: const PostWatchSheet()),
    );

    await tester.tap(find.byType(SwitchListTile).at(7));
    await tester.pumpAndSettle();

    expect(backend.writes, [
      {
        'reaction': {
          'reactions': false,
          'replies': false,
          'chains': false,
          'forwards': false,
          'edits': true,
        },
      },
    ]);
    expect(_values(tester)[7], isFalse);
    expect(_values(tester).sublist(0, 5), [true, true, true, true, true]);
  });

  testWidgets('reverts the switch when the write fails', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final backend = _WatchBackend(failWrites: true);
    await _pumpApp(
      tester,
      _app(client: backend.client(), child: const PostWatchSheet()),
    );

    await tester.tap(find.byType(SwitchListTile).at(0));
    await tester.pumpAndSettle();

    expect(backend.writes, hasLength(1));
    expect(_values(tester)[0], isTrue);
  });
}
