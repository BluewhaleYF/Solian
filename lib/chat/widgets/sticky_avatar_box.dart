// The render object is an implementation detail of the widget above it: it is
// never named outside this file, so keeping it private is the point.
// ignore_for_file: library_private_types_in_public_api

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps an avatar pinned [topMargin] below the top edge of the enclosing
/// scroll viewport while the row that owns the avatar slot scrolls past it, and
/// lets it ride up with the bottom of that row once the row itself leaves.
///
/// [anchorKey] identifies the box whose top-left corner is where the avatar
/// rests when nothing is pinned. It has to be a descendant of this widget's
/// parent, so the corner can be expressed in the parent's coordinate space; a
/// null key means the avatar rests at the parent's own top-left corner. The
/// parent is also what bounds the travel, so the pinned avatar never leaves the
/// row or group it belongs to.
///
/// The offset is resolved while painting instead of while building. A rebuild
/// caused by a scroll notification runs before the viewport applies the new
/// scroll offset, so geometry read during that rebuild is a frame behind: the
/// avatar visibly trails the content it is pinned to. Painting happens after
/// layout, so the geometry used here is the one on screen.
class StickyAvatarBox extends SingleChildRenderObjectWidget {
  const StickyAvatarBox({
    super.key,
    this.anchorKey,
    this.topMargin = 12,
    this.enabled = true,
    required super.child,
  });

  final GlobalKey? anchorKey;
  final double topMargin;

  /// When false the avatar stays at its anchor and never pins.
  final bool enabled;

  @override
  _RenderStickyAvatar createRenderObject(BuildContext context) {
    return _RenderStickyAvatar(
      anchorKey: anchorKey,
      topMargin: topMargin,
      enabled: enabled,
      scrollPosition: Scrollable.maybeOf(context)?.position,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderStickyAvatar renderObject,
  ) {
    renderObject
      ..anchorKey = anchorKey
      ..topMargin = topMargin
      ..enabled = enabled
      ..scrollPosition = Scrollable.maybeOf(context)?.position;
  }
}

class _RenderStickyAvatar extends RenderProxyBox {
  _RenderStickyAvatar({
    GlobalKey? anchorKey,
    double topMargin = 12,
    bool enabled = true,
    ScrollPosition? scrollPosition,
  }) : _anchorKey = anchorKey,
       _topMargin = topMargin,
       _enabled = enabled {
    this.scrollPosition = scrollPosition;
  }

  GlobalKey? _anchorKey;
  double _topMargin;
  bool _enabled;
  ScrollPosition? _scrollPosition;
  Offset? _shift;
  bool _resolving = false;

  set anchorKey(GlobalKey? value) {
    if (_anchorKey == value) return;
    _anchorKey = value;
    _shift = null;
    markNeedsPaint();
  }

  set topMargin(double value) {
    if (_topMargin == value) return;
    _topMargin = value;
    markNeedsPaint();
  }

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    markNeedsPaint();
  }

  set scrollPosition(ScrollPosition? value) {
    if (identical(_scrollPosition, value)) return;
    _scrollPosition?.removeListener(_handleScroll);
    _scrollPosition = value;
    _scrollPosition?.addListener(_handleScroll);
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    super.performLayout();
    // A relayout can move the anchor — a bubble grows, an image decodes —
    // without a scroll or a rebuild, so recompute the pinned offset.
    markNeedsPaint();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (attached) markNeedsPaint();
  }

  /// Top-left corner of the anchor, expressed in this box's parent. Null while
  /// the anchor box is not laid out yet.
  Offset? _anchorOrigin(RenderBox parentBox) {
    final anchorKey = _anchorKey;
    if (anchorKey == null) return Offset.zero;

    final anchor = anchorKey.currentContext?.findRenderObject();
    if (anchor is! RenderBox || !anchor.hasSize) return null;

    try {
      return anchor.localToGlobal(Offset.zero, ancestor: parentBox);
    } catch (_) {
      return null;
    }
  }

  Offset _ownOriginInParent() {
    final parentData = this.parentData;
    return parentData is BoxParentData ? parentData.offset : Offset.zero;
  }

  /// Offset the child is painted at, in this box's coordinate space. The avatar
  /// sticks [topMargin] below the viewport top and is clamped to its resting
  /// place and to the bottom of the box that owns it.
  Offset? _resolveShift() {
    if (_resolving) return _shift;

    final renderChild = child;
    final parentBox = parent;
    if (renderChild == null || parentBox is! RenderBox || !parentBox.hasSize) {
      return _shift;
    }

    _resolving = true;
    try {
      final origin = _anchorOrigin(parentBox);
      if (origin == null) return _shift;

      var shift = origin - _ownOriginInParent();
      if (renderChild.hasSize && _enabled) {
        final viewportBox = RenderAbstractViewport.of(this) as RenderBox?;
        if (viewportBox != null && viewportBox.hasSize) {
          final viewportTop =
              parentBox.localToGlobal(Offset.zero).dy -
              viewportBox.localToGlobal(Offset.zero).dy;
          final lowestTop = math.max(
            shift.dy,
            parentBox.size.height - renderChild.size.height,
          );
          shift = Offset(
            shift.dx,
            (_topMargin - viewportTop).clamp(shift.dy, lowestTop),
          );
        }
      }

      _shift = shift;
      return shift;
    } finally {
      _resolving = false;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final renderChild = child;
    if (renderChild == null) return;

    final shift = _resolveShift();
    // Skip painting until the anchor has been laid out; the avatar would
    // otherwise flash at the wrong spot for a frame.
    if (shift == null) return;

    context.paintChild(renderChild, offset + shift);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final local = position - (_resolveShift() ?? Offset.zero);
    if (!(Offset.zero & size).contains(local)) return false;

    if (hitTestChildren(result, position: local) || hitTestSelf(local)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final shift = _resolveShift() ?? Offset.zero;
    transform.translate(shift.dx, shift.dy);
  }
}
