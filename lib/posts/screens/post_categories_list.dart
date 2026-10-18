import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/posts/pods/post_categories.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class PostCategoriesListScreen extends HookConsumerWidget {
  const PostCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isWide = isWideScreen(context);
    // Narrow (portrait) bars follow the app's themed top bars and use the theme
    // colour; the wide split view keeps a plain surface bar, matching the
    // creator hub.
    final barColor = isWide
        ? theme.colorScheme.surface
        : theme.colorScheme.primary;
    final barForeground = isWide
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        isNoBackground: false,
        appBar: AppBar(
          backgroundColor: barColor,
          foregroundColor: barForeground,
          // The theme pins the title to onSurface, so re-tint it to match.
          titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
            color: barForeground,
          ),
          title: const Text('categoriesAndTags').tr(),
          bottom: TabBar(
            // Keep the default indicator on the surface bar; on the themed bar
            // it must switch to the on-colour to stay visible.
            indicatorColor: isWide ? null : theme.colorScheme.onPrimary,
            tabs: [
              Tab(
                child: Text(
                  'categories'.tr(),
                  style: TextStyle(color: barForeground),
                ),
              ),
              Tab(
                child: Text(
                  'tags'.tr(),
                  style: TextStyle(color: barForeground),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_CategoriesTab(), _TagsTab()]),
      ),
    );
  }
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList(
      provider: postCategoriesProvider,
      notifier: postCategoriesProvider.notifier,
      footerSkeletonMaxWidth: 640,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index, category) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListTile(
              leading: const Icon(Symbols.category),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              trailing: const Icon(Symbols.chevron_right),
              title: Text(category.categoryTranslationKey).tr(),
              subtitle: Text('postCount'.plural(category.usage)),
              onTap: () {
                context.router.push(
                  PostCategoryDetailRoute(
                    slug: category.slug,
                    isCategory: true,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TagsTab extends ConsumerWidget {
  const _TagsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList(
      provider: postTagsProvider,
      notifier: postTagsProvider.notifier,
      footerSkeletonMaxWidth: 640,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index, tag) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListTile(
              title: Text(tag.name ?? '#${tag.slug}'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(tag.isProtected ? Symbols.lock : Symbols.label),
              trailing: const Icon(Symbols.chevron_right),
              subtitle: Text('postCount'.plural(tag.usage)),
              onTap: () {
                context.router.push(
                  PostCategoryDetailRoute(slug: tag.slug, isCategory: false),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
