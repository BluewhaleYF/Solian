import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/hover_horizontal_scroll_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Horizontal quick-pick strip of friends, styled like the subscribed
/// publishers strip: a leading summary tile plus avatar + presence badge +
/// one-line name, ordered active -> online -> recently online.
///
/// Tapping a friend opens their profile card; the leading tile opens the full
/// friends list sheet. Renders nothing when the user has no friends.
class FriendPresenceStrip extends HookConsumerWidget {
  const FriendPresenceStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsOverviewExpandedProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) return const SizedBox.shrink();

        final ordered = _orderByPresence(friends);
        final onlineCount = friends
            .where((friend) => showsOnlinePresence(friend.status))
            .length;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Material(
          color: colorScheme.surfaceContainerLow.withOpacity(0.65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Height: 8 top + 48 avatar + 4 gap + ~14 label + 6 bottom
              SizedBox(
                height: 80,
                child: HoverHorizontalScrollList(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                  itemCount: ordered.length + 1,
                  separatorWidth: 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: _FriendsSummaryTile(
                          onlineCount: onlineCount,
                          onTap: () => showFriendsOverviewSheet(context),
                        ),
                      );
                    }

                    final friend = ordered[index - 1];
                    return Align(
                      alignment: Alignment.topCenter,
                      child: AccountPfcRegion(
                        uname: friend.account.name,
                        child: _FriendPresenceTile(friend: friend),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Sliver wrapper for [FriendPresenceStrip], placed above the post feed.
class SliverFriendPresenceStrip extends StatelessWidget {
  const SliverFriendPresenceStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: FriendPresenceStrip());
  }
}

/// Active friends first, then online, then the most recently seen offline ones.
List<SnFriendOverviewItem> _orderByPresence(List<SnFriendOverviewItem> friends) {
  final ordered = [...friends];
  ordered.sort((a, b) {
    final byActivity = (b.activities.isNotEmpty ? 1 : 0).compareTo(
      a.activities.isNotEmpty ? 1 : 0,
    );
    if (byActivity != 0) return byActivity;

    final byOnline = (showsOnlinePresence(b.status) ? 1 : 0).compareTo(
      showsOnlinePresence(a.status) ? 1 : 0,
    );
    if (byOnline != 0) return byOnline;

    final aLastOnline = a.account.profile.lastSeenAt ?? a.status.updatedAt;
    final bLastOnline = b.account.profile.lastSeenAt ?? b.status.updatedAt;
    return bLastOnline.compareTo(aLastOnline);
  });
  return ordered;
}

class _FriendPresenceTile extends StatelessWidget {
  final SnFriendOverviewItem friend;

  const _FriendPresenceTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final emphasize =
        friend.activities.isNotEmpty || showsOnlinePresence(friend.status);

    return SizedBox(
      width: 64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                ProfilePictureWidget(
                  file: friend.account.profile.picture,
                  fallbackName: friend.account.nick,
                  radius: 22,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FriendPresenceBadge(friend: friend),
                ),
              ],
            ),
          ),
          const Gap(4),
          Text(
            friend.account.nick.isNotEmpty
                ? friend.account.nick
                : friend.account.name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(emphasize ? 0.95 : 0.7),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Leading tile: online-count badge over a group icon; opens the friends sheet.
class _FriendsSummaryTile extends StatelessWidget {
  final int onlineCount;
  final VoidCallback onTap;

  const _FriendsSummaryTile({required this.onlineCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer.withOpacity(0.7),
                      ),
                      child: Icon(
                        Symbols.group,
                        size: 22,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (onlineCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            onlineCount > 99 ? '99+' : '$onlineCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(4),
              Text(
                'friendsOnline'.tr(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
