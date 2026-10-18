import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/explore.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/discovery/widgets/friend_presence_strip.dart';
import 'package:island/discovery/widgets/subscribed_publishers_strip.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
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

SnPost _smallPost({
  Map<String, dynamic> overrides = const {},
  String id = 'small-post',
}) {
  return SnPost.fromJson({
    'id': id,
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
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async => [
    _postEvent(post),
  ];
}

/// Timeline with two rows, so the uniform gap between floating cards can be
/// measured.
class _TwoPostFeed extends ActivityListNotifier {
  _TwoPostFeed(this.posts);

  final List<SnPost> posts;

  List<SnTimelineEvent> get _events => [
    for (final (index, post) in posts.indexed)
      SnTimelineEvent.fromJson({
        'id': 'event-$index',
        'type': 'posts.new',
        'resource_identifier': 'post:${post.id}',
        'data': post.toJson(),
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
        'deleted_at': null,
      }),
  ];

  @override
  Future<PaginationState<SnTimelineEvent>> build() async => PaginationState(
    items: _events,
    isLoading: false,
    isReloading: false,
    totalCount: _events.length,
    hasMore: false,
    cursor: null,
  );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async => _events;
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
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
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
    expect(
      find.ancestor(of: strip, matching: find.byType(ExploreCard)),
      findsOneWidget,
      reason: 'the quick pick floats as its own section card',
    );

    final pane = find.ancestor(
      of: sliver,
      matching: find.byType(CustomScrollView),
    );
    final scrollView = tester.widget<CustomScrollView>(pane);
    // The pane keeps the wide reading measure and stays centred instead of
    // spanning the window. It is no longer wrapped in a page-wide card.
    final paneRect = tester.getRect(pane.first);
    expect(paneRect.width, closeTo(720, 1));
    expect(paneRect.left, closeTo((windowWidth - paneRect.width) / 2, 1));
    // The wide header is no longer a sliver: it floats over the pane at the
    // window's full width, so the feed starts with the gap that reserves its
    // height and the quick pick is the first content sliver.
    expect(
      find.ancestor(of: strip, matching: find.byType(PillSliverAppBar)),
      findsNothing,
      reason: 'the wide pill is not pinned inside the feed',
    );
    expect(find.byType(PillAppBar), findsOneWidget);

    final sliverWidget = tester.widget(sliver);
    expect(
      scrollView.slivers.indexWhere(
        (s) => s.runtimeType == sliverWidget.runtimeType,
      ),
      1,
      reason: 'the strip is the first content sliver under the floating pill',
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
    // The section itself floats on a card, though.
    expect(
      find.ancestor(of: featured, matching: find.byType(ExploreCard)),
      findsOneWidget,
      reason: 'the featured section is its own floating card',
    );
    // The online strip uses the same list, so scope to the featured one.
    final featuredStrip = find.descendant(
      of: featured,
      matching: find.byType(CarouselView),
    );
    expect(featuredStrip, findsOneWidget);
    expect(
      find.descendant(of: featured, matching: find.byType(PageView)),
      findsNothing,
      reason: 'a snapped strip replaces the full-width pager',
    );
    final featuredItem = find
        .descendant(
          of: featuredStrip,
          matching: find.byType(PostActionableItem),
        )
        .first;
    expect(
      tester.getSize(featuredItem).width,
      320,
      reason: 'one post keeps its own width instead of filling the pane',
    );
    final scrollView = tester.widget<CustomScrollView>(
      find.ancestor(of: featured, matching: find.byType(CustomScrollView)),
    );
    expect(
      scrollView.slivers.indexWhere((s) => s is SliverFriendPresenceStrip),
      1,
      reason: 'only the gap reserving the pill height precedes it',
    );
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
      matching: find.byType(CarouselView),
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

  testWidgets('wide explore: posts float on their own cards', (tester) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () =>
          _TwoPostFeed([_smallPost(id: 'post-a'), _smallPost(id: 'post-b')]),
      featuredPosts: const <SnPost>[],
    );

    final posts = find.byType(PostActionableItem);
    expect(posts, findsNWidgets(2));
    final cards = find.ancestor(of: posts, matching: find.byType(ExploreCard));
    expect(cards, findsNWidgets(2));
    final cardWidget = tester.widget<ExploreCard>(cards.first);
    expect(cardWidget.radius, 20);
    expect(
      tester
          .widget<Card>(
            find.descendant(of: cards.first, matching: find.byType(Card)),
          )
          .elevation,
      0,
    );

    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    // The feed is an inset card stack in the centred 720px column.
    expect(first.left, closeTo((1400 - 720) / 2 + 12, 1));
    expect(first.width, closeTo(720 - 24, 1));
    expect(second.top - first.bottom, closeTo(kExploreCardGap, 1));

    final scrollView = find.ancestor(
      of: posts.first,
      matching: find.byType(CustomScrollView),
    );
    expect(
      find.descendant(of: scrollView, matching: find.byType(Divider)),
      findsNothing,
      reason: 'cards are separated by gaps, not horizontal rules',
    );

    await disposeTree(tester);
  });

  testWidgets('narrow explore: cards use the page gutter and one gap', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(420, 900),
      feed: () =>
          _TwoPostFeed([_smallPost(id: 'post-a'), _smallPost(id: 'post-b')]),
      featuredPosts: const <SnPost>[],
    );

    final posts = find.byType(PostActionableItem);
    expect(posts, findsNWidgets(2));
    final cards = find.ancestor(of: posts, matching: find.byType(ExploreCard));
    expect(cards, findsNWidgets(2));

    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    expect(first.left, closeTo(12, 1));
    expect(first.width, closeTo(420 - 24, 1));
    expect(second.top - first.bottom, closeTo(kExploreCardGap, 1));

    await disposeTree(tester);
  });
  testWidgets('the header stays put and only fades its surface in', (
    tester,
  ) async {
    // A feed tall enough to hold the drag below: with only a couple of short
    // posts the scroll bounces straight back to the origin, and the fill
    // would never get a chance to fade in.
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () =>
          _TwoPostFeed([for (var i = 0; i < 8; i++) _smallPost(id: 'post-$i')]),
      featuredPosts: const <SnPost>[],
    );

    // The pill's own box is the only container inside the surface chrome that
    // carries an outer margin.
    Container barContainer() => tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(PillBarSurface),
            matching: find.byType(Container),
          ),
        )
        .firstWhere((container) => container.margin != null);

    // The painted glass: the pill's own [DecoratedBox], which is the first one
    // in the surface — the controls inside it come after.
    BoxDecoration barDecoration() =>
        (tester
                .widgetList<DecoratedBox>(
                  find.descendant(
                    of: find.byType(PillBarSurface),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .first
                .decoration
            as BoxDecoration);

    BackdropFilter? glass() => tester
        .widgetList<BackdropFilter>(find.byType(BackdropFilter))
        .firstOrNull;

    // The bar's own geometry never changes with the scroll: the container
    // keeps the same height, margins and capsule at every offset. On wide it
    // spans the whole window, so the pill is as wide as the viewport minus its
    // own 12px margins.
    void expectBarGeometry() {
      final container = barContainer();
      final margin = container.margin! as EdgeInsets;
      expect(margin.left, SolSpace.md);
      expect(margin.right, SolSpace.md);
      expect(margin.top, SolSpace.md);
      expect(
        barDecoration().borderRadius,
        SolRadius.pillRadius,
        reason: 'the shape is always the capsule',
      );
      final barRect = tester.getRect(find.byWidget(container));
      expect(barRect.width, closeTo(1400, 1));
      expect(barRect.height, closeTo(kPillAppBarHeight, 1));
    }

    expectBarGeometry();
    expect(
      barDecoration().color!.a,
      0,
      reason: 'the feed starts flush, so the bar has no surface yet',
    );
    expect(
      barDecoration().boxShadow,
      isNull,
      reason: 'a transparent pill over the empty page top has no shadow',
    );
    expect(
      glass(),
      isNull,
      reason: 'nothing is under the bar yet, so there is no layer to blur',
    );

    // The pill deliberately no longer aligns with the cards: it owns the
    // window's full width while the feed stays in the centred reading column,
    // so the capsule is wider than a card by the gutters on both sides.
    final barRect = tester.getRect(find.byWidget(barContainer()));
    final stripRect = tester.getRect(find.byType(FriendPresenceStrip));
    expect(barRect.left, closeTo(0, 1));
    expect(barRect.right, closeTo(1400, 1));
    expect(
      barRect.width - stripRect.width,
      closeTo(1400 - (720 - SolSpace.md * 2), 1),
      reason: 'the cards stay in the 720 column under the full-width pill',
    );
    expect(stripRect.left, greaterThan(barRect.left + SolSpace.md));

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -200),
    );
    // Let the fling settle: a pinned header interpolates its height while
    // the scroll is still animating.
    await tester.pumpAndSettle();

    // Scrolled: same geometry, but now glass — a blur layer over the feed, a
    // translucent tint short of opaque, a hairline and a soft shadow.
    expectBarGeometry();
    expect(barDecoration().color!.a, closeTo(kPillGlassTint, 0.01));
    expect(barDecoration().border, isNotNull);
    final shadow = barDecoration().boxShadow!.single;
    expect(shadow.color.a, greaterThan(0));
    expect(
      glass()!.filter,
      ImageFilter.blur(sigmaX: kPillGlassSigma, sigmaY: kPillGlassSigma),
      reason: 'the fully surfaced pill blurs the rows sliding under it',
    );

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

    // The section picker is now a dropdown in the leading slot, not a tab bar.
    await tester.tap(find.byType(MenuAnchor).first);
    await tester.pumpAndSettle();
    // Second menu item = Subscriptions (Explore, Subscriptions, Friends).
    await tester.tap(find.byType(MenuItemButton).at(1));
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
