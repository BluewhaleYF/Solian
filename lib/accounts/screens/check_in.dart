import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/accounts/widgets/account/fortune_graph.dart';
import 'package:island/auth/captcha.dart';
import 'package:island/core/check_in_debug.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:lunar/lunar.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

TextStyle checkInSerif(
  BuildContext context, {
  TextStyle? base,
  FontWeight? fontWeight,
  double? height,
  Color? color,
}) {
  return (base ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
    fontWeight: fontWeight,
    height: height,
    color: color,
  );
}

String? checkInResultAsset(int level) {
  if (level < 0 || level > 4) return null;
  return 'assets/images/michan/check-in-result$level.webp';
}

Color checkInResultBackdrop(int level) {
  switch (level) {
    case 0:
      return const Color(0xFF7A587D);
    case 1:
      return const Color(0xFF79709C);
    case 2:
      return const Color(0xFF8DB7EF);
    case 3:
      return const Color(0xFFFEDE81);
    case 4:
      return const Color(0xFFE04A46);
    case 5:
      return const Color(0xFFFFB7C0);
    default:
      return const Color(0xFF8DB7EF);
  }
}

class CheckInScreen extends ConsumerStatefulWidget {
  /// When set, the sheet runs entirely offline: the today result and the event
  /// calendar are never fetched, and the draw resolves locally.
  final CheckInDebugOptions? debugOptions;

  const CheckInScreen({super.key, this.debugOptions});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  /// Draws made in this session, keyed by the day they belong to. A backdated
  /// draw lands on a past day, and until the calendar is refetched the result
  /// only lives here.
  final _instantResults = <DateTime, SnCheckInResult>{};

  /// Days with a draw in flight, so the banner and the past-day prompt each
  /// show their own spinner.
  final _checkingInDays = <DateTime>{};

  /// Days whose draw just landed. The rail pastes their stamp on while they
  /// stay here; _markFresh drops them again shortly after, so a later rebuild
  /// — a scroll, a re-selection — never replays the entrance.
  final _freshDays = <DateTime>{};
  final _freshTimers = <Timer>[];

  /// Marks [day] as just drawn, for the length of its stamp's entrance.
  void _markFresh(DateTime day) {
    _freshDays.add(day);
    _freshTimers.add(
      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() => _freshDays.remove(day));
      }),
    );
  }

  @override
  void dispose() {
    for (final timer in _freshTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Draw after the first frame so the sheet opens on the un-drawn today
    // (banner up, rail parked on the last check-in) before it animates.
    if (widget.debugOptions?.autoDraw ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkIn());
    }
  }

  Future<void> _checkIn() => _draw(null);

  Future<void> _checkInBackdated(DateTime day) => _draw(_day(day));

  /// Runs one draw, for today when [day] is null and for that past day
  /// otherwise. Backdating is a paid feature the server enforces; the sheet
  /// only has to route the request and surface the refusal.
  Future<void> _draw(DateTime? day) async {
    final target = day ?? _day(DateTime.now());
    if (_checkingInDays.contains(target)) return;
    final debugOptions = widget.debugOptions;
    if (debugOptions != null) {
      setState(() => _checkingInDays.add(target));
      await Future<void>.delayed(debugOptions.drawDelay);
      if (!mounted) return;
      setState(() {
        _instantResults[target] = buildDebugCheckInResult(
          id: 'debug-check-in-${target.toIso8601String()}',
          level: debugOptions.level,
          createdAt: target == _day(DateTime.now()) ? DateTime.now() : target,
        );
        _checkingInDays.remove(target);
      });
      _markFresh(target);
      return;
    }
    setState(() => _checkingInDays.add(target));
    final client = ref.read(solarNetworkClientProvider);
    try {
      final result = await client.accounts.checkIn(backdated: day);
      if (!mounted) return;
      setState(() => _instantResults[target] = result);
      _markFresh(target);
      ref.invalidate(checkInResultTodayProvider);
      // Backdated draws leave the daily streak and the wallet untouched, so
      // only a draw on its own day is worth refreshing the account for.
      if (day == null) await ref.read(userInfoProvider.notifier).fetchUser();
      if (result.fortuneReport == null) {
        unawaited(_refreshReport(client, target));
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 423 && mounted) {
        final token = await Navigator.of(context, rootNavigator: true)
            .push<String>(
              MaterialPageRoute(
                builder: (_) => const CaptchaScreen(),
                fullscreenDialog: true,
              ),
            );
        if (token != null) await _drawWithToken(token, day, target);
      } else if (mounted) {
        showErrorAlert(error);
      }
    } catch (error) {
      if (mounted) showErrorAlert(error);
    } finally {
      if (mounted) setState(() => _checkingInDays.remove(target));
    }
  }

  Future<void> _drawWithToken(
    String token,
    DateTime? day,
    DateTime target,
  ) async {
    final result = await ref
        .read(solarNetworkClientProvider)
        .accounts
        .checkIn(captchaToken: token, backdated: day);
    if (!mounted) return;
    setState(() => _instantResults[target] = result);
    _markFresh(target);
    ref.invalidate(checkInResultTodayProvider);
    if (result.fortuneReport == null) {
      unawaited(_refreshReport(ref.read(solarNetworkClientProvider), target));
    }
  }

  /// The fortune report is generated server-side a moment after the draw; poll
  /// the day it landed on until the report shows up.
  Future<void> _refreshReport(dynamic client, DateTime day) async {
    for (var attempt = 0; attempt < 45; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      try {
        final result = day == _day(DateTime.now())
            ? await client.accounts.getCheckInResultToday()
            : await _checkInResultOnDay(client, day);
        if (result?.fortuneReport == null) continue;
        if (!mounted) return;
        setState(() => _instantResults[day] = result!);
        ref.invalidate(checkInResultTodayProvider);
        return;
      } catch (_) {}
    }
  }

  /// Looks a past day's draw up through the calendar, which is the only
  /// endpoint that answers for a day other than today. Both sides are compared
  /// as UTC days: the server files every entry at UTC midnight.
  Future<SnCheckInResult?> _checkInResultOnDay(
    dynamic client,
    DateTime day,
  ) async {
    final entries = await client.accounts.getEventCalendar(
      year: day.year,
      month: day.month,
    );
    final wanted = DateTime.utc(day.year, day.month, day.day);
    for (final entry in entries as List<SnEventCalendarEntry>) {
      final entryDay = DateTime.utc(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      if (entryDay == wanted) return entry.checkInResult;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final debugOptions = widget.debugOptions;
    final today = _day(DateTime.now());

    final instant = Map<DateTime, SnCheckInResult>.of(_instantResults);
    // Debug sheets start un-drawn so the local draw still animates today in.
    final todayResult = debugOptions != null
        ? instant[today]
        : instant[today] ?? ref.watch(checkInResultTodayProvider).asData?.value;
    if (todayResult != null) instant[today] = todayResult;

    return SheetScaffold(
      titleText: 'checkInTemple'.tr(),
      actions: [
        if (todayResult != null)
          IconButton(
            tooltip: 'share'.tr(),
            onPressed: () =>
                shareCheckInAsScreenshot(context, ref, todayResult),
            icon: const Icon(Symbols.share_reviews),
          ),
        const Gap(8),
      ],
      child: _CheckInDatePage(
        todayResult: todayResult,
        instantResults: instant,
        checkingInDays: _checkingInDays,
        freshDays: _freshDays,
        onCheckIn: _checkIn,
        onCheckInBackdated: _checkInBackdated,
        debugResults: debugOptions == null
            ? null
            : {
                for (final past in debugOptions.pastResults)
                  _day(past.createdAt): past,
              },
      ),
    );
  }
}

class _CheckInDatePage extends ConsumerStatefulWidget {
  final SnCheckInResult? todayResult;

  /// Draws made in this session, keyed by day; overrides the calendar feed for
  /// those days.
  final Map<DateTime, SnCheckInResult> instantResults;

  /// Days with a draw in flight.
  final Set<DateTime> checkingInDays;

  /// Days whose draw just landed: their stamp is pasted onto the tile.
  final Set<DateTime> freshDays;

  final VoidCallback onCheckIn;

  /// Fills in a past day, which the server only allows for subscribers and up
  /// to four times a month.
  final ValueChanged<DateTime> onCheckInBackdated;

  /// Set by the debug tools; when present the rail is fed from these results
  /// instead of the event calendar API.
  final Map<DateTime, SnCheckInResult>? debugResults;

  const _CheckInDatePage({
    required this.todayResult,
    required this.instantResults,
    required this.checkingInDays,
    required this.freshDays,
    required this.onCheckIn,
    required this.onCheckInBackdated,
    this.debugResults,
  });
  @override
  ConsumerState<_CheckInDatePage> createState() => _CheckInDatePageState();
}

class _CheckInDatePageState extends ConsumerState<_CheckInDatePage> {
  /// Days the rail keeps past today. The strip never re-flows under the
  /// visitor's finger while a date is picked, so this stays fixed.
  static const _railWindow = 3;

  /// How much history one page of the rail adds.
  static const _railPageDays = 7;

  /// How far back the rail currently reaches; grows as history is paged in.
  int _backDays = _railWindow;

  /// Null while the visitor has not picked a day, so the page can open on the
  /// newest check-in instead of an empty today.
  DateTime? _selected;

  @override
  void didUpdateWidget(covariant _CheckInDatePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A fresh draw just landed: the rail slides off the last check-in and onto
    // today, which is the animation the visitor waits for.
    if (oldWidget.todayResult == null && widget.todayResult != null) {
      _selected = _day(DateTime.now());
    }
  }

  /// Pages another week of history into the rail; the events for the months it
  /// reaches are fetched by [_calendarResults] as it grows.
  void _extendOlder() {
    if (!mounted) return;
    setState(() => _backDays += _railPageDays);
  }

  @override
  Widget build(BuildContext context) {
    final today = _day(DateTime.now());
    final dates = _railDates(today);
    final results = _resultsFor(dates);
    final selected = _selected ?? _lastCheckIn(today, dates, results);
    final selectedResult = results[selected];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The strip runs to the sheet's edges: it should read as
                  // continuing past them, not as a row of tiles in a gutter.
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _CheckInDateRail(
                      dates: dates,
                      results: results,
                      freshDays: widget.freshDays,
                      selected: selected,
                      today: today,
                      onSelected: (date) => setState(() => _selected = date),
                      onExtendOlder: _extendOlder,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: results[today] == null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _CheckInTodayBanner(
                                    isLoading: widget.checkingInDays.contains(
                                      today,
                                    ),
                                    onCheckIn: widget.onCheckIn,
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const Gap(20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, .04),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: _CheckInContent(
                            key: ValueKey(selected),
                            result: selectedResult,
                            // There is nothing to draw for a day still ahead of
                            // the visitor, even inside the rail's forward
                            // window.
                            isFuture: selected.isAfter(today),
                            isToday: _sameDay(selected, today),
                            isCheckingIn: widget.checkingInDays.contains(
                              selected,
                            ),
                            onCheckInBackdated: () =>
                                widget.onCheckInBackdated(selected),
                            debugResults: widget.debugResults,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The rail spans today plus the history paged in so far; [_extendOlder]
  /// grows the older edge, the newer edge stays [_railWindow] days past today
  /// because there is nothing to draw ahead of it.
  List<DateTime> _railDates(DateTime today) => [
    for (var offset = -_backDays; offset <= _railWindow; offset++)
      DateTime(today.year, today.month, today.day + offset),
  ];

  /// Check-ins for every month the rail touches, plus the draw that just came
  /// back (it is not in the calendar yet).
  Map<DateTime, SnCheckInResult> _resultsFor(List<DateTime> dates) {
    final results = widget.debugResults != null
        ? Map<DateTime, SnCheckInResult>.of(widget.debugResults!)
        : _calendarResults(dates);
    // Draws made in this session win over the calendar, which does not know
    // about them until it is fetched again.
    results.addAll(widget.instantResults);
    final todayResult = widget.todayResult;
    if (todayResult != null) results[_day(DateTime.now())] = todayResult;
    return results;
  }

  Map<DateTime, SnCheckInResult> _calendarResults(List<DateTime> dates) {
    final results = <DateTime, SnCheckInResult>{};
    // Paged-in history can span more than two months, so walk every month the
    // rail touches instead of only its two edges.
    final lastMonth = DateTime(dates.last.year, dates.last.month);
    for (
      var month = DateTime(dates.first.year, dates.first.month);
      !month.isAfter(lastMonth);
      month = DateTime(month.year, month.month + 1)
    ) {
      final entries = ref
          .watch(
            eventCalendarProvider(
              EventCalendarQuery(
                uname: 'me',
                year: month.year,
                month: month.month,
              ),
            ),
          )
          .asData
          ?.value;
      for (final entry in entries ?? const <SnEventCalendarEntry>[]) {
        final result = entry.checkInResult;
        if (result != null) results[_day(entry.date)] = result;
      }
    }
    return results;
  }

  /// Opens on the newest check-in visible in the rail, so the visitor sees what
  /// they last drew rather than an empty today.
  DateTime _lastCheckIn(
    DateTime today,
    List<DateTime> dates,
    Map<DateTime, SnCheckInResult> results,
  ) {
    if (results.containsKey(today)) return today;
    final past =
        results.keys
            .where((date) => date.isBefore(today) && dates.contains(date))
            .toList()
          ..sort();
    return past.isEmpty ? today : past.last;
  }
}

class _CheckInDateRail extends StatefulWidget {
  final List<DateTime> dates;

  /// The day the strip is showing, with its draw when there is one: a tile
  /// wears the stamp of the tier it landed on.
  final Map<DateTime, SnCheckInResult> results;

  /// Days whose draw just landed, so their stamp is pasted on rather than
  /// simply present.
  final Set<DateTime> freshDays;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelected;

  /// Fires when the strip is dragged past its oldest loaded day, so the page
  /// can hand it another week of history.
  final VoidCallback onExtendOlder;

  const _CheckInDateRail({
    required this.dates,
    required this.results,
    required this.freshDays,
    required this.selected,
    required this.today,
    required this.onSelected,
    required this.onExtendOlder,
  });

  @override
  State<_CheckInDateRail> createState() => _CheckInDateRailState();
}

class _CheckInDateRailState extends State<_CheckInDateRail> {
  static const _cardWidth = 108.0;
  static const _cardHeight = 122.0;

  /// The card, plus the slack the corner stamps hang into; a rotated stamp
  /// reaches a few pixels further than its overhang, so the rail keeps extra.
  static const _railHeight = 170.0;

  /// Room at both ends of the strip for the first and last tile's corner
  /// stamps; without it the strip's viewport would shave them off.
  static const _stampMargin = 24.0;

  /// Slack around a scaled card, so a smaller neighbour does not hug the one
  /// beside it.
  static const _slack = 8.0;

  /// Space between two days: wide enough that a corner stamp hanging off one
  /// tile does not reach the next.
  static const _gap = 12.0;

  /// Distance the strip has to travel back from an edge before it may page
  /// again, so one continuous drag does not unroll a month at a time.
  static const _rearmDistance = 32.0;

  final _controller = ScrollController();
  bool _olderArmed = true;

  static double _scaleFor(int distance) => switch (distance) {
    0 => 1.0,
    1 => .76,
    2 => .58,
    _ => .46,
  };

  static double _opacityFor(int distance) => switch (distance) {
    0 => 1.0,
    1 => .72,
    2 => .48,
    _ => .28,
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) return false;
    if (notification is OverscrollNotification) {
      // The strip is anchored on its newest day, so the older end is the
      // trailing edge: dragging past it pages in more history.
      if (notification.overscroll > 0 && _olderArmed) {
        _olderArmed = false;
        widget.onExtendOlder();
      }
      return false;
    }
    if (notification is ScrollUpdateNotification &&
        notification.metrics.maxScrollExtent - notification.metrics.pixels >
            _rearmDistance) {
      _olderArmed = true;
    }
    return false;
  }

  void _select(DateTime date) {
    widget.onSelected(date);
    // The oldest loaded day ends the strip, so picking it pages in the week
    // behind it. That keeps history reachable on layouts wide enough to show
    // the whole window at once, where there is nothing to drag.
    if (date == widget.dates.first) widget.onExtendOlder();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: _railHeight,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: ListView.separated(
          // Reversed so the strip is anchored on today's end and paging older
          // days in appends to the far side instead of shifting the view.
          reverse: true,
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _stampMargin),
          itemCount: widget.dates.length,
          separatorBuilder: (_, _) => const Gap(_gap),
          itemBuilder: (context, index) {
            final date = widget.dates[widget.dates.length - 1 - index];
            final distance = date.difference(widget.selected).inDays.abs();
            final active = distance == 0;
            final scale = _scaleFor(distance);
            final level = widget.results[date]?.level;
            return AnimatedContainer(
              // Keyed by day so paging in history rebuilds the strip instead of
              // morphing every card into its new neighbour's size.
              key: ValueKey(date),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              width: _cardWidth * scale + _slack,
              alignment: Alignment.center,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                scale: scale,
                // The slot is narrower than the card once the card is scaled
                // down; the card keeps its full size so its contents never
                // reflow as the strip moves.
                child: OverflowBox(
                  minWidth: _cardWidth,
                  maxWidth: _cardWidth,
                  maxHeight: _cardHeight,
                  child: Opacity(
                    opacity: _opacityFor(distance),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => _select(_day(date)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          width: _cardWidth,
                          height: _cardHeight,
                          decoration: BoxDecoration(
                            color: active
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: .4),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: active
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: .32,
                                    )
                                  : theme.colorScheme.outlineVariant.withValues(
                                      alpha: .35,
                                    ),
                            ),
                          ),
                          // The stamp is stuck to the tile's edge and hangs
                          // past it, so the layer it rides on does not clip.
                          child: Stack(
                            fit: StackFit.passthrough,
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _sameDay(date, widget.today)
                                          ? 'TODAY'
                                          : DateFormat.E()
                                                .format(date)
                                                .toUpperCase(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            letterSpacing: 1.1,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const Gap(5),
                                    Text(
                                      '${date.day}',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            height: .95,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      DateFormat.MMM().format(date),
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (level != null)
                                _RailStamp(
                                  date: date,
                                  level: level,
                                  selected: active,
                                  pasteIn: widget.freshDays.contains(date),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The stamp of the tier a day landed on. On its corner it hangs off the tile
/// edge; on the day the visitor picked it grows over the whole tile and parks
/// in the middle, hiding the date. Corner and tilt come off the date, so a tile
/// keeps the same look on every rebuild while the next day's lands elsewhere.
///
/// A day whose draw just landed has its stamp pasted on instead: it arrives
/// cocked and oversized, slaps flat with a squash, and wobbles to rest.
class _RailStamp extends StatefulWidget {
  static const _size = 64.0;

  /// Fills the tile, so a selected day reads as its stamp rather than a date
  /// with a picture on it.
  static const _selectedSize = _CheckInDateRailState._cardWidth;

  /// How far the stamp reaches past the tile edge, so it reads as stuck on
  /// rather than placed inside. The rail leaves slack for it on every side.
  static const _overhang = -16.0;

  static const _morph = Duration(milliseconds: 380);

  /// The whole paste: down fast, then the settle.
  static const _paste = Duration(milliseconds: 560);

  final DateTime date;
  final int level;
  final bool selected;

  /// Set for the day a draw just landed on, which pastes its stamp on.
  final bool pasteIn;

  const _RailStamp({
    required this.date,
    required this.level,
    required this.selected,
    this.pasteIn = false,
  });

  @override
  State<_RailStamp> createState() => _RailStampState();
}

class _RailStampState extends State<_RailStamp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _RailStamp._paste,
    // A stamp that was already on the tile is simply at rest.
    value: widget.pasteIn ? 0 : 1,
  );

  /// Down fast, a little past the tile, then back to flat.
  late final Animation<double> _press = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.22,
        end: .955,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: .955,
        end: 1.025,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 34,
    ),
    TweenSequenceItem(tween: Tween<double>(begin: 1.025, end: 1), weight: 36),
  ]).animate(_controller);

  /// The squash of something pressed onto a surface, and its rebound.
  late final Animation<double> _squash = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: .13, end: -.03), weight: 34),
    TweenSequenceItem(tween: Tween<double>(begin: -.03, end: 0), weight: 66),
  ]).animate(_controller);

  /// Extra tilt on top of where the stamp comes to rest: it lands crooked,
  /// swings past, and settles.
  late final Animation<double> _tilt = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: .18,
        end: -.035,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: -.035, end: .012),
      weight: 32,
    ),
    TweenSequenceItem(tween: Tween<double>(begin: .012, end: 0), weight: 33),
  ]).animate(_controller);

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, .16, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pasteIn) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = checkInStampRandom(widget.date);
    final corner = random.nextInt(4);
    final width = _CheckInDateRailState._cardWidth;
    final height = _CheckInDateRailState._cardHeight;
    final size = widget.selected ? _RailStamp._selectedSize : _RailStamp._size;
    // Anchored by its top-left in both states, so the implicit animation can
    // tween straight from the corner it was dealt to the middle.
    final left = widget.selected
        ? (width - size) / 2
        : (corner.isEven
              ? _RailStamp._overhang
              : width - size - _RailStamp._overhang);
    final top = widget.selected
        ? (height - size) / 2
        : (corner < 2
              ? _RailStamp._overhang
              : height - size - _RailStamp._overhang);

    return AnimatedPositioned(
      duration: _RailStamp._morph,
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      width: size,
      height: size,
      child: AnimatedRotation(
        turns: widget.selected
            ? 0
            : (random.nextDouble() - 0.5) * 0.36 / (2 * pi),
        duration: _RailStamp._morph,
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.rotate(
            angle: _tilt.value,
            child: Transform.scale(
              scaleX: _press.value * (1 + _squash.value),
              scaleY: _press.value * (1 - _squash.value),
              child: child,
            ),
          ),
          child: FadeTransition(
            opacity: _fade,
            child: Image.asset(
              checkInStampAsset(widget.level),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

/// Today's draw action sits outside the day content so it stays reachable
/// while the visitor browses earlier check-ins.
class _CheckInTodayBanner extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCheckIn;

  const _CheckInTodayBanner({required this.isLoading, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onCheckIn,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Symbols.auto_awesome),
      label: Text('checkInDrawToday'.tr()),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Space between two blocks of the reading, and the radius every block shares.
const _panelGap = 14.0;
const _panelRadius = 16.0;

/// Flat shell for everything below the date rail: one tinted surface, a
/// hairline edge, no shadow. The rail's stamps carry the decoration on this
/// page, so the blocks underneath stay quiet and let the type do the talking.
class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_panelRadius),
        border: Border.all(
          color:
              borderColor ??
              theme.colorScheme.outlineVariant.withValues(alpha: .45),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// One heading treatment for every block, so the scroll keeps a single voice.
class _PanelHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PanelHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 9,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        Expanded(
          child: Text(
            label,
            style: checkInSerif(
              context,
              base: theme.textTheme.titleMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckInContent extends ConsumerWidget {
  final SnCheckInResult? result;

  /// The selected day is still ahead of the visitor: the rail shows a few of
  /// those so today sits off the edge, but there is nothing to draw on them.
  final bool isFuture;

  /// The selected day is today, which draws through the banner above.
  final bool isToday;

  /// A draw for this day is in flight.
  final bool isCheckingIn;

  /// Fills in this day after the fact.
  final VoidCallback onCheckInBackdated;

  /// Set by the debug tools; replaces the calendar feed under the fortune
  /// page so no request is made for the graph.
  final Map<DateTime, SnCheckInResult>? debugResults;

  const _CheckInContent({
    super.key,
    required this.result,
    required this.isFuture,
    required this.isToday,
    required this.isCheckingIn,
    required this.onCheckInBackdated,
    this.debugResults,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = result?.fortuneReport;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result == null)
          if (isFuture)
            const _NoCheckInRecorded()
          else if (isToday)
            const _CheckInPrompt()
          else
            _BackdatePrompt(
              isLoading: isCheckingIn,
              onCheckIn: onCheckInBackdated,
            )
        else
          ...(() {
            final checkInResult = result!;
            return [
              FortuneCard(
                level: checkInResult.level,
                createdAt: checkInResult.createdAt,
                poem: report?.poem,
                summary: report?.summary,
                showArtwork: false,
              ),
              if (report != null) ...[
                const Gap(_panelGap),
                FortuneGuidanceCard(report: report),
                if (checkInResult.tips.isNotEmpty) ...[
                  const Gap(_panelGap),
                  FortuneTipsCard(tips: checkInResult.tips),
                ],
                const Gap(_panelGap),
                FortuneLuckyGrid(report: report),
                const Gap(_panelGap),
                FortuneDetails(report: report),
                const Gap(_panelGap),
                FortuneActionCard(report: report),
                const Gap(_panelGap),
                FortuneRitualCard(report: report),
                const Gap(_panelGap),
                _Panel(
                  child: FortuneGraphWidget(
                    events: debugResults == null
                        ? ref.watch(
                            eventCalendarProvider(
                              EventCalendarQuery(
                                uname: 'me',
                                year: now.year,
                                month: now.month,
                              ),
                            ),
                          )
                        : AsyncValue.data([
                            for (final entry in debugResults!.entries)
                              SnEventCalendarEntry(
                                date: entry.key,
                                checkInResult: entry.value,
                              ),
                          ]),
                    eventCalandarUser: 'me',
                  ),
                ),
              ] else ...[
                const Gap(_panelGap),
                const FallbackMessage(),
              ],
            ];
          })(),
      ],
    );
  }
}

class TempleHeader extends StatelessWidget {
  final DateTime date;

  const TempleHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Symbols.temple_buddhist,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const Gap(12),
        Text(
          'checkInTempleTitle'.tr(),
          style: checkInSerif(
            context,
            base: theme.textTheme.headlineSmall,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(4),
        Text(
          DateFormat.yMMMMEEEEd().format(date),
          style: checkInSerif(
            context,
            base: theme.textTheme.bodyMedium,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Today has not been drawn yet. The draw action lives in the banner above, so
/// this stays a quiet invitation rather than a second button.
class _CheckInPrompt extends StatelessWidget {
  const _CheckInPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Symbols.local_fire_department,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const Gap(16),
          Text(
            'checkInNone'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'checkInTempleHint'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A past day without a draw offers to fill it in. The server rejects the
/// attempt for accounts without a subscription and past the monthly cap, and
/// its error explains which, so this stays a plain invitation.
class _BackdatePrompt extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCheckIn;

  const _BackdatePrompt({required this.isLoading, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Symbols.history, size: 48, color: theme.colorScheme.primary),
          const Gap(16),
          Text(
            'checkInBackdateTitle'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'checkInBackdateHint'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          FilledButton.icon(
            onPressed: isLoading ? null : onCheckIn,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Symbols.auto_awesome),
            label: Text('checkInBackdateDraw'.tr()),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const Gap(10),
          Text(
            'checkInBackdateNote'.tr(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Past days never offer a check-in, so they get a quiet record instead of a
/// call to action that cannot do anything.
class _NoCheckInRecorded extends StatelessWidget {
  const _NoCheckInRecorded();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Symbols.event_busy,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const Gap(12),
          Text(
            'checkInNonePast'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class FortuneCard extends StatelessWidget {
  final int level;
  final DateTime? createdAt;
  final String? poem;
  final String? summary;
  final double? artHeight;
  final bool showSealHeader;
  final bool showArtwork;

  const FortuneCard({
    super.key,
    required this.level,
    this.createdAt,
    this.poem,
    this.summary,
    this.artHeight,
    this.showSealHeader = true,
    this.showArtwork = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = _getLevelColor(context, level);
    final artAsset = checkInResultAsset(level);
    final artBackdrop = checkInResultBackdrop(level);
    final lunarDate = createdAt != null ? Lunar.fromDate(createdAt!) : null;
    final hasPoem = poem?.isNotEmpty ?? false;
    final hasSummary = summary?.isNotEmpty ?? false;

    // The draw is the one block that wears a colour of its own: the tier it
    // landed on. Still flat, tinted and edged rather than raised.
    return _Panel(
      background: levelColor.withValues(alpha: .07),
      borderColor: levelColor.withValues(alpha: .26),
      child: Column(
        children: [
          if (showArtwork && artAsset != null) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: artBackdrop,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (artHeight != null)
                      SizedBox(
                        height: artHeight,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(artAsset, fit: BoxFit.contain),
                        ),
                      )
                    else
                      AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(artAsset, fit: BoxFit.contain),
                        ),
                      ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                            stops: const [0.55, 1],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(18),
          ],
          if (showSealHeader) ...[
            FortuneSealHeader(
              level: level,
              lunarDate: lunarDate,
              levelColor: levelColor,
            ),
            // The tier's rule closes the heading and opens the verse. There is
            // nothing to open on a draw whose report has not landed yet, so the
            // card keeps it in reserve until the verse is there.
            if (hasPoem || hasSummary) ...[
              const Gap(18),
              // The rule hangs with the verse rather than the heading: the
              // opening lines of a slip sit just under its frame line.
              Container(height: 1, color: levelColor.withValues(alpha: .28)),
              const Gap(10),
            ],
          ],
          // The verse is the body of the card and the gloss is its caption, so
          // they are told apart by size and colour rather than by decoration.
          if (hasPoem)
            Text(
              poem!,
              style: checkInSerif(
                context,
                base: theme.textTheme.titleMedium,
                height: 1.9,
              ),
              textAlign: TextAlign.center,
            ),
          if (hasPoem && hasSummary) const Gap(18),
          if (hasSummary)
            Text(
              summary!,
              style: checkInSerif(
                context,
                base: theme.textTheme.bodySmall,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(BuildContext context, int level) {
    switch (level) {
      case 4:
        return const Color(0xFFC83B37);
      case 3:
        return const Color(0xFFB8871A);
      case 2:
        return const Color(0xFF447BC8);
      case 1:
        return const Color(0xFF5F5890);
      case 0:
        return const Color(0xFF69496C);
      case 5:
        return const Color(0xFFC85E74);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class FortuneDetails extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneDetails({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // One panel, one heading, hairline rules: the readings are a list of the
    // same kind, so they read as one block rather than six stacked cards.
    final items = [
      (Symbols.volunteer_activism, 'checkInFortuneWish'.tr(), report.wish),
      (Symbols.favorite, 'checkInFortuneLove'.tr(), report.love),
      (Symbols.school, 'checkInFortuneStudy'.tr(), report.study),
      (Symbols.work, 'checkInFortuneCareer'.tr(), report.career),
      (Symbols.spa, 'checkInFortuneHealth'.tr(), report.health),
      (Symbols.travel_explore, 'checkInFortuneLostItem'.tr(), report.lostItem),
    ];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Symbols.auto_awesome,
            label: 'fortuneDetails'.tr(),
          ),
          const Gap(4),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: .4),
              ),
            _FortuneItem(
              icon: items[i].$1,
              label: items[i].$2,
              value: items[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class FortuneTipsCard extends StatelessWidget {
  final List<SnFortuneTip> tips;

  const FortuneTipsCard({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Symbols.tips_and_updates,
            label: 'checkInFortuneTips'.tr(),
          ),
          const Gap(12),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    tip.isPositive ? Symbols.thumb_up : Symbols.thumb_down,
                    size: 16,
                    color: tip.isPositive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: checkInSerif(
                            context,
                            base: theme.textTheme.bodyMedium,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          tip.content,
                          style: checkInSerif(
                            context,
                            base: theme.textTheme.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FortuneActionCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneActionCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Symbols.directions_run,
            label: 'checkInFortuneActions'.tr(),
          ),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ActionItem(
                  icon: Symbols.task_alt,
                  label: 'checkInFortuneLuckyAction'.tr(),
                  value: report.luckyAction,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(16),
              Expanded(
                child: _ActionItem(
                  icon: Symbols.block,
                  label: 'checkInFortuneAvoidAction'.tr(),
                  value: report.avoidAction,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            Icon(icon, size: 16, color: color),
            Flexible(
              child: Text(
                label,
                style: checkInSerif(
                  context,
                  base: theme.textTheme.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const Gap(4),
        Text(
          value,
          style: checkInSerif(
            context,
            base: theme.textTheme.bodyMedium,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class FortuneSealHeader extends StatelessWidget {
  final int level;
  final Lunar? lunarDate;
  final Color levelColor;

  const FortuneSealHeader({
    super.key,
    required this.level,
    required this.lunarDate,
    required this.levelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lunar = lunarDate;
    // Both halves of the note are set identically: stacking only says which
    // half is the label, it does not make the label a lesser note.
    final noteStyle = checkInSerif(
      context,
      base: theme.textTheme.bodySmall,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );

    // One axis, one hero. The tier the draw landed on is the answer the visitor
    // opened the sheet for, so it is the loudest thing on the card; everything
    // under it is quieter, and all of it sits on the card's midline.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scales down rather than overflowing on the long tiers ("Happy
        // Birthday 🥳", "생일 축하합니다 🥳").
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            'checkInResultLevel$level'.tr(),
            style: checkInSerif(
              context,
              base: theme.textTheme.headlineSmall,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: levelColor,
            ),
          ),
        ),
        if (lunar != null) ...[
          const Gap(9),
          // Month and day belong together, so they read as one note under the
          // tier instead of two numerals pulled to opposite edges, with the
          // 农历 mark stacked in the margin the way a slip is annotated.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('农\n历', style: noteStyle.copyWith(height: 1.05)),
              const Gap(10),
              Text(
                '${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}',
                style: noteStyle,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FortuneGuidanceCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneGuidanceCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Symbols.menu_book,
            label: 'checkInFortuneGuidance'.tr(),
          ),
          const Gap(12),
          if (report.summaryDetail != null)
            Text(
              report.summaryDetail!,
              style: checkInSerif(
                context,
                base: theme.textTheme.bodyMedium,
                height: 1.75,
                color: theme.colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

class FortuneLuckyGrid extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneLuckyGrid({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Symbols.palette, 'checkInFortuneLuckyColor'.tr(), report.luckyColor),
      (
        Symbols.explore,
        'checkInFortuneLuckyDirection'.tr(),
        report.luckyDirection,
      ),
      (Symbols.schedule, 'checkInFortuneLuckyTime'.tr(), report.luckyTime),
      (Symbols.key, 'checkInFortuneLuckyItem'.tr(), report.luckyItem),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        // One panel, no inner cards, no fixed row heights: a lucky time that
        // wraps to a second line simply makes its row taller.
        final rows = [
          for (var i = 0; i < items.length; i += columns)
            items.sublist(i, min(i + columns, items.length)),
        ];
        return _Panel(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var column = 0; column < columns; column++) ...[
                        if (column > 0) const Gap(20),
                        Expanded(
                          child: column < row.length
                              ? _Omen(
                                  icon: row[column].$1,
                                  label: row[column].$2,
                                  value: row[column].$3,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// One of the four omens: an icon, the name it goes by, and what it points at.
class _Omen extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Omen({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: checkInSerif(
                  context,
                  base: theme.textTheme.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(4),
              Text(
                value,
                style: checkInSerif(
                  context,
                  base: theme.textTheme.bodyMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FortuneRitualCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneRitualCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Panel(
      background: theme.colorScheme.primaryContainer.withValues(alpha: .3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Symbols.auto_fix_high,
            label: 'checkInFortuneRitual'.tr(),
          ),
          const Gap(12),
          Text(
            report.ritual,
            style: checkInSerif(
              context,
              base: theme.textTheme.bodyMedium,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _FortuneItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FortuneItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodyMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FallbackMessage extends StatelessWidget {
  const FallbackMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 12,
        children: [
          Icon(
            Symbols.info,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: Text(
              'checkInReportPending'.tr(),
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
