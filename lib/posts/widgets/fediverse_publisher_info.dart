import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:island/core/network.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/pagination_list.dart';

import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';

/// Relationship the current account has with a remote fediverse actor.
///
/// Remote actors are ordinary publishers now, so this only carries the
/// ActivityPub level follow state that a local subscription cannot express.
final fediverseActorRelationshipProvider = FutureProvider.autoDispose
    .family<FediverseActorRelationship?, String>((ref, actorId) async {
      final client = ref.watch(solarNetworkClientProvider);
      try {
        return await client.sphere.getActorRelationship(actorId);
      } catch (err) {
        if (err is DioException && err.response?.statusCode == 404) return null;
        rethrow;
      }
    });

/// Posts of a remote actor, including its boosts and cached remote posts.
final fediverseActorPostsProvider = AsyncNotifierProvider.autoDispose
    .family<FediverseActorPostsNotifier, PaginationState<SnPost>, String>(
      FediverseActorPostsNotifier.new,
    );

class FediverseActorPostsNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int pageSize = 20;

  final String actorId;

  FediverseActorPostsNotifier(this.actorId);

  @override
  Future<PaginationState<SnPost>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final result = await client.sphere.getActorPosts(
      actorId,
      offset: fetchedCount,
      take: pageSize,
    );
    totalCount = result.totalCount;
    return result.items;
  }
}

class FediverseActorPostsWidget extends ConsumerWidget {
  final String actorId;

  const FediverseActorPostsWidget({super.key, required this.actorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = fediverseActorPostsProvider(actorId);

    // Same presentation as the local publisher timeline: flat rows split by a
    // divider, so the hosts may render either list flush inside their card.
    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: PostItemSkeleton(maxWidth: double.infinity),
      ),
      seperatorBuilder: (context, index, post) => const Divider(height: 1),
      itemBuilder: (context, index, post) {
        return PostActionableItem(
          item: post,
          borderRadius: 8,
          onTap: !post.isCached && post.fediverseUri != null
              ? () => launchUrlString(post.fediverseUri!)
              : null,
        );
      },
    );
  }
}

/// Card linking back to the actor page on its home instance.
class FediverseOriginHintCard extends StatelessWidget {
  final SnPublisher data;

  const FediverseOriginHintCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final webUrl = data.webUrl;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: webUrl != null ? () => launchUrlString(webUrl) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Symbols.hub, size: 20, color: theme.colorScheme.primary),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'fediverseProfileHint'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (webUrl != null)
                      Text(
                        'viewOnOriginalSite'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              if (webUrl != null)
                Icon(
                  Symbols.open_in_new,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hashtags and custom emojis the remote actor advertises.
class FediverseActorTagsCard extends StatelessWidget {
  final SnPublisher data;

  const FediverseActorTagsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tagList = data.metadata?['tag'];
    if (tagList is! List || tagList.isEmpty) return const SizedBox.shrink();

    final emojis = <Map<String, dynamic>>[];
    final hashtags = <Map<String, dynamic>>[];
    for (final item in tagList) {
      if (item is! Map<String, dynamic>) continue;
      final type = item['type'] as String?;
      if (type == 'Emoji') {
        emojis.add(item);
      } else if (type == 'Hashtag') {
        hashtags.add(item);
      }
    }

    if (emojis.isEmpty && hashtags.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emojis.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: emojis.map((emoji) {
                  final icon = emoji['icon'] as Map<String, dynamic>?;
                  final url = icon?['url'] as String?;
                  final name = emoji['name'] as String? ?? '';
                  return Tooltip(
                    message: name,
                    child: url != null
                        ? CachedNetworkImage(
                            imageUrl: url,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Text(
                              name,
                              style: const TextStyle(fontSize: 16),
                            ),
                            errorWidget: (context, url, error) => Text(
                              name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        : Text(name, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            if (emojis.isNotEmpty && hashtags.isNotEmpty) const Gap(8),
            if (hashtags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hashtags.map((tag) {
                  final href = tag['href'] as String?;
                  final name = tag['name'] as String? ?? '';
                  return ActionChip(
                    label: Text(
                      name,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    avatar: const Icon(Symbols.tag, size: 14),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: href != null
                        ? () => launchUrlString(href)
                        : null,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Profile metadata fields (PropertyValue attachments) of a remote actor.
class FediverseActorFieldsCard extends StatelessWidget {
  final SnPublisher data;

  const FediverseActorFieldsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final attachments = data.metadata?['attachment'];
    if (attachments is! List || attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final validAttachments = attachments
        .whereType<Map<String, dynamic>>()
        .where((a) => a['type'] == 'PropertyValue')
        .toList();

    if (validAttachments.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('profileFields'.tr(), style: theme.textTheme.titleSmall),
            const Gap(8),
            ...validAttachments.map((attachment) {
              final name = attachment['name'] as String? ?? '';
              final value = attachment['value'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: _PropertyValueRenderer(html: value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PropertyValueRenderer extends StatelessWidget {
  final String html;

  const _PropertyValueRenderer({required this.html});

  @override
  Widget build(BuildContext context) {
    final plainText = html.htmlToPlainText();
    final uri = _extractFirstLink(html);

    final child = Text(
      plainText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: uri != null ? Theme.of(context).colorScheme.primary : null,
      ),
    );

    if (uri != null) {
      return InkWell(
        onTap: () => launchUrlString(uri),
        borderRadius: BorderRadius.circular(4),
        child: child.padding(horizontal: 2),
      );
    }
    return child;
  }

  String? _extractFirstLink(String input) {
    final match = RegExp(r'href="([^"]*)"').firstMatch(input);
    return match?.group(1);
  }
}

/// Misskey style welcome message the actor asks followers to read.
class FediverseFollowedMessageCard extends StatelessWidget {
  final SnPublisher data;

  const FediverseFollowedMessageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final message = data.metadata?['_misskey_followedMessage'] as String?;
    if (message?.isEmpty ?? true) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const Gap(8),
            Expanded(
              child: MarkdownTextContent(
                content: message!,
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Relative last activity of a remote actor.
class FediverseLastActiveCard extends StatelessWidget {
  final DateTime lastActivityAt;

  const FediverseLastActiveCard({super.key, required this.lastActivityAt});

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inDays > 30) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '${date.year}-$month-$day';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'justNow'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Symbols.schedule,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const Gap(8),
            Expanded(
              child: Text(
                'lastActiveAt'.tr(args: [_formatDate(lastActivityAt)]),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every fediverse-only card of an actor profile, in display order.
class FediversePublisherInfoCards extends StatelessWidget {
  final SnPublisher data;

  const FediversePublisherInfoCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if ((data.metadata?['_misskey_followedMessage'] as String?)?.isNotEmpty ??
            false)
          FediverseFollowedMessageCard(data: data),
        FediverseOriginHintCard(data: data),
        FediverseActorTagsCard(data: data),
        FediverseActorFieldsCard(data: data),
        if (data.lastActivityAt != null)
          FediverseLastActiveCard(lastActivityAt: data.lastActivityAt!),
      ],
    );
  }
}
