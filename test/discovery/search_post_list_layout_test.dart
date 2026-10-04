import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/search.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Serves a canned posts page so the search tab renders real rows.
class _ScriptedAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode([_postJson('p1'), _postJson('p2'), _postJson('p3')]),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
      'x-total': ['3'],
    },
  );
}

Map<String, dynamic> _postJson(String id) => {
  'id': id,
  'type': 0,
  'content': 'body $id',
  'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
  'reactions_count': <String, dynamic>{},
  'reactions_made': <String, dynamic>{},
  'chained_posts': <dynamic>[],
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpSearch(WidgetTester tester, Size size) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _ScriptedAdapter();

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
                  apiClientProvider.overrideWithValue(dio),
                ],
                child: const UniversalSearchScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    // The skeleton shimmer animates indefinitely, so settle with bounded
    // pumps instead of pumpAndSettle and stop once the rows are up.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(PostActionableItem).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Unmounts inside the test body: VisibilityDetector reschedules a 500ms
  /// update as the tree goes away, which otherwise trips the binding's
  /// pending-timer invariant at teardown.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  testWidgets('wide: rows sit inside one top-rounded card wrapper', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(1400, 900));

    final items = find.byType(PostActionableItem);
    expect(items, findsNWidgets(3));

    // Every row's only Card ancestor is the shared pane wrapper.
    for (var i = 0; i < 3; i++) {
      final cardFinder = find.ancestor(
        of: items.at(i),
        matching: find.byType(Card),
      );
      expect(cardFinder, findsOneWidget);
      if (i == 0) {
        expect(
          tester.widget<Card>(cardFinder).shape,
          isA<RoundedRectangleBorder>().having(
            (s) => s.borderRadius,
            'borderRadius',
            const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
        );
        // The wrapper spans the pane rather than shrink-wrapping the rows.
        expect(tester.getSize(cardFinder).height, greaterThan(500));
      }
    }
    expect(find.byType(Divider), findsAtLeastNWidgets(2));
    await disposeTree(tester);
  });

  testWidgets('narrow: rows render straight onto the background', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    final items = find.byType(PostActionableItem);
    expect(items, findsNWidgets(3));
    for (var i = 0; i < 3; i++) {
      expect(
        find.ancestor(of: items.at(i), matching: find.byType(Card)),
        findsNothing,
      );
    }

    // No outer list padding: gutters come from PostItem, and a null padding
    // would pull in the status-bar inset as a large top gap.
    final list = tester.widget<PaginationList<SnPost>>(
      find.byWidgetPredicate((w) => w is PaginationList<SnPost>),
    );
    expect(list.padding, EdgeInsets.zero);
    expect(tester.getTopLeft(items.first).dy, lessThan(220));
    expect(find.byType(Divider), findsAtLeastNWidgets(2));
    await disposeTree(tester);
  });
}
