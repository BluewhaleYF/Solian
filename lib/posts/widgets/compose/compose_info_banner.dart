import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/core/theme.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A compose indicator — editing, replying, forwarding, chaining — as a
/// floating card.
///
/// The composer page has no page-wide surface: the fields sit straight on the
/// page ground, so these indicators are the only chrome above them. They
/// float like the cards in the feed instead of bleeding off both edges as
/// bands: inset from the form's sides, one corner radius, one tone.
class ComposeIndicatorCard extends StatelessWidget {
  final Widget child;

  /// The card's fill. Defaults to the feed's card tone; a caller overrides it
  /// to mark a mode (editing) with a color.
  final Color? color;

  const ComposeIndicatorCard({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // The top margin is what floats the card: the first indicator keeps
      // clear of the top edge, and a second one steps down by the same gap.
      margin: const EdgeInsets.fromLTRB(
        SolSpace.lg,
        SolSpace.md,
        SolSpace.lg,
        0,
      ),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: SolRadius.cardRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

/// A reusable widget for displaying info banners in compose screens.
/// Shows editing, reply, forward, and chain information.
class ComposeInfoBanner extends StatelessWidget {
  final SnPost? originalPost;
  final SnPost? replyingTo;
  final SnPost? forwardingTo;
  final SnPost? chainingTo;
  final Function(BuildContext, SnPost)? onReferencePostTap;

  const ComposeInfoBanner({
    super.key,
    this.originalPost,
    this.replyingTo,
    this.forwardingTo,
    this.chainingTo,
    this.onReferencePostTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRepliedPost = replyingTo ?? originalPost?.repliedPost;
    final effectiveForwardedPost = forwardingTo ?? originalPost?.forwardedPost;
    final effectiveChainedPost = chainingTo ?? originalPost?.chainedPost;

    // One list, one shape: every indicator is a floating card, and an edited
    // post simply carries its mode's card above the ones it also relates to.
    final indicators = <Widget>[
      if (originalPost != null) _buildEditingIndicator(context),
      if (effectiveRepliedPost != null)
        _buildReferenceIndicator(
          context,
          effectiveRepliedPost,
          Symbols.reply,
          'postReplyingTo'.tr(),
        ),
      if (effectiveForwardedPost != null)
        _buildReferenceIndicator(
          context,
          effectiveForwardedPost,
          Symbols.forward,
          'postForwardingTo'.tr(),
        ),
      if (effectiveChainedPost != null)
        _buildReferenceIndicator(
          context,
          effectiveChainedPost,
          Symbols.link,
          'postChainingTo'.tr(),
        ),
    ];

    if (indicators.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: indicators,
    );
  }

  /// The card announcing that an existing post is being edited.
  Widget _buildEditingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return ComposeIndicatorCard(
      color: theme.colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Symbols.edit,
            size: 16,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const Gap(8),
          Text(
            'postEditing'.tr(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ).padding(horizontal: SolSpace.lg, vertical: SolSpace.sm),
    );
  }

  /// The card naming the post a reply, forward or chain relates to, with the
  /// post itself inlined below the label.
  Widget _buildReferenceIndicator(
    BuildContext context,
    SnPost post,
    IconData icon,
    String label,
  ) {
    final theme = Theme.of(context);
    return ComposeIndicatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const Gap(6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(SolSpace.sm),
          CompactReferencePost(
            post: post,
            onTap: onReferencePostTap != null
                ? () => onReferencePostTap!(context, post)
                : null,
          ),
        ],
      ).padding(all: SolSpace.lg),
    );
  }
}

/// A compact widget for displaying reference posts (replies/forwards).
class CompactReferencePost extends StatelessWidget {
  final SnPost post;
  final VoidCallback? onTap;

  const CompactReferencePost({super.key, required this.post, this.onTap});

  Widget _buildProfilePicture(BuildContext context) {
    // Handle publisher case
    if (post.publisher != null) {
      return ProfilePictureWidget(
        file: post.publisher!.picture,
        fallbackName: post.publisher!.nick,
        radius: 16,
      );
    }
    // Remote actors keep their avatar on the home instance as a plain URL.
    final publisher = post.publisher;
    final actorAvatar = publisher?.picture?.storageUrl;
    if (publisher?.isFediverse == true &&
        actorAvatar != null &&
        actorAvatar.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          actorAvatar,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 32,
            height: 32,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Symbols.account_circle,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }
    // Fallback
    return ProfilePictureWidget(file: null, radius: 16);
  }

  String _getDisplayName() {
    final publisher = post.publisher;
    if (publisher == null) return 'Unknown';
    return publisher.effectiveName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      // Flat: the indicator card around this row is the card, so the
      // reference post itself carries no surface of its own — only its
      // content and the affordance that opens it.
      child: Row(
        children: [
          _buildProfilePicture(context),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (post.title?.isNotEmpty ?? false)
                  Text(
                    post.title!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (post.content?.isNotEmpty ?? false)
                  Text(
                    post.content!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (post.attachments.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.attach_file,
                        size: 12,
                        color: theme.colorScheme.secondary,
                      ),
                      const Gap(4),
                      Text(
                        'postHasAttachments'.plural(post.attachments.length),
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Symbols.open_in_full,
              size: 16,
              color: theme.colorScheme.outline,
            ),
        ],
      ),
    );
  }
}
