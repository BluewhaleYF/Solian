import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/bookmarks.dart';
import 'package:island/posts/widgets/compose/post_watch_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

/// Explains that the post is being watched, and opens the filter sheet.
///
/// A post is watched once the account bookmarked, reacted to, or replied to it;
/// only the first two are visible on the client, so the row shows for those.
class PostWatchIndicator extends ConsumerWidget {
  final SnPost post;

  const PostWatchIndicator({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked =
        ref.watch(bookmarkStatusProvider(post.id)).value != null ||
        post.isBookmarked;
    final reacted = post.reactionsMade.isNotEmpty;
    if (!bookmarked && !reacted) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showPostWatchSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Symbols.notifications_active,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text('postWatchHint').tr().fontSize(12)),
            Icon(
              Symbols.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
