import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_attachment_thumbnails.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The element tag [PostLinkEmbedSyntax] emits and [PostLinkEmbedBuilder]
/// answers to.
const String postLinkEmbedTag = 'post-embed';

/// Post ids are UUIDs, so a bare `solian.app/posts/<something>` only counts as
/// a post link when the segment after `posts` is one. Without this, routes that
/// merely live under `/posts` (`/posts/categories`) would be fetched as posts.
final RegExp _postIdPattern = RegExp(
  r'^[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}$',
  caseSensitive: false,
);

/// A paragraph made of nothing but a Solian post link becomes a [PostLinkEmbed]
/// instead of a link: the preview reads better than the URL it replaces, which
/// is exactly the case a bare URL makes worst (it is not even a link here —
/// nothing linkifies bare URLs in this renderer).
///
/// Only a link that stands alone qualifies. A URL inside a sentence keeps its
/// text, and so does one the author labelled — `[看看这篇](https://…)` exists to
/// say something with the label, and a card would throw those words away.
class PostLinkEmbedSyntax extends markdown.BlockSyntax {
  const PostLinkEmbedSyntax();

  /// The whole line: up to three leading spaces (four would be indented code),
  /// then either a markdown link or a bare URL, then only trailing spaces.
  static final RegExp _standalonePostLink = RegExp(
    r'^ {0,3}(?:\[(?<label>[^\]]*)\]\((?<labelled>[^)\s]+)\)|(?<bare>[^\s\[\]()]+)) *$',
  );

  @override
  RegExp get pattern => _standalonePostLink;

  @override
  bool canParse(markdown.BlockParser parser) {
    if (_linkOnLine(parser.current.content) == null) return false;
    // …and nothing else may share its paragraph, or the card would cut a
    // sentence in half.
    final next = parser.peek(1);
    if (next != null && next.content.trim().isNotEmpty) return false;
    return _startsParagraph(parser);
  }

  @override
  bool canEndBlock(markdown.BlockParser parser) => _startsParagraph(parser);

  @override
  markdown.Node? parse(markdown.BlockParser parser) {
    final link = _linkOnLine(parser.current.content);
    // Not ours after all: leave the line for the paragraph syntax rather than
    // eating text a preview cannot stand in for.
    if (link == null) return null;
    parser.advance();
    return markdown.Element.withTag(postLinkEmbedTag)
      ..attributes['post-id'] = link.id
      ..attributes['href'] = link.href;
  }

  /// The Solian post link [content] holds and nothing else, or null when the
  /// line carries anything more, points somewhere else, or names a
  /// non-post id.
  static ({String id, String href})? _linkOnLine(String content) {
    final match = _standalonePostLink.firstMatch(content);
    if (match == null) return null;

    final label = match.namedGroup('label');
    final href = (match.namedGroup('labelled') ?? match.namedGroup('bare')!)
        .trim();
    // A labelled link says its own thing; only a label repeating the URL is an
    // unlabelled link.
    if (label != null && label.trim() != href) return null;

    final uri = Uri.tryParse(href);
    if (uri == null) return null;
    final id = parsePostLinkId(uri);
    if (id == null || !_postIdPattern.hasMatch(id)) return null;
    return (id: id, href: href);
  }
}

/// Whether the line under the parser opens a block of its own instead of
/// continuing the paragraph above it. `BlockParser.currentSyntax` still names
/// that paragraph while its own loop is walking the lines — the same signal
/// `SetextHeaderSyntax` reads to find the text it underlines.
bool _startsParagraph(markdown.BlockParser parser) =>
    parser.currentSyntax is! markdown.ParagraphSyntax;

/// Renders the element [PostLinkEmbedSyntax] emits.
class PostLinkEmbedBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    markdown.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final id = element.attributes['post-id'];
    if (id == null || id.isEmpty) return null;
    return PostLinkEmbed(
      postId: id,
      href: element.attributes['href'] ?? 'https://solian.app/posts/$id',
    );
  }
}

/// The post a Solian link points at, drawn inline in the content that linked
/// it: who wrote it, what it says, its media, and how much conversation it has.
///
/// The fetch goes through [postProvider] — the same one the post detail screen
/// reads — so opening the post afterwards is instant.
///
/// The body is reduced to [markdownToPlainLine] prose rather than rendered as
/// markdown: a preview has to be cheap and cannot grow with its post, and text
/// keeps it from nesting one post's media, stickers and embeds inside another.
class PostLinkEmbed extends ConsumerWidget {
  /// Characters of the post body the preview keeps before it elides the rest.
  static const int maxExcerptLength = 600;

  final String postId;

  /// The link this embed replaced, kept for the fallback: a post the viewer
  /// cannot read is still something they can try to open.
  final String href;

  const PostLinkEmbed({super.key, required this.postId, required this.href});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(postProvider(postId))
        .when(
          data: (post) => post == null
              ? _UnavailablePostLink(postId: postId, href: href)
              : _buildCard(context, post),
          loading: () => const _PostLinkEmbedSkeleton(),
          error: (_, _) => _UnavailablePostLink(postId: postId, href: href),
        );
  }

  Widget _buildCard(BuildContext context, SnPost post) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = post.title?.trim();
    final excerpt = _excerpt(post);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: _borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          // The modal keeps the reader where they were reading — the same view
          // a tapped post link opens, one card closer.
          onTap: () => showPostDetailAttentionModal(post.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _PostLinkEmbedHeader(post: post),
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (excerpt.isNotEmpty)
                  Text(
                    excerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                if (post.attachments.isNotEmpty)
                  PostAttachmentThumbnails(attachments: post.attachments),
                _PostLinkEmbedStats(post: post),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The one line of prose the preview shows for [post]'s body.
  String _excerpt(SnPost post) {
    final raw = post.content ?? '';
    if (raw.trim().isEmpty) return '';

    // Articles carry HTML; everything else is markdown.
    final plain = post.contentType == 1
        ? raw.htmlToPlainText()
        : raw.markdownToPlainLine();
    if (plain.length <= maxExcerptLength) return plain;
    return '${plain.substring(0, maxExcerptLength).trimRight()}…';
  }
}

const BorderRadius _borderRadius = BorderRadius.all(Radius.circular(12));

/// Author, handle and age of the embedded post, with the affordance that says
/// the card opens.
class _PostLinkEmbedHeader extends StatelessWidget {
  final SnPost post;

  const _PostLinkEmbedHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final publisher = post.publisher;
    final realmNick = publisher?.realmNick?.trim();
    final name = (realmNick != null && realmNick.isNotEmpty)
        ? realmNick
        : publisher?.effectiveName ?? 'unknown'.tr();
    final handle = publisher?.handle;
    final age = (post.publishedAt ?? post.createdAt)?.formatRelative(context);
    final subtitle = [
      if (handle != null && handle.isNotEmpty) '@$handle',
      if (age != null && age.isNotEmpty) age,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        ProfilePictureWidget(
          file: publisher?.picture ?? publisher?.account?.profile.picture,
          fallbackName: publisher?.nick,
          radius: 14,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                spacing: 4,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (publisher?.verification != null)
                    VerificationMark(
                      mark: publisher!.verification!,
                      hideOverlay: true,
                    ),
                ],
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Symbols.open_in_new,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// How much conversation the embedded post carries, when it carries any.
class _PostLinkEmbedStats extends StatelessWidget {
  final SnPost post;

  const _PostLinkEmbedStats({required this.post});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reactions = post.reactionsCount.values.fold<int>(
      0,
      (total, count) => total + count,
    );
    if (post.repliesCount == 0 && reactions == 0) {
      return const SizedBox.shrink();
    }

    Widget stat(IconData icon, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Icon(icon, size: 15, color: scheme.onSurfaceVariant),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );

    return Row(
      spacing: 14,
      children: [
        if (post.repliesCount > 0)
          stat(Symbols.mode_comment, 'repliesCount'.plural(post.repliesCount)),
        if (reactions > 0) stat(Symbols.add_reaction, '$reactions'),
      ],
    );
  }
}

/// The space the preview will take, so a body that links a post does not jump
/// when the post arrives.
class _PostLinkEmbedSkeleton extends StatelessWidget {
  const _PostLinkEmbedSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bone = scheme.surfaceContainerHighest;

    Widget box({double? width, required double height, double radius = 4}) =>
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bone,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: scheme.surfaceContainerHigh,
        highlightColor: scheme.surfaceContainerHighest,
      ),
      containersColor: scheme.surfaceContainerLow,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: _borderRadius,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 10,
              children: [
                box(width: 28, height: 28, radius: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [box(width: 120, height: 11), box(width: 80, height: 9)],
                ),
              ],
            ),
            box(width: double.infinity, height: 11),
            box(width: double.infinity, height: 11),
            box(width: 160, height: 11),
          ],
        ),
      ),
    );
  }
}

/// What is left of the link when the post cannot be shown: the URL itself,
/// tappable through the same path any other Solian link takes, next to a retry
/// for the loads that fail merely because the network was away.
class _UnavailablePostLink extends ConsumerWidget {
  final String postId;
  final String href;

  const _UnavailablePostLink({required this.postId, required this.href});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: _borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  final uri = Uri.tryParse(href);
                  if (uri != null) openExternalLink(uri, ref);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(
                        Symbols.link,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      Expanded(
                        child: Text(
                          href,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => ref.invalidate(postProvider(postId)),
              icon: const Icon(Symbols.refresh, size: 18),
              tooltip: 'retry'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
