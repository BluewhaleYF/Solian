import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/posts/screens/compose_blog.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/posts/widgets/publishers/publisher_card.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_card.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/friend_presence_strip.dart';
import 'package:island/discovery/widgets/friend_presence_widgets.dart';
import 'package:island/discovery/widgets/subscribed_publishers_strip.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';

@RoutePage()
class ExploreScreen extends HookConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The timeline algorithm (section, ranking, aggressive mode) is configured
    // in the app settings screen and mirrored onto the timeline by the activity
    // list notifier; this screen only renders what it selects.
    final exploreSettings = ref.watch(appSettingsProvider).exploreSettings;
    // Publisher picks are session-scoped; only category/tag filters persist.
    final selectedPublisherNames = useState<List<String>>(<String>[]);
    // The explore section is a single persisted choice (null / subscriptions /
    // friends). The settings screen can change it out from under the page, so
    // it is read straight from the persisted state on every build.

    void handleFilterChange(String? filter) {
      ref
          .read(appSettingsProvider.notifier)
          .setExploreSettings(exploreSettings.copyWith(filter: filter));
    }

    // Selecting publishers is session-scoped and supersedes category/tag
    // filters, mirroring the subscription filter sheet behavior. Deselecting
    // every publisher leaves the persisted category/tag filters untouched.
    void handlePublishersChanged(List<String> names) {
      selectedPublisherNames.value = names;
      if (names.isEmpty) return;
      ref
          .read(appSettingsProvider.notifier)
          .setExploreSettings(
            exploreSettings.copyWith(
              selectedCategoryIds: const <String>[],
              selectedTagIds: const <String>[],
            ),
          );
    }

    // Drives the header's morph on a 0..1 scale: 0 is the flush, square band
    // at the top of the feed, 1 the fully inset pill after scrolling. A
    // notifier rather than setState so a scroll tick repaints the header only,
    // never the whole timeline.
    final morph = useValueNotifier(0.0);

    final isWide = isWideScreen(context);

    final hasSubscriptionFiltersApplied =
        selectedPublisherNames.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;

    final userInfo = ref.watch(userInfoProvider);

    final feed = _buildFeed(
      context,
      ref,
      morph: morph,
      selectedPublisherNames: selectedPublisherNames,
      onPublishersChanged: handlePublishersChanged,
      hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
      handleFilterChange: handleFilterChange,
      currentFilter: exploreSettings.filter,
      isWide: isWide,
      onOpenPost: isWide ? (post) => _openPost(context, post) : null,
    );

    final composeFab = userInfo.value != null
        ? _buildComposeFab(context)
        : null;

    if (isWide) {
      return AppScaffold(
        isNoBackground: false,
        appBar: null,
        floatingActionButton: composeFab,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _kWideTimelineMaxWidth,
            ),
            child: SizedBox.expand(child: feed),
          ),
        ),
      );
    }

    return AppScaffold(floatingActionButton: composeFab, body: feed);
  }

  /// Opens a post the way the wide layout wants it: short posts in the
  /// attention modal, anything that needs room on the full detail page.
  void _openPost(BuildContext context, SnPost post) {
    if (postFitsAttentionModal(post)) {
      showPostDetailAttentionModal(post.id);
      return;
    }
    context.router.push(PostDetailRoute(id: post.id));
  }

  /// The compose action, shared by both layouts.
  Widget _buildComposeFab(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'explore-fab',
      child: const Icon(Symbols.create),
      onPressed: () {
        final parentContext = context;
        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(40),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Symbols.post_add_rounded),
                title: Text('postCompose').tr(),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await PostComposeDialog.show(parentContext);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Symbols.article),
                title: Text('articleCompose').tr(),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await context.router.push(ArticleComposeRoute());
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Symbols.docs),
                title: Text('linkBlog').tr(),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await BlogComposeDialog.show(parentContext);
                },
              ),
              const Gap(16),
            ],
          ),
        );
      },
    ).padding(bottom: MediaQuery.of(context).padding.bottom);
  }

  /// Header of the explore feed.
  ///
  /// The bar morphs continuously with [morph] (0..1):
  ///
  /// * At 0 it is flush and square: it reads as the top of the page, not as a
  ///   card floating over it.
  /// * At 1 it is a capsule inset 12px left/right and 12px below the status
  ///   bar, so it keeps breathing room instead of clipping against it.
  ///
  /// Intermediate values lerp the margin and radius, so the transition tracks
  /// the drag rather than snapping.
  ///
  /// The pill paints a tonal surface (`surfaceContainerLow`): the page has one
  /// accent vocabulary — cards — and a saturated primary band would compete
  /// with every card in the stack. The section picker replaced the tab strip
  /// that used to be the bar's `bottom` row, so the bar is a single compact
  /// row. The shape follows the scroll offset, not the bar's attachment: it
  /// returns to the flush band as the feed comes back to the top.
  Widget _buildExploreSliverAppBar({
    required BuildContext context,
    required ValueNotifier<double> morph,
    required String? currentFilter,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    // With `primary: false` the bar does not add the status-bar inset itself.
    // The inset has to live *inside* the bar's box: a `SliverPadding` above
    // the bar scrolls away with the content, which let the pill ride up to
    // y=0 and collide with the status bar. Reserving it here keeps the
    // surface below the status bar in both the flush and the pill state.
    final statusTop = MediaQuery.paddingOf(context).top;

    // Bar geometry never changes; only what is painted inside `flexibleSpace`
    // morphs. Rebuilding the sliver from the `slivers` list on every scroll
    // tick would unmount it and the bar would vanish mid-scroll.
    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      // Status bar + one control row + the collapsed pill's top margin, so
      // the box can host both states without resizing the sliver.
      toolbarHeight: statusTop + SolSpace.control + SolSpace.md,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      floating: true,
      snap: true,
      flexibleSpace: ValueListenableBuilder<double>(
        valueListenable: morph,
        builder: (context, t, _) {
          // Margin and radius lerp with the scroll offset, so the band visibly
          // contracts into the capsule as the feed leaves the top instead of
          // popping at the first scrolled pixel.
          return Container(
            margin: EdgeInsets.fromLTRB(
              SolSpace.md * t,
              statusTop + SolSpace.md * t,
              SolSpace.md * t,
              0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(SolRadius.pill * t),
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  // The section picker takes the brand mark's place, so the
                  // bar holds exactly two things: the drawer toggle and the
                  // dropdown.
                  const SolDrawerButton(),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _ExploreSectionButton(
                        filter: currentFilter,
                        hasFiltersApplied: hasSubscriptionFiltersApplied,
                        onSelected: handleFilterChange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    WidgetRef ref, {
    void Function(SnPost)? onOpenPost,
  }) {
    return PaginationWidget(
      provider: activityListProvider,
      notifier: activityListProvider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: const SizedBox(
        height: 64,
        child: Center(child: ConfuseSpinner(size: 40, speed: 6)),
      ),
      contentBuilder: (data, footer) => _ActivityListView(
        data: data,
        footer: footer,
        onOpenPost: onOpenPost,
      ),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedPublishers,
    List<String> selectedCategories,
    List<String> selectedTags, {
    void Function(SnPost)? onOpenPost,
  }) {
    return SliverPostList(
      queryKey: 'explore_filtered',
      query: PostListQuery(
        publishers: selectedPublishers,
        categories: selectedCategories,
        tags: selectedTags,
      ),
      padding: EdgeInsets.zero,
      itemPadding: const EdgeInsets.fromLTRB(
        SolSpace.lg,
        SolSpace.md + 2,
        SolSpace.lg,
        SolSpace.md,
      ),
      onOpenPost: onOpenPost,
      itemWrapper: (context, index, post, child) => ExploreCard(child: child),
      separatorBuilder: (context, index, post) =>
          const Gap(kExploreCardGap),
    );
  }

  /// The feed itself.
  ///
  /// There is no page-wide surface card: the section quick pick, the featured
  /// strip and every row in the timeline are floating cards on the page
  /// background, separated by one uniform gap and no horizontal rules. The wide
  /// layout only constrains the feed to a readable column; it no longer wraps
  /// it in a card.
  Widget _buildFeed(
    BuildContext context,
    WidgetRef ref, {
    required ValueNotifier<double> morph,
    required ValueNotifier<List<String>> selectedPublisherNames,
    required ValueChanged<List<String>> onPublishersChanged,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
    required String? currentFilter,
    required bool isWide,
    required void Function(SnPost)? onOpenPost,
  }) {
    final appSettings = ref.watch(appSettingsProvider);
    final exploreSettings = appSettings.exploreSettings;
    final gutter = explorePageGutter(context);
    // The header is a single toolbar row; the old 48px tab strip is gone, so
    // the refresh indicator only has to clear the bar itself.
    final sliverRefreshInset =
        MediaQuery.paddingOf(context).top + SolSpace.md + SolSpace.control;
    final usePostList =
        selectedPublisherNames.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;
    final isSubscriptionsTab = currentFilter == 'subscriptions';
    final isExploreTab = currentFilter == null;
    // The featured carousel is a wide-screen section; only watch it there.
    final hasFeaturedPosts =
        isWide &&
        isExploreTab &&
        (ref.watch(featuredPostsProvider).value?.isNotEmpty == true);
    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    Future<void> refreshTimeline() async {
      // The publisher live list only exists while its quick pick is on screen
      // (the Subscriptions tab). Reading its notifier on any other tab would
      // refresh a throwaway instance that is already disposed by the time the
      // request resolves.
      if (isSubscriptionsTab) {
        await ref.read(publishersSubscriptionsLiveProvider.notifier).refresh();
      }
      if (!usePostList) {
        await ref.read(activityListProvider.notifier).refresh();
      }
    }

    // The morph is driven off the scroll offset itself, on a 0..1 ramp, so it
    // interpolates with the drag instead of snapping at the first pixel. A
    // feed that is still at its origin is flush; once it has moved a full
    // header height it is the fully inset pill. Because the bar is
    // `floating` + `snap`, scrolling back brings it in again at the same
    // offset, so the inverse plays as the feed returns to the top.
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics.axis != Axis.vertical) return false;
        final ramp = (metrics.pixels / _kHeaderMorphDistance).clamp(0.0, 1.0);
        if (morph.value != ramp) morph.value = ramp;
        return false;
      },
      child: ExtendedRefreshIndicator(
        leadingEdgeInset: sliverRefreshInset,
        hoverRefreshLabel: 'refresh'.tr(),
        onRefresh: refreshTimeline,
        child: CustomScrollView(
          slivers: [
            _buildExploreSliverAppBar(
              context: context,
              morph: morph,
              currentFilter: currentFilter,
              hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
              handleFilterChange: handleFilterChange,
            ),
          const SliverGap(kExploreCardGap),
          // The Subscriptions tab keeps the publisher quick pick; Explore and
          // Friends show the friend presence strip in the same floating slot.
          if (isSubscriptionsTab)
            SliverSubscribedPublishersStrip(
              selectedPublisherNames: selectedPublisherNames.value,
              onSelectedPublishersChanged: onPublishersChanged,
            )
          else
            const SliverFriendPresenceStrip(),
          const SliverGap(kExploreCardGap),
          // Explore only, and only once the carousel has something to show.
          if (hasFeaturedPosts) ...[
            SliverPadding(
              padding: gutter,
              sliver: SliverToBoxAdapter(
                child: ExploreCard(
                  child: const PostFeaturedList(flush: true),
                ),
              ),
            ),
            const SliverGap(kExploreCardGap),
          ],
          if (usePostList)
            SliverPadding(
              padding: gutter,
              sliver: _buildPostList(
                context,
                ref,
                selectedPublisherNames.value,
                exploreSettings.selectedCategoryIds,
                exploreSettings.selectedTagIds,
                onOpenPost: onOpenPost,
              ),
            )
          else if (isListInitialLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ConfuseSpinner(
                  speed: 7,
                  size: 72,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                ),
              ),
            )
          else
            SliverPadding(
              padding: gutter,
              sliver: _buildActivityList(
                context,
                ref,
                onOpenPost: onOpenPost,
              ),
            ),
            // The tab shell floats the NavigationBar over the page, so reserve
            // its height or the last card stays underneath the bar.
            SliverGap(MediaQuery.paddingOf(context).bottom + kExploreCardGap),
          ],
        ),
      ),
    );
  }
}

/// Reading measure of the wide explore timeline. A single column spanning the
/// whole window reads as a stretched feed, so the pane is centred instead.
const _kWideTimelineMaxWidth = 720.0;

class _DiscoveryActivityItem extends ConsumerWidget {
  final Map<String, dynamic> data;
  final String eventType;
  final String resourceIdentifier;

  const _DiscoveryActivityItem({
    required this.data,
    required this.eventType,
    required this.resourceIdentifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final currentUserId = userInfo.value?.id;
    final isAdmin = userInfo.value?.isSuperuser == true;

    final items =
        (data['items'] as List?)?.whereType<Map>().toList() ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();

    final type = _resolveDiscoveryType(
      eventType: eventType,
      resourceIdentifier: resourceIdentifier,
      data: data,
      items: items,
    );
    final title = _resolveDiscoveryTitle(type, data);
    final isSingleSuggestion = type != 'post' && items.length == 1;

    var flexWeights = isWideScreen(context) ? <int>[3, 2, 1] : <int>[4, 1];
    if (type == 'post') flexWeights = <int>[3, 2];

    final height = switch (type) {
      'post' => 280.0,
      _ when isSingleSuggestion => null,
      _ => 180.0,
    };

    final contentWidget = switch (type) {
      'post' => SuperListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Gap(SolSpace.md),
        padding: const EdgeInsets.symmetric(vertical: SolSpace.xxs),
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(items[index]);
          final itemData = _extractDiscoveryItemData(item);
          final post = SnPost.fromJson(itemData);
          final rank = item['rank'] as String?;

          return Container(
            width: 320,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.all(
                Radius.circular(SolRadius.md),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: PostActionableItem(
                      item: post,
                      isCompact: true,
                      borderRadius: SolRadius.md,
                      padding: const EdgeInsets.fromLTRB(
                        SolSpace.lg,
                        SolSpace.md + 2,
                        SolSpace.lg,
                        SolSpace.md,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      if (rank == 'highest')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(SolRadius.xs),
                          ),
                          child: Text(
                            'discoveryTopPick'.tr(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                      if (rank == 'lowest')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(SolRadius.xs),
                          ),
                          child: Text(
                            'discoveryNotRecommended'.tr(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(SolRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SolSpace.xs,
                      vertical: SolSpace.xxs,
                    ),
                    child: DiscoveryFeedbackWidget(
                      kind: 'post',
                      referenceId: post.id,
                      showNotInterested: false,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      _ when isSingleSuggestion => () {
        final item = Map<String, dynamic>.from(items.single);
        final itemData = _extractDiscoveryItemData(item);
        final reasons =
            (item['reasons'] as List?)?.whereType<String>().toList() ??
            const <String>[];
        if (reasons.isEmpty) reasons.add('discoverySuggestionReason'.tr());
        final rank = item['score'] is num
            ? (item['score'] as num).toDouble()
            : null;

        final itemOwnerId = switch (type) {
          'post' => (itemData['author'] as Map?)?['id'] as String?,
          'account' => itemData['id'] as String?,
          'publisher' => itemData['id'] as String?,
          'realm' => itemData['id'] as String?,
          _ => null,
        };
        final isCurrentUserItem =
            currentUserId != null && itemOwnerId == currentUserId;
        final shouldShowRank = rank != null && isAdmin && !isCurrentUserItem;

        return Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiscoveryCard(type, itemData, maxWidth: double.infinity),
            if (reasons.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Icon(Symbols.mindfulness, size: 16),
                  for (final reason in reasons.take(3))
                    Text(
                      reason,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            if (shouldShowRank)
              Row(
                spacing: 8,
                children: [
                  const Icon(Symbols.rule, size: 16),
                  Text(
                    'discoveryRank'.tr(args: ['$rank']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
          ],
        );
      }(),
      _ => CarouselView.weighted(
        flexWeights: flexWeights,
        consumeMaxWeight: false,
        enableSplash: false,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SolRadius.md)),
        ),
        itemSnapping: false,
        children: [
          for (final item in items)
            () {
              final itemMap = Map<String, dynamic>.from(item);
              final itemData = _extractDiscoveryItemData(itemMap);
              return _buildDiscoveryCard(type, itemData);
            }(),
        ],
      ),
    };

    return ExploreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                switch (type) {
                  'realm' => Symbols.public,
                  'publisher' => Symbols.account_circle,
                  'account' => Symbols.person,
                  'article' => Symbols.auto_stories,
                  'post' => Symbols.shuffle,
                  _ => Symbols.explore,
                },
                size: 19,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const Gap(8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ).padding(top: 1),
            ],
          ).padding(
            horizontal: SolSpace.lg,
            top: SolSpace.md + 2,
            bottom: SolSpace.sm,
          ),
          SizedBox(
            height: height,
            child: contentWidget,
          ).padding(
            left: SolSpace.md,
            right: SolSpace.md,
            bottom: SolSpace.md,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard(
    String type,
    Map<String, dynamic> itemData, {
    double? maxWidth,
  }) {
    return switch (type) {
      'realm' => RealmDiscoveryCard(
        realm: SnRealm.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),
      'publisher' => PublisherDiscoveryCard(
        publisher: SnPublisher.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),
      'account' => AccountDiscoveryCard(
        account: SnAccount.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),

      _ => const SizedBox.shrink(),
    };
  }
}

String _resolveDiscoveryType({
  required String eventType,
  required String resourceIdentifier,
  required Map<String, dynamic> data,
  required List<Map> items,
}) {
  if (eventType == 'discovery.v2') {
    final kind = data['kind'];
    if (kind is String && kind.isNotEmpty) return kind;

    final parts = resourceIdentifier.split(':');
    if (parts.length > 1 && parts.last.isNotEmpty) return parts.last;
  }

  final itemType = items.firstOrNull?['type'];
  if (itemType is String && itemType.isNotEmpty) return itemType;

  final fallbackKind = data['kind'];
  if (fallbackKind is String && fallbackKind.isNotEmpty) return fallbackKind;

  return 'unknown';
}

String _resolveDiscoveryTitle(String type, Map<String, dynamic> data) {
  return (switch (type) {
    'realm' => 'suggestedRealm',
    'publisher' => 'suggestedPublisher',
    'account' => 'suggestedPeople',
    'article' => 'discoverWebArticles',
    'post' => 'discoverShuffledPost',
    _ => 'unknown',
  }).tr();
}

Map<String, dynamic> _extractDiscoveryItemData(Map<String, dynamic> item) {
  final raw = item['data'];
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return item;
}

class AccountDiscoveryCard extends ConsumerWidget {
  final SnAccount account;
  final double? maxWidth;
  final bool showFeedback;

  const AccountDiscoveryCard({
    super.key,
    required this.account,
    this.maxWidth,
    this.showFeedback = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = account.profile.background;
    final imageWidget = background != null
        ? CloudImageWidget(file: background, fit: BoxFit.cover, imageOnly: true)
        : ColoredBox(color: Theme.of(context).colorScheme.secondaryContainer);

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(SolRadius.md),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.router.push(AccountProfileRoute(name: account.name));
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ProfilePictureWidget(
                          file: account.profile.picture,
                          fallbackName: account.nick,
                          radius: 12,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        account.nick,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${account.name}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (showFeedback)
                Positioned(
                  top: 8,
                  right: 8,
                  child: DiscoveryFeedbackWidget(
                    kind: 'account',
                    referenceId: account.id,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: card,
    );
  }
}

class _ActivityListView extends HookConsumerWidget {
  final List<SnTimelineEvent> data;
  final Widget footer;
  final void Function(SnPost)? onOpenPost;

  const _ActivityListView({
    required this.data,
    required this.footer,
    this.onOpenPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(activityListProvider.notifier);

    return SuperSliverList.separated(
      itemCount: data.length + 1,
      // Cards own their boundary; the feed separates them with one gap instead
      // of a horizontal rule.
      separatorBuilder: (_, _) => const Gap(kExploreCardGap),
      itemBuilder: (context, index) {
        if (index == data.length) {
          return footer;
        }

        final item = data[index];
        if (item.data == null) {
          return const SizedBox.shrink();
        }
        Widget itemWidget;

        switch (item.type) {
          case 'posts.new':
          case 'posts.new.replies':
            final postData = item.data!;
            final postJson = postData is Map<String, dynamic>
                ? postData
                : (postData as Map).cast<String, dynamic>();
            final post = SnPost.fromJson(postJson);

            itemWidget = ExploreCard(
              child: PostActionableItem(
                borderRadius: SolRadius.card,
                padding: const EdgeInsets.fromLTRB(
                  SolSpace.lg,
                  SolSpace.md + 2,
                  SolSpace.lg,
                  SolSpace.md,
                ),
                item: post,
                onRefresh: () {
                  notifier.refresh();
                },
                onUpdate: (updatedPost) {
                  notifier.updateOne(
                    index,
                    item.copyWith(data: updatedPost.toJson()),
                  );
                },
                onTap: onOpenPost != null ? () => onOpenPost!(post) : null,
              ),
            );
            break;
          case 'discovery':
          case 'discovery.v2':
            // Discovery sections carry their own card (they own a header plus
            // a row of suggestion cards inside it).
            itemWidget = _DiscoveryActivityItem(
              data: item.data!,
              eventType: item.type,
              resourceIdentifier: item.resourceIdentifier,
            );
            break;
          case 'presence.friend':
            final rawData = asStringKeyedMap(item.data);
            final activityJson = normalizePresenceActivityJson(
              asStringKeyedMap(rawData['activity']),
            );
            final activity = SnPresenceActivity.fromJson(activityJson);
            itemWidget = ExploreCard(
              child: FriendPresenceItem(
                activity: activity,
                rawData: rawData,
              ),
            );
            break;
          case 'status.friend':
            final statusJson = normalizeStatusJson(
              asStringKeyedMap(asStringKeyedMap(item.data)['status']),
            );
            final status = SnAccountStatus.fromJson(statusJson);
            itemWidget = ExploreCard(
              child: FriendStatusItem(
                status: status,
                createdAt: item.createdAt,
              ),
            );
            break;
          default:
            itemWidget = const SizedBox.shrink();
        }

        return itemWidget;
      },
    );
  }
}

/// Section picker for the explore header.
///
/// Shows the active section's icon and label in the bar's title slot, where
/// the brand mark used to sit. The trigger paints no surface of its own — it
/// floats directly on the bar's pill — so the only chrome is the icon, the
/// label and a dropdown caret. Selecting a section persists it through
/// [onSelected] using the same `null` / `'subscriptions'` / `'friends'`
/// vocabulary the old tab bar used.
class _ExploreSectionButton extends StatelessWidget {
  final String? filter;
  final bool hasFiltersApplied;
  final ValueChanged<String?> onSelected;

  const _ExploreSectionButton({
    required this.filter,
    required this.hasFiltersApplied,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = _sections.firstWhere(
      (section) => section.filter == filter,
      orElse: () => _sections.first,
    );

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHigh,
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: SolRadius.menuRadius),
        ),
      ),
      builder: (context, controller, child) {
        return InkWell(
          borderRadius: SolRadius.pillRadius,
          onTap: () => controller.isOpen
              ? controller.close()
              : controller.open(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SolSpace.sm,
              vertical: SolSpace.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(selected.icon, size: 20, color: colorScheme.onSurface),
                Text(
                  selected.label.tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Symbols.arrow_drop_down,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
      menuChildren: [
        for (final section in _sections)
          MenuItemButton(
            leadingIcon: Icon(section.icon, size: 20),
            trailingIcon: filter == section.filter
                ? const Icon(Symbols.check, size: 18)
                : null,
            onPressed: hasFiltersApplied
                ? null
                : () => onSelected(section.filter),
            child: Text(section.label.tr()),
          ),
      ],
    );
  }
}

class _ExploreSection {
  final String? filter;
  final String label;
  final IconData icon;

  const _ExploreSection({
    required this.filter,
    required this.label,
    required this.icon,
  });
}

const _sections = <_ExploreSection>[
  _ExploreSection(
    filter: null,
    label: 'explore',
    icon: Symbols.explore,
  ),
  _ExploreSection(
    filter: 'subscriptions',
    label: 'exploreFilterSubscriptions',
    icon: Symbols.subscriptions,
  ),
  _ExploreSection(
    filter: 'friends',
    label: 'exploreFilterFriends',
    icon: Symbols.people,
  ),
];

/// Scroll distance over which the explore header completes its morph into the
/// pill state. Tied to roughly one header height: by the time the bar has
/// scrolled out of the way, it is fully a capsule.
const _kHeaderMorphDistance = 96.0;
