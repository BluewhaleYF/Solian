import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
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
/// Deliberately built like the connection pill rather than the notification
/// cards: an avatar, a single sentence that holds the whole event, and the
/// status as a glyph at the end. The capsule owns its surface, so the overlay
/// must not paint a card behind it.
///
/// The body holds the verb ("came online", "started Dyson Sphere Program");
/// the name is the loud part, the verb the quiet part. Details that would need
/// a second line — a busy message, a track's artist — ride along in the
/// tooltip and the screen-reader label instead of stretching the pill.
class FriendStatusToast extends HookWidget {
  final FriendStatusChangeEvent event;
  final VoidCallback? onDismiss;

  /// Auto-dismiss timer, 1 → 0. Drives the countdown etched along the capsule's
  /// own outline. Null renders a static outline (previews, tests).
  final Animation<double>? progress;

  /// Desktop notices dock against the right edge; phones center them.
  final bool isDesktop;

  const FriendStatusToast({
    super.key,
    required this.event,
    this.onDismiss,
    this.progress,
    this.isDesktop = false,
  });

  static const Duration _entranceDuration = Duration(milliseconds: 360);

  static const Duration _contentDuration = Duration(milliseconds: 260);

  SnPresenceActivity? get _activity =>
      event.changeType == FriendStatusChangeType.activityStarted &&
          event.activities.isNotEmpty
      ? event.activities.first
      : null;

  String get _name => event.account.nick.isNotEmpty
      ? event.account.nick
      : event.account.name;

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
      FriendStatusChangeType.activityEnded => theme.colorScheme.onSurfaceVariant,
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

    // Entrances are staggered off one controller so the capsule assembles as a
    // unit: the avatar lands, then the sentence slides in, then the glyph pops.
    final entrance = useAnimationController(
      duration: reduceMotion ? Duration.zero : _entranceDuration,
      initialValue: reduceMotion ? 1 : 0,
    );
    useEffect(() {
      if (!reduceMotion) entrance.forward();
      return null;
    }, [entrance, reduceMotion]);

    final avatarScale = useMemoized(
      () => Tween<double>(begin: 0.58, end: 1).animate(
        CurvedAnimation(
          parent: entrance,
          curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
        ),
      ),
      [entrance],
    );
    final textFade = useMemoized(
      () => CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.16, 1, curve: Curves.easeOut),
      ),
      [entrance],
    );
    final textSlide = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(-0.08, 0),
        end: Offset.zero,
      ).animate(textFade),
      [textFade],
    );
    final glyphScale = useMemoized(
      () => Tween<double>(begin: 0.4, end: 1).animate(
        CurvedAnimation(
          parent: entrance,
          curve: const Interval(0.28, 1, curve: Curves.easeOutBack),
        ),
      ),
      [entrance],
    );

    // Leaves room for the avatar, the trailing slot and the capsule's own
    // insets before the sentence starts truncating.
    final textMaxWidth = math.max(
      120.0,
      math.min(320.0, MediaQuery.sizeOf(context).width - 132),
    );
    final contentDuration = reduceMotion ? Duration.zero : _contentDuration;
    final semanticLabel = [name, message, ?detail].join(' ');

    final capsule = AnimatedSize(
      duration: contentDuration,
      curve: Curves.easeOutCubic,
      alignment: isDesktop ? Alignment.centerRight : Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Material(
        color: fill,
        elevation: 3,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onDismiss,
          customBorder: const StadiumBorder(),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    ScaleTransition(
                      scale: avatarScale,
                      child: ProfilePictureWidget(
                        file: event.account.profile.picture,
                        fallbackName: name,
                        radius: 11,
                      ),
                    ),
                    SlideTransition(
                      position: textSlide,
                      child: FadeTransition(
                        opacity: textFade,
                        child: ConstrainedBox(
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
                              alignment: isDesktop
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
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
                                    style: theme.textTheme.labelLarge
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
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
                      ),
                    ),
                    ScaleTransition(
                      scale: glyphScale,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: contentDuration,
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                            child: _Trailing(
                              key: ValueKey<String>(
                                glyph?.hashCode.toString() ??
                                    event.changeType.name,
                              ),
                              glyph: glyph,
                              online:
                                  event.changeType ==
                                  FriendStatusChangeType.online,
                              tone: tone,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CapsuleOutline(
                      progress: progress,
                      color: tone,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final labelled = Semantics(
      container: true,
      button: onDismiss != null,
      label: semanticLabel,
      child: ExcludeSemantics(child: capsule),
    );

    return Align(
      alignment: isDesktop ? Alignment.topRight : Alignment.topCenter,
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

/// The capsule's hairline, with the remaining display time burned along it.
///
/// The timer follows the outline itself instead of a bar or a ring, so the pill
/// keeps one silhouette whether it is counting down or not. The segment starts
/// at the capsule's top-left corner and is consumed clockwise.
class _CapsuleOutline extends CustomPainter {
  final Animation<double>? progress;
  final Color color;

  _CapsuleOutline({required this.progress, required this.color})
    : super(repaint: progress);

  static const double _outlineWidth = 1;

  static const double _timerWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.shortestSide <= 0) return;

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _outlineWidth
      ..color = color.withValues(alpha: 0.22);
    final inset = (Offset.zero & size).deflate(_outlineWidth / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, Radius.circular(inset.height / 2)),
      outline,
    );

    final progress = this.progress;
    final fraction = progress?.value.clamp(0.0, 1.0) ?? 0.0;
    if (fraction <= 0) return;

    final timerInset = (Offset.zero & size).deflate(_timerWidth / 2);
    if (timerInset.width <= 0 || timerInset.height <= 0) return;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          timerInset,
          Radius.circular(timerInset.height / 2),
        ),
      );
    // Materialised: a path metric iterable reports emptiness and length
    // through fresh iterators, and `first` on the lazy one can land on an
    // exhausted sweep while a resize is in flight.
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final timer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _timerWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawPath(metric.extractPath(0, metric.length * fraction), timer);
  }

  @override
  bool shouldRepaint(_CapsuleOutline oldDelegate) =>
      oldDelegate.color != color || oldDelegate.progress != progress;
}
