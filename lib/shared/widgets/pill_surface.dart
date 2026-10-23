import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:island/core/theme.dart';

/// Alpha of the pill's shadow once it is fully surfaced.
const double _kPillShadowOpacity = 0.12;

/// Blur radius of the glass once it is fully surfaced.
///
/// Enough to dissolve the rows sliding under the bar without flattening them
/// into a slab: at a lower radius the feed's own colours still bleed through
/// blurred, which is what reads as glass rather than a translucent fill.
const double kPillGlassSigma = 14.0;

/// Alpha of the glass tint once it is fully surfaced.
///
/// Well short of opaque on purpose — the blur, not the fill, is what separates
/// the bar from what is behind it. The tint only has to pull the blurred
/// pixels towards the page's own surface colour so the blur reads as dirtied
/// glass.
const double kPillGlassTint = 0.4;

/// Alpha of the hairline outlining the glass once it is fully surfaced.
///
/// Public so other floating chrome built from the same glass recipe — the chat
/// composer, for one — draws an edge of the same weight as the pills.
const double kPillBorderOpacity = 0.5;

/// Stroke of the ring a loading pill paints along its own edge.
const double _kPillRingStroke = 2.0;

/// Share of the capsule's perimeter the indeterminate ring sweeps.
const double _kPillRingSweep = 0.26;

/// One full lap of the indeterminate ring.
const Duration _kPillRingPeriod = Duration(milliseconds: 1100);

/// How long the loading border takes to fade in or out.
///
/// Long enough for the ring and the hairline to hand over to each other
/// without a blink, short enough that the bar still reads as reacting at once.
const Duration _kPillRingFade = Duration(milliseconds: 220);

/// The painted chrome of a floating pill.
///
/// Geometry is fixed: the capsule keeps the same [margin], radius and height
/// at every scroll offset, so its controls never move under the user's thumb.
/// Only the surface fades in with [t] (0..1): invisible at rest, glass over
/// the content beneath once the page moves.
///
/// The glass is a real [BackdropFilter] over that content, not a translucent
/// fill: what is behind the capsule is blurred ([kPillGlassSigma]) and tinted
/// towards `surfaceContainerLow` ([kPillGlassTint]). The tint alone would
/// leave the content legible through the bar; the blur is what separates the
/// layer, and it stays soft enough that the page's colours still bleed
/// through. A hairline border and a soft shadow come with the fill, and both
/// are scaled by [t], so a pill over an empty page stays completely flat.
///
/// A loading pill drops the hairline and laps its own outline instead: see
/// [loading].
class PillSurface extends StatelessWidget {
  /// Fade position, 0..1. Drives the blur, tint, border and shadow together.
  final double t;

  /// Outer margin of the capsule, painted against the container it floats in.
  final EdgeInsets margin;

  final BorderRadius radius;

  /// Inset of [child] inside the capsule. The capsule's end caps bite into the
  /// bar, so the controls keep a full spacing step of inset from the edge.
  final EdgeInsets contentPadding;

  final Widget child;

  /// Draw the capsule's border as a spinner: the hairline is dropped and an
  /// arc laps the outline instead.
  ///
  /// The ring deliberately ignores [t]. The glass only exists once content has
  /// slid under the bar, but a loader has to be legible while the page is
  /// still sitting at its top, so it paints over a fully transparent pill.
  final bool loading;

  const PillSurface({
    super.key,
    required this.t,
    required this.margin,
    required this.radius,
    required this.contentPadding,
    required this.child,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      // `passthrough` so the pill's height comes from its controls: the glass
      // layer is positioned and contributes no size of its own.
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // The glass, painted under everything else the bar draws. At rest
          // there is no layer at all: nothing to blur, and skipping it keeps
          // the content free of a save layer while the page sits at the top.
          if (t > 0)
            Positioned.fill(
              child: ClipRRect(
                // Load-bearing clip: the filter's save layer is bounded by it,
                // so the blur stays inside the capsule instead of smearing the
                // window during a route transition.
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: kPillGlassSigma * t,
                    sigmaY: kPillGlassSigma * t,
                  ),
                  child: const ColoredBox(color: Color(0x00000000)),
                ),
              ),
            ),
          // Animated rather than a bare [DecoratedBox]: entering and leaving
          // the loading state swaps the hairline for the ring, and both halves
          // of that swap should arrive and leave with the same timing instead
          // of the edge snapping twice.
          AnimatedContainer(
            duration: _kPillRingFade,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(
                alpha: kPillGlassTint * t,
              ),
              borderRadius: radius,
              // While loading the edge carries the spinner, so the static
              // hairline stands down rather than doubling it up.
              border: t == 0 || loading
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: kPillBorderOpacity * t,
                      ),
                    ),
              boxShadow: t == 0
                  ? null
                  : [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(
                          alpha: _kPillShadowOpacity * t,
                        ),
                        blurRadius: 12 * t,
                        offset: Offset(0, 4 * t),
                      ),
                    ],
            ),
            child: Padding(padding: contentPadding, child: child),
          ),
          // The ring keeps a slot while it fades out, so leaving the loading
          // state dissolves the arc instead of clipping it off mid-lap.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _kPillRingFade,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: loading
                  ? _PillRing(
                      key: const ValueKey('pill-ring'),
                      radius: radius,
                      color: colorScheme.primary,
                    )
                  : const SizedBox.shrink(key: ValueKey('pill-ring-idle')),
            ),
          ),
        ],
      ),
    );
  }
}

/// The capsule's own edge as a spinner.
///
/// The arc is extracted from a rounded rect of the caller's [radius] and
/// swept clockwise, so it reads as the pill's border lapping rather than as
/// a separate widget laid over it.
class _PillRing extends StatefulWidget {
  final BorderRadius radius;
  final Color color;

  const _PillRing({super.key, required this.radius, required this.color});

  @override
  State<_PillRing> createState() => _PillRingState();
}

class _PillRingState extends State<_PillRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _kPillRingPeriod,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        // A childless [CustomPaint] takes its size from its child, and inside
        // the switcher's stack there is none — it would collapse to zero and
        // paint nothing. `SizedBox.expand` gives the painter the bar's box.
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _PillRingPainter(
              radius: widget.radius,
              color: widget.color,
              sweep: _controller,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillRingPainter extends CustomPainter {
  final BorderRadius radius;
  final Color color;
  final Animation<double> sweep;

  _PillRingPainter({
    required this.radius,
    required this.color,
    required this.sweep,
  }) : super(repaint: sweep);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Inset by half the stroke so the ring's outer edge lands on the capsule
    // outline the hairline used to draw, not half a stroke outside it.
    final outline = radius
        .toRRect(Offset.zero & size)
        .deflate(_kPillRingStroke / 2);
    // A capsule is a single contour, so one metric covers the whole edge.
    final metric = (Path()..addRRect(outline)).computeMetrics().first;
    final total = metric.length;
    if (total <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kPillRingStroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    // The rounded rect's contour starts at the middle of its top edge, which
    // is exactly where a lap should begin. This offsets the *extraction*
    // only, never the canvas: rotating the canvas would turn the capsule
    // itself and paint the arc down the page.
    final start = (sweep.value * total) % total;
    final extent = total * _kPillRingSweep;

    void draw(double from, double to) {
      if (to - from < 0.5) return;
      canvas.drawPath(
        metric.extractPath(from.clamp(0.0, total), to.clamp(0.0, total)),
        paint,
      );
    }

    if (start + extent <= total) {
      draw(start, start + extent);
    } else {
      // The lap straddles the seam: paint the tail and the head separately.
      draw(start, total);
      draw(0, start + extent - total);
    }
  }

  @override
  bool shouldRepaint(covariant _PillRingPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}

/// Side gutter of a pill: the capsule sits [SolSpace.md] in from each edge of
/// its container so the end caps clear it.
const double kPillSideGutter = SolSpace.md;