import 'package:material_ui/material_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:island/core/services/responsive.dart';

// Tab routes that should show the bottom navigation
const kTabRoutes = [
  '/',
  '/explore',
  '/search',
  '/chat',
  '/realms',
  '/account',
  '/files',
  '/creators',
];

const kWideScreenRouteStart = 6;

String? _normalizeRoutePath(String? route) {
  if (route == null) return null;
  if (route.isEmpty) return '/';

  Uri uri;
  try {
    uri = Uri.parse(route);
  } catch (_) {
    return route;
  }

  var path = uri.path;
  if (path.isEmpty) path = '/';
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path;
}

bool shouldShowBottomNavForCurrentPath(
  BuildContext context, {
  List<String>? routes,
}) {
  final effectiveRoutes = routes ?? kTabRoutes;
  final currentLocation = _normalizeRoutePath(context.router.root.currentPath);
  if (currentLocation == null) return false;

  return effectiveRoutes.any((route) {
    final normalized = _normalizeRoutePath(route);
    if (normalized == null) return false;
    return currentLocation == normalized;
  });
}

/// Tab shell's bottom bar: shows only on the configured tab routes, and — on
/// those — slides out of the way while the page below is scrolled down (see
/// [ScrollHideBottomNav]). Use it as a `Scaffold.bottomNavigationBar`.
class ConditionalBottomNav extends StatefulWidget {
  final Widget child;
  final List<String>? routes;

  /// Scroll distance before the bar leaves or returns; see
  /// [ScrollHideBottomNav.hideThreshold].
  final double hideThreshold;

  /// Time the bar takes to leave or return; see
  /// [ScrollHideBottomNav.hideDuration].
  final Duration hideDuration;

  const ConditionalBottomNav({
    super.key,
    required this.child,
    this.routes,
    this.hideThreshold = kBottomNavHideScrollThreshold,
    this.hideDuration = kBottomNavHideDuration,
  });

  @override
  State<ConditionalBottomNav> createState() => _ConditionalBottomNavState();
}

class _ConditionalBottomNavState extends State<ConditionalBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Start fully visible
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateVisibility(bool shouldShow) {
    if (shouldShow == _isVisible) return;
    setState(() {
      _isVisible = shouldShow;
    });
    if (shouldShow) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultRoutes = kTabRoutes.sublist(
      0,
      isWideScreen(context) ? null : kWideScreenRouteStart,
    );
    final effectiveRoutes = widget.routes ?? defaultRoutes;

    final shouldShowBottomNav = shouldShowBottomNavForCurrentPath(
      context,
      routes: effectiveRoutes,
    );

    // Schedule visibility update after the frame to avoid build during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateVisibility(shouldShowBottomNav);
    });

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1,
      child: SlideTransition(
        position: _slideAnimation,
        child: ClipRect(
          child: IgnorePointer(
            ignoring: !_isVisible,
            // Scrolling only translates the bar inside its slot: the height
            // that keeps the body clear of it stays put. Only the route check
            // above collapses the slot.
            child: ScrollHideBottomNav(
              enabled: _isVisible,
              resetToken: _normalizeRoutePath(context.router.root.currentPath),
              hideThreshold: widget.hideThreshold,
              hideDuration: widget.hideDuration,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Default scroll distance that must accumulate in one direction before the
/// bar commits to leaving or returning.
///
/// Accumulated rather than per-event, so one sub-pixel tick cannot flip the
/// bar on its own; the jitter that out-of-bounds rubber bands produce is
/// handled separately by the bounds checks in the handler.
///
/// Eight logical pixels leaves almost nothing on the table: the bar is gone
/// as soon as the feed meaningfully moves, and back on the first sign of
/// scrolling up. Raise it for a calmer bar.
///
/// Override per call site with [ScrollHideBottomNav.hideThreshold] or
/// [ConditionalBottomNav.hideThreshold].
const double kBottomNavHideScrollThreshold = 8.0;

/// Default time the bar takes to leave or return.
const Duration kBottomNavHideDuration = Duration(milliseconds: 200);

/// Bottom bar that slides off the bottom edge while the page below it is
/// scrolled down.
///
/// The bar keeps the height its slot declared: only paint moves. The
/// `MediaQuery.padding.bottom` a `Scaffold` injects into its body under
/// `extendBody: true` therefore never changes, so the page does not jump when
/// the bar leaves or returns, and the body stays reachable in the meantime.
///
/// Scrolling is read from the [ScrollNotificationObserver] that every
/// `Scaffold` installs above its slots, so pages publish nothing. Only the
/// outermost viewport counts ([ScrollNotification.depth] `0`) and only on the
/// vertical axis, so a nested horizontal rail, `TabBarView` or inner list
/// cannot move the bar.
class ScrollHideBottomNav extends StatefulWidget {
  /// Whether the bar may leave. `false` forces it back in, for callers that
  /// collapse the slot themselves.
  final bool enabled;

  /// Re-shows the bar whenever it changes, so a newly opened page starts with
  /// its bar rather than inheriting the previous page's hidden state.
  final Object? resetToken;

  /// Scroll distance that must accumulate in one direction before the bar
  /// leaves or returns. Lower is twitchier; zero follows every delta.
  final double hideThreshold;

  /// How long the bar takes to leave or return.
  final Duration hideDuration;

  /// The bar itself.
  final Widget child;

  const ScrollHideBottomNav({
    super.key,
    required this.child,
    this.enabled = true,
    this.resetToken,
    this.hideThreshold = kBottomNavHideScrollThreshold,
    this.hideDuration = kBottomNavHideDuration,
  });

  @override
  State<ScrollHideBottomNav> createState() => _ScrollHideBottomNavState();
}

class _ScrollHideBottomNavState extends State<ScrollHideBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _hideOffset;
  ScrollNotificationObserverState? _observer;
  double _scrollDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.hideDuration,
    );
    _hideOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_handleScrollNotification);
    // The nearest one is the enclosing Scaffold's, which owns the body this
    // bar sits under.
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_handleScrollNotification);
  }

  @override
  void didUpdateWidget(covariant ScrollHideBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hideDuration != oldWidget.hideDuration) {
      _controller.duration = widget.hideDuration;
    }
    if (!widget.enabled || widget.resetToken != oldWidget.resetToken) {
      _setHidden(false);
    }
  }

  @override
  void dispose() {
    _observer?.removeListener(_handleScrollNotification);
    _controller.dispose();
    super.dispose();
  }

  void _setHidden(bool hidden) {
    _scrollDistance = 0;
    if (_controller.value == (hidden ? 1.0 : 0.0)) return;
    if (hidden) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (!widget.enabled) return;
    if (notification.depth != 0) return;
    if (notification.metrics.axis != Axis.vertical) return;
    if (notification is UserScrollNotification) {
      // A drag starts from rest, so distance accumulated before it was
      // released must not carry over into it.
      _scrollDistance = 0;
      return;
    }
    if (notification is! ScrollUpdateNotification) return;
    final delta = notification.scrollDelta;
    if (delta == null) return;
    final metrics = notification.metrics;
    // A page whose content fits its viewport can only rubber-band — a
    // refreshable feed pulled down, a list bounced at its end. Those offsets
    // are real, and a drag past the threshold would flicker the bar out over
    // nothing, so they never hide it.
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) return;
    // A pull past either edge reveals nothing the current position does not
    // already show, so that rubber band must never cost the bar. Without this
    // the trailing bounce — a fling off the end of the feed — accumulates real
    // positive deltas and flickers the bar out and back.
    if (metrics.pixels > metrics.maxScrollExtent) return;
    // The leading edge is stronger than the trailing one: it always wants its
    // bar back, which also swallows a bounce off the top.
    if (metrics.pixels <= metrics.minScrollExtent) {
      _setHidden(false);
      return;
    }
    _scrollDistance += delta;
    if (_scrollDistance >= widget.hideThreshold) {
      _setHidden(true);
    } else if (_scrollDistance <= -widget.hideThreshold) {
      _setHidden(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clipped to the slot, so the parked bar costs nothing to paint and the
    // body it uncovers takes the pointers.
    return ClipRect(
      child: SlideTransition(position: _hideOffset, child: widget.child),
    );
  }
}
