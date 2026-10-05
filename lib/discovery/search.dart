import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/search_navigation.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_list.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const kSearchPostListId = 'search';

/// Wide-screen posts search: the results card and the side pane both start this
/// far below the tab bar, so their top edges line up across the gutter.
const _kWidePaneInset = 12.0;

enum SearchScope { local, remote }

@RoutePage()
class UniversalSearchScreen extends HookConsumerWidget {
  const UniversalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(searchTabProvider);
    final tabController = useMaterialTabController(
      initialLength: SearchTab.values.length,
      initialIndex: selectedTab.index,
    );
    final searchQuery = useState<String>('');
    final debouncedSearchQuery = useState<String>('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);
    // Filter panel visibility, driven solely by the app bar action so it can
    // stay in sync across the sections that expose filters.
    final filtersVisible = useState(false);
    const debounce = Duration(milliseconds: 450);

    // A query handed over by an outside entry point (the command palette) lands
    // in the field and runs straight away.
    final querySeed = ref.watch(searchQuerySeedProvider);
    useEffect(() {
      if (querySeed == null || querySeed.trim().isEmpty) return null;
      searchController.text = querySeed;
      searchQuery.value = querySeed;
      debouncedSearchQuery.value = querySeed;
      // Consuming the seed writes to a provider, which is not allowed while the
      // tree is building — the hook effect runs mid-build, so defer it.
      final seeds = ref.read(searchQuerySeedProvider.notifier);
      WidgetsBinding.instance.addPostFrameCallback((_) => seeds.clear());
      return null;
    }, [querySeed]);

    useEffect(() {
      if (searchQuery.value.isEmpty) {
        debounceTimer.value?.cancel();
        debouncedSearchQuery.value = '';
        return null;
      }

      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(debounce, () {
        debouncedSearchQuery.value = searchQuery.value;
      });

      return () {
        debounceTimer.value?.cancel();
      };
    }, [searchQuery.value]);

    // Follow section requests from outside the page (chat list, realms...).
    useEffect(() {
      if (tabController.index != selectedTab.index) {
        tabController.animateTo(selectedTab.index);
      }
      return null;
    }, [selectedTab]);

    // Publish section switches so they survive leaving the tab.
    useEffect(() {
      void onTabChanged() {
        final tab = SearchTab.values[tabController.index];
        if (ref.read(searchTabProvider) != tab) {
          ref.read(searchTabProvider.notifier).select(tab);
        }
      }

      tabController.addListener(onTabChanged);
      return () => tabController.removeListener(onTabChanged);
    }, [tabController]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.menu),
          onPressed: () {
            rootScaffoldKey.currentState?.openDrawer();
          },
        ),
        title: SearchBar(
          controller: searchController,
          focusNode: searchFocusNode,
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'search'.tr(),
          hintStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          onTapOutside: (_) => searchFocusNode.unfocus(),
          trailing: [
            if (searchController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  debounceTimer.value?.cancel();
                  searchController.clear();
                  searchQuery.value = '';
                  debouncedSearchQuery.value = '';
                  searchFocusNode.unfocus();
                },
                icon: Icon(
                  Symbols.close,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
          ],
          onChanged: (value) {
            searchQuery.value = value;
          },
          onSubmitted: (value) {
            debounceTimer.value?.cancel();
            searchQuery.value = value;
            debouncedSearchQuery.value = value;
            searchFocusNode.unfocus();
          },
          leading: Icon(
            Symbols.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: filtersVisible,
            builder: (context, visible, _) {
              final supported =
                  selectedTab == SearchTab.posts ||
                  selectedTab == SearchTab.messages;
              return IconButton(
                onPressed: supported
                    ? () => filtersVisible.value = !filtersVisible.value
                    : null,
                icon: Icon(
                  visible ? Symbols.filter_list_off : Symbols.filter_list,
                ),
                tooltip: visible ? 'hideFilters'.tr() : 'showFilters'.tr(),
              );
            },
          ),
          const Gap(8),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'posts'.tr()),
              Tab(text: 'accounts'.tr()),
              Tab(text: 'realms'.tr()),
              Tab(text: 'messages'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _PostsSearchTab(
                  searchQuery: debouncedSearchQuery,
                  filtersVisible: filtersVisible,
                ),
                _AccountSearchTab(searchQuery: debouncedSearchQuery),
                _RealmsSearchTab(searchQuery: debouncedSearchQuery),
                ChatMessageSearchView(
                  searchQuery: debouncedSearchQuery,
                  filtersVisible: filtersVisible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RealmsSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  const _RealmsSearchTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverGap(8),
            SliverRealmList(
              query: searchQuery.value,
              key: ValueKey(searchQuery.value),
            ),
            SliverGap(MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ],
    );
  }
}

class _PostsSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;
  final ValueNotifier<bool> filtersVisible;

  const _PostsSearchTab({
    required this.searchQuery,
    required this.filtersVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFilters = useValueListenable(filtersVisible);

    final categoryTabController = useMaterialTabController(initialLength: 3);
    final queryState = useState(const PostListQuery(includeReplies: false));

    final noti = ref.read(
      postListProvider(PostListQueryConfig(id: kSearchPostListId)).notifier,
    );

    void onSearchChanged(String query) {
      queryState.value = queryState.value.copyWith(queryTerm: query);
      noti.applyFilter(queryState.value);
    }

    void toggleFilterDisplay() {
      filtersVisible.value = !filtersVisible.value;
    }

    Widget buildFilterPanel() {
      return PostFilterWidget(
        categoryTabController: categoryTabController,
        initialQuery: queryState.value,
        onQueryChanged: (newQuery) {
          queryState.value = newQuery;
          noti.applyFilter(newQuery);
        },
        hideSearch: true,
      );
    }

    // Listen to debounced search query changes and update the list.
    useEffect(() {
      Future.microtask(() => onSearchChanged(searchQuery.value));
      return null;
    }, [searchQuery.value]);

    return Consumer(
      builder: (context, ref, child) {
        final searchState = ref.watch(
          postListProvider(PostListQueryConfig(id: kSearchPostListId)),
        );

        return isWideScreen(context)
            ? Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: Card(
                      margin: const EdgeInsets.fromLTRB(
                        _kWidePaneInset,
                        _kWidePaneInset,
                        0,
                        0,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ExtendedRefreshIndicator(
                        onRefresh: noti.refresh,
                        child: CustomScrollView(
                          slivers: [
                            const SliverGap(4),
                            PaginationList(
                              provider: postListProvider(
                                PostListQueryConfig(id: kSearchPostListId),
                              ),
                              notifier: postListProvider(
                                PostListQueryConfig(id: kSearchPostListId),
                              ).notifier,
                              isSliver: true,
                              isRefreshable: false,
                              seperatorBuilder: (context, index, post) =>
                                  const Divider(height: 1),
                              footerSkeletonChild: const PostItemSkeleton(
                                maxWidth: double.infinity,
                                showCard: false,
                              ),
                              itemBuilder: (context, index, post) {
                                return PostActionableItem(
                                  item: post,
                                  borderRadius: 8,
                                );
                              },
                            ),
                            if (searchState.value?.items.isEmpty == true &&
                                searchQuery.value.isNotEmpty &&
                                !searchState.isLoading)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: EmptyState(
                                  key: const Key('postSearchEmpty'),
                                  icon: Symbols.search_off,
                                  title: 'noResultsFound'.tr(),
                                  description: 'tryDifferentKeywords'.tr(),
                                ),
                              ),
                            SliverGap(
                              MediaQuery.of(context).padding.bottom + 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(_kWidePaneInset),
                            Card(
                              margin: EdgeInsets.only(left: 16, right: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.tune,
                                    ).padding(horizontal: 8),
                                    Expanded(
                                      child: Text(
                                        'filters'.tr(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Symbols.filter_alt,
                                        fill: showFilters ? 1 : null,
                                      ),
                                      onPressed: toggleFilterDisplay,
                                      tooltip: 'toggleFilters'.tr(),
                                    ),
                                    const Gap(4),
                                  ],
                                ),
                              ),
                            ),
                            if (showFilters) ...[
                              const Gap(8),
                              buildFilterPanel().padding(horizontal: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    offset: showFilters ? Offset.zero : const Offset(0, -0.08),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: showFilters
                            ? Padding(
                                key: const ValueKey('filters-visible'),
                                padding: const EdgeInsets.fromLTRB(
                                  8,
                                  12,
                                  8,
                                  12,
                                ),
                                child: buildFilterPanel().padding(
                                  horizontal: 8,
                                ),
                              )
                            : const SizedBox(key: ValueKey('filters-hidden')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PaginationList(
                      provider: postListProvider(
                        PostListQueryConfig(id: kSearchPostListId),
                      ),
                      notifier: postListProvider(
                        PostListQueryConfig(id: kSearchPostListId),
                      ).notifier,
                      // Bottom-only padding: null would also pull the status
                      // bar inset in as a top gap, and the tab shell's
                      // extendBody leaves the last row under the bottom bar
                      // without the hint.
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom + 16,
                      ),
                      seperatorBuilder: (context, index, post) =>
                          const Divider(height: 1),
                      footerSkeletonChild: const PostItemSkeleton(
                        maxWidth: double.infinity,
                        showCard: false,
                      ),
                      itemBuilder: (context, index, post) {
                        return PostActionableItem(item: post, borderRadius: 8);
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }
}

class _AccountSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  const _AccountSearchTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountResults = useState<List<SnAccount>>([]);
    final publisherResults = useState<List<SnPublisher>>([]);
    final fediverseResults = useState<List<SnPublisher>>([]);
    final isSearching = useState(false);
    final searchScope = useState(SearchScope.local);
    final requestToken = useRef(0);

    Future<void> performSearch(String query) async {
      final normalizedQuery = query.trim();
      final token = ++requestToken.value;

      if (normalizedQuery.isEmpty) {
        accountResults.value = [];
        publisherResults.value = [];
        fediverseResults.value = [];
        isSearching.value = false;
        return;
      }

      isSearching.value = true;
      try {
        final apiClient = ref.read(apiClientProvider);
        final accountFuture = ref.read(
          searchAccountsProvider(query: normalizedQuery).future,
        );
        final publisherFuture = apiClient.get(
          '/sphere/publishers/search',
          queryParameters: {'query': normalizedQuery},
        );

        final futures = <Future>[accountFuture, publisherFuture];

        if (searchScope.value == SearchScope.remote) {
          futures.add(
            apiClient.get(
              '/sphere/fediverse/actors/search',
              queryParameters: {'query': normalizedQuery, 'limit': 20},
            ),
          );
        }

        final results = await Future.wait(futures);

        if (token == requestToken.value) {
          accountResults.value = results[0] as List<SnAccount>;
          publisherResults.value = (results[1].data as List)
              .map((json) => SnPublisher.fromJson(json))
              .toList();

          if (searchScope.value == SearchScope.remote && results.length > 2) {
            fediverseResults.value = (results[2].data as List)
                .map((json) => SnPublisher.fromJson(json))
                .toList();
          } else {
            fediverseResults.value = [];
          }
        }
      } catch (err) {
        if (token == requestToken.value) {
          showErrorAlert(err);
        }
      } finally {
        if (token == requestToken.value) {
          isSearching.value = false;
        }
      }
    }

    // Listen to debounced search query changes and update the list.
    useEffect(() {
      performSearch(searchQuery.value);
      return null;
    }, [searchQuery.value, searchScope.value]);

    // Combine and display results - accounts first, then publishers, then fediverse.
    final allResults = [
      ...accountResults.value.map(
        (account) => {'type': 'account', 'data': account},
      ),
      ...publisherResults.value.map(
        (publisher) => {'type': 'publisher', 'data': publisher},
      ),
      ...fediverseResults.value.map(
        (actor) => {'type': 'fediverse', 'data': actor},
      ),
    ];

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SegmentedButton<SearchScope>(
                segments: [
                  ButtonSegment(
                    value: SearchScope.local,
                    icon: const Icon(Symbols.home),
                    label: Text('localOnly'.tr()),
                  ),
                  ButtonSegment(
                    value: SearchScope.remote,
                    icon: const Icon(Symbols.public),
                    label: Text('includeFediverse'.tr()),
                  ),
                ],
                selected: {searchScope.value},
                onSelectionChanged: (selection) {
                  searchScope.value = selection.first;
                },
                showSelectedIcon: false,
              ),
            ).width(double.infinity),
          ),
        ),
        Expanded(
          child: isSearching.value
              ? const Center(child: CircularProgressIndicator())
              : allResults.isEmpty
              ? EmptyState(
                  key: const Key('accountSearchEmpty'),
                  icon: searchQuery.value.isEmpty
                      ? Symbols.search
                      : Symbols.search_off,
                  title: searchQuery.value.isEmpty
                      ? 'searchUsersEmpty'.tr()
                      : 'searchUsersNoResults'.tr(),
                  description: searchQuery.value.isEmpty
                      ? 'searchAccountsHint'.tr()
                      : 'tryDifferentKeywords'.tr(),
                )
              : ExtendedRefreshIndicator(
                  onRefresh: () => performSearch(searchQuery.value),
                  child: ListView.separated(
                    // Keep the last row clear of the tab shell's bottom bar.
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8 + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: allResults.length,
                    separatorBuilder: (context, index) => const Gap(8),
                    itemBuilder: (context, index) {
                      final result = allResults[index];
                      if (result['type'] == 'publisher') {
                        final publisher = result['data'] as SnPublisher;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
                              onTap: () {
                                context.router.push(
                                  PublisherProfileRoute(name: publisher.name),
                                );
                              },
                              leading: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ProfilePictureWidget(
                                    file: publisher.picture,
                                    fallbackName: publisher.nick,
                                    borderRadius: publisher.type == 0
                                        ? null
                                        : 6,
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: publisher.account != null
                                          ? ProfilePictureWidget(
                                              file: publisher
                                                  .account
                                                  ?.profile
                                                  .picture,
                                              fallbackName:
                                                  publisher.account?.nick,
                                            )
                                          : Icon(
                                              publisher.type == 0
                                                  ? Symbols.person
                                                  : Symbols.corporate_fare,
                                              size: 10,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                publisher.nick.isNotEmpty
                                    ? publisher.nick
                                    : publisher.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                publisher.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: const Icon(
                                Symbols.chevron_right,
                              ).padding(right: 12),
                            ),
                          ),
                        );
                      } else if (result['type'] == 'fediverse') {
                        final actor = result['data'] as SnPublisher;
                        // Remote actors summarise themselves in HTML; the row
                        // shows the plain-text excerpt.
                        final actorBio = actor.bio.htmlToPlainText();
                        final actorAvatar = actor.picture?.storageUrl;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
                              onTap: () {
                                context.router.push(
                                  FediverseActorProfileRoute(
                                    id: actor.id,
                                    fullHandle: actor.activitypub?.fullHandle,
                                  ),
                                );
                              },
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: actorAvatar != null
                                        ? CachedNetworkImageProvider(
                                            actorAvatar,
                                          )
                                        : null,
                                    radius: 24,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                    child: actorAvatar == null
                                        ? Icon(Symbols.person)
                                        : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Symbols.public,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      actor.effectiveName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      actor.domain ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: actorBio.isNotEmpty
                                  ? Text(
                                      actorBio,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    )
                                  : null,
                              trailing: const Icon(
                                Symbols.chevron_right,
                              ).padding(right: 12),
                            ),
                          ),
                        );
                      } else {
                        final account = result['data'] as SnAccount;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
                              onTap: () {
                                context.router.push(
                                  AccountProfileRoute(name: account.name),
                                );
                              },
                              leading: Stack(
                                children: [
                                  ProfilePictureWidget(
                                    file: account.profile.picture,
                                    fallbackName: account.nick,
                                  ),
                                ],
                              ),
                              title: AccountName(
                                account: account,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                account.profile.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: const Icon(
                                Symbols.chevron_right,
                              ).padding(right: 12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
