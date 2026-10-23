import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Height a [SliverFloatingTabBar] reserves: a `TabBar`'s own 46px plus the
/// strips' vertical padding — `SolSpace.sm` above the tabs and `SolSpace.xs`
/// below them, so the strip sits closer to the content it heads.
const double kFloatingTabBarHeight = 46 + SolSpace.sm + SolSpace.xs;

/// Tab strip that lives inside a pane's scroll view as a floating header.
///
/// The strip scrolls away with the content it belongs to, but comes back as
/// soon as the reader scrolls back up ([SliverAppBar.floating] with
/// [SliverAppBar.snap]) instead of waiting for the pane to reach its top. That
/// keeps the tabs one gesture away on a long board or timeline without
/// spending a pinned band of the viewport on them.
///
/// It paints no surface of its own beyond [backgroundColor]: the pane ground
/// shows through, so the strip reads as part of the page rather than a bar
/// stacked on top of it.
class SliverFloatingTabBar extends StatelessWidget {
  /// The `TabBar` itself.
  final Widget child;

  /// Tone behind the strip while it is on screen. Should be the page ground,
  /// not a card tone, so the strip does not become a band.
  final Color backgroundColor;

  /// Height the strip reserves, matching the `TabBar` plus its own padding.
  final double height;

  const SliverFloatingTabBar({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.height = kFloatingTabBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // Floating + snap is the "reveal on scroll back" half: the strip is not
      // pinned, so it leaves with the content, and it returns as soon as the
      // reader reverses direction rather than at the pane's top.
      pinned: false,
      floating: true,
      snap: true,
      // The pane's scroll view is not the route's primary one, so the bar must
      // not claim the status-bar inset.
      primary: false,
      toolbarHeight: height,
      // The strip owns its own padding; the app bar must not add a title inset
      // or a leading slot on top of it.
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      title: child,
    );
  }
}
