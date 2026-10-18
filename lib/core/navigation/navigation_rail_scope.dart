import 'package:material_ui/material_ui.dart';

/// Shell-level handle for the wide layout's navigation rail.
///
/// On the wide layout the rail replaces the drawer: a request to open the
/// navigation menu expands the rail over every destination instead of sliding
/// a drawer over the page. The shell owns that flag; this scope is how the app
/// bars' menu buttons reach it.
class NavigationRailScope extends InheritedWidget {
  /// Whether the shell currently presents a rail in place of the drawer.
  final bool available;

  /// Whether the rail is expanded to show every destination.
  final bool expanded;

  /// Expands the rail, or collapses it when it is already expanded.
  final VoidCallback toggle;

  const NavigationRailScope({
    super.key,
    required this.available,
    required this.expanded,
    required this.toggle,
    required super.child,
  });

  static NavigationRailScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationRailScope>();
  }

  @override
  bool updateShouldNotify(NavigationRailScope oldWidget) {
    return available != oldWidget.available || expanded != oldWidget.expanded;
  }
}
