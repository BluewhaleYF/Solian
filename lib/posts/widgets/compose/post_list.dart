import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_creator.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Defines which post item widget to use in the list
enum PostItemType {
  /// Regular post item with user information
  regular,

  /// Creator view with analytics and metadata
  creator,
}

class SliverPostList extends HookConsumerWidget {
  final PostListQuery? query;
  final PostItemType itemType;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? itemPadding;
  final bool isOpenable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  final double? maxWidth;
  final String? queryKey;
  final void Function(String)? onPostTap;

  /// Wraps each built row, letting a host give it the page's own card chrome
  /// (the explore feed floats every post on its own card) without changing the
  /// widget used for the row itself.
  final Widget Function(BuildContext, int, SnPost, Widget)? itemWrapper;

  /// Separator between rows. Defaults to a hairline divider; hosts that render
  /// cards pass a gap instead so no line touches a card edge.
  final Widget Function(BuildContext, int, SnPost)? separatorBuilder;

  /// Receives the tapped post itself, so a host can pick how to open it (e.g.
  /// a modal for short posts). Takes precedence over [onPostTap], which stays
  /// wired to taps on posts embedded in the row.
  final void Function(SnPost)? onOpenPost;

  const SliverPostList({
    super.key,
    this.query,
    this.itemType = PostItemType.regular,
    this.backgroundColor,
    this.padding,
    this.itemPadding,
    this.isOpenable = true,
    this.onRefresh,
    this.onUpdate,
    this.maxWidth,
    this.queryKey,
    this.onPostTap,
    this.itemWrapper,
    this.separatorBuilder,
    this.onOpenPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: queryKey,
        initialFilter: query ?? PostListQuery(),
      ),
    );
    final notifier = ref.watch(provider.notifier);

    final currentFilter = useState(query ?? PostListQuery());

    useEffect(() {
      if (currentFilter.value != query) {
        notifier.applyFilter(query ?? PostListQuery());
      }
      return null;
    }, [query, queryKey]);

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
      ),
      seperatorBuilder: separatorBuilder ??
          (context, index, post) => const Divider(height: 1),
      itemBuilder: (context, index, post) {
        Widget row;
        if (maxWidth != null) {
          row = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: _buildPostItem(post, itemPadding),
            ),
          );
        } else {
          row = _buildPostItem(post, itemPadding);
        }

        if (itemWrapper != null) {
          return itemWrapper!(context, index, post, row);
        }
        return row;
      },
    );
  }

  Widget _buildPostItem(SnPost post, EdgeInsets? padding) {
    final onTap = onOpenPost != null
        ? () => onOpenPost!(post)
        : onPostTap != null
        ? () => onPostTap!(post.id)
        : null;
    switch (itemType) {
      case PostItemType.creator:
        return PostItemCreator(
          item: post,
          backgroundColor: backgroundColor,
          padding: padding,
          isOpenable: isOpenable,
          onRefresh: onRefresh,
          onUpdate: onUpdate,
          onTap: onTap,
          onPostTap: onPostTap,
        );
      case PostItemType.regular:
        return PostActionableItem(
          item: post,
          padding: padding,
          borderRadius: 8,
          onTap: onTap,
          onPostTap: onPostTap,
        );
    }
  }
}
