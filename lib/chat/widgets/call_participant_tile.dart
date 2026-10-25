import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/call_participants.dart';
import 'package:island/core/theme.dart';
import 'package:island/chat/widgets/call_participant_card.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpeakingRipple extends StatelessWidget {
  final double size;
  final double audioLevel;
  final bool isSpeaking;
  final Widget child;

  const SpeakingRipple({
    super.key,
    required this.size,
    required this.audioLevel,
    required this.isSpeaking,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarRadius = size / 2;
    final clampedLevel = audioLevel.clamp(0.0, 1.0);
    final rippleRadius = avatarRadius + clampedLevel * (size * 0.333);

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: avatarRadius,
          end: isSpeaking ? rippleRadius : avatarRadius,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        builder: (context, animatedRadius, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (isSpeaking)
                Container(
                  width: animatedRadius * 2,
                  height: animatedRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // The speaker's own accent: the ring marks *who* is
                    // talking, so it takes the theme's primary rather than a
                    // fixed green that clashes with a custom seed color.
                    color: colorScheme.primary.withValues(
                      alpha: 0.35 + 0.35 * clampedLevel,
                    ),
                  ),
                ),
              child!,
            ],
          );
        },
        child: SizedBox(width: size, height: size, child: child),
      ),
    );
  }
}

class SpeakingRippleAvatar extends HookConsumerWidget {
  final CallParticipantLive live;
  final double size;

  const SpeakingRippleAvatar({super.key, required this.live, this.size = 96});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(
      callParticipantAccountProvider(live.participant.identity),
    );

    return CallParticipantRegion(
      participant: live,
      child: SpeakingRipple(
        size: size,
        audioLevel: live.remoteParticipant.audioLevel,
        isSpeaking: live.remoteParticipant.isSpeaking,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: account.when(
                data: (value) => ProfilePictureWidget(
                  file: value.profile.picture,
                  fallbackName: value.nick,
                  radius: size / 2,
                ),
                error: (_, _) => CircleAvatar(
                  radius: size / 2,
                  child: const Icon(Symbols.question_mark),
                ),
                loading: () => CircleAvatar(
                  radius: size / 2,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            if (live.remoteParticipant.isMuted)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Symbols.mic_off,
                    size: 14,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CallParticipantTile extends HookConsumerWidget {
  final CallParticipantLive live;
  final bool allTiles;
  final double radius;
  final bool tightPadding;
  final bool forceLarge;
  final double? tileHeight;

  const CallParticipantTile({
    super.key,
    required this.live,
    this.allTiles = false,
    this.radius = 48,
    this.tightPadding = false,
    this.forceLarge = false,
    this.tileHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(
      callParticipantAccountProvider(live.participant.identity),
    );

    final hasVideoTrack =
        live.hasVideo &&
        live.remoteParticipant.trackPublications.values
            .where(
              (pub) =>
                  pub.track != null &&
                  pub.kind == TrackType.VIDEO &&
                  !pub.isDisposed,
            )
            .isNotEmpty;

    if (!hasVideoTrack && !allTiles) {
      return SpeakingRippleAvatar(size: 84, live: live);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isSpeaking = live.remoteParticipant.isSpeaking;
    final audioLevel = live.remoteParticipant.audioLevel.clamp(0.0, 1.0);
    final tileRadius = forceLarge ? 18.0 : 14.0;
    final participantName =
        account.value?.nick ??
        (live.participant.name.isNotEmpty
            ? live.participant.name
            : live.participant.identity);

    Widget tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        // The tile is a media frame on the call's dark stage, so it takes the
        // theme's container role rather than a fixed slate; the speaker ring
        // is the same primary accent the avatar ripple uses.
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(tileRadius),
        border: Border.all(
          color: isSpeaking
              ? colorScheme.primary.withValues(
                  alpha: (0.7 + 0.3 * audioLevel).clamp(0.0, 1.0),
                )
              : colorScheme.outlineVariant,
          width: isSpeaking ? 2.4 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tileRadius - 2),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasVideoTrack)
                CallParticipantRegion(
                  participant: live,
                  child: RepaintBoundary(
                    child: VideoTrackRenderer(
                      live.remoteParticipant.trackPublications.values
                              .where((track) => track.kind == TrackType.VIDEO)
                              .first
                              .track
                          as VideoTrack,
                      renderMode: VideoRenderMode.auto,
                    ),
                  ),
                )
              else
                ColoredBox(
                  color: colorScheme.surfaceContainerLowest,
                  child: Center(
                    child: account.when(
                      data: (value) => CallParticipantRegion(
                        participant: live,
                        child: ProfilePictureWidget(
                          file: value.profile.picture,
                          fallbackName: value.nick,
                          radius: radius,
                        ),
                      ),
                      error: (_, _) => CircleAvatar(
                        radius: radius,
                        child: const Icon(Symbols.question_mark),
                      ),
                      loading: () => CircleAvatar(
                        radius: radius,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              // The caption is a scrim over video, not a themed surface: it has
              // to stay legible whatever frame is playing behind it, so it
              // keeps a translucent ink while its text takes onInverseSurface.
              Positioned(
                left: SolSpace.sm,
                right: SolSpace.sm,
                bottom: SolSpace.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SolSpace.sm,
                    vertical: SolSpace.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.scrim.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(SolRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: account.value == null
                            ? Text(
                                participantName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : AccountName(
                                account: account.value!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      if (live.remoteParticipant.isMuted)
                        Icon(
                          Symbols.mic_off,
                          size: 14,
                          color: colorScheme.error,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tileHeight != null) {
      tile = SizedBox(height: tileHeight, child: tile);
    }

    if (!tightPadding) {
      tile = Padding(padding: const EdgeInsets.all(8), child: tile);
    }

    return tile;
  }
}
