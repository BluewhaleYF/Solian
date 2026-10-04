import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/discovery/widgets/friend_presence_strip.dart';
import 'package:island/discovery/widgets/friend_presence_widgets.dart';
import 'package:island/discovery/widgets/subscribed_publishers_strip.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/config.dart';

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
    // Recreating the controller on an external section change keeps the tab
    // indicator on the section the settings screen selected.
    final filterTabController = useMaterialTabController(
      initialLength: 3,
      initialIndex: _filterTabIndex(exploreSettings.filter),
      keys: [exploreSettings.filter],
    );

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

    final isWide = isWideScreen(context);

    final hasSubscriptionFiltersApplied =
        selectedPublisherNames.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;

    final userInfo = ref.watch(userInfoProvider);

    if (isWide) {
      return AppScaffold(
        isNoBackground: false,
        appBar: null,
        floatingActionButton: userInfo.value != null
            ? FloatingActionButton(
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          leading: const Icon(Symbols.post_add_rounded),
                          title: Text('postCompose').tr(),
                          onTap: () async {
                            Navigator.of(sheetContext).pop();
                            await PostComposeDialog.show(parentContext);
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          leading: const Icon(Symbols.article),
                          title: Text('articleCompose').tr(),
                          onTap: () async {
                            Navigator.of(sheetContext).pop();
                            await context.router.push(ArticleComposeRoute());
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
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
              ).padding(bottom: MediaQuery.of(context).padding.bottom)
            : null,
        body: _buildWideBody(
          context,
          ref,
          filterTabController,
          selectedPublisherNames,
          handlePublishersChanged,
          hasSubscriptionFiltersApplied,
          handleFilterChange,
          exploreSettings.filter,
        ),
      );
    }

    return AppScaffold(
      floatingActionButton: userInfo.value != null
          ? FloatingActionButton(
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: const Icon(Symbols.post_add_rounded),
                        title: Text('postCompose').tr(),
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await PostComposeDialog.show(parentContext);
                        },
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: const Icon(Symbols.article),
                        title: Text('articleCompose').tr(),
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await context.router.push(ArticleComposeRoute());
                        },
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
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
            ).padding(bottom: MediaQuery.of(context).padding.bottom)
          : null,
      body: _buildNarrowBodySliver(
        context,
        ref,
        filterTabController,
        selectedPublisherNames,
        handlePublishersChanged,
        hasSubscriptionFiltersApplied,
        handleFilterChange,
        exploreSettings.filter,
      ),
    );
  }

  SliverAppBar _buildExploreSliverAppBar({
    required BuildContext context,
    required TabController filterTabController,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
    required bool isWide,
  }) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      shape: isWide
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            )
          : null,
      flexibleSpace:
          Row(
            children: [
              IconButton(
                icon: const Icon(Symbols.category),
                color: Theme.of(context).colorScheme.onSurface,
                tooltip: 'categoriesAndTags'.tr(),
                onPressed: () => context.router.push(PostCategoriesListRoute()),
              ),
              IconButton(
                icon: const Icon(Symbols.shuffle),
                color: Theme.of(context).colorScheme.onSurface,
                tooltip: 'postShuffle'.tr(),
                onPressed: () => context.router.push(const PostShuffleRoute()),
              ),
            ],
          ).padding(
            horizontal: 12,
            bottom: 8,
            top: MediaQuery.paddingOf(context).top + 8,
          ),
      title: SvgPicture.asset(
        'assets/icons/icon-outline.svg',
        color: Theme.of(context).appBarTheme.foregroundColor,
        width: 32,
        height: 32,
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          children: [
            Expanded(
              child: IgnorePointer(
                ignoring: hasSubscriptionFiltersApplied,
                child: TabBar(
                  indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
                  controller: filterTabController,
                  dividerHeight: 0,
                  onTap: hasSubscriptionFiltersApplied
                      ? null
                      : (index) {
                          final filter = switch (index) {
                            1 => 'subscriptions',
                            2 => 'friends',
                            _ => null,
                          };
                          handleFilterChange(filter);
                        },
                  tabs: [
                    Tab(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.explore,
                            size: 18,
                            fill: filterTabController.index == 0 ? 1 : 0,
                            color: Theme.of(
                              context,
                            ).appBarTheme.foregroundColor,
                          ),
                          Flexible(
                            child: Text(
                              'explore'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.subscriptions,
                            size: 18,
                            fill: filterTabController.index == 1 ? 1 : 0,
                            color: Theme.of(
                              context,
                            ).appBarTheme.foregroundColor,
                          ),
                          Flexible(
                            child: Text(
                              'exploreFilterSubscriptions'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.people,
                            size: 18,
                            fill: filterTabController.index == 2 ? 1 : 0,
                            color: Theme.of(
                              context,
                            ).appBarTheme.foregroundColor,
                          ),
                          Flexible(
                            child: Text(
                              'exploreFilterFriends'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floating: true,
      snap: true,
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    WidgetRef ref, {
    void Function(SnPost)? onOpenPost,
  }) {
    final isWide = isWideScreen(context);

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
        isWide: isWide,
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
      itemPadding: const EdgeInsets.only(bottom: 8),
      onOpenPost: onOpenPost,
    );
  }

  Widget _buildNarrowBodySliver(
    BuildContext context,
    WidgetRef ref,
    TabController filterTabController,
    ValueNotifier<List<String>> selectedPublishers,
    ValueChanged<List<String>> onPublishersChanged,
    bool hasSubscriptionFiltersApplied,
    void Function(String?) handleFilterChange,
    String? currentFilter,
  ) {
    final exploreSettings = ref.watch(appSettingsProvider).exploreSettings;
    final sliverRefreshInset =
        MediaQuery.paddingOf(context).top + kToolbarHeight + 48;
    final usePostList =
        selectedPublishers.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;
    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    final notifier = ref.watch(activityListProvider.notifier);

    return ExtendedRefreshIndicator(
      leadingEdgeInset: sliverRefreshInset,
      hoverRefreshLabel: 'refresh'.tr(),
      onRefresh: () async {
        await ref.read(publishersSubscriptionsLiveProvider.notifier).refresh();
        if (!usePostList) {
          await notifier.refresh();
        }
      },
      child: CustomScrollView(
        slivers: [
          _buildExploreSliverAppBar(
            context: context,
            filterTabController: filterTabController,
            hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
            handleFilterChange: handleFilterChange,
            isWide: false,
          ),
          SliverToBoxAdapter(child: const Divider(height: 1)),
          // The Subscriptions tab keeps the publisher quick pick; Explore and
          // Friends show the friend presence strip in the same slot.
          if (currentFilter == 'subscriptions')
            SliverSubscribedPublishersStrip(
              selectedPublisherNames: selectedPublishers.value,
              onSelectedPublishersChanged: onPublishersChanged,
            )
          else
            const SliverFriendPresenceStrip(),
          if (usePostList) ...[
            _buildPostList(
              context,
              ref,
              selectedPublishers.value,
              exploreSettings.selectedCategoryIds,
              exploreSettings.selectedTagIds,
            ),
          ] else if (isListInitialLoading)
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
            _buildActivityList(context, ref),
          // The tab shell floats the NavigationBar over the page, so reserve
          // its height or the last row stays underneath the bar.
          SliverGap(MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }

  Widget _buildWideBody(
    BuildContext context,
    WidgetRef ref,
    TabController filterTabController,
    ValueNotifier<List<String>> selectedPublishers,
    ValueChanged<List<String>> onPublishersChanged,
    bool hasSubscriptionFiltersApplied,
    void Function(String?) handleFilterChange,
    String? currentFilter,
  ) {
    final exploreSettings = ref.watch(appSettingsProvider).exploreSettings;
    final sliverRefreshInset =
        MediaQuery.paddingOf(context).top + kToolbarHeight + 48;
    final usePostList =
        selectedPublishers.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;
    final notifier = usePostList
        ? null
        : ref.watch(activityListProvider.notifier);
    final isSubscriptionsTab = currentFilter == 'subscriptions';
    final isExploreTab = currentFilter == null;
    final hasFeaturedPosts =
        ref.watch(featuredPostsProvider).value?.isNotEmpty == true;
    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    // Short posts read fine in the attention modal, so the wide timeline opens
    // them there; anything that needs room (media, chains, a long body) keeps
    // the full detail page.
    void openPost(SnPost post) {
      if (postFitsAttentionModal(post)) {
        showPostDetailAttentionModal(post.id);
        return;
      }
      context.router.push(PostDetailRoute(id: post.id));
    }

    Future<void> refreshTimeline() async {
      await ref.read(publishersSubscriptionsLiveProvider.notifier).refresh();
      if (notifier != null) await notifier.refresh();
    }

    final timelinePane = Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ExtendedRefreshIndicator(
        leadingEdgeInset: sliverRefreshInset,
        hoverRefreshLabel: 'refresh'.tr(),
        onRefresh: refreshTimeline,
        child: CustomScrollView(
          slivers: [
            _buildExploreSliverAppBar(
              context: context,
              filterTabController: filterTabController,
              hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
              handleFilterChange: handleFilterChange,
              isWide: true,
            ),
            SliverToBoxAdapter(child: const Divider(height: 1)),
            // The quick pick lives under the section app bar (same slot as the
            // narrow layout) instead of the right sidebar.
            if (isSubscriptionsTab)
              SliverSubscribedPublishersStrip(
                selectedPublisherNames: selectedPublishers.value,
                onSelectedPublishersChanged: onPublishersChanged,
              )
            else
              const SliverFriendPresenceStrip(),
            // Explore only, and only once the carousel has something to show:
            // the card would otherwise draw an empty header band above the
            // feed.
            if (isExploreTab && hasFeaturedPosts)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverToBoxAdapter(
                  child: PostFeaturedList(flush: true),
                ),
              ),
            if (usePostList)
              _buildPostList(
                context,
                ref,
                selectedPublishers.value,
                exploreSettings.selectedCategoryIds,
                exploreSettings.selectedTagIds,
                onOpenPost: openPost,
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
              _buildActivityList(context, ref, onOpenPost: openPost),
          ],
        ),
      ),
    );

    // One centered column: without a right sidebar the timeline stretches
    // across the whole window, so it keeps the comfortable measure the wide
    // layout used before the sidebar existed.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kWideTimelineMaxWidth),
        child: SizedBox.expand(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: timelinePane,
          ),
        ),
      ),
    );
  }
}





/// Position of a persisted section in the explore filter tabs:
/// Explore (0), Subscriptions (1), Friends (2).
int _filterTabIndex(String? filter) => switch (filter) {
  'subscriptions' => 1,
  'friends' => 2,
  _ => 0,
};

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
        separatorBuilder: (context, index) => const Gap(12),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(items[index]);
          final itemData = _extractDiscoveryItemData(item);
          final post = SnPost.fromJson(itemData);
          final rank = item['rank'] as String?;

          return Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1 / MediaQuery.of(context).devicePixelRatio,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SingleChildScrollView(
                      child: PostActionableItem(item: post, isCompact: true),
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
                            borderRadius: BorderRadius.circular(4),
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
                            borderRadius: BorderRadius.circular(4),
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
                      ).colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
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
              ),
            if (shouldShowRank)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
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
              ),
          ],
        );
      }(),
      _ => CarouselView.weighted(
        flexWeights: flexWeights,
        consumeMaxWeight: false,
        enableSplash: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
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

    return Container(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(switch (type) {
                'realm' => Symbols.public,
                'publisher' => Symbols.account_circle,
                'account' => Symbols.person,
                'article' => Symbols.auto_stories,
                'post' => Symbols.shuffle,
                _ => Symbols.explore,
              }, size: 19),
              const Gap(8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ).padding(top: 1),
            ],
          ).padding(horizontal: 20, top: 8, bottom: 4),
          SizedBox(height: height, child: contentWidget).padding(bottom: 8),
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.zero,
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
  final bool isWide;
  final Widget footer;
  final void Function(SnPost)? onOpenPost;

  const _ActivityListView({
    required this.data,
    required this.isWide,
    required this.footer,
    this.onOpenPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(activityListProvider.notifier);

    return SuperSliverList.separated(
      itemCount: data.length + 1,
      separatorBuilder: (_, _) => Divider(
        height: 1 / MediaQuery.devicePixelRatioOf(context),
        thickness: 1 / MediaQuery.devicePixelRatioOf(context),
      ),
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

            itemWidget = PostActionableItem(
              borderRadius: 8,
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
            );
            break;
          case 'discovery':
          case 'discovery.v2':
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
            itemWidget = FriendPresenceItem(
              activity: activity,
              rawData: rawData,
            );
            break;
          case 'status.friend':
            final statusJson = normalizeStatusJson(
              asStringKeyedMap(asStringKeyedMap(item.data)['status']),
            );
            final status = SnAccountStatus.fromJson(statusJson);
            itemWidget = FriendStatusItem(
              status: status,
              createdAt: item.createdAt,
            );
            break;
          default:
            itemWidget = const Placeholder();
        }

        return itemWidget;
      },
    );
  }
}
