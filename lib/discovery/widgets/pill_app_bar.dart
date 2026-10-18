import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/pill_surface.dart';

export 'package:island/shared/widgets/pill_surface.dart'
    show kPillGlassSigma, kPillGlassTint;

/// Scroll distance over which a pill header finishes fading its surface in.
///
/// Tied to roughly one header height: by the time the content has meaningfully
/// slid under the bar, the pill is fully surfaced and can carry its controls.
const double kPillFadeDistance = 96.0;

/// Total height of a pill bar, excluding the status-bar inset.
///
/// A bar reserves `statusTop + kPillAppBarHeight`: the capsule's top margin
/// plus one control row. Anything that has to clear a pill header — a body
/// gap, a scaffold slot, a test assertion — should be computed from this so
/// every pill lands on the same band.
const double kPillAppBarHeight = SolSpace.control + SolSpace.md;

/// Feeds a pill's fade ramp (0..1) from a scroll notification.
///
/// The ramp is read off the scroll offset itself so the surface tracks the
/// drag instead of snapping at the first pixel. Only the outermost scrollable
/// counts: inside a [NestedScrollView] the inner list reports `depth` 1 and
/// restarts at offset 0 whenever the header re-expands, which would slam the
/// pill back to invisible while content is still under it.
///
/// Returns false so the notification keeps bubbling to other listeners.
bool updatePillFade(
  ScrollNotification notification,
  ValueNotifier<double> fade,
) {
  final metrics = notification.metrics;
  if (notification.depth != 0 || metrics.axis != Axis.vertical) return false;
  final ramp = (metrics.pixels / kPillFadeDistance).clamp(0.0, 1.0);
  if (fade.value != ramp) fade.value = ramp;
  return false;
}

/// [PillSurface] for a header: the capsule sits 12px in from each side and
/// 12px below the status bar, and carries [SolSpace.md] of inner inset.
///
/// Wide pages give the bar the window's full width, so the pill spans the
/// viewport rather than hugging the feed column.
class PillBarSurface extends StatelessWidget {
  /// Fade position, 0..1. Drives the blur, tint, border and shadow together.
  final double t;

  /// Status-bar inset, reserved inside the bar's own box.
  final double statusTop;

  final Widget child;

  const PillBarSurface({
    super.key,
    required this.t,
    required this.statusTop,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PillSurface(
      t: t,
      margin: EdgeInsets.fromLTRB(
        kPillSideGutter,
        statusTop + kPillSideGutter,
        kPillSideGutter,
        0,
      ),
      radius: SolRadius.pillRadius,
      contentPadding: const EdgeInsets.symmetric(horizontal: SolSpace.md),
      // The capsule is one control row tall, always. `PillSurface` sizes the
      // glass to its child, so leaving it to the row would let any child that
      // fills its constraints — an `Expanded`, an `Align`, a `Center` — stretch
      // the pill to whatever height the slot happens to offer, and the glass
      // would then hang over the content the page reserved space for. Pinning
      // it keeps every pill the same shape and makes the bar's
      // `preferredSize` the whole truth.
      child: SizedBox(height: SolSpace.control, child: child),
    );
  }
}

/// Pinned header sliver that keeps a pill in place and fades its surface in
/// with the scroll offset.
///
/// [fade] is driven by [updatePillFade] from the enclosing scroll view. The
/// sliver's own geometry never changes, and because it is pinned nothing moves
/// the bar either: the feed slides underneath it while only the fill animates.
class PillSliverAppBar extends StatelessWidget {
  final ValueListenable<double> fade;

  /// Status-bar inset, measured by the caller so the sliver's height matches.
  final double statusTop;

  /// The bar's single row of controls.
  final Widget child;

  const PillSliverAppBar({
    super.key,
    required this.fade,
    required this.statusTop,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      // Status bar + the pill's own height.
      toolbarHeight: statusTop + kPillAppBarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      pinned: true,
      flexibleSpace: ValueListenableBuilder<double>(
        valueListenable: fade,
        builder: (context, t, _) => PillBarSurface(
          t: t,
          statusTop: statusTop,
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
    );
  }
}

/// [PillBarSurface] for a `Scaffold`'s `appBar` slot.
///
/// The same chrome as [PillSliverAppBar] for pages whose content is not one
/// sliver list. The scaffold reserves the bar's height, so the pill floats
/// over whatever the body paints underneath instead of being part of it.
class PillAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueListenable<double> fade;

  /// Status-bar inset, measured by the caller so the bar's height matches.
  final double statusTop;

  final Widget child;

  const PillAppBar({
    super.key,
    required this.fade,
    required this.statusTop,
    required this.child,
  });

  @override
  Size get preferredSize => Size.fromHeight(statusTop + kPillAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: fade,
      builder: (context, t, _) => PillBarSurface(
        t: t,
        statusTop: statusTop,
        child: Material(color: Colors.transparent, child: child),
      ),
    );
  }
}
