import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// An action that fires only after the user holds it for the full hold
/// duration.
///
/// Used where the cost of a mis-tap is not a mis-tap: opening a domain the
/// anti-fraud service flagged, or loading an image whose host is untrusted,
/// leaks the user's IP or lands them on a phishing page. A plain tap is too
/// cheap a confirmation for that, so the gesture itself is the confirmation.
///
/// The fill is the only feedback a hold can give — a static label cannot show
/// how much of the gesture is left — so the button fills from the left with
/// [error] while the pointer is down and empties again if it leaves early.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.icon = Symbols.touch_app,
    this.dense = false,
  });

  final String label;

  /// Called once the hold completes.
  final VoidCallback onConfirmed;

  /// Shown before the label, so the label alone does not have to explain that
  /// this button is held rather than tapped.
  final IconData icon;

  /// Tighter padding and a smaller type ramp, for a button sitting inside a
  /// card rather than on a row of its own.
  final bool dense;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  static const _holdDuration = Duration(milliseconds: 900);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onConfirmed();
          _controller.reset();
        }
      });
  }

  void _startHold() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_controller.isCompleted) return;
    _controller.stop();
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textStyle =
        (widget.dense ? textTheme.labelMedium : textTheme.labelLarge)?.copyWith(
          fontWeight: FontWeight.w600,
        );
    final padding = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final radius = BorderRadius.circular(999);

    // A bare Listener never claims the pointer, so inside a scrollable the
    // enclosing drag would win and cancel the hold; the inner detector keeps
    // the pointer until the finger lifts. Semantics carries the same action
    // for users who cannot hold, and the visual label is excluded so the
    // button is announced once.
    return Semantics(
      button: true,
      label: widget.label,
      onLongPress: widget.onConfirmed,
      child: Listener(
        onPointerDown: (_) => _startHold(),
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onLongPress: () {},
          behavior: HitTestBehavior.opaque,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: radius,
              border: widget.dense
                  ? null
                  : Border.all(color: scheme.error.withOpacity(0.35)),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Once the fill reaches the label the label needs the
                // contrasting role, not the accent role.
                final holding = _controller.value > 0;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _controller.value,
                            heightFactor: 1,
                            child: ColoredBox(color: scheme.error),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: padding,
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.icon,
                              size: widget.dense ? 16 : 18,
                              color: holding ? scheme.onError : scheme.error,
                            ),
                            const Gap(8),
                            // One line, so the button keeps the height of the
                            // button it stands in for: a wrapped label would
                            // grow the row the sheet sized itself around.
                            Flexible(
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle?.copyWith(
                                  color: holding
                                      ? scheme.onError
                                      : scheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
