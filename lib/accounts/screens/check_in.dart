import 'dart:async';

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
      return;
    }
    setState(() => _checkingInDays.add(target));
    final client = ref.read(solarNetworkClientProvider);
    try {
      final result = await client.accounts.checkIn(backdated: day);
      if (!mounted) return;
      setState(() => _instantResults[target] = result);
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CheckInDateRail(
                      dates: dates,
                      selected: selected,
                      today: today,
                      onSelected: (date) => setState(() => _selected = date),
                      onExtendOlder: _extendOlder,
                    ),
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
                    const Gap(24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => FadeTransition(
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
                        // There is nothing to draw for a day still ahead of the
                        // visitor, even inside the rail's forward window.
                        isFuture: selected.isAfter(today),
                        isToday: _sameDay(selected, today),
                        isCheckingIn: widget.checkingInDays.contains(selected),
                        onCheckInBackdated: () =>
                            widget.onCheckInBackdated(selected),
                        debugResults: widget.debugResults,
                      ),
                    ),
                  ],
                ),
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
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelected;

  /// Fires when the strip is dragged past its oldest loaded day, so the page
  /// can hand it another week of history.
  final VoidCallback onExtendOlder;

  const _CheckInDateRail({
    required this.dates,
    required this.selected,
    required this.today,
    required this.onSelected,
    required this.onExtendOlder,
  });

  @override
  State<_CheckInDateRail> createState() => _CheckInDateRailState();
}

class _CheckInDateRailState extends State<_CheckInDateRail> {
  static const _cardWidth = 92.0;
  static const _cardHeight = 104.0;
  static const _railHeight = 116.0;

  /// Slack around a scaled card and the separator between cards. Kept tight so
  /// a day reads as one segment of a strip rather than a tile with margins.
  static const _slack = 8.0;
  static const _gap = 4.0;

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
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: widget.dates.length,
          separatorBuilder: (_, _) => const Gap(_gap),
          itemBuilder: (context, index) {
            final date = widget.dates[widget.dates.length - 1 - index];
            final distance = date.difference(widget.selected).inDays.abs();
            final active = distance == 0;
            final scale = _scaleFor(distance);
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _sameDay(date, widget.today)
                                    ? 'TODAY'
                                    : DateFormat.E().format(date).toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Gap(5),
                              Text(
                                '${date.day}',
                                style: theme.textTheme.headlineMedium?.copyWith(
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
                const Gap(16),
                FortuneGuidanceCard(report: report),
                if (checkInResult.tips.isNotEmpty) ...[
                  const Gap(16),
                  FortuneTipsCard(tips: checkInResult.tips),
                ],
                const Gap(16),
                FortuneLuckyGrid(report: report),
                const Gap(16),
                FortuneDetails(report: report),
                const Gap(16),
                FortuneActionCard(report: report),
                const Gap(16),
                FortuneRitualCard(report: report),
                const Gap(16),
                Card(
                  margin: EdgeInsets.zero,
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
              ] else
                FallbackMessage(),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
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
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
      child: Padding(
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

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              levelColor.withValues(alpha: 0.1),
              levelColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (showArtwork && artAsset != null) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: artBackdrop,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: artBackdrop.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
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
              if (showSealHeader)
                FortuneSealHeader(
                  level: level,
                  lunarDate: lunarDate,
                  levelColor: levelColor,
                ),
              if (poem?.isNotEmpty ?? false) ...[
                const Gap(8),
                Text(
                  poem!,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.titleMedium,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (summary?.isNotEmpty ?? false) ...[
                const Gap(16),
                Text(
                  summary!,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodyMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(
              Symbols.auto_awesome,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            Expanded(
              child: Text(
                'fortuneDetails'.tr(),
                style: checkInSerif(
                  context,
                  base: theme.textTheme.titleMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _FortuneItem(
                icon: Symbols.volunteer_activism,
                label: 'checkInFortuneWish'.tr(),
                value: report.wish,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.favorite,
                label: 'checkInFortuneLove'.tr(),
                value: report.love,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.school,
                label: 'checkInFortuneStudy'.tr(),
                value: report.study,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.work,
                label: 'checkInFortuneCareer'.tr(),
                value: report.career,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.spa,
                label: 'checkInFortuneHealth'.tr(),
                value: report.health,
              ),
              const Divider(height: 1),
              _FortuneItem(
                icon: Symbols.travel_explore,
                label: 'checkInFortuneLostItem'.tr(),
                value: report.lostItem,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FortuneTipsCard extends StatelessWidget {
  final List<SnFortuneTip> tips;

  const FortuneTipsCard({super.key, required this.tips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.tips_and_updates,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'checkInFortuneTips'.tr(),
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.titleMedium,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.directions_run,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'checkInFortuneActions'.tr(),
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.titleMedium,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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
    final lunarMonth = lunarDate?.getMonthInChinese() ?? '--';
    final lunarDay = lunarDate?.getDayInChinese() ?? '--';

    // Both halves scale down instead of overflowing: "A Normal Day" at
    // headline weight is wider than a phone-sized card.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '农\n历',
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.bodyMedium,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(10),
                Text(
                  lunarMonth,
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.headlineMedium,
                    fontWeight: FontWeight.w900,
                    color: levelColor,
                  ),
                ),
                const Gap(6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '月',
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.titleMedium,
                      fontWeight: FontWeight.w700,
                      color: levelColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Flexible(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  'checkInResultLevel$level'.tr(),
                  style: checkInSerif(
                    context,
                    base: theme.textTheme.headlineMedium,
                    fontWeight: FontWeight.w900,
                    color: levelColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lunarDay,
                style: checkInSerif(
                  context,
                  base: theme.textTheme.titleMedium,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.menu_book,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'checkInFortuneGuidance'.tr(),
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.titleMedium,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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
        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 2 ? 2.8 : 3.6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.$1,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: checkInSerif(
                              context,
                              base: Theme.of(context).textTheme.bodySmall,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            item.$3,
                            style: checkInSerif(
                              context,
                              base: Theme.of(context).textTheme.bodyMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FortuneRitualCard extends StatelessWidget {
  final SnCheckInFortuneReport report;

  const FortuneRitualCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Symbols.auto_fix_high,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'checkInFortuneRitual'.tr(),
                    style: checkInSerif(
                      context,
                      base: theme.textTheme.titleMedium,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.all(16),
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
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
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
        ),
      ),
    );
  }
}
