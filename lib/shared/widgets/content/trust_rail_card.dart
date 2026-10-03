import 'package:material_ui/material_ui.dart';

/// Card chrome shared by the two domain-trust surfaces: the prompt sheet for
/// an untrusted link and the placeholder that stands in for an untrusted
/// image.
///
/// The verdict is carried by the rail on the left edge rather than by the
/// body copy, so an [accent] of `error` (blocked) against `primary` (merely
/// unverified) reads the same at both sizes, and the text inside stays calm.
class TrustRailCard extends StatelessWidget {
  const TrustRailCard({
    super.key,
    required this.accent,
    required this.background,
    required this.border,
    required this.child,
    this.padding = defaultPadding,
  });

  /// Colour of the rail: the trust verdict, not decoration.
  final Color accent;

  final Color background;

  /// Hairline around the card, tinted per verdict.
  final Color border;

  /// Distance from the rail, not from the card edge.
  final EdgeInsetsGeometry padding;

  final Widget child;

  /// Geometry the sheet's height estimate has to mirror: it measures the
  /// card's text with the width the text will actually get.
  static const railWidth = 3.0;
  static const defaultPadding = EdgeInsets.fromLTRB(16, 12, 14, 12);

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: border),
      ),
      // The rail is positioned rather than laid out in a Row: it must run the
      // card's full height without dictating it, and the clip keeps its ends
      // inside the corner radius.
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: railWidth,
              child: ColoredBox(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
