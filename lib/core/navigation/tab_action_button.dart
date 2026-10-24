import 'package:material_ui/material_ui.dart';

/// The shell's primary action button, owned by whichever tab is active.
///
/// The iOS glass tab bar draws a native `UITabBar`, whose action button
/// sits inside the bar itself — there is no floating button above it. The
/// tabs that used to carry a floating action button (Explore's compose
/// sheet, Chat's create-room sheet) register their action here instead of
/// painting their own FAB, so the shell can offer one button per tab from
/// a single place.
///
/// Each tab wraps its body in a [TabActionRegistration]; the registration
/// publishes its spec into the [TabActionScope] that the tab shell installs
/// above the whole stack, keyed by the tab's destination id. A tab that
/// offers no action registers `null`, and the shell hides the button while
/// it is active.
class TabActionScope extends InheritedWidget {
  final TabActionState state;

  const TabActionScope({super.key, required this.state, required super.child});

  @override
  bool updateShouldNotify(TabActionScope oldWidget) {
    return state != oldWidget.state;
  }
}

/// Live map of tab id → action. A [ValueNotifier] so a tab registering or
/// unregistering its action rebuilds only the shell, not the tab stack.
class TabActionState extends ValueNotifier<Map<String, TabActionButtonSpec?>> {
  TabActionState() : super(const {});

  TabActionButtonSpec? of(String id) => value[id];

  void set(String id, TabActionButtonSpec? spec) {
    if (value[id] == spec) return;
    value = {...value, id: spec};
  }
}

/// Publishes the owning tab's action into the shell's [TabActionScope].
///
/// Pass `spec: null` (or omit it while signed out) to offer no action: the
/// shell then paints no button while this tab is active.
class TabActionRegistration extends StatefulWidget {
  final String id;
  final TabActionButtonSpec? spec;
  final Widget child;

  const TabActionRegistration({
    super.key,
    required this.id,
    required this.spec,
    required this.child,
  });

  @override
  State<TabActionRegistration> createState() => _TabActionRegistrationState();
}

class _TabActionRegistrationState extends State<TabActionRegistration> {
  /// The shell's action map, captured while the element is still mounted:
  /// [dispose] cannot look ancestors up.
  TabActionState? _actions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _actions = context
        .dependOnInheritedWidgetOfExactType<TabActionScope>()
        ?.state;
  }

  @override
  void initState() {
    super.initState();
    // Registered after the frame: mutating a notifier during build would
    // mark it dirty while it is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actions?.set(widget.id, widget.spec);
    });
  }

  @override
  void didUpdateWidget(TabActionRegistration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.spec != widget.spec) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (oldWidget.id != widget.id) _actions?.set(oldWidget.id, null);
        _actions?.set(widget.id, widget.spec);
      });
    }
  }

  // No dispose-time withdrawal: a tab unmounts only when the shell above it
  // unmounts (auto_route keeps tabs alive in its IndexedStack), so its
  // registration dies with the notifier it wrote to. Clearing here would
  // also notify during tree finalization, when the framework is locked.

  @override
  Widget build(BuildContext context) => widget.child;
}

/// What the shell needs to paint a tab's action button.
class TabActionButtonSpec {
  /// SF Symbol name for the native glass bar.
  final String symbol;

  /// Material icon for the fallback bars.
  final IconData icon;

  /// Invoked when the button is pressed.
  final VoidCallback onPressed;

  /// Semantics/tooltip label; the native bar has no tooltip, so this is
  /// for the fallback bars and screen readers.
  final String label;

  const TabActionButtonSpec({
    required this.symbol,
    required this.icon,
    required this.onPressed,
    required this.label,
  });
}
