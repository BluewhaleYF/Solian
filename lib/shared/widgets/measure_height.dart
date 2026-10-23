import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

/// Reports the laid-out height of its child to [onHeight].
///
/// Used by pages whose chrome floats over a scroll view: the scrollable needs
/// the chrome's real height to pad itself clear of it, and that height is only
/// known once the chrome has laid out. The callback runs after the frame, so
/// the parent can store it without mutating state mid-layout, and only fires
/// when the height actually changes.
class MeasureHeight extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onHeight;

  const MeasureHeight({super.key, required this.onHeight, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureHeight(onHeight);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderMeasureHeight).onHeight = onHeight;
  }
}

class _RenderMeasureHeight extends RenderProxyBox {
  ValueChanged<double> _onHeight;
  double? _reportedHeight;

  _RenderMeasureHeight(this._onHeight);

  set onHeight(ValueChanged<double> value) {
    if (identical(value, _onHeight)) return;
    _onHeight = value;
  }

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (_reportedHeight == height) return;
    _reportedHeight = height;

    final callback = _onHeight;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A detached box belongs to a page that is gone; its caller may have
      // dropped the state the callback would write to.
      if (!attached) return;
      callback(height);
    });
  }
}
