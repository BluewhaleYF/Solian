import 'package:easy_localization/easy_localization.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/theme.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Publish-time control of the composer, rendered as one decorated field
/// beside the other post settings.
///
/// Scheduling is a post property like visibility or the language, so it lives
/// in the settings sheet as a field instead of a toolbar action that opens a
/// sheet for a single tap. An unset schedule reads as "not set" inside the
/// field; a set one shows the time it will be published at.
class ComposeScheduleField extends StatelessWidget {
  final ComposeState state;

  const ComposeScheduleField({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<DateTime?>(
      valueListenable: state.scheduledAt,
      builder: (context, scheduledAt, _) {
        final scheduled =
            scheduledAt != null && scheduledAt.isAfter(DateTime.now());
        return InputDecorator(
          // The label floats, like every composite field: the value row owns
          // the inside of the field, so the label never sits over it.
          decoration: InputDecoration(
            labelText: 'postSchedule'.tr(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SolSpace.lg,
              vertical: SolSpace.md,
            ),
          ),
          child: Wrap(
            spacing: SolSpace.sm,
            runSpacing: SolSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                scheduled ? Symbols.event_available : Symbols.event,
                size: 20,
                color: scheduled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              Text(
                scheduled
                    ? 'postScheduledFor'.tr(
                        namedArgs: {'time': scheduledAt.formatSystem()},
                      )
                    : 'notSet'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheduled ? null : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => ComposeLogic.pickSchedule(context, state),
                child: Text(
                  (scheduled ? 'postScheduleChange' : 'postScheduleSet').tr(),
                ),
              ),
              if (scheduled)
                TextButton(
                  onPressed: () => ComposeLogic.clearSchedule(state),
                  child: Text('postPublishNow'.tr()),
                ),
            ],
          ),
        );
      },
    );
  }
}
