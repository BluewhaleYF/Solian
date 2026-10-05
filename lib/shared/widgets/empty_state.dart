import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// The app's placeholder: what a surface shows when it has nothing to show.
///
/// One shape everywhere — a dimmed icon, a bold line, a quiet explanation and
/// an optional way out — so "nothing here" reads the same in a search tab, a
/// sheet or a settings page. Pass `compact: true` inside panels, overlays and
/// sheets, where a full-page placeholder would shout.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  /// The line that tells the reader what to do next. Omitted when the title
  /// already says everything.
  final String? description;
  final Widget? action;

  /// Overrides the dimmed icon ink — an error placeholder keeps its own tint.
  final Color? iconColor;

  /// Sizes the whole block down for a panel or sheet rather than a page.
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.iconColor,
    this.compact = false,
  });

  /// Long explanations wrap here rather than running the width of a desktop
  /// window.
  static const double maxTextWidth = 420;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final muted = colorScheme.onSurfaceVariant;
    final description = this.description;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 40,
          vertical: compact ? 16 : 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxTextWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: compact ? 28 : 44,
                color: iconColor ?? muted.withValues(alpha: 0.35),
              ),
              Gap(compact ? 10 : 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    (compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
              ),
              if (description != null) ...[
                Gap(compact ? 4 : 6),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    height: compact ? 1.35 : 1.4,
                  ),
                ),
              ],
              if (action != null) ...[Gap(compact ? 12 : 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
