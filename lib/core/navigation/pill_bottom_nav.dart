import 'package:material_ui/material_ui.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/pill_surface.dart';

/// Vertical gutter between the floating tab bar and the edges of its band.
///
/// Same value as the header pills' side gutter, so the two bars read as one
/// family: the capsule is inset from the viewport on all three free sides
/// rather than welded to the bottom edge.
const double kBottomNavGutter = SolSpace.md;

/// Height the tab bar's scaffold slot occupies beyond its own controls.
///
/// A `Scaffold(extendBody: true)` hands the slot's full height to the page as
/// `MediaQuery.padding.bottom`, so a page that has to clear the bar — and any
/// test standing in for the shell — should size the bar as
/// `kBottomNavHeight + kBottomNavPillInset + safeArea`.
const double kBottomNavPillInset = kBottomNavGutter * 2;

/// Bottom bar floated as a capsule over the page, matching the header pills.
///
/// [PillSurface] always fully surfaced: unlike a header, which fades in only
/// once content has slid under it, a persistent control has to stay legible
/// over whatever the page paints beneath it.
///
/// The home-indicator inset is spent *outside* the capsule — the bar's own
/// `SafeArea` is muted and the inset folded into the pill's bottom margin —
/// so the capsule floats clear of the system chrome instead of growing a
/// slab of dead surface below its controls.
class PillBottomNav extends StatelessWidget {
  final Widget child;

  const PillBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // `viewPadding` rather than `padding`: the slot must reserve the device
    // inset even when an ancestor has already folded a bar height into it.
    final safeArea = MediaQuery.viewPaddingOf(context).bottom;
    return PillSurface(
      t: 1,
      margin: EdgeInsets.fromLTRB(
        kPillSideGutter,
        kBottomNavGutter,
        kPillSideGutter,
        kBottomNavGutter + safeArea,
      ),
      radius: SolRadius.pillRadius,
      // Wider than a header's inset: the bar's end destinations need room to
      // breathe inside the capsule's end caps.
      contentPadding: const EdgeInsets.symmetric(horizontal: SolSpace.lg),
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}