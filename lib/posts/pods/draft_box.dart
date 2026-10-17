import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Where a draft box entry lives.
enum DraftBoxSource {
  /// Saved on this device only; the server does not have it yet.
  localDraft,

  /// Stored on the server with `drafted_at` set.
  cloudDraft,

  /// Stored on the server with a `published_at` that has not arrived yet.
  scheduledPost,
}

class DraftBoxEntry {
  final SnPost post;
  final DraftBoxSource source;

  const DraftBoxEntry({required this.post, required this.source});

  /// True when the entry only exists on this device.
  bool get isLocalOnly => source == DraftBoxSource.localDraft;

  /// True when the entry waits for its publish time.
  bool get isScheduled => source == DraftBoxSource.scheduledPost;

  /// The local publish time of a scheduled entry, null for plain drafts.
  DateTime? get scheduledAt {
    final publishedAt = post.publishedAt;
    if (publishedAt == null || !publishedAt.isAfter(DateTime.now())) {
      return null;
    }
    return publishedAt.toLocal();
  }
}

final draftBoxProvider = AsyncNotifierProvider.autoDispose(
  DraftBoxNotifier.new,
);

/// Pages the authoring box: drafts and already scheduled posts, newest first,
/// with the locally saved drafts the server has never seen in front of them.
class DraftBoxNotifier extends AsyncNotifier<PaginationState<DraftBoxEntry>>
    with AsyncPaginationController<DraftBoxEntry> {
  static const int pageSize = 20;

  int _serverOffset = 0;
  int _localDraftCount = 0;
  bool _loadedLocalDrafts = false;
  final Set<String> _loadedServerIds = {};

  @override
  Future<void> refresh() async {
    _serverOffset = 0;
    _localDraftCount = 0;
    _loadedLocalDrafts = false;
    _loadedServerIds.clear();
    await super.refresh();
  }

  @override
  Future<List<DraftBoxEntry>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final response = await client.dio.get<List<dynamic>>(
      '/sphere/posts/drafts',
      queryParameters: {
        'offset': _serverOffset,
        'take': pageSize,
        'include_scheduled': true,
      },
    );

    final posts = (response.data ?? const [])
        .map((e) => SnPost.fromJson(e as Map<String, dynamic>))
        .toList();
    _serverOffset += posts.length;
    _loadedServerIds.addAll(posts.map((post) => post.id));

    final serverTotal =
        int.tryParse(response.headers.value('x-total') ?? '') ?? posts.length;

    final entries = <DraftBoxEntry>[];
    if (!_loadedLocalDrafts) {
      _loadedLocalDrafts = true;
      final database = ref.read(databaseProvider);
      final localDrafts = await database.getAllPostDrafts();
      for (final draft in localDrafts) {
        // Cloud drafts are mirrored locally with `drafted_at` set; only the
        // drafts the server never received belong in this list.
        if (draft.draftedAt != null) continue;
        if (_loadedServerIds.contains(draft.id)) continue;
        entries.add(
          DraftBoxEntry(post: draft, source: DraftBoxSource.localDraft),
        );
      }
      _localDraftCount = entries.length;

      // The first server page and the local drafts are interleaved by the time
      // they were last touched; later pages are older than both.
      entries.addAll(posts.map(_entryOf));
      entries.sort(_byUpdatedAtDesc);
    } else {
      entries.addAll(posts.map(_entryOf));
    }

    totalCount = serverTotal + _localDraftCount;
    return entries;
  }

  static DraftBoxEntry _entryOf(SnPost post) => DraftBoxEntry(
    post: post,
    source: post.draftedAt != null
        ? DraftBoxSource.cloudDraft
        : DraftBoxSource.scheduledPost,
  );

  static int _byUpdatedAtDesc(DraftBoxEntry a, DraftBoxEntry b) =>
      (b.post.updatedAt ?? b.post.createdAt ?? DateTime(0)).compareTo(
        a.post.updatedAt ?? a.post.createdAt ?? DateTime(0),
      );
}
