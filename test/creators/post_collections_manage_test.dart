import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/posts/post_collections_manage.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Stands in for the collection endpoints the manage screen touches, so the
/// test observes the reorder request the sheet actually sends.
class _CollectionsBackend {
  final List<List<String>> reorders = [];

  Map<String, dynamic> _post(String id, String title) => {
    'id': id,
    'title': title,
    'content': 'content for $id',
    'publisher_id': 'pub',
  };

  SolarNetworkClient client() {
    final dio = Dio(BaseOptions(baseUrl: 'https://collections.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;
          if (options.method == 'GET' &&
              path == '/sphere/publishers/pub/collections') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 'c1',
                    'slug': 'field-notes',
                    'name': 'Field notes',
                    'publisher_id': 'pub',
                  },
                ],
              ),
            );
            return;
          }
          if (options.method == 'GET' &&
              path == '/sphere/publishers/pub/collections/field-notes/posts') {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                headers: Headers.fromMap({
                  'X-Total': ['3'],
                }),
                data: [
                  _post('p1', 'First'),
                  _post('p2', 'Second'),
                  _post('p3', 'Third'),
                ],
              ),
            );
            return;
          }
          if (options.method == 'PUT' &&
              path ==
                  '/sphere/publishers/pub/collections/field-notes/posts/reorder') {
            final body = Map<String, dynamic>.from(options.data as Map);
            reorders.add(List<String>.from(body['post_ids'] as List));
            handler.resolve(Response(requestOptions: options, statusCode: 200));
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 404),
            ),
          );
        },
      ),
    );
    return SolarNetworkClient.fromDio(dio);
  }
}

class _StubRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PageInfo.builder(
        'collections',
        builder: (context, data) =>
            const CreatorPostCollectionsScreen(pubName: 'pub'),
      ),
      path: '/',
      initial: true,
    ),
  ];
}

Future<void> _pump(WidgetTester tester, _CollectionsBackend backend) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(420, 900);
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final config = _StubRouter().config();

  // Real async window so EasyLocalization's file-backed load settles.
  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          solarNetworkClientProvider.overrideWithValue(backend.client()),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp.router(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              routerConfig: config,
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('dragging a post persists the new order', (tester) async {
    final backend = _CollectionsBackend();
    await _pump(tester, backend);

    // The label is inert: the tap has to fall through to the cover's InkWell.
    await tester.tap(find.text('Field notes'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);

    final handle = find.byIcon(Symbols.drag_handle).first;
    final gesture = await tester.startGesture(
      tester.getCenter(handle),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(backend.reorders, hasLength(1));
    expect(jsonEncode(backend.reorders.single), jsonEncode(['p2', 'p1', 'p3']));
    expect(tester.takeException(), isNull);
  });
}
