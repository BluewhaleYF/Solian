import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/posts/widgets/compose/post_card_tile.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final publisherCollectionsProvider = FutureProvider.autoDispose
    .family<List<SnPostCollection>, String>((ref, pubName) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.sphere.listPublisherCollections(pubName);
    });

final collectionPostsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<SnPost>, (String, String)>((ref, args) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.sphere.listPublisherCollectionPosts(
        publisherName: args.$1,
        slug: args.$2,
      );
    });

/// Sheet width ceiling for the card column: covers stop growing before they
/// turn a list row into a full-bleed hero on a desktop window.
const double _kContentMaxWidth = 720;

enum _CollectionAction { edit, delete }

enum _CoverAction { changeBackground, changeIcon, removeBackground, removeIcon }

/// Deletes a collection after confirmation. Returns true when it is gone, so
/// callers can pop a sheet or refresh a list without repeating the flow.
Future<bool> _deleteCollection(
  BuildContext context,
  WidgetRef ref, {
  required String pubName,
  required String slug,
}) async {
  final confirm = await showConfirmAlert(
    'deleteThisCollection'.tr(),
    'deleteCollection'.tr(),
    isDanger: true,
  );
  if (confirm != true || !context.mounted) return false;

  try {
    final client = ref.read(solarNetworkClientProvider);
    await client.sphere.deletePublisherCollection(
      publisherName: pubName,
      slug: slug,
    );
    return true;
  } catch (err) {
    showErrorAlert(err);
    return false;
  }
}

@RoutePage()
class CreatorPostCollectionsScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostCollectionsScreen({
    super.key,
    @PathParam("pubName") required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(publisherCollectionsProvider(pubName));

    Future<void> reload() async {
      ref.invalidate(publisherCollectionsProvider(pubName));
      await ref.read(publisherCollectionsProvider(pubName).future);
    }

    Future<void> editCollection([SnPostCollection? existing]) async {
      final result = await showModalBottomSheet<SnPostCollection>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            _CollectionEditorSheet(pubName: pubName, existing: existing),
      );
      if (result != null) {
        ref.invalidate(publisherCollectionsProvider(pubName));
      }
    }

    Future<void> openCollection(SnPostCollection collection) async {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            _CollectionDetailSheet(pubName: pubName, collection: collection),
      );
      ref.invalidate(publisherCollectionsProvider(pubName));
    }

    Future<void> deleteCollection(SnPostCollection collection) async {
      final removed = await _deleteCollection(
        context,
        ref,
        pubName: pubName,
        slug: collection.slug,
      );
      if (removed) {
        ref.invalidate(publisherCollectionsProvider(pubName));
      }
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('collections'.tr()),
      ),
      // The empty state already offers the same action; two competing
      // "new collection" buttons on a blank page is one too many.
      floatingActionButton: collections.value?.isEmpty == true
          ? null
          : FloatingActionButton.extended(
              onPressed: editCollection,
              icon: const Icon(Symbols.add),
              label: Text('newCollection'.tr()),
            ),
      body: collections.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Symbols.collections,
              title: 'noCollections'.tr(),
              description: 'collectionsEmptyHint'.tr(),
              action: FilledButton.icon(
                onPressed: editCollection,
                icon: const Icon(Symbols.add),
                label: Text('newCollection'.tr()),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: reload,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gutter = constraints.maxWidth > _kContentMaxWidth
                    ? (constraints.maxWidth - _kContentMaxWidth) / 2
                    : SolSpace.lg;
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(gutter, SolSpace.md, gutter, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Gap(SolSpace.md),
                  itemBuilder: (context, index) {
                    final collection = items[index];
                    return _CollectionCard(
                      collection: collection,
                      onOpen: () => openCollection(collection),
                      onAction: (action) {
                        switch (action) {
                          case _CollectionAction.edit:
                            editCollection(collection);
                          case _CollectionAction.delete:
                            deleteCollection(collection);
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(publisherCollectionsProvider(pubName)),
        ),
      ),
    );
  }
}

/// The collection as the reader meets it on the publisher profile: cover art,
/// icon, name and identifier. Management reuses that card instead of inventing
/// a second, unrelated row for the same object.
class _CollectionCover extends StatelessWidget {
  final IDisplayableCloudFile? background;
  final IDisplayableCloudFile? icon;
  final String title;
  final String? description;
  final String? meta;
  final int descriptionMaxLines;
  final double iconRadius;
  final double maxHeight;
  final double minHeight;

  /// Height used when there is no artwork. A card should not reserve a
  /// banner-sized hole for a cover the creator has not chosen yet.
  final double emptyHeight;
  final VoidCallback? onTap;
  final VoidCallback? onIconTap;
  final Widget? overlayAction;

  const _CollectionCover({
    required this.title,
    this.background,
    this.icon,
    this.description,
    this.meta,
    this.descriptionMaxLines = 1,
    this.iconRadius = 22,
    this.maxHeight = 240,
    this.minHeight = 132,
    this.emptyHeight = 88,
    this.onTap,
    this.onIconTap,
    this.overlayAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = background != null;
    final titleColor = hasImage ? Colors.white : scheme.onSurface;
    final bodyColor = hasImage
        ? Colors.white.withValues(alpha: 0.8)
        : scheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _kContentMaxWidth;
        final height = hasImage
            ? (width * 7 / 16).clamp(minHeight, maxHeight).toDouble()
            : emptyHeight;
        return SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (background != null)
                CloudFileWidget(item: background!, fit: BoxFit.cover)
              else
                ColoredBox(color: scheme.surfaceContainerHighest),
              if (hasImage)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x94000000)],
                      stops: [0.4, 1],
                    ),
                  ),
                ),
              if (onTap != null)
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onTap),
                ),
              Positioned(
                left: SolSpace.lg,
                // Keep the text clear of the corner menu.
                right: SolSpace.lg + (overlayAction != null ? 44 : 0),
                bottom: SolSpace.md,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onIconTap ?? onTap,
                      child: ProfilePictureWidget(
                        file: icon,
                        radius: iconRadius,
                        fallbackIcon: Symbols.collections,
                      ),
                    ),
                    const Gap(SolSpace.md),
                    Expanded(
                      // Labels describe the card; they are not controls. Let
                      // the tap reach the cover underneath instead of the
                      // paragraph swallowing it.
                      child: IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            if (description != null &&
                                description!.isNotEmpty) ...[
                              const Gap(2),
                              Text(
                                description!,
                                maxLines: descriptionMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: bodyColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                            if (meta != null && meta!.isNotEmpty) ...[
                              const Gap(SolSpace.xs),
                              Text(
                                meta!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: bodyColor,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (overlayAction != null)
                Positioned(
                  top: SolSpace.sm,
                  right: SolSpace.sm,
                  child: overlayAction!,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final SnPostCollection collection;
  final VoidCallback onOpen;
  final ValueChanged<_CollectionAction> onAction;

  const _CollectionCard({
    required this.collection,
    required this.onOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final title = collection.name?.isNotEmpty == true
        ? collection.name!
        : collection.slug;

    return ExploreCard(
      child: _CollectionCover(
        background: collection.background,
        icon: collection.icon,
        title: title,
        description: collection.description,
        // An unnamed collection already shows its slug as the title.
        meta: title == collection.slug ? null : collection.slug,
        onTap: onOpen,
        overlayAction: _OverlayMenuButton<_CollectionAction>(
          items: [
            (
              value: _CollectionAction.edit,
              icon: Symbols.edit,
              label: 'edit'.tr(),
              enabled: true,
            ),
            (
              value: _CollectionAction.delete,
              icon: Symbols.delete,
              label: 'delete'.tr(),
              enabled: true,
            ),
          ],
          onSelected: onAction,
        ),
      ),
    );
  }
}

/// A circular, cover-legible menu. The translucent disc keeps the glyph
/// readable over both bright artwork and the fallback surface.
class _OverlayMenuButton<T> extends StatelessWidget {
  final List<({T value, IconData icon, String label, bool enabled})> items;
  final ValueChanged<T> onSelected;

  const _OverlayMenuButton({required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.32),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<T>(
        tooltip: 'more'.tr(),
        icon: const Icon(Symbols.more_vert, size: 20, color: Colors.white),
        onSelected: onSelected,
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          maximumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
        ),
        itemBuilder: (context) => [
          for (final item in items)
            PopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                children: [
                  Icon(item.icon, size: 18),
                  const Gap(SolSpace.md),
                  Text(item.label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CollectionEditorSheet extends HookConsumerWidget {
  final String pubName;
  final SnPostCollection? existing;

  const _CollectionEditorSheet({required this.pubName, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final slugController = useTextEditingController(text: existing?.slug ?? '');
    final nameController = useTextEditingController(text: existing?.name ?? '');
    final descController = useTextEditingController(
      text: existing?.description ?? '',
    );
    final background = useState<IDisplayableCloudFile?>(existing?.background);
    final icon = useState<IDisplayableCloudFile?>(existing?.icon);
    final saving = useState(false);
    final previewListenable = useMemoized(
      () => Listenable.merge([slugController, nameController]),
    );

    Future<IDisplayableCloudFile?> pickBackground() async {
      final result = await showImagePickerEditor(
        context,
        config: ImageEditorConfig.banner,
        title: 'collectionBackground'.tr(),
      );
      return result as IDisplayableCloudFile?;
    }

    Future<IDisplayableCloudFile?> pickIcon() async {
      final result = await showImagePickerEditor(
        context,
        config: ImageEditorConfig.avatar,
        title: 'collectionIcon'.tr(),
      );
      return result as IDisplayableCloudFile?;
    }

    Future<void> changeBackground() async {
      final picked = await pickBackground();
      // A cancelled picker must not clear an existing cover.
      if (picked != null) background.value = picked;
    }

    Future<void> changeIcon() async {
      final picked = await pickIcon();
      if (picked != null) icon.value = picked;
    }

    Future<void> submit() async {
      if (saving.value) return;
      if (!(formKey.currentState?.validate() ?? false)) return;

      final slug = slugController.text.trim();
      final name = nameController.text.trim();
      final description = descController.text.trim();
      try {
        saving.value = true;
        final client = ref.read(solarNetworkClientProvider);
        final result = existing == null
            ? await client.sphere.createPublisherCollection(
                publisherName: pubName,
                slug: slug,
                name: name.isEmpty ? null : name,
                description: description.isEmpty ? null : description,
                backgroundId: background.value?.id,
                iconId: icon.value?.id,
              )
            : await client.sphere.updatePublisherCollection(
                publisherName: pubName,
                slug: existing!.slug,
                name: name.isEmpty ? null : name,
                description: description.isEmpty ? null : description,
                backgroundId: background.value?.id,
                iconId: icon.value?.id,
                clearBackground:
                    existing?.background != null && background.value == null,
                clearIcon: existing?.icon != null && icon.value == null,
              );
        if (context.mounted) Navigator.pop(context, result);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        saving.value = false;
      }
    }

    return SheetScaffold(
      titleText: existing == null ? 'create'.tr() : 'edit'.tr(),
      heightFactor: 0.9,
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SolSpace.lg,
            SolSpace.lg,
            SolSpace.lg,
            SolSpace.xxl,
          ),
          children: [
            ClipRRect(
              borderRadius: SolRadius.cardRadius,
              child: AnimatedBuilder(
                animation: previewListenable,
                builder: (context, _) {
                  final name = nameController.text.trim();
                  final slug = slugController.text.trim();
                  return _CollectionCover(
                    background: background.value,
                    icon: icon.value,
                    title: name.isNotEmpty
                        ? name
                        : slug.isNotEmpty
                        ? slug
                        : 'untitled'.tr(),
                    meta: slug.isEmpty ? null : slug,
                    iconRadius: 26,
                    maxHeight: 190,
                    minHeight: 120,
                    emptyHeight: 112,
                    onTap: changeBackground,
                    onIconTap: changeIcon,
                    overlayAction: _OverlayMenuButton<_CoverAction>(
                      items: [
                        (
                          value: _CoverAction.changeBackground,
                          icon: Symbols.wallpaper,
                          label: 'collectionChangeBackground'.tr(),
                          enabled: true,
                        ),
                        (
                          value: _CoverAction.changeIcon,
                          icon: Symbols.add_photo_alternate,
                          label: 'collectionChangeIcon'.tr(),
                          enabled: true,
                        ),
                        (
                          value: _CoverAction.removeBackground,
                          icon: Symbols.hide_image,
                          label: 'collectionRemoveBackground'.tr(),
                          enabled: background.value != null,
                        ),
                        (
                          value: _CoverAction.removeIcon,
                          icon: Symbols.no_photography,
                          label: 'collectionRemoveIcon'.tr(),
                          enabled: icon.value != null,
                        ),
                      ],
                      onSelected: (action) {
                        switch (action) {
                          case _CoverAction.changeBackground:
                            changeBackground();
                          case _CoverAction.changeIcon:
                            changeIcon();
                          case _CoverAction.removeBackground:
                            background.value = null;
                          case _CoverAction.removeIcon:
                            icon.value = null;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const Gap(SolSpace.lg),
            TextFormField(
              controller: slugController,
              enabled: existing == null,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'slug'.tr(),
                helperText: existing == null
                    ? 'collectionIdentifier'.tr()
                    : 'collectionSlugLocked'.tr(),
                prefixIcon: const Icon(Symbols.link),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'fieldCannotBeEmpty'.tr();
                }
                return null;
              },
            ),
            const Gap(SolSpace.md),
            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'name'.tr(),
                prefixIcon: const Icon(Symbols.title),
              ),
            ),
            const Gap(SolSpace.md),
            TextFormField(
              controller: descController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'description'.tr(),
                alignLabelWithHint: true,
              ),
            ),
            const Gap(SolSpace.xl),
            SizedBox(
              height: SolSpace.control,
              child: FilledButton.icon(
                onPressed: saving.value ? null : submit,
                icon: saving.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.check),
                label: Text(existing == null ? 'create'.tr() : 'update'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionDetailSheet extends HookConsumerWidget {
  final String pubName;
  final SnPostCollection collection;

  const _CollectionDetailSheet({
    required this.pubName,
    required this.collection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final provider = collectionPostsProvider((pubName, collection.slug));
    final posts = ref.watch(provider);
    final ordered = useState<List<SnPost>?>(null);
    final saving = useState(false);
    final title = collection.name?.isNotEmpty == true
        ? collection.name!
        : collection.slug;

    // Any new answer from the server replaces the optimistic order.
    useEffect(() {
      ordered.value = null;
      return null;
    }, [posts]);

    Future<void> deleteCollection() async {
      final removed = await _deleteCollection(
        context,
        ref,
        pubName: pubName,
        slug: collection.slug,
      );
      if (removed && context.mounted) Navigator.pop(context, true);
    }

    Future<void> editCollection() async {
      final updated = await showModalBottomSheet<SnPostCollection>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            _CollectionEditorSheet(pubName: pubName, existing: collection),
      );
      // The sheet above holds the old copy of the collection; close it so the
      // list shows the saved version instead of stale artwork and title.
      if (updated != null && context.mounted) Navigator.pop(context, true);
    }

    Future<void> reorderPosts(int oldIndex, int newIndex) async {
      final data = posts.value;
      if (data == null || saving.value) return;

      final next = List<SnPost>.of(ordered.value ?? data.items);
      if (oldIndex < 0 || oldIndex >= next.length) return;
      final moved = next.removeAt(oldIndex);
      next.insert(newIndex.clamp(0, next.length), moved);

      ordered.value = next;
      saving.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.reorderPublisherCollectionPosts(
          publisherName: pubName,
          slug: collection.slug,
          postIds: next.map((post) => post.id).toList(),
        );
        // The local list is now the server order. Refetching here would show
        // the old order for a frame before the response lands.
      } catch (err) {
        ordered.value = null;
        showErrorAlert(err);
        if (context.mounted) ref.invalidate(provider);
      } finally {
        saving.value = false;
      }
    }

    Widget buildHeader({int? totalPosts, Widget? footer}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SolSpace.lg),
            child: ClipRRect(
              borderRadius: SolRadius.cardRadius,
              child: _CollectionCover(
                background: collection.background,
                icon: collection.icon,
                title: title,
                description: collection.description,
                descriptionMaxLines: 2,
                iconRadius: 28,
                maxHeight: 260,
                emptyHeight: 104,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SolSpace.xl,
              SolSpace.md,
              SolSpace.xl,
              SolSpace.xs,
            ),
            child: Row(
              children: [
                Icon(Symbols.link, size: 14, color: scheme.onSurfaceVariant),
                const Gap(SolSpace.xs),
                Expanded(
                  child: Text(
                    collection.slug,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SolSpace.xl,
              SolSpace.sm,
              SolSpace.xl,
              SolSpace.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'posts'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (saving.value)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (totalPosts != null && totalPosts > 0)
                  Text(
                    '$totalPosts',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ?footer,
        ],
      );
    }

    return SheetScaffold(
      titleText: title,
      actions: [
        IconButton(
          icon: const Icon(Symbols.edit),
          tooltip: 'edit'.tr(),
          onPressed: editCollection,
        ),
        IconButton(
          icon: const Icon(Symbols.delete),
          tooltip: 'delete'.tr(),
          onPressed: deleteCollection,
        ),
      ],
      child: posts.when(
        data: (result) {
          final items = ordered.value ?? result.items;
          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: SolSpace.xxl),
            header: buildHeader(
              // Only claim a total when the whole collection is on screen;
              // this sheet loads one page.
              totalPosts: items.length == result.totalCount
                  ? result.totalCount
                  : null,
              footer: items.isEmpty
                  ? EmptyState(
                      icon: Symbols.article,
                      title: 'noPosts'.tr(),
                      description: 'collectionPostsEmptyHint'.tr(),
                      compact: true,
                    )
                  : null,
            ),
            itemCount: items.length,
            onReorderItem: reorderPosts,
            itemBuilder: (context, index) {
              final post = items[index];
              return Padding(
                key: ValueKey(post.id),
                padding: const EdgeInsets.fromLTRB(
                  SolSpace.lg,
                  0,
                  SolSpace.lg,
                  SolSpace.sm,
                ),
                child: CreatorPostCardTile(
                  index: index,
                  post: post,
                  trailing: ReorderableDragStartListener(
                    index: index,
                    enabled: !saving.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SolSpace.xs,
                        vertical: SolSpace.md,
                      ),
                      child: Icon(
                        Symbols.drag_handle,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            buildHeader(
              footer: const Padding(
                padding: EdgeInsets.all(SolSpace.xxxl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            buildHeader(
              footer: SizedBox(
                height: 280,
                child: ResponseErrorWidget(
                  error: error,
                  onRetry: () => ref.invalidate(provider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
