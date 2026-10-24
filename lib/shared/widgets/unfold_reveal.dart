import 'package:material_ui/material_ui.dart';

/// Slides a pill's payload out of its leading edge.
///
/// The host keeps a fixed leading element — an avatar, a progress ring — and
/// puts everything else through this: at `0` the widget is a bare circle, at
/// `1` the sentence sits beside it. Width and opacity move together so the
/// capsule grows rather than revealing text under a travelling mask, and the
/// clip keeps a mid-flight frame from painting past the pill's silhouette.
class UnfoldReveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  /// Gap between the leading element and this payload, folded into the reveal
  /// so the collapsed pill is exactly as wide as the leading element.
  final double inset;

  const UnfoldReveal({
    super.key,
    required this.animation,
    required this.child,
    this.inset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: t,
            // Without a height factor the align takes the incoming height and
            // the tightened pill would be as tall as its lane.
            heightFactor: 1,
            child: Opacity(opacity: t, child: child),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(left: inset),
        child: child,
      ),
    );
  }
}
