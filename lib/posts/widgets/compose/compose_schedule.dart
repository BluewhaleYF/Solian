import 'package:easy_localization/easy_localization.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the schedule sheet for the current composer state.
Future<void> showComposeScheduleSheet(
  BuildContext context,
  ComposeState state,
) async {
  final scheduledAt = state.scheduledAt.value;
  final isScheduled =
      scheduledAt != null && scheduledAt.isAfter(DateTime.now());

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Symbols.event),
            title: Text(
              isScheduled ? 'postScheduleChange'.tr() : 'postScheduleSet'.tr(),
            ),
            subtitle: isScheduled ? Text(scheduledAt.formatSystem()) : null,
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await ComposeLogic.pickSchedule(context, state);
            },
          ),
          if (isScheduled)
            ListTile(
              leading: const Icon(Symbols.bolt),
              title: Text('postPublishNow'.tr()),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ComposeLogic.clearSchedule(state);
              },
            ),
        ],
      ),
    ),
  );
}

/// Toolbar action that lets the author schedule the post instead of
/// publishing it immediately.
class ComposeScheduleButton extends StatelessWidget {
  final ComposeState state;

  const ComposeScheduleButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: state.scheduledAt,
      builder: (context, scheduledAt, _) {
        final isScheduled =
            scheduledAt != null && scheduledAt.isAfter(DateTime.now());
        return IconButton(
          icon: Icon(isScheduled ? Symbols.event_available : Symbols.event),
          color: isScheduled ? Theme.of(context).colorScheme.primary : null,
          tooltip: isScheduled
              ? 'postScheduledFor'.tr(
                  namedArgs: {'time': scheduledAt.formatSystem()},
                )
              : 'postSchedule'.tr(),
          onPressed: () => showComposeScheduleSheet(context, state),
        );
      },
    );
  }
}

/// Banner shown inside the composer while a publish time is selected.
class ComposeScheduledBanner extends StatelessWidget {
  final ComposeState state;

  const ComposeScheduledBanner({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<DateTime?>(
      valueListenable: state.scheduledAt,
      builder: (context, scheduledAt, _) {
        if (scheduledAt == null || !scheduledAt.isAfter(DateTime.now())) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Symbols.event_available,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'postScheduledFor'.tr(
                    namedArgs: {'time': scheduledAt.formatSystem()},
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
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
