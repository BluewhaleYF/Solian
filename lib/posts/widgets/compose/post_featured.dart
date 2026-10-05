import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/shared/widgets/hover_horizontal_scroll_list.dart';
import 'package:logging/logging.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/core/config.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_featured.g.dart';

@riverpod
Future<List<SnPost>> featuredPosts(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  // Note: There's no typed API for featured posts in PostsApi
  // We fall back to raw Dio call
  final resp = await client.dio.get('/sphere/posts/featured');
  return resp.data.map((e) => SnPost.fromJson(e)).cast<SnPost>().toList();
}

class PostFeaturedList extends HookConsumerWidget {
  final bool collapsable;
  final double? maxHeight;
  final bool emphasizeHeader;
  final double borderRadius;

  /// Hosts that already own the surface (the wide explore timeline) drop the
  /// card chrome and lay the posts out as a snapping horizontal list of cards
  /// with their own fixed width, instead of one full-width page per post.
  final bool flush;
  const PostFeaturedList({
    super.key,
    this.collapsable = true,
    this.maxHeight,
    this.emphasizeHeader = true,
    this.borderRadius = 8,
    this.flush = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredPostsAsync = ref.watch(featuredPostsProvider);

    final pageViewController = usePageController();
    final prefs = ref.watch(sharedPreferencesProvider);
    final pageViewCurrent = useState(0);
    final previousFirstPostId = useState<String?>(null);
    final storedCollapsedId = useState<String?>(
      prefs.getString(kFeaturedPostsCollapsedId),
    );
    final isCollapsed = useState(false);

    useEffect(() {
      pageViewController.addListener(() {
        pageViewCurrent.value = pageViewController.page?.round() ?? 0;
      });
      return null;
    }, [pageViewController]);

    // Log isCollapsed state changes
    useEffect(() {
      Logger.root.info('isCollapsed changed to ${isCollapsed.value}');
      return null;
    }, [isCollapsed]);

    useEffect(() {
      if (featuredPostsAsync.hasValue && featuredPostsAsync.value!.isNotEmpty) {
        final currentFirstPostId = featuredPostsAsync.value!.first.id;
        Logger.root.info('Current first post ID: $currentFirstPostId');
        Logger.root.info(
          'Previous first post ID: ${previousFirstPostId.value}',
        );
        Logger.root.info('Stored collapsed ID: ${storedCollapsedId.value}');

        if (previousFirstPostId.value == null) {
          // Initial load
          previousFirstPostId.value = currentFirstPostId;
          isCollapsed.value = (storedCollapsedId.value == currentFirstPostId);
          Logger.root.info(
            'Initial load. isCollapsed set to ${isCollapsed.value}',
          );
        } else if (previousFirstPostId.value != currentFirstPostId) {
          // First post changed, expand by default
          previousFirstPostId.value = currentFirstPostId;
          isCollapsed.value = false;
          prefs.remove(
            kFeaturedPostsCollapsedId,
          ); // Clear stored ID if post changes
          Logger.root.info('First post changed. isCollapsed set to false.');
        } else {
          // Same first post, maintain current collapse state
          // No change needed for isCollapsed.value unless manually toggled
          Logger.root.info(
            'Same first post. Maintaining current collapse state.',
          );
        }
      } else {
        Logger.root.info('featuredPostsAsync has no value or is empty.');
      }
      return null;
    }, [featuredPostsAsync]);

    final appSettings = ref.watch(appSettingsProvider);

    void toggleCollapse() {
      isCollapsed.value = !isCollapsed.value;
      Logger.root.info(
        'Manual toggle. isCollapsed set to ${isCollapsed.value}',
      );
      if (isCollapsed.value &&
          featuredPostsAsync.hasValue &&
          featuredPostsAsync.value!.isNotEmpty) {
        prefs.setString(
          kFeaturedPostsCollapsedId,
          featuredPostsAsync.value!.first.id,
        );
        Logger.root.info(
          'Stored collapsed ID: ${featuredPostsAsync.value!.first.id}',
        );
      } else {
        prefs.remove(kFeaturedPostsCollapsedId);
        Logger.root.info('Removed stored collapsed ID.');
      }
    }

    // The whole header band toggles the section, not just the chevron: when
    // collapsed the band is all that stays on screen, so the tile itself is
    // the natural hit target for expanding or hiding the posts again. In
    // flush hosts (the explore timeline) the band spans the pane width.
    final header = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: collapsable ? toggleCollapse : null,
        child: SizedBox(
          height: 48,
          child:
              Row(
                spacing: 8,
                children: [
                  Icon(
                    Symbols.highlight,
                    size: 20,
                    color: emphasizeHeader
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      'highlightPost'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: emphasizeHeader
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  // The arrows page the carded layout; the flush strip scrolls and
                  // snaps on its own.
                  if (!flush) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        pageViewController.animateToPage(
                          pageViewCurrent.value - 1,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Symbols.arrow_left),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        pageViewController.animateToPage(
                          pageViewCurrent.value + 1,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Symbols.arrow_right),
                    ),
                  ],
                  if (collapsable)
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      onPressed: toggleCollapse,
                      icon: Icon(
                        isCollapsed.value
                            ? Symbols.expand_more
                            : Symbols.expand_less,
                      ),
                    ),
                ],
              ).padding(
                // The flush strip sits in the host's own surface, so it keeps a
                // tighter gutter than the carded variant.
                horizontal: flush ? _FlushFeaturedStrip.itemPadding : 16,
                vertical: 8,
              ),
        ),
      ),
    );

    final body = AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Visibility(
        visible: collapsable ? !isCollapsed.value : true,
        child: featuredPostsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (posts) {
            return SizedBox(
              height: maxHeight == null ? 344 : (maxHeight! - 48),
              child: flush
                  ? _FlushFeaturedStrip(posts: posts)
                  : PageView.builder(
                      controller: pageViewController,
                      scrollDirection: Axis.horizontal,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return SingleChildScrollView(
                          child: PostActionableItem(
                            item: posts[index],
                            borderRadius: 8,
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );

    if (flush) {
      return Column(mainAxisSize: MainAxisSize.min, children: [header, body]);
    }

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(
        appSettings.cardTransparency,
      ),
      margin: EdgeInsets.zero,
      // Clip content to the rounded corners without clipping the elevation
      // shadow; an outer ClipRRect would cut the shadow (visible at the bottom).
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: [header, body]),
    );
  }
}

/// Fixed-width, snapping list of featured posts for hosts that own the surface
/// (see [PostFeaturedList.flush]). Cards keep their intrinsic height and stay
/// narrower than the pane, so the next post peeks in.
class _FlushFeaturedStrip extends StatelessWidget {
  /// Width of one featured post card, and the gutter kept on each side of it.
  static const double itemWidth = 320;
  static const double itemPadding = 8;

  /// Distance between two cards; the strip snaps on multiples of it.
  static const double itemStride = itemWidth + itemPadding * 2;

  final List<SnPost> posts;

  const _FlushFeaturedStrip({required this.posts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HoverHorizontalScrollList(
      itemCount: posts.length,
      snapExtent: itemStride,
      padding: const EdgeInsets.symmetric(horizontal: itemPadding),
      separatorWidth: itemPadding * 2,
      itemBuilder: (context, index) => Align(
        alignment: Alignment.topCenter,
        // Cards keep their own width so a card entering the viewport can never
        // be squeezed into the space left over by the previous one.
        child: Container(
          width: itemWidth,
          margin: const .only(bottom: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1 / MediaQuery.devicePixelRatioOf(context),
                color: theme.dividerColor.withOpacity(0.5),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: SingleChildScrollView(
              child: PostActionableItem(
                item: posts[index],
                isCompact: true,
                borderRadius: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
