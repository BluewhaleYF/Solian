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
const double _kPillBorderOpacity = 0.5;

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

  const PillSurface({
    super.key,
    required this.t,
    required this.margin,
    required this.radius,
    required this.contentPadding,
    required this.child,
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(
                alpha: kPillGlassTint * t,
              ),
              borderRadius: radius,
              border: t == 0
                  ? null
                  : Border.all(
                      color: colorScheme.outlineVariant.withValues(
                        alpha: _kPillBorderOpacity * t,
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
        ],
      ),
    );
  }
}

/// Side gutter of a pill: the capsule sits [SolSpace.md] in from each edge of
/// its container so the end caps clear it.
const double kPillSideGutter = SolSpace.md;