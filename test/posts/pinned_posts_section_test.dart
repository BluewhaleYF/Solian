import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _pubName = 'pinned';

SnPost _pinnedPost(String id) => SnPost.fromJson({
  'id': id,
  'title': 'Pinned $id',
  'content': 'Pinned body $id',
  'content_type': 0,
  'type': 0,
  'created_at': '2026-10-20T10:00:00Z',
  'updated_at': '2026-10-20T10:00:00Z',
  'published_at': '2026-10-20T10:00:00Z',
  'visibility': 0,
  'status': 0,
  'publisher_id': 'pub-1',
  'author': {
    'id': 'acc-1',
    'name': 'littlesheep',
    'nick': 'LittleSheep',
    'language': 'en-US',
    'region': '',
    'is_superuser': false,
    'automated_id': null,
    'profile': {
      'id': 'prof-1',
      'bio': '',
      'experience': 0,
      'level': 1,
      'leveling_progress': 0,
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
    'badges': [],
    'contacts': [],
    'permissions': 0,
    'created_at': '2024-01-01T00:00:00Z',
    'updated_at': '2024-01-01T00:00:00Z',
  },
});

class _PinnedFeed extends PostListNotifier {
  _PinnedFeed(super.arg);

  @override
  Future<PaginationState<SnPost>> build() async => PaginationState(
    items: [_pinnedPost('p1'), _pinnedPost('p2')],
    isLoading: false,
    isReloading: false,
    totalCount: 2,
    hasMore: false,
    cursor: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  /// Pinned posts sit in an explore-style section: one floating card with a
  /// header band, and the pinned strip inside it.
  testWidgets('pinned posts render as an explore section', (tester) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final prefs = await SharedPreferences.getInstance();
    // Exactly the config the section builds for its own name; the family key
    // has to match or the override lands on a different instance.
    final pinnedQuery = PostListQueryConfig(
      id: 'publisher-$_pubName-pinned',
      initialFilter: const PostListQuery(pubName: _pubName, pinned: true),
    );

    // EasyLocalization resolves its delegate on the real clock, so the tree is
    // built inside runAsync (same reason as the fediverse profile test).
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => mui.MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: mui.Material(
                child: ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWith((ref) => prefs),
                    postListProvider(
                      pinnedQuery,
                    ).overrideWith(() => _PinnedFeed(pinnedQuery)),
                  ],
                  child: const Scaffold(
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: PinnedPostsSection(pubName: _pubName),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.byType(ExploreCard), findsOneWidget);
    expect(find.byIcon(Symbols.push_pin), findsOneWidget);
    expect(find.byType(PostActionableItem), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    // The header band collapses the strip.
    await tester.tap(find.byIcon(Symbols.push_pin));
    await tester.pumpAndSettle();
    expect(find.byType(PostActionableItem), findsNothing);
    expect(find.byIcon(Symbols.expand_more), findsOneWidget);

    // Ink splashes and the AnimatedSize settle on their own clocks; drain them
    // so the binding's "no pending timer" invariant holds at teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
