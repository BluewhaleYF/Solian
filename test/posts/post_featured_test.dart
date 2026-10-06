import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers every request with an empty JSON list so nothing reaches the
/// network while the cards render.
class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(const <dynamic>[]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

SnPost _post(String id) => SnPost.fromJson({
  'id': id,
  'type': 0,
  'content': 'featured body',
  'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
  'reactions_count': <String, dynamic>{},
  'reactions_made': <String, dynamic>{},
  'chained_posts': <dynamic>[],
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpFeatured(WidgetTester tester, {bool flush = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  apiClientProvider.overrideWithValue(
                    Dio(BaseOptions(baseUrl: 'https://example.test'))
                      ..httpClientAdapter = _EmptyAdapter(),
                  ),
                  featuredPostsProvider.overrideWith(
                    (ref) async => [_post('f1'), _post('f2')],
                  ),
                ],
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: 600,
                      child: PostFeaturedList(flush: flush),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Unmounts inside the test body: pending provider retries otherwise trip
  /// the binding's pending-timer invariant at teardown.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  testWidgets('default variant keeps its card chrome and header pager', (
    tester,
  ) async {
    await pumpFeatured(tester);

    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(CarouselView), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.byIcon(Symbols.arrow_left), findsOneWidget);
    expect(find.byIcon(Symbols.arrow_right), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('flush variant drops the card chrome for a snapping carousel', (
    tester,
  ) async {
    await pumpFeatured(tester, flush: true);

    expect(find.byType(Card), findsNothing);
    expect(find.byType(CarouselView), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.byIcon(Symbols.arrow_left), findsNothing);
    expect(find.byIcon(Symbols.arrow_right), findsNothing);

    await disposeTree(tester);
  });
}
