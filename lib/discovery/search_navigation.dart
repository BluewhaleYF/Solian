import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';

/// Sections of the universal search page.
enum SearchTab { posts, accounts, realms, messages }

/// Section the universal search page focuses.
///
/// Set before requesting the search tab (see [openUniversalSearch]) and kept
/// in sync while the user switches sections.
final searchTabProvider = NotifierProvider<SearchTabNotifier, SearchTab>(
  SearchTabNotifier.new,
);

class SearchTabNotifier extends Notifier<SearchTab> {
  @override
  SearchTab build() => SearchTab.posts;

  void select(SearchTab tab) => state = tab;
}

/// One-shot query handed to the universal search page by an outside entry
/// point (the command palette) so the search runs on arrival. The page applies
/// it to its field and clears it.
final searchQuerySeedProvider =
    NotifierProvider<SearchQuerySeedNotifier, String?>(
      SearchQuerySeedNotifier.new,
    );

class SearchQuerySeedNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void seed(String query) => state = query;

  void clear() => state = null;
}

/// Switches the tab shell to the universal search tab, optionally focusing
/// [tab].
void openUniversalSearch(BuildContext context, {SearchTab? tab}) {
  if (tab != null) {
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(searchTabProvider.notifier).select(tab);
  }

  final tabsRouter = AutoTabsRouter.of(context);
  // Index into the tab shell's own page stack: [TabsRouter.stackData] follows
  // the declaration order in `TabsScreen`, which is what `setActiveIndex`
  // expects, unlike the route-collection order in `route.dart`.
  final index = tabsRouter.stackData.indexWhere(
    (data) => data.name == UniversalSearchRoute.name,
  );
  if (index >= 0 && tabsRouter.activeIndex != index) {
    tabsRouter.setActiveIndex(index);
  }
}
