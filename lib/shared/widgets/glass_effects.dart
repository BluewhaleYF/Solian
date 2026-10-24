import 'package:material_ui/material_ui.dart';

/// Whether the app draws its liquid-glass chrome — pill headers, the chat
/// composer and the quick-reply composer — or flat solid surfaces instead.
///
/// Scoped once at the root from the user's setting
/// (`AppSettings.glassEffects`). Glass costs a backdrop copy plus a shader
/// pass on every frame a surface is on screen; turning this off keeps every
/// layout identical but repaints the same capsules with a plain theme fill,
/// so scrolling a feed no longer pays for the samples.
///
/// Defaults to `true` when no scope is present: a surface rendered in
/// isolation (a test, a sheet) still gets the material the app ships with.
class GlassEffects extends InheritedWidget {
  final bool enabled;

  const GlassEffects({super.key, required this.enabled, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassEffects>()?.enabled ??
      true;

  @override
  bool updateShouldNotify(GlassEffects oldWidget) =>
      oldWidget.enabled != enabled;
}
