import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'file_list.g.dart';

/// The Drive's listing data, as the surfaces that stayed in Island still need
/// it: the composer's cloud-file attachment picker browses an indexed folder
/// path through [indexedCloudFileListFamilyProvider], and the quota purchase
/// sheet reads the account's billing quota.
///
/// The Drive file manager itself (the Files tab, its Miller-column browser,
/// the filter bar and the storage overview) lives in the SolWatt app now, and
/// so do the browser-only providers this file used to carry.

final indexedCloudFileListFamilyProvider =
    AsyncNotifierProvider.family<
      IndexedCloudFileListNotifier,
      PaginationState<FileListItem>,
      String
    >(IndexedCloudFileListNotifier.new);

class IndexedCloudFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  final String tabId;
  IndexedCloudFileListNotifier(this.tabId);

  String _currentPath = '/';

  void setPath(String path) {
    if (_currentPath == path) return;
    _currentPath = path;
    _resetPagination();
    ref.invalidateSelf();
  }

  void _resetPagination() {
    totalCount = null;
    state = AsyncData(
      const PaginationState<FileListItem>(
        items: [],
        isLoading: true,
        isReloading: true,
        totalCount: null,
        hasMore: true,
        cursor: null,
      ),
    );
  }

  static const int pageSize = 50;

  @override
  FutureOr<PaginationState<FileListItem>> build() async {
    final items = await fetch();
    if (!ref.mounted) {
      return PaginationState(
        items: items,
        isLoading: false,
        isReloading: false,
        totalCount: totalCount,
        hasMore: false,
        cursor: null,
      );
    }
    final resolvedTotal = totalCount;
    final more = resolvedTotal == null
        ? items.length >= pageSize
        : items.length < resolvedTotal;
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: resolvedTotal,
      hasMore: more,
      cursor: null,
    );
  }

  @override
  Future<List<FileListItem>> fetch() async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;

    final resolution = await _resolveParentIdForPath(driveApi);
    if (!resolution.found) {
      totalCount = 0;
      return const [];
    }

    final PaginatedResult<SnCloudFile> result;
    if (resolution.parentId == null) {
      result = await driveApi.listRootChildren(
        offset: fetchedCount,
        take: pageSize,
      );
    } else {
      result = await driveApi.listFolderChildren(
        resolution.parentId!,
        offset: fetchedCount,
        take: pageSize,
      );
    }

    totalCount = result.totalCount;
    return result.items.map(_toFileListItem).toList();
  }

  FileListItem _toFileListItem(SnCloudFile file) {
    if (file.isFolder) {
      return FileListItem.folder(file);
    }
    return FileListItem.file(file);
  }

  /// Resolve each path segment by exact folder name lookup (avoids missing
  /// folders that fall outside the default list page of 50 items).
  Future<({bool found, String? parentId})> _resolveParentIdForPath(
    DriveApi driveApi,
  ) async {
    final parts = _currentPath
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return (found: true, parentId: null);
    }

    String? parentId;
    for (final part in parts) {
      final PaginatedResult<SnCloudFile> result;
      if (parentId == null) {
        result = await driveApi.listRootChildren(
          name: part,
          isFolder: true,
          take: 20,
          orderDesc: false,
        );
      } else {
        result = await driveApi.listFolderChildren(
          parentId,
          name: part,
          isFolder: true,
          take: 20,
          orderDesc: false,
        );
      }

      final matchedFolder = result.items
          .where((item) => item.isFolder)
          .where((item) => item.name.toLowerCase() == part.toLowerCase())
          .firstOrNull;

      if (matchedFolder == null || matchedFolder.id.isEmpty) {
        return (found: false, parentId: null);
      }

      parentId = matchedFolder.id;
    }

    return (found: true, parentId: parentId);
  }
}

@riverpod
Future<Map<String, dynamic>?> billingQuota(Ref ref) async {
  final driveApi = ref.read(solarNetworkClientProvider).drive;
  return driveApi.getQuota();
}
