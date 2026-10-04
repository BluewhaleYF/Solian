import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Horizontal, lazily-built list with desktop hover chevrons.
///
/// Shared by the quick-pick strips (subscribed publishers, friend presence):
/// tiles scroll horizontally, and chevron affordances fade in on pointer hover
/// whenever there is more content in that direction. Touch/trackpad dragging is
/// enabled so the strip stays swipeable on mobile.
class HoverHorizontalScrollList extends HookWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double separatorWidth;

  /// Distance between the leading edges of two items. When set, the strip
  /// settles on a whole-item boundary once a scroll ends, and the hover
  /// chevrons advance one item at a time.
  final double? snapExtent;

  const HoverHorizontalScrollList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.separatorWidth = 2,
    this.snapExtent,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
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
    }, [controller, itemCount, padding, separatorWidth]);

    Future<void> scrollBy(double direction) async {
      if (!controller.hasClients) return;
      final position = controller.position;
      final delta = snapExtent != null
          ? snapExtent!
          : math.max(position.viewportDimension * 0.75, 180.0);
      final target = (position.pixels + delta * direction).clamp(
        0.0,
        position.maxScrollExtent,
      );
      await controller.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    /// Settles a partly scrolled card back onto its item boundary.
    void snapToItemBoundary() {
      final extent = snapExtent;
      if (extent == null || !controller.hasClients) return;
      final position = controller.position;
      final target = (position.pixels / extent).round() * extent;
      final clamped = target.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((clamped - position.pixels).abs() < 0.5) return;
      controller.animateTo(
        clamped,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }

    final scrollBehavior = ScrollConfiguration.of(context).copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.trackpad},
    );

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: scrollBehavior,
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  snapToItemBoundary();
                  return false;
                },
                child: ListView.separated(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  padding: padding,
                  itemCount: itemCount,
                  separatorBuilder: (_, _) => SizedBox(width: separatorWidth),
                  itemBuilder: itemBuilder,
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ScrollArrowButton(
                icon: Symbols.chevron_left,
                isVisible: isHovered.value && canScrollLeft.value,
                hiddenOffset: const Offset(-0.4, 0),
                onTap: () => scrollBy(-1),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ScrollArrowButton(
                icon: Symbols.chevron_right,
                isVisible: isHovered.value && canScrollRight.value,
                hiddenOffset: const Offset(0.4, 0),
                onTap: () => scrollBy(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final Offset hiddenOffset;
  final VoidCallback onTap;

  const _ScrollArrowButton({
    required this.icon,
    required this.isVisible,
    required this.hiddenOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : hiddenOffset,
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
      ),
    );
  }
}
