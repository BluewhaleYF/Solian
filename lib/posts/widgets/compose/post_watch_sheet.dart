import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_watch.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

/// Opens the post watch filter sheet.
Future<void> showPostWatchSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => const PostWatchSheet(),
  );
}

class _WatchEventRow extends StatelessWidget {
  final String labelKey;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _WatchEventRow({
    required this.labelKey,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: const EdgeInsets.only(left: 20, right: 12),
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(labelKey).tr(),
    );
  }
}

class _WatchSourceSection extends StatelessWidget {
  final String titleKey;
  final String hintKey;
  final IconData icon;
  final List<Widget> rows;

  const _WatchSourceSection({
    required this.titleKey,
    required this.hintKey,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey,
                    ).tr().fontWeight(FontWeight.w600).fontSize(15),
                    const Gap(2),
                    Text(hintKey)
                        .tr()
                        .fontSize(12)
                        .textColor(theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...rows,
      ],
    );
  }
}

/// Filter editor for the three post watch sources.
///
/// Every change is written immediately: the server merges partial writes, so
/// a toggle only has to send its own source back.
class PostWatchSheet extends HookConsumerWidget {
  const PostWatchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(postWatchPreferencesProvider);
    final overrides = useState<Map<PostWatchSource, SnPostWatchPreference>>({});

    final preferences = [
      for (final base
          in preferencesAsync.value ?? const <SnPostWatchPreference>[])
        overrides.value[base.source] ?? base,
    ];

    Future<void> apply(SnPostWatchPreference updated) async {
      final previous = overrides.value[updated.source];
      overrides.value = {...overrides.value, updated.source: updated};
      try {
        final server = await savePostWatchPreferences(ref, [updated]);
        overrides.value = {for (final item in server) item.source: item};
      } catch (err) {
        final reverted = {...overrides.value};
        if (previous == null) {
          reverted.remove(updated.source);
        } else {
          reverted[updated.source] = previous;
        }
        overrides.value = reverted;
        if (context.mounted) showErrorAlert(err);
      }
    }

    Widget? buildSourceSection({
      required PostWatchSource source,
      required String titleKey,
      required String hintKey,
      required IconData icon,
    }) {
      final preference = preferences
          .where((item) => item.source == source)
          .firstOrNull;
      if (preference == null) return null;

      return _WatchSourceSection(
        titleKey: titleKey,
        hintKey: hintKey,
        icon: icon,
        rows: [
          _WatchEventRow(
            labelKey: 'postWatchEventReactions',
            icon: Symbols.favorite,
            value: preference.notifyReactions,
            onChanged: (value) =>
                apply(preference.copyWith(notifyReactions: value)),
          ),
          _WatchEventRow(
            labelKey: 'postWatchEventReplies',
            icon: Symbols.reply,
            value: preference.notifyReplies,
            onChanged: (value) =>
                apply(preference.copyWith(notifyReplies: value)),
          ),
          _WatchEventRow(
            labelKey: 'postWatchEventChains',
            icon: Symbols.linear_scale,
            value: preference.notifyChains,
            onChanged: (value) =>
                apply(preference.copyWith(notifyChains: value)),
          ),
          _WatchEventRow(
            labelKey: 'postWatchEventForwards',
            icon: Symbols.repeat,
            value: preference.notifyForwards,
            onChanged: (value) =>
                apply(preference.copyWith(notifyForwards: value)),
          ),
          _WatchEventRow(
            labelKey: 'postWatchEventEdits',
            icon: Symbols.edit,
            value: preference.notifyEdits,
            onChanged: (value) =>
                apply(preference.copyWith(notifyEdits: value)),
          ),
        ],
      );
    }

    return SheetScaffold(
      titleText: 'postWatchSettings'.tr(),
      heightFactor: 0.85,
      child: preferencesAsync.isLoading && preferences.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : preferences.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'postWatchLoadFailed',
                      textAlign: TextAlign.center,
                    ).tr(),
                    const Gap(12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(postWatchPreferencesProvider),
                      child: Text('retry').tr(),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text('postWatchSettingsDescription').tr().fontSize(12),
                ),
                ...[
                  buildSourceSection(
                    source: PostWatchSource.bookmark,
                    titleKey: 'postWatchSectionBookmark',
                    hintKey: 'postWatchSectionBookmarkHint',
                    icon: Symbols.bookmark,
                  ),
                  buildSourceSection(
                    source: PostWatchSource.reaction,
                    titleKey: 'postWatchSectionReaction',
                    hintKey: 'postWatchSectionInteractionHint',
                    icon: Symbols.favorite,
                  ),
                  buildSourceSection(
                    source: PostWatchSource.reply,
                    titleKey: 'postWatchSectionReply',
                    hintKey: 'postWatchSectionInteractionHint',
                    icon: Symbols.reply,
                  ),
                ].whereType<Widget>(),
              ],
            ),
    );
  }
}
