import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/explore.dart';
import 'package:island/discovery/widgets/friend_presence_strip.dart';
import 'package:island/discovery/widgets/subscribed_publishers_strip.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/shared/widgets/hover_horizontal_scroll_list.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:island/shared/widgets/layouts/sidebar_panel_host.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Holds the timeline in its initial-loading state: the wide body then renders
/// the spinner instead of paging the feed, so the test exercises layout only.
class _LoadingActivityList extends ActivityListNotifier {
  @override
  Future<PaginationState<SnTimelineEvent>> build() async =>
      const PaginationState(
        items: <SnTimelineEvent>[],
        isLoading: true,
        isReloading: false,
        totalCount: 0,
        hasMore: false,
        cursor: null,
      );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async =>
      const <SnTimelineEvent>[];
}

/// One subscribed publisher so the quick pick has real content to paint.
class _OnePublisherSubscription extends PublishersSubscriptionsLiveNotifier {
  @override
  Future<List<PublisherSubscriptionLiveItem>> build() async => [
    _publisherSubscription(),
  ];
}

PublisherSubscriptionLiveItem _publisherSubscription() {
  return PublisherSubscriptionLiveItem(
    subscription: SnPublisherSubscriptionCompact(
      accountId: 'account-1',
      publisherId: 'publisher-1',
      publisher: SnPublisher.fromJson({
        'id': 'publisher-1',
        'name': 'alice',
        'nick': 'Alice',
      }),
    ),
    isLive: false,
    hasNewContent: true,
  );
}

SnPost _featuredPost([String id = 'featured-1']) {
  return SnPost.fromJson({
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
}

SnFriendOverviewItem _friendOverviewItem() {
  final now = DateTime.utc(2026, 1, 1);
  return SnFriendOverviewItem(
    account: SnAccount(
      id: 'account-2',
      name: 'bob',
      nick: 'Bob',
      language: 'en-US',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'profile-2',
        experience: 0,
        level: 1,
        levelingProgress: 0,
        picture: null,
        background: null,
        verification: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
      perkSubscription: null,
      activatedAt: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    status: SnAccountStatus(
      id: 'status-2',
      attitude: 0,
      isOnline: true,
      isCustomized: false,
      meta: null,
      clearedAt: null,
      accountId: 'account-2',
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    activities: const <SnPresenceActivity>[],
  );
}

SnPost _smallPost({Map<String, dynamic> overrides = const {}}) {
  return SnPost.fromJson({
    'id': 'small-post',
    'type': 0,
    'content': 'A short post body.',
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'reactions_count': <String, dynamic>{},
    'reactions_made': <String, dynamic>{},
    'chained_posts': <dynamic>[],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
    ...overrides,
  });
}

SnTimelineEvent _postEvent(SnPost post) => SnTimelineEvent.fromJson({
  'id': 'event-1',
  'type': 'posts.new',
  'resource_identifier': 'post:${post.id}',
  'data': post.toJson(),
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

/// Timeline holding a single post row, so the wide feed renders something to
/// tap.
class _OnePostFeed extends ActivityListNotifier {
  _OnePostFeed(this.post);

  final SnPost post;

  @override
  Future<PaginationState<SnTimelineEvent>> build() async => PaginationState(
    items: [_postEvent(post)],
    isLoading: false,
    isReloading: false,
    totalCount: 1,
    hasMore: false,
    cursor: null,
  );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async =>
      [_postEvent(post)];
}

/// Answers every request with an empty JSON list so the sidebar cards settle
/// into their empty states without touching the network.
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
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpExplore(
    WidgetTester tester,
    Size size, {
    List<SnPost>? featuredPosts,
    ActivityListNotifier Function()? feed,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              navigatorKey: navigatorKey,
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  apiClientProvider.overrideWithValue(dio),
                  userInfoProvider.overrideWith(() => _GuestUserInfo()),
                  activityListProvider.overrideWith(
                    feed ?? () => _LoadingActivityList(),
                  ),
                  publishersSubscriptionsLiveProvider.overrideWith(
                    () => _OnePublisherSubscription(),
                  ),
                  featuredPostsProvider.overrideWith(
                    (ref) async => featuredPosts ?? [_featuredPost()],
                  ),
                  friendsOverviewExpandedProvider.overrideWith(
                    (ref) async => [_friendOverviewItem()],
                  ),
                ],
                child: const ExploreScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Unmounts inside the test body: visibility detectors reschedule their
  /// timers as the tree goes away, which otherwise trips the binding's
  /// pending-timer invariant at teardown.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  /// The quick pick is painted as a sliver of the main section's own scroll
  /// view, directly under the section app bar, in a pane that owns the window
  /// (there is no right sidebar sharing it).
  void expectUnderSectionAppBar(
    WidgetTester tester,
    Finder sliver,
    Finder strip, {
    required double windowWidth,
  }) {
    expect(sliver, findsOneWidget);
    expect(strip, findsOneWidget);
    expect(find.byType(SidebarPanelHost), findsNothing);

    final pane = find.ancestor(
      of: sliver,
      matching: find.byType(CustomScrollView),
    );
    final scrollView = tester.widget<CustomScrollView>(pane);
    // The pane keeps the wide reading measure and stays centred instead of
    // spanning the window.
    final paneRect = tester.getRect(
      find.ancestor(of: sliver, matching: find.byType(Card)).first,
    );
    expect(paneRect.width, closeTo(720, 1));
    expect(paneRect.left, closeTo((windowWidth - paneRect.width) / 2, 1));
    expect(scrollView.slivers.first, isA<SliverAppBar>());
    // [app bar, divider, strip, feed] — the same stack the narrow layout uses.
    expect(scrollView.slivers[1], isA<SliverToBoxAdapter>());
    final sliverWidget = tester.widget(sliver);
    expect(
      scrollView.slivers.indexWhere(
        (s) => s.runtimeType == sliverWidget.runtimeType,
      ),
      2,
      reason: 'the strip sits right below the app bar sliver',
    );

    // Painted, not merely present: the strip occupies its full height at the
    // top of the pane.
    expect(tester.getSize(strip).height, greaterThan(60));
    expect(tester.getTopLeft(strip).dy, lessThan(200));
  }

  testWidgets('wide explore: the featured carousel follows the quick pick', (
    tester,
  ) async {
    await pumpExplore(tester, const Size(1400, 900));

    expectUnderSectionAppBar(
      tester,
      find.byType(SliverFriendPresenceStrip),
      find.byType(FriendPresenceStrip),
      windowWidth: 1400,
    );
    expect(find.byType(SliverSubscribedPublishersStrip), findsNothing);

    final featured = find.byType(PostFeaturedList);
    expect(featured, findsOneWidget);
    expect(
      find.descendant(of: featured, matching: find.byType(Card)),
      findsNothing,
      reason: 'the carousel no longer paints a card surface of its own',
    );
    // The online strip uses the same list, so scope to the featured one.
    final featuredStrip = find.descendant(
      of: featured,
      matching: find.byType(HoverHorizontalScrollList),
    );
    expect(featuredStrip, findsOneWidget);
    expect(
      find.descendant(of: featured, matching: find.byType(PageView)),
      findsNothing,
      reason: 'a snapped strip replaces the full-width pager',
    );
    final featuredItem = find
        .descendant(of: featuredStrip, matching: find.byType(PostActionableItem))
        .first;
    expect(
      tester.getSize(featuredItem).width,
      320,
      reason: 'one post keeps its own width instead of filling the pane',
    );
    final scrollView = tester.widget<CustomScrollView>(
      find.ancestor(of: featured, matching: find.byType(CustomScrollView)),
    );
    expect(scrollView.slivers.indexWhere((s) => s is SliverFriendPresenceStrip), 2);
    expect(scrollView.slivers.indexWhere((s) => s is SliverPadding), 3);
    expect(
      tester.getTopLeft(featured).dy,
      greaterThan(tester.getTopLeft(find.byType(FriendPresenceStrip)).dy),
      reason: 'the carousel sits below the online accounts strip',
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: no carousel without featured posts', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      featuredPosts: const <SnPost>[],
    );

    expectUnderSectionAppBar(
      tester,
      find.byType(SliverFriendPresenceStrip),
      find.byType(FriendPresenceStrip),
      windowWidth: 1400,
    );
    expect(find.byType(PostFeaturedList), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('wide explore: the featured strip snaps to post boundaries', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      featuredPosts: [for (var i = 0; i < 5; i++) _featuredPost('featured-$i')],
    );

    final carousel = find.descendant(
      of: find.byType(PostFeaturedList),
      matching: find.byType(HoverHorizontalScrollList),
    );
    final items = find.descendant(
      of: carousel,
      matching: find.byType(PostActionableItem),
    );
    // Cards are spaced by the carousel's item extent, not by their width.
    final stride =
        tester.getTopLeft(items.at(1)).dx - tester.getTopLeft(items.at(0)).dx;
    final position = tester
        .state<ScrollableState>(
          find
              .descendant(of: carousel, matching: find.byType(Scrollable))
              .first,
        )
        .position;

    final gesture = await tester.startGesture(tester.getCenter(carousel));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    await gesture.moveBy(Offset(-stride, 0));
    await tester.pump();
    expect(position.pixels, greaterThan(0), reason: 'the strip scrolls');
    await gesture.up();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(position.pixels, greaterThan(0));
    expect(
      position.pixels % stride,
      moreOrLessEquals(0, epsilon: 1),
      reason: 'settling lands on a post boundary',
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: a short post opens in the attention modal', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    IslandUIFoundation.configureNavigator(navigatorKey);

    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () => _OnePostFeed(_smallPost()),
      navigatorKey: navigatorKey,
      // No featured strip, so the feed row is the only tappable post.
      featuredPosts: const <SnPost>[],
    );

    expect(find.byType(PostActionableItem), findsOneWidget);
    await tester.tap(find.textContaining('A short post body.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PostDetailAttentionModal), findsOneWidget);

    await disposeTree(tester);
  });

  group('postFitsAttentionModal', () {
    test('a short regular post fits', () {
      expect(postFitsAttentionModal(_smallPost()), isTrue);
    });

    test('long bodies keep the full page', () {
      expect(
        postFitsAttentionModal(_smallPost(overrides: {'content': 'x' * 500})),
        isFalse,
      );
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {'content': List.filled(12, 'line').join('\n')},
          ),
        ),
        isFalse,
      );
    });

    test('media, chains, embeds and articles keep the full page', () {
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {
              'attachments': [
                {'id': 'file-1', 'name': 'a.png', 'mime_type': 'image/png'},
              ],
            },
          ),
        ),
        isFalse,
      );
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {
              'chained_posts': [
                {
                  'id': 'chain-1',
                  'type': 0,
                  'content': 'chained',
                  'created_at': '2026-01-01T00:00:00Z',
                  'updated_at': '2026-01-01T00:00:00Z',
                },
              ],
            },
          ),
        ),
        isFalse,
      );
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {
              'embed_view': {'uri': 'https://example.com', 'renderer': 0},
            },
          ),
        ),
        isFalse,
      );
      expect(
        postFitsAttentionModal(_smallPost(overrides: {'type': 1})),
        isFalse,
      );
      expect(
        postFitsAttentionModal(_smallPost(overrides: {'is_truncated': true})),
        isFalse,
      );
    });
  });

  testWidgets('wide explore: the subscriptions tab swaps the quick pick', (
    tester,
  ) async {
    await pumpExplore(tester, const Size(1400, 900));

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.byType(Tab)).at(1),
    );
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expectUnderSectionAppBar(
      tester,
      find.byType(SliverSubscribedPublishersStrip),
      find.byType(SubscribedPublishersStrip),
      windowWidth: 1400,
    );
    expect(find.byType(SliverFriendPresenceStrip), findsNothing);
    expect(
      find.byType(PostFeaturedList),
      findsNothing,
      reason: 'the carousel is Explore-only',
    );

    await disposeTree(tester);
  });
}
