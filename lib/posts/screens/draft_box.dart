import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/pods/draft_box.dart';
import 'package:island/posts/screens/compose_post.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';

/// The authoring box: cloud drafts, posts waiting for their publish time and
/// the drafts that only exist on this device, in one list.
@RoutePage()
class DraftBoxScreen extends HookConsumerWidget {
  const DraftBoxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = draftBoxProvider;

    final statusTop = MediaQuery.paddingOf(context).top;

    return AppScaffold(
      appBarOverContent: true,
      appBar: PillAppBar(
        statusTop: statusTop,
        child: Row(
          children: [
            const AutoLeadingButton(),
            const Gap(SolSpace.xs),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'draftBox'.tr(),
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
      // The pill floats over the body; its band is reserved by the list
      // itself, so drafts scroll under the glass.
      body: PaginationWidget<DraftBoxEntry>(
        provider: provider,
        notifier: provider.notifier,
        contentBuilder: (items, footer) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Symbols.drafts,
              title: 'draftBoxEmpty'.tr(),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              12,
              statusTop + kPillAppBarHeight + SolSpace.sm,
              12,
              24,
            ),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const Gap(8),
            itemBuilder: (context, index) {
              if (index == items.length) return footer;
              return DraftBoxTile(entry: items[index]);
            },
          );
        },
      ),
    );
  }
}

class DraftBoxTile extends ConsumerWidget {
  final DraftBoxEntry entry;

  const DraftBoxTile({super.key, required this.entry});

  String get _previewText {
    final title = entry.post.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    final content = entry.post.content?.trim();
    if (content != null && content.isNotEmpty) return content;
    return 'postPlaceholder'.tr();
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(composeStorageProvider);
    await ref.read(draftBoxProvider.notifier).refresh();
  }

  /// A locally saved draft stores only the ids of the post it replies to,
  /// forwards or chains; resolve them so the composer keeps that context.
  Future<(SnPost?, SnPost?, SnPost?)> _resolveTargets(WidgetRef ref) async {
    final client = ref.read(solarNetworkClientProvider);
    Future<SnPost?> load(String? id) async {
      if (id == null || id.isEmpty) return null;
      try {
        return await client.sphere.getPost(id);
      } catch (_) {
        return null;
      }
    }

    return (
      await load(entry.post.repliedPostId),
      await load(entry.post.forwardedPostId),
      await load(entry.post.chainedPostId),
    );
  }

  Future<void> _openComposer(BuildContext context, WidgetRef ref) async {
    final post = entry.post;
    if (!entry.isLocalOnly) {
      await PostComposeScreen.show(context, originalPost: post);
      return;
    }

    // A draft the server has never seen cannot go through an edit route that
    // fetches it by id; open the composer seeded with the local copy instead.
    switch (post.type) {
      case 1:
        await context.router.push(ArticleComposeRoute(originalPost: post));
      case 2:
        await context.router.push(BlogComposeRoute(originalPost: post));
      default:
        final (repliedPost, forwardedPost, chainedPost) = await _resolveTargets(
          ref,
        );
        if (!context.mounted) return;
        await PostComposeScreen.show(
          context,
          originalPost: post,
          replyingTo: repliedPost,
          forwardingTo: forwardedPost,
          chainingTo: chainedPost,
        );
    }
  }

  Future<void> _upload(WidgetRef ref, BuildContext context) async {
    try {
      showLoadingModal(context);
      await ref
          .read(composeStorageProvider.notifier)
          .uploadDraftToCloud(entry.post.id);
      await _refresh(ref);
      if (context.mounted) showSnackBar('draftUploadedToCloud'.tr());
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _publishNow(WidgetRef ref, BuildContext context) async {
    try {
      showLoadingModal(context);
      final client = ref.read(solarNetworkClientProvider);
      await client.sphere.batchUpdatePostVisibility(
        postIds: [entry.post.id],
        publishedAt: DateTime.now(),
      );
      await _refresh(ref);
      if (context.mounted) showSnackBar('draftPublishNowDone'.tr());
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _unschedule(WidgetRef ref, BuildContext context) async {
    try {
      showLoadingModal(context);
      final client = ref.read(solarNetworkClientProvider);
      await client.sphere.batchUpdatePostVisibility(
        postIds: [entry.post.id],
        draftedAt: DateTime.now(),
      );
      await _refresh(ref);
      if (context.mounted) showSnackBar('draftUnscheduleDone'.tr());
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _delete(WidgetRef ref, BuildContext context) async {
    final confirmed = await showConfirmAlert(
      'deleteDraftConfirmHint'.tr(),
      'deleteDraft'.tr(),
      isDanger: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      showLoadingModal(context);
      if (entry.isLocalOnly) {
        await ref
            .read(composeStorageProvider.notifier)
            .deleteLocalDraft(entry.post.id);
      } else {
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.batchDeletePosts([entry.post.id]);
      }
      await _refresh(ref);
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheduledAt = entry.scheduledAt;
    final publisher = entry.post.publisher;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openComposer(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  scheduledAt != null ? Symbols.event_available : Symbols.draft,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _previewText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Gap(6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _DraftChip(
                          icon: scheduledAt != null
                              ? Symbols.event_available
                              : Symbols.draft,
                          label: scheduledAt != null
                              ? 'postScheduledFor'.tr(
                                  namedArgs: {
                                    'time': scheduledAt.formatSystem(),
                                  },
                                )
                              : 'draft'.tr(),
                        ),
                        if (entry.isLocalOnly)
                          _DraftChip(
                            icon: Symbols.cloud_off,
                            label: 'draftLocalOnly'.tr(),
                          ),
                        if (publisher != null)
                          _DraftChip(
                            icon: Symbols.person,
                            label: publisher.nick.isNotEmpty
                                ? publisher.nick
                                : publisher.name,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_DraftAction>(
                tooltip: 'more'.tr(),
                icon: const Icon(Symbols.more_vert),
                onSelected: (action) async {
                  switch (action) {
                    case _DraftAction.edit:
                      await _openComposer(context, ref);
                    case _DraftAction.upload:
                      await _upload(ref, context);
                    case _DraftAction.publishNow:
                      await _publishNow(ref, context);
                    case _DraftAction.unschedule:
                      await _unschedule(ref, context);
                    case _DraftAction.delete:
                      await _delete(ref, context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _DraftAction.edit,
                    child: Text('edit'.tr()),
                  ),
                  if (entry.isLocalOnly)
                    PopupMenuItem(
                      value: _DraftAction.upload,
                      child: Text('draftUploadToCloud'.tr()),
                    ),
                  if (entry.isScheduled)
                    PopupMenuItem(
                      value: _DraftAction.publishNow,
                      child: Text('postPublishNow'.tr()),
                    ),
                  if (entry.isScheduled)
                    PopupMenuItem(
                      value: _DraftAction.unschedule,
                      child: Text('draftUnschedule'.tr()),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _DraftAction.delete,
                    child: Text('deleteDraft'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DraftAction { edit, upload, publishNow, unschedule, delete }

class _DraftChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DraftChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.secondary),
          const Gap(4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
