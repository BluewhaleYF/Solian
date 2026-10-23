import 'package:flutter/widgets.dart';

/// Outline of a messenger-style chat bubble.
///
/// Bubbles live on the left side of the message row, next to the avatar
/// gutter. Within a sender group, the avatar-side corners are squared where
/// consecutive bubbles meet so the group reads as one connected unit.
///
/// The free corner nearest the avatar (the top-left) is cut tighter than the
/// rest ([tailRadius] against [radius]). That single tighter corner is the
/// bubble's signature: it points the shape at the face that wrote it, the way
/// a speech tail does, without drawing an actual tail. Every other free corner
/// keeps the generous [radius], so a bubble still reads as a soft sheet of
/// paper rather than a teardrop.
@immutable
class MessageBubbleShape {
  /// Radius of the free corners that are not the tail.
  final double radius;

  /// Radius of the free corner nearest the avatar.
  final double tailRadius;

  /// Square the top-left corner: another bubble of the same sender group sits
  /// above this one.
  final bool connectsAbove;

  /// Square the bottom-left corner: another bubble of the same sender group
  /// sits below this one.
  final bool connectsBelow;

  const MessageBubbleShape({
    this.radius = 20,
    this.tailRadius = 8,
    this.connectsAbove = false,
    this.connectsBelow = false,
  });

  double get _topLeft => connectsAbove ? 0 : tailRadius;
  double get _bottomLeft => connectsBelow ? 0 : radius;

  /// Corner radii for the current connection state.
  BorderRadius get borderRadius => BorderRadius.only(
    topLeft: Radius.circular(_topLeft),
    topRight: Radius.circular(radius),
    bottomLeft: Radius.circular(_bottomLeft),
    bottomRight: Radius.circular(radius),
  );

  /// The bubble outline: the body rectangle with the connection-aware
  /// corners.
  Path path(Size size) => Path()..addRRect(_rrect(size));

  RRect _rrect(Size size) => RRect.fromRectAndCorners(
    Offset.zero & size,
    topLeft: Radius.circular(_topLeft),
    topRight: Radius.circular(radius),
    bottomLeft: Radius.circular(_bottomLeft),
    bottomRight: Radius.circular(radius),
  );
}
