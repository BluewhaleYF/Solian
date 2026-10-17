import 'package:material_ui/material_ui.dart';
import 'package:island/core/theme.dart';

/// Vertical gap between two floating cards in the explore feed.
///
/// Every card in the feed — sections, posts, discovery suggestions — uses the
/// same gap so the page reads as one evenly spaced stack instead of a mix of
/// bands and rows.
const double kExploreCardGap = SolSpace.md;

/// A flat floating surface used by the explore page.
///
/// The explore feed has no page-wide background surface: sections, posts and
/// suggestion items each own a card. Separation comes from tone and a uniform
/// gap, never from elevation, so the card always paints flat (the global card
/// theme also uses elevation 0).
class ExploreCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final Clip clipBehavior;

  const ExploreCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = SolRadius.card,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: color,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: padding == null
          ? child
          : Padding(padding: padding!, child: child),
    );
  }
}

/// Horizontal gutter used by the explore page.
///
/// The feed uses one 12px gap between cards, so the side margin matches it:
/// the stacked cards read as one evenly spaced column instead of a narrow
/// column floating inside wide page gutters.
EdgeInsets explorePageGutter(BuildContext context) =>
    const EdgeInsets.symmetric(horizontal: SolSpace.md);
