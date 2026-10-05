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
import 'package:island/posts/posts_pod.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sidebar_panel_host.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Timeline the refresh tests page through: enough rows to overflow the
/// viewport, and a [refreshCount] the tests can read back.
class _RecordingFeed extends ActivityListNotifier {
  int refreshCount = 0;

  List<SnTimelineEvent> get _events => List<SnTimelineEvent>.generate(
    12,
    (index) => _postEvent(_post('post-$index')),
    growable: false,
  );

  @override
  Future<PaginationState<SnTimelineEvent>> build() async => PaginationState(
    items: _events,
    isLoading: false,
    isReloading: false,
    totalCount: 12,
    hasMore: false,
    cursor: null,
  );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async => _events;

  @override
  Future<void> refresh() async {
    refreshCount++;
    return super.refresh();
  }
}

SnPost _post(String id) {
  return SnPost.fromJson({
    'id': id,
    'type': 0,
    'content': 'Post body for $id.',
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'reactions_count': <String, dynamic>{},
    'reactions_made': <String, dynamic>{},
    'chained_posts': <dynamic>[],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

SnTimelineEvent _postEvent(SnPost post) => SnTimelineEvent.fromJson({
  'id': 'event-${post.id}',
  'type': 'posts.new',
  'resource_identifier': 'post:${post.id}',
  'data': post.toJson(),
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

/// The explore quick pick refreshes this live list, so the screen has to
/// survive its notifier being read while the strip is off screen.
class _OnePublisherSubscription extends PublishersSubscriptionsLiveNotifier {
  static int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
    return super.refresh();
  }

  @override
  Future<List<PublisherSubscriptionLiveItem>> build() async => [
    PublisherSubscriptionLiveItem(
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
    ),
  ];
}

/// Answers every request with an empty JSON list so unrelated providers settle
/// without touching the network.
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

  setUp(() => _OnePublisherSubscription.refreshCount = 0);

  Future<void> pumpExplore(
    WidgetTester tester,
    Size size,
    _RecordingFeed feed,
  ) async {
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
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  apiClientProvider.overrideWithValue(dio),
                  userInfoProvider.overrideWith(() => _GuestUserInfo()),
                  activityListProvider.overrideWith(() => feed),
                  publishersSubscriptionsLiveProvider.overrideWith(
                    () => _OnePublisherSubscription(),
                  ),
                  featuredPostsProvider.overrideWith(
                    (ref) async => const <SnPost>[],
                  ),
                  friendsOverviewExpandedProvider.overrideWith(
                    (ref) async => const <SnFriendOverviewItem>[],
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

  testWidgets('explore: pulling the timeline down reloads the feed', (
    tester,
  ) async {
    final feed = _RecordingFeed();
    await pumpExplore(tester, const Size(1400, 420), feed);
    expect(find.byType(SidebarPanelHost), findsNothing);

    await tester.fling(
      find.byType(CustomScrollView).first,
      const Offset(0, 320),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(feed.refreshCount, 1);
    // The publisher quick pick is not on screen, so its live list is left
    // alone instead of being refreshed through a throwaway instance.
    expect(_OnePublisherSubscription.refreshCount, 0);

    await disposeTree(tester);
  });

  testWidgets('explore: the refresh action reloads the feed', (tester) async {
    final feed = _RecordingFeed();
    await pumpExplore(tester, const Size(1400, 420), feed);

    // The hover refresh action and the pull gesture both run this callback.
    final indicator = tester.widget<ExtendedRefreshIndicator>(
      find.byType(ExtendedRefreshIndicator),
    );
    final pending = indicator.onRefresh();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await pending;

    expect(tester.takeException(), isNull);
    expect(feed.refreshCount, 1);
    expect(_OnePublisherSubscription.refreshCount, 0);

    await disposeTree(tester);
  });

  testWidgets('explore: refresh keeps working on the subscriptions tab', (
    tester,
  ) async {
    final feed = _RecordingFeed();
    await pumpExplore(tester, const Size(1400, 420), feed);

    // Render the quick pick so the publisher live list is on screen.
    await tester.tap(find.byType(Tab).at(1));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Subscriptions'), findsOneWidget);

    final indicator = tester.widget<ExtendedRefreshIndicator>(
      find.byType(ExtendedRefreshIndicator),
    );
    final pending = indicator.onRefresh();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await pending;

    expect(tester.takeException(), isNull);
    expect(feed.refreshCount, 1);
    expect(_OnePublisherSubscription.refreshCount, 1);

    await disposeTree(tester);
  });
}
