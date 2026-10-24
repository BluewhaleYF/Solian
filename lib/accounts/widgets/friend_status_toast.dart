import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:island/shared/widgets/unfold_reveal.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum FriendStatusChangeType {
  online,
  offline,
  busy,
  doNotDisturb,
  activityStarted,
  activityEnded,
}

class FriendStatusChangeEvent {
  final SnAccount account;
  final SnAccountStatus? status;
  final List<SnPresenceActivity> activities;
  final FriendStatusChangeType changeType;

  const FriendStatusChangeEvent({
    required this.account,
    this.status,
    this.activities = const [],
    required this.changeType,
  });
}

/// One-line capsule for a friend's presence change.
///
/// The capsule travels like the connection pill: it drops in from above the
/// lane as a bare avatar, and only once it has landed does the sentence grow
/// out of the avatar's trailing edge. Leaving is the same flight reversed —
/// the sentence retracts, then the avatar is carried off. There is no
/// countdown chrome; the pill is the whole notice.
///
/// The body holds the verb ("came online", "started Dyson Sphere Program");
/// the name is the loud part, the verb the quiet part. Details that would need
/// a second line — a busy message, a track's artist — ride along in the
/// tooltip and the screen-reader label instead of stretching the pill.
class FriendStatusToast extends HookWidget {
  final FriendStatusChangeEvent event;
  final VoidCallback? onDismiss;

  /// Set by the overlay as soon as the notice is dismissed. The capsule
  /// retracts to the avatar while the overlay slides it out, so the exit shows
  /// the same bare avatar as the entrance.
  final bool dismissed;

  const FriendStatusToast({
    super.key,
    required this.event,
    this.onDismiss,
    this.dismissed = false,
  });

  /// Beat between the avatar landing and the sentence unfolding. Matches the
  /// overlay's own entrance so the widening starts after the drop, not during.
  static const Duration _expandDelay = Duration(milliseconds: 280);

  static const Duration _expandDuration = Duration(milliseconds: 320);

  /// Shorter than the overlay's exit reverse, so the retraction finishes while
  /// the item is still on screen instead of being cut off by its removal.
  static const Duration _collapseDuration = Duration(milliseconds: 160);

  static const Duration _contentDuration = Duration(milliseconds: 260);

  SnPresenceActivity? get _activity =>
      event.changeType == FriendStatusChangeType.activityStarted &&
          event.activities.isNotEmpty
      ? event.activities.first
      : null;

  String get _name =>
      event.account.nick.isNotEmpty ? event.account.nick : event.account.name;

  String _message() {
    final activity = _activity;
    if (activity != null) {
      final title = activity.title;
      if (title?.isNotEmpty == true) {
        return 'friendStatusStartedSpecificActivity'.tr(args: [title!]);
      }
      final subtitle = activity.subtitle;
      if (subtitle?.isNotEmpty == true) {
        return 'friendStatusStartedSpecificActivity'.tr(args: [subtitle!]);
      }
    }

    return switch (event.changeType) {
      FriendStatusChangeType.online => 'friendStatusCameOnline'.tr(),
      FriendStatusChangeType.offline => 'friendStatusWentOffline'.tr(),
      FriendStatusChangeType.busy => 'friendStatusIsNowBusy'.tr(),
      FriendStatusChangeType.doNotDisturb =>
        'friendStatusEnabledDoNotDisturb'.tr(),
      FriendStatusChangeType.activityStarted =>
        'friendStatusStartedActivity'.tr(),
      FriendStatusChangeType.activityEnded =>
        'friendStatusStoppedActivity'.tr(),
    };
  }

  /// What the one-liner had to leave out: a custom busy/DND message, or the
  /// artist line of a track.
  String? _detail() {
    final activity = _activity;
    if (activity != null) {
      final subtitle = activity.subtitle;
      return subtitle?.isNotEmpty == true && subtitle != activity.title
          ? subtitle
          : null;
    }
    final label = event.status?.label;
    return label?.isNotEmpty == true ? label : null;
  }

  /// Glyph for the trailing slot. Online and offline read better as a dot, so
  /// they return null and [_Trailing] draws the presence dot instead.
  IconData? _glyph() {
    final activity = _activity;
    if (activity != null) return presenceActivityIcon(activity.type);

    return switch (event.changeType) {
      FriendStatusChangeType.online || FriendStatusChangeType.offline => null,
      FriendStatusChangeType.busy => Symbols.pause,
      FriendStatusChangeType.doNotDisturb => Symbols.do_not_disturb_on,
      FriendStatusChangeType.activityStarted => Symbols.play_arrow,
      FriendStatusChangeType.activityEnded => Symbols.stop_circle,
    };
  }

  /// Presence tone, stepped for the surface it sits on: Material's 600 shades
  /// go muddy on a dark ground, so dark picks the lighter step.
  Color _tone(ThemeData theme) {
    final dark = theme.brightness == Brightness.dark;
    return switch (event.changeType) {
      FriendStatusChangeType.online =>
        dark ? Colors.green.shade400 : Colors.green.shade700,
      FriendStatusChangeType.offline => theme.colorScheme.onSurfaceVariant,
      FriendStatusChangeType.busy =>
        dark ? Colors.orange.shade400 : Colors.orange.shade800,
      FriendStatusChangeType.doNotDisturb =>
        dark ? Colors.deepOrange.shade300 : Colors.deepOrange.shade700,
      FriendStatusChangeType.activityStarted => theme.colorScheme.primary,
      FriendStatusChangeType.activityEnded =>
        theme.colorScheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final tone = _tone(theme);
    final dark = theme.brightness == Brightness.dark;
    final message = _message();
    final detail = _detail();
    final glyph = _glyph();
    final name = _name;

    final fill = Color.alphaBlend(
      tone.withValues(alpha: dark ? 0.18 : 0.11),
      theme.colorScheme.surfaceContainerHigh,
    );

    // 0 → 1 is the sentence's width: the pill is a bare avatar at 0 and a full
    // capsule at 1. The overlay owns the vertical flight; this owns the
    // horizontal unfolding and its retraction on the way out.
    final unfold = useAnimationController(
      duration: reduceMotion ? Duration.zero : _expandDuration,
      reverseDuration: reduceMotion ? Duration.zero : _collapseDuration,
      initialValue: reduceMotion ? 1 : 0,
    );
    final unfoldCurve = useMemoized(
      () => CurvedAnimation(
        parent: unfold,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      [unfold],
    );
    useEffect(() {
      if (reduceMotion) return null;
      var alive = true;
      final timer = Timer(_expandDelay, () {
        if (alive) unfold.forward();
      });
      return () {
        alive = false;
        timer.cancel();
      };
    }, [unfold, reduceMotion]);
    useEffect(() {
      if (dismissed) unfold.reverse();
      return null;
    }, [dismissed, unfold]);

    // Leaves room for the avatar, the trailing slot and the capsule's own
    // insets before the sentence starts truncating.
    final textMaxWidth = math.max(
      120.0,
      math.min(320.0, MediaQuery.sizeOf(context).width - 132),
    );
    final contentDuration = reduceMotion ? Duration.zero : _contentDuration;
    final semanticLabel = [name, message, ?detail].join(' ');

    final body = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 0,
      children: [
        ProfilePictureWidget(
          file: event.account.profile.picture,
          fallbackName: name,
          radius: 11,
        ),
        UnfoldReveal(
          animation: unfoldCurve,
          inset: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: textMaxWidth),
                child: AnimatedSwitcher(
                  duration: contentDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: Text.rich(
                    key: ValueKey<String>(message),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        TextSpan(
                          text: ' $message',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: contentDuration,
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: _Trailing(
                      key: ValueKey<String>(
                        glyph?.hashCode.toString() ?? event.changeType.name,
                      ),
                      glyph: glyph,
                      online: event.changeType == FriendStatusChangeType.online,
                      tone: tone,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final capsule = Material(
      color: fill,
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDismiss,
        customBorder: const StadiumBorder(),
        child: Padding(padding: const EdgeInsets.all(6), child: body),
      ),
    );

    final labelled = Semantics(
      container: true,
      button: onDismiss != null,
      label: semanticLabel,
      child: ExcludeSemantics(child: capsule),
    );

    return Align(
      alignment: Alignment.topCenter,
      child: detail == null
          ? labelled
          : Tooltip(
              message: detail,
              excludeFromSemantics: true,
              waitDuration: const Duration(milliseconds: 500),
              child: labelled,
            ),
    );
  }
}

/// Trailing presence mark: a dot for online/offline, a glyph otherwise.
class _Trailing extends StatelessWidget {
  final IconData? glyph;
  final bool online;
  final Color tone;

  const _Trailing({
    super.key,
    required this.glyph,
    required this.online,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final glyph = this.glyph;
    if (glyph == null) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: online ? tone : Colors.transparent,
          border: online ? null : Border.all(color: tone, width: 1.6),
        ),
      );
    }
    return Icon(glyph, size: 16, color: tone);
  }
}
