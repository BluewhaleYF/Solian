import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// How far the reflection paints past the seam, over the artwork itself.
///
/// Long enough to carry the transition from "no subject survives" to "here is
/// the picture", short enough that the artwork's own detail is not veiled.
const double kArtworkReflectionFeather = 56;

/// Height of the artwork strip the reflection samples.
///
/// The strip is taken from the picture's top and stretched to fill the band,
/// so it only needs to be tall enough to carry the palette: too tall and the
/// reflection starts reproducing subjects, which is exactly what the blur is
/// there to prevent.
const double _kSampleHeight = 72;

/// The band above a page's artwork: the picture's own top edge, mirrored
/// upward and blurred so far past legibility that only its colors survive.
///
/// This is the iOS trick for extending artwork under the status bar, and it is
/// the reason the band needs no color of its own: the reflection's bottom edge
/// is the artwork's top edge, so the seam is a continuation rather than a
/// join. A plain fill here would read as a gap, and a blur of the whole
/// picture would average the interesting part away — sampling the top strip
/// keeps the sky, the treeline, whatever the picture opens with.
///
/// The flip is what makes it read as a reflection instead of a smeared copy:
/// features lean away from the seam the way they would in a mirror.
///
/// It also paints [kArtworkReflectionFeather] past its band, fading to nothing
/// over the artwork itself. Without that overlap the two meet at a line where
/// the blur simply stops, which reads as a cut between two pictures; with it
/// the sharp picture emerges out of the soft one.
class ArtworkReflection extends StatelessWidget {
  /// The same image the artwork below shows.
  final ImageProvider image;

  /// Height of the band, status bar included. The widget is taller than this
  /// by [kArtworkReflectionFeather].
  final double band;

  const ArtworkReflection({super.key, required this.image, required this.band});

  @override
  Widget build(BuildContext context) {
    final total = band + kArtworkReflectionFeather;
    return ClipRect(
      child: ShaderMask(
        // Fade out only over the part that overlaps the artwork: inside the
        // band the reflection stays at full strength, so it still reads as the
        // picture continuing upward.
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF000000),
            Color(0xFF000000),
            Color(0x00000000),
          ],
          stops: [0.0, band / total, 1.0],
        ).createShader(bounds),
        child: ImageFiltered(
          // Heavy on purpose: the band is texture, not a second picture. At
          // this sigma no subject survives, only the palette and the way the
          // light falls.
          imageFilter: ui.ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..scaleByDouble(1.0, -1.0, 1.0, 1.0)
              // The source is the artwork's top strip, so the copy is scaled
              // up to fill the band from that strip alone.
              ..scaleByDouble(1.0, total / _kSampleHeight, 1.0, 1.0),
            // Anchored so the flipped strip's top edge — the artwork's own
            // first row — lands on the seam, `band` down from the top.
            child: Transform.translate(
              offset: Offset(0, band - _kSampleHeight),
              child: SizedBox(
                height: _kSampleHeight,
                child: Image(
                  image: image,
                  // The strip is the picture's top edge; `topCenter` keeps the
                  // horizontal framing identical to the artwork below it.
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
