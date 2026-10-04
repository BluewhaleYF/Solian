import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/discovery/search.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
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
  ) async {
    // The messages section syncs chat rooms (expects an object); everything
    // else serves the canned posts page.
    if (options.path.contains('/messager/chat/rooms/sync')) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{}),
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }
    return ResponseBody.fromString(
      jsonEncode([_postJson('p1'), _postJson('p2'), _postJson('p3')]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-total': ['3'],
      },
    );
  }
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

  Future<void> pumpSearch(
    WidgetTester tester,
    Size size, {
    AppDatabase? database,
  }) async {
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
                  // Only the messages section reads the local database.
                  if (database != null)
                    databaseProvider.overrideWithValue(database),
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

    // Gutters come from PostItem, so the rows sit right under the app bar.
    expect(tester.getTopLeft(items.first).dy, lessThan(220));
    expect(find.byType(Divider), findsAtLeastNWidgets(2));
    await disposeTree(tester);
  });

  /// The single app bar filter action (icon-only [IconButton]).
  Finder filterAction() => find.descendant(
    of: find.byType(AppBar),
    matching: find.byWidgetPredicate(
      (w) =>
          w is IconButton &&
          w.icon is Icon &&
          ((w.icon as Icon).icon == Symbols.filter_list ||
              (w.icon as Icon).icon == Symbols.filter_list_off),
    ),
  );

  Finder postList() =>
      find.byWidgetPredicate((w) => w is PaginationList<SnPost>);

  testWidgets('narrow: the app bar action toggles the posts filter panel', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    // Only the app bar action exists — the section no longer carries its own.
    expect(find.byIcon(Symbols.filter_list), findsOneWidget);
    expect(find.byType(PostFilterWidget), findsNothing);

    await tester.tap(filterAction());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Symbols.filter_list_off), findsOneWidget);
    expect(find.byType(PostFilterWidget), findsOneWidget);

    await tester.tap(filterAction());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Symbols.filter_list), findsOneWidget);
    expect(find.byType(PostFilterWidget), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('wide: the app bar action toggles the posts filter panel', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(1400, 900));

    expect(find.byType(PostFilterWidget), findsNothing);
    await tester.tap(filterAction());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PostFilterWidget), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('narrow: scrolling the posts results does not toggle filters', (
    tester,
  ) async {
    // A short viewport makes the three canned rows overflow and scroll.
    await pumpSearch(tester, const Size(400, 280));

    final scrollable = find
        .descendant(of: postList(), matching: find.byType(Scrollable))
        .first;
    final firstRow = find.byType(PostActionableItem).first;
    final start = tester.getTopLeft(firstRow).dy;

    // Scroll down first so the upward leg actually moves the list.
    await tester.drag(scrollable, const Offset(0, -160));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getTopLeft(firstRow).dy,
      lessThan(start),
      reason: 'the list should have scrolled down',
    );

    // Scrolling back up previously revealed the filter panel.
    await tester.drag(scrollable, const Offset(0, 160));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(PostFilterWidget), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('the filter action is disabled on sections without filters', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    expect(tester.widget<IconButton>(filterAction()).onPressed, isNotNull);

    await tester.tap(find.text('Accounts'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<IconButton>(filterAction()).onPressed, isNull);

    await disposeTree(tester);
  });

  testWidgets('the messages section reuses the app bar filter action', (
    tester,
  ) async {
    await pumpSearch(
      tester,
      const Size(400, 800),
      database: AppDatabase.web(),
    );

    await tester.tap(find.text('Messages'));
    await tester.pump(const Duration(milliseconds: 800));

    // No per-view trigger remains, and the filter bar starts collapsed.
    expect(find.byIcon(Symbols.filter_list), findsOneWidget);
    expect(find.byIcon(Symbols.cloud), findsNothing);

    await tester.tap(filterAction());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Symbols.cloud), findsOneWidget);

    await disposeTree(tester);
  });
}
