import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/chat/widgets/chat_member_list_tile.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/websocket.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void _showOnlineMembers(BuildContext context, String roomId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => OnlineMembersSheet(roomId: roomId),
  );
}

/// Who is in the room right now.
///
/// The room list is sorted online-first by the server, so the sheet pages
/// until the first offline member and stops: everything after that point is
/// the room's membership, which the member sheet in the room details already
/// covers.
class OnlineMembersSheet extends HookConsumerWidget {
  static const _pageSize = 10;

  final String roomId;
  const OnlineMembersSheet({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = useState<List<SnChatMember>>(const []);
    final loading = useState(true);
    final error = useState<Object?>(null);

    Future<void> fetch() async {
      loading.value = true;
      error.value = null;
      members.value = const [];

      final apiClient = ref.read(apiClientProvider);
      final found = <SnChatMember>[];
      try {
        var offset = 0;
        while (true) {
          final response = await apiClient.get(
            '/messager/chat/$roomId/members',
            queryParameters: {
              'offset': offset.toString(),
              'take': _pageSize.toString(),
              'withStatus': true,
            },
          );
          final page = (response.data as List)
              .map((e) => SnChatMember.fromJson(e))
              .cast<SnChatMember>()
              .toList();

          final firstOffline = page.indexWhere(
            (member) => member.status?.isOnline != true,
          );
          found.addAll(
            firstOffline == -1 ? page : page.sublist(0, firstOffline),
          );
          if (firstOffline != -1 || page.length < _pageSize) break;
          offset += _pageSize;
        }
        members.value = found;
      } catch (err) {
        error.value = err;
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      Future.microtask(fetch);
      return null;
    }, [roomId]);

    return SheetScaffold(
      titleText: 'chatPeopleOnline'.plural(members.value.length),
      heightFactor: 0.6,
      actions: [
        IconButton(
          onPressed: loading.value ? null : fetch,
          tooltip: 'refresh'.tr(),
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
        ),
      ],
      child: switch ((loading.value, error.value)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (_, final Object err) => ResponseErrorWidget(
          error: err,
          onRetry: fetch,
        ),
        (_, _) when members.value.isEmpty => EmptyState(
          compact: true,
          icon: Symbols.group_off,
          title: 'chatNoOnlineMembers'.tr(),
        ),
        _ => ListView.builder(
          padding: const EdgeInsets.only(bottom: SolSpace.lg),
          itemCount: members.value.length,
          itemBuilder: (context, index) =>
              ChatMemberListTile(member: members.value[index]),
        ),
      },
    );
  }
}

/// The room header's busy state.
///
/// One source for both halves of the merged indicator: the pill paints its
/// border as a spinner while [loading] is set, and its status line carries
/// [status] instead of the member count.
///
/// [loading] keeps the pair of conditions the standalone sync bar used —
/// a global chat sync, or the summary fetch that backs the unread badges.
/// [status] prefers the sync's own hint (it names the room being worked on)
/// and otherwise says which of the two is running.
({bool loading, String? status}) watchRoomHeaderState(WidgetRef ref) {
  final summaryLoading = ref.watch(chatSummaryProvider).isLoading;
  final isSyncing = ref.watch(chatSyncingProvider);
  final hint = ref.watch(chatSyncHintProvider);
  final loading = summaryLoading || isSyncing;
  return (
    loading: loading,
    status: !loading
        ? null
        : isSyncing
        ? (hint ?? 'syncing'.tr())
        : 'loading'.tr(),
  );
}

List<SnChatMember> getValidMembers(List<SnChatMember> members, String? userId) {
  return members.where((member) => member.accountId != userId).toList();
}

class RoomAppBar extends ConsumerWidget {
  final SnChatRoom room;
  final SnChatOnlineStatus? onlineStatus;

  /// Line shown where the member count normally sits, while the room is busy
  /// — a sync in progress, a timeline still loading. Null shows the count.
  final String? statusLine;

  const RoomAppBar({
    super.key,
    required this.room,
    required this.onlineStatus,
    this.statusLine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final validMembers = getValidMembers(
      room.members ?? [],
      userInfo.value?.id,
    );
    final isDirect = room.type == 1;
    String title;
    if (isDirect && room.name == null) {
      // Look up relationship aliases for each member
      final memberNames = <String>[];
      for (final member in validMembers) {
        final aliasAsync = ref.watch(
          relationshipAliasProvider(member.accountId),
        );
        final alias = aliasAsync.hasValue ? aliasAsync.value : null;
        memberNames.add(
          (alias != null && alias.isNotEmpty) ? alias : member.account.nick,
        );
      }
      title = memberNames.join(', ');
    } else {
      title = room.name!;
    }
    final weakInternetMode = ref.watch(weakInternetModeProvider);
    final subtitle = _buildSubtitle(
      context,
      room,
      validMembers,
      onlineStatus,
      userInfo.value?.id,
      weakInternetMode,
      statusLine: statusLine,
    );
    final hasOnlineAccounts =
        room.type != 1 && (onlineStatus?.onlineAccounts.isNotEmpty == true);

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _RoomAvatar(room: room, validMembers: validMembers, size: 28),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).fontSize(15),
              // The count and the busy line are the same slot showing the
              // same kind of thing, so they cross-fade instead of swapping:
              // the row keeps its height and the change reads as a state
              // transition rather than a redraw.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: subtitle == null
                    ? const SizedBox.shrink(key: ValueKey('subtitle-none'))
                    : GestureDetector(
                        key: ValueKey(
                          statusLine != null
                              ? 'subtitle-status'
                              : 'subtitle-info',
                        ),
                        onTap: hasOnlineAccounts && statusLine == null
                            ? () => _showOnlineMembers(context, room.id)
                            : null,
                        child: subtitle,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget? _buildSubtitle(
  BuildContext context,
  SnChatRoom room,
  List<SnChatMember> validMembers,
  SnChatOnlineStatus? onlineStatus,
  String? currentUserId,
  bool weakInternetMode, {
  String? statusLine,
}) {
  final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
    fontSize: 11,
    height: 1,
    color:
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface,
  );

  // The room's own status takes the count's place rather than joining it: the
  // line carries one piece of information, and a sync hint is more urgent than
  // how many people are around.
  if (statusLine != null && statusLine.isNotEmpty) {
    return Row(
      children: [
        if (weakInternetMode) ...[
          _WeakInternetChip(style: subtitleStyle),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            statusLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subtitleStyle,
          ),
        ),
      ],
    );
  }

  if (room.type == 1) {
    final status = onlineStatus?.directMessageStatus;
    final isBot = validMembers.any(
      (member) => member.account.automatedId != null,
    );
    final label = status != null
        ? getStatusDisplayLabel(context, status)
        : null;
    if (label == null && !isBot && !weakInternetMode) return null;
    final statusColor = getStatusIndicatorColor(status);
    final isOnline = showsOnlinePresence(status);

    return Row(
      children: [
        if (weakInternetMode) ...[
          _WeakInternetChip(style: subtitleStyle),
          if (label != null || isBot) const SizedBox(width: 6),
        ],
        if (label != null) ...[
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isOnline ? statusColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: isOnline ? 0 : 1.5),
            ),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle,
            ),
          ),
        ],
        if (label != null && isBot) const SizedBox(width: 6),
        if (isBot) _BotChip(style: subtitleStyle),
      ],
    );
  }

  final onlineNames =
      onlineStatus?.onlineAccounts
          .where((account) => account.id != currentUserId)
          .map((account) => account.nick.trim())
          .where((name) => name.isNotEmpty)
          .toList() ??
      const <String>[];

  String subtitleText;
  if (onlineNames.isNotEmpty) {
    final preview = onlineNames.take(3).join(', ');
    final remaining = onlineNames.length - 3;
    subtitleText = remaining > 0
        ? '$preview +$remaining online'
        : '$preview online';
  } else {
    final count = onlineStatus?.onlineCount ?? 0;
    subtitleText = count > 0
        ? '$count online'
        : '${validMembers.length} members';
  }

  return Row(
    children: [
      if (weakInternetMode) ...[
        _WeakInternetChip(style: subtitleStyle),
        const SizedBox(width: 6),
      ],
      if (_shouldShowSubtitleOnlineDot(room, onlineStatus))
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      Expanded(
        child: Text(
          subtitleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        ),
      ),
    ],
  );
}

class _WeakInternetChip extends StatelessWidget {
  final TextStyle? style;

  const _WeakInternetChip({required this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.amber.withOpacity(0.45)),
      ),
      child: Text(
        'weakInternetMode'.tr(),
        style: style?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

bool _shouldShowSubtitleOnlineDot(
  SnChatRoom room,
  SnChatOnlineStatus? onlineStatus,
) {
  return room.type != 1 && (onlineStatus?.onlineCount ?? 0) >= 2;
}

class _BotChip extends StatelessWidget {
  final TextStyle? style;

  const _BotChip({required this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.35)),
      ),
      child: Text(
        'Bot',
        style: style?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _RoomAvatar extends StatelessWidget {
  final SnChatRoom room;
  final List<SnChatMember> validMembers;
  final double size;

  const _RoomAvatar({
    required this.room,
    required this.validMembers,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: (room.type == 1 && room.picture == null)
          ? SplitAvatarWidget(
              files: validMembers
                  .map((e) => e.account.profile.picture)
                  .toList(),
            )
          : room.picture != null
          ? ProfilePictureWidget(
              file: room.picture,
              fallbackName: room.name,
              fallbackIcon: Symbols.chat,
            )
          : CircleAvatar(
              child: Text(
                avatarFallbackText(room.name) ?? '?',
                style: const TextStyle(fontSize: 12),
              ),
            ),
    );
  }
}
