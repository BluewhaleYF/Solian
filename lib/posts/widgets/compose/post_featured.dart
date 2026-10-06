import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/shared/hooks/material_hooks.dart';
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

    final carouselController = useMaterialCarouselController();
    final prefs = ref.watch(sharedPreferencesProvider);
    final carouselIndex = useState(0);
    final previousFirstPostId = useState<String?>(null);
    final storedCollapsedId = useState<String?>(
      prefs.getString(kFeaturedPostsCollapsedId),
    );
    final isCollapsed = useState(false);

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
                  // The arrows page the carousel; the flush strip scrolls and
                  // snaps on its own.
                  if (!flush) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        carouselController.animateToItem(
                          carouselIndex.value - 1,
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
                        carouselController.animateToItem(
                          carouselIndex.value + 1,
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
                horizontal: flush ? _kFeaturedCarouselGap : 16,
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
            if (posts.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: maxHeight == null ? 344 : (maxHeight! - 48),
              child: _FeaturedPostCarousel(
                posts: posts,
                controller: carouselController,
                compact: flush,
                showHoverArrows: flush,
                itemWidth: flush ? _FeaturedPostCarousel.stripItemWidth : null,
                sideGap: flush ? _kFeaturedCarouselGap : 16,
                onIndexChanged: (index) => carouselIndex.value = index,
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

/// Gutter kept on each side of a featured post card, and between two cards.
const double _kFeaturedCarouselGap = 8;

/// Snapping carousel of featured posts, built on Material's [CarouselView].
///
/// In the flush strip ([itemWidth] set) cards keep a fixed width so several are
/// visible at once; otherwise each post fills the viewport. Either way the card
/// is inset from the container edges, and its attachments are inset too (see
/// [PostActionableItem.containAttachments]), so an image never touches an edge.
class _FeaturedPostCarousel extends HookWidget {
  /// Width of a card in the flush strip layout.
  static const double stripItemWidth = 320;

  final List<SnPost> posts;
  final CarouselController controller;
  final bool compact;
  final bool showHoverArrows;

  /// Fixed card width for the multi-card strip; null makes each post fill the
  /// viewport with [sideGap] on both sides.
  final double? itemWidth;
  final double sideGap;
  final ValueChanged<int>? onIndexChanged;

  const _FeaturedPostCarousel({
    required this.posts,
    required this.controller,
    this.compact = false,
    this.showHoverArrows = false,
    this.itemWidth,
    this.sideGap = 16,
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = useState(false);
    final canScrollLeft = useState(false);
    final canScrollRight = useState(false);

    void updateScrollState() {
      if (!controller.hasClients) {
        canScrollLeft.value = false;
        canScrollRight.value = false;
        return;
      }
      final position = controller.position;
      canScrollLeft.value = position.pixels > 0.5;
      canScrollRight.value = position.pixels < position.maxScrollExtent - 0.5;
    }

    useEffect(() {
      void listener() => updateScrollState();
      controller.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateScrollState());
      return () => controller.removeListener(listener);
    }, [controller, posts.length]);

    void step(int direction, double itemExtent) {
      final current = itemExtent <= 0
          ? 0
          : (controller.offset / itemExtent).round();
      controller.animateToItem(
        current + direction,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.maxWidth;
        if (viewport <= 0) return const SizedBox.shrink();

        final double itemExtent;
        final EdgeInsets itemPadding;
        final fixedWidth = itemWidth;
        if (fixedWidth != null) {
          // Fixed-width cards: [sideGap] at each edge of the strip and twice
          // that between two cards.
          final cardWidth = math.min(
            fixedWidth,
            math.max(0.0, viewport - sideGap * 2),
          );
          itemExtent = cardWidth + sideGap * 2;
          itemPadding = EdgeInsets.symmetric(horizontal: sideGap);
        } else {
          // One post per viewport, inset on both sides.
          itemExtent = viewport;
          itemPadding = EdgeInsets.symmetric(horizontal: sideGap);
        }

        return MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: Stack(
            children: [
              Positioned.fill(
                child: CarouselView(
                  controller: controller,
                  itemSnapping: true,
                  itemExtent: itemExtent,
                  padding: itemPadding,
                  backgroundColor: Colors.transparent,
                  enableSplash: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  onIndexChanged: onIndexChanged,
                  children: [
                    for (final post in posts)
                      _FeaturedPostCard(post: post, compact: compact),
                  ],
                ),
              ),
              if (showHoverArrows) ...[
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _CarouselArrowButton(
                      icon: Symbols.chevron_left,
                      isVisible: isHovered.value && canScrollLeft.value,
                      onTap: () => step(-1, itemExtent),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _CarouselArrowButton(
                      icon: Symbols.chevron_right,
                      isVisible: isHovered.value && canScrollRight.value,
                      onTap: () => step(1, itemExtent),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Bordered, rounded card wrapping one featured post.
class _FeaturedPostCard extends StatelessWidget {
  static const double _radius = 12;

  final SnPost post;
  final bool compact;

  const _FeaturedPostCard({required this.post, required this.compact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1 / MediaQuery.devicePixelRatioOf(context),
            color: theme.dividerColor.withOpacity(0.5),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(_radius)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(_radius)),
          child: SingleChildScrollView(
            child: PostActionableItem(
              item: post,
              isCompact: compact,
              borderRadius: _radius,
              containAttachments: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.icon,
    required this.isVisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        opacity: isVisible ? 1 : 0,
        child: Material(
          color: colorScheme.surface.withOpacity(0.92),
          elevation: 2,
          shadowColor: Colors.black26,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(icon, size: 20, color: colorScheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
