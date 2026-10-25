import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/call_participants.dart';
import 'package:island/core/theme.dart';
import 'package:island/chat/widgets/call_chrome.dart' show kCallChromeGutter;
import 'package:island/chat/widgets/call_participant_tile.dart';
import 'package:island/drive/widgets/cloud_files.dart'
    show ProfilePictureWidget;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

final RegExp _toolParticipantPattern = RegExp(r'^(.+)_tool_([A-Za-z0-9_-]+)$');

class ToolCallParticipantInfo {
  final String username;
  final String slug;

  const ToolCallParticipantInfo({required this.username, required this.slug});
}

ToolCallParticipantInfo? parseToolCallParticipant(
  CallParticipantLive participant,
) {
  final match = _toolParticipantPattern.firstMatch(
    participant.participant.identity,
  );
  if (match == null) return null;
  return ToolCallParticipantInfo(
    username: match.group(1) ?? '',
    slug: match.group(2) ?? '',
  );
}

bool isToolCallParticipant(CallParticipantLive participant) =>
    parseToolCallParticipant(participant) != null;

Future<void> showToolParticipantsSheet(
  BuildContext context,
  List<CallParticipantLive> toolParticipants,
) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (ctx) => SheetScaffold(
      titleText: 'toolsInCall'.tr(),
      heightFactor: 0.5,
      child: ListView.separated(
        itemCount: toolParticipants.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, index) {
          return _ToolParticipantListTile(live: toolParticipants[index]);
        },
      ),
    ),
  );
}

class _ToolParticipantListTile extends HookConsumerWidget {
  final CallParticipantLive live;

  const _ToolParticipantListTile({required this.live});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = parseToolCallParticipant(live);
    final username = info?.username ?? '';
    final account = username.isEmpty
        ? const AsyncValue<Never>.loading()
        : ref.watch(callParticipantAccountProvider(username));
    final subtitle = info == null
        ? live.participant.identity
        : '${info.slug} • ${live.participant.identity}';

    return ListTile(
      leading: account.when(
        data: (value) => Stack(
          clipBehavior: Clip.none,
          children: [
            ProfilePictureWidget(
              file: value.profile.picture,
              fallbackName: value.nick,
              radius: 18,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: const Icon(Symbols.terminal, size: 11),
              ),
            ),
          ],
        ),
        error: (_, _) =>
            const CircleAvatar(child: Icon(Symbols.terminal, size: 18)),
        loading: () => const CircleAvatar(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      title: account.maybeWhen(
        data: (value) => AccountName(
          account: value,
          style: Theme.of(context).textTheme.bodyLarge,
          hideOverlay: true,
        ),
        orElse: () => Text(
          username.isNotEmpty ? username : 'unknownToolParticipant'.tr(),
        ),
      ),
      subtitle: Text(subtitle),
      trailing: live.remoteParticipant.isSpeaking
          ? const Icon(Symbols.graph_3, size: 18)
          : null,
    );
  }
}

bool _hasActiveVideo(CallParticipantLive participant) {
  return participant.hasVideo &&
      participant.remoteParticipant.trackPublications.values.any(
        (publication) =>
            publication.track != null &&
            publication.kind == TrackType.VIDEO &&
            !publication.muted &&
            !publication.isDisposed,
      );
}

class CallStageView extends HookConsumerWidget {
  final List<CallParticipantLive> participants;
  final double? outerMaxHeight;

  const CallStageView({
    super.key,
    required this.participants,
    this.outerMaxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedSid = useState<String?>(null);

    useEffect(() {
      if (participants.isEmpty) return null;
      if (focusedSid.value != null &&
          participants.any(
            (participant) =>
                participant.remoteParticipant.sid == focusedSid.value,
          )) {
        return null;
      }
      final speaking = participants
          .where((participant) => participant.remoteParticipant.isSpeaking)
          .toList();
      if (speaking.isNotEmpty) {
        speaking.sort(
          (a, b) => b.remoteParticipant.audioLevel.compareTo(
            a.remoteParticipant.audioLevel,
          ),
        );
        focusedSid.value = speaking.first.remoteParticipant.sid;
      } else {
        focusedSid.value = participants.first.remoteParticipant.sid;
      }
      return null;
    }, [participants]);

    final focusedParticipant =
        participants
            .where(
              (participant) =>
                  participant.remoteParticipant.sid == focusedSid.value,
            )
            .firstOrNull ??
        participants.first;

    final stripParticipants = participants
        .where((participant) => participant != focusedParticipant)
        .toList();

    return Column(
      children: [
        if (stripParticipants.isNotEmpty)
          SizedBox(
            height: 108,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                kCallChromeGutter,
                SolSpace.sm,
                kCallChromeGutter,
                SolSpace.xs,
              ),
              itemCount: stripParticipants.length,
              itemBuilder: (context, index) {
                final participant = stripParticipants[index];
                return Padding(
                  padding: const EdgeInsets.only(right: SolSpace.sm),
                  child: SizedBox(
                    width: 160,
                    child: GestureDetector(
                      onTap: () {
                        focusedSid.value = participant.remoteParticipant.sid;
                      },
                      child: CallParticipantTile(
                        live: participant,
                        allTiles: true,
                        tightPadding: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              kCallChromeGutter,
              0,
              kCallChromeGutter,
              SolSpace.sm,
            ),
            child: CallParticipantTile(
              live: focusedParticipant,
              allTiles: true,
              forceLarge: true,
              tileHeight: outerMaxHeight != null ? outerMaxHeight! - 120 : null,
            ),
          ),
        ),
      ],
    );
  }
}

class CallContent extends HookConsumerWidget {
  final double? outerMaxHeight;
  const CallContent({super.key, this.outerMaxHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    final callNotifier = ref.read(callProvider.notifier);
    final viewMode = callState.viewMode;

    final participants = callNotifier.participants
        .where((participant) => !isToolCallParticipant(participant))
        .toList();
    final hasRenderableCall =
        participants.isNotEmpty ||
        callState.hasJoined ||
        callState.isReconnecting;

    if (!hasRenderableCall) {
      return const Center(child: CircularProgressIndicator());
    }

    if (participants.isEmpty) {
      return Center(
        child: Text(
          callState.isReconnecting
              ? 'Reconnecting call...'
              : 'Waiting for participants...',
        ),
      );
    }
    final allAudioOnly = participants.every(
      (participant) => !_hasActiveVideo(participant),
    );

    if (allAudioOnly) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: SolSpace.xxl,
            runSpacing: SolSpace.xxl,
            children: [
              for (final live in participants) _AudioParticipant(live: live),
            ],
          ),
        ),
      );
    }

    if (viewMode == ViewMode.stage) {
      return CallStageView(
        participants: participants,
        outerMaxHeight: outerMaxHeight,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = participants.length;
        final crossAxisCount = switch (count) {
          <= 1 => 1,
          <= 4 => width > 900 ? 2 : 1,
          <= 9 => width > 1200 ? 3 : 2,
          _ => width > 1400 ? 4 : 3,
        };

        return GridView.builder(
          // Tiles share the chrome's side gutter, so the grid, the header
          // capsule and the controls row all sit on the same column edges.
          padding: const EdgeInsets.symmetric(
            horizontal: kCallChromeGutter,
            vertical: SolSpace.xs,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: SolSpace.sm,
            crossAxisSpacing: SolSpace.sm,
            childAspectRatio: 16 / 9,
          ),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            return CallParticipantTile(
              live: participants[index],
              allTiles: true,
              tightPadding: true,
            );
          },
        );
      },
    );
  }
}

/// One participant in the audio-only layout: speaking avatar over their name.
///
/// The name follows the account identity the same way a message author does
/// ([AccountName]), so a call and the timeline agree on how a person is drawn.
class _AudioParticipant extends HookConsumerWidget {
  static const _avatarSize = 108.0;

  final CallParticipantLive live;

  const _AudioParticipant({required this.live});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final account = ref.watch(
      callParticipantAccountProvider(live.participant.identity),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpeakingRippleAvatar(live: live, size: _avatarSize),
        const Gap(SolSpace.sm),
        SizedBox(
          width: _avatarSize,
          child: account.value == null
              ? Text(
                  live.participant.name.isNotEmpty
                      ? live.participant.name
                      : live.participant.identity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                )
              : AccountName(
                  account: account.value!,
                  style: theme.textTheme.bodyMedium,
                  hideOverlay: true,
                ).center(),
        ),
      ],
    );
  }
}
