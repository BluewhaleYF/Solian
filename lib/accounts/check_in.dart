import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'check_in.g.dart';

Future<void> showCheckInSheet(
  BuildContext context, {
  CheckInDebugOptions? debugOptions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => CheckInScreen(debugOptions: debugOptions),
  );
}

/// Offline replay of the temple flow for the debug tools.
///
/// A sheet opened with these options never touches the network: it skips
/// [checkInResultTodayProvider] and the event calendar, feeds the date rail from
/// [pastResults], and resolves the draw locally after [drawDelay]. That is what
/// drives the same transition a real draw does — rail sliding off the last
/// check-in onto today, banner collapsing, day content swapping.
class CheckInDebugOptions {
  /// Level of the simulated draw: artwork, backdrop and reward chip.
  final int level;

  /// How long the simulated draw pretends to be in flight before landing.
  final Duration drawDelay;

  /// Whether the sheet draws by itself once open; otherwise the draw button
  /// has to be pressed.
  final bool autoDraw;

  /// Check-ins the rail shows before the draw lands, so the transition has a
  /// past day to slide away from.
  final List<SnCheckInResult> pastResults;

  const CheckInDebugOptions({
    this.level = 4,
    this.drawDelay = const Duration(milliseconds: 1600),
    this.autoDraw = true,
    this.pastResults = const [],
  });

  /// Default replay setup: two past draws keep the rail parked away from today,
  /// and the simulated draw lands [level] on today.
  factory CheckInDebugOptions.simulated({int level = 4, bool autoDraw = true}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return CheckInDebugOptions(
      level: level,
      autoDraw: autoDraw,
      pastResults: [
        buildDebugCheckInResult(
          id: 'debug-check-in-past-2',
          level: 1,
          createdAt: today.subtract(const Duration(days: 2)),
        ),
        buildDebugCheckInResult(
          id: 'debug-check-in-past-1',
          level: 3,
          createdAt: today.subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}

/// Builds a check-in result that renders like a real draw, fortune report
/// included, so the animation lands on the full temple page instead of the
/// "report pending" fallback.
SnCheckInResult buildDebugCheckInResult({
  required String id,
  required int level,
  required DateTime createdAt,
}) {
  return SnCheckInResult(
    id: id,
    level: level,
    accountId: 'debug',
    account: null,
    createdAt: createdAt,
    updatedAt: createdAt,
    deletedAt: null,
    tips: const [
      SnFortuneTip(
        isPositive: true,
        title: 'Sit with the quiet',
        content: 'The morning bell still rings for whoever stops to listen.',
      ),
      SnFortuneTip(
        isPositive: true,
        title: 'Finish one thing',
        content: 'A single finished task outweighs three started ones today.',
      ),
      SnFortuneTip(
        isPositive: false,
        title: 'Skip the shortcut',
        content: 'The quick path costs more than it saves before nightfall.',
      ),
    ],
    fortuneReport: const SnCheckInFortuneReport(
      version: 1,
      poem:
          'Rain on the old eaves —\nthe kettle answers slowly,\nnoon arrives anyway.',
      summary: 'A steady day: small efforts compound, loud ones scatter.',
      summaryDetail:
          'Simulated report rendered by the debug tools; no request was sent.',
      wish: 'Ask plainly and the answer arrives unpolished.',
      love: 'Warmth shows up as patience rather than grand gestures.',
      study: 'Two quiet hours beat six distracted ones.',
      career: 'Hold the long thread; the short cuts unravel by evening.',
      health: 'Stretch before the desk wins the argument.',
      lostItem: 'Look under the second thing you moved.',
      luckyColor: 'Ink blue',
      luckyDirection: 'Southwest',
      luckyTime: 'Late afternoon',
      luckyItem: 'A well-used notebook',
      luckyAction: 'Write the decision down before acting on it.',
      avoidAction: 'Reopening a settled argument.',
      ritual: 'Pour the first cup, then start.',
    ),
  );
}

@riverpod
Future<SnCheckInResult?> checkInResultToday(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getCheckInResultToday();
}

@riverpod
Future<SnNotableDay?> nextNotableDay(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final day = await client.accounts.getNextNotableDay();
  if (day == null) return null;

  if (day.localizableKey != null) {
    final key = 'notableDay${day.localizableKey}';
    if (key.trExists()) {
      return day.copyWith(
        localName: key.tr(),
        date: day.date.toLocal().copyWith(hour: 0, second: 0),
      );
    }
  }
  return day.copyWith(date: day.date.toLocal().copyWith(hour: 0, second: 0));
}

@riverpod
Future<SnNotableDay?> recentNotableDay(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final day = await client.accounts.getRecentNotableDay();
  if (day == null) return null;

  if (day.localizableKey != null) {
    final key = 'notableDay${day.localizableKey}';
    if (key.trExists()) {
      return day.copyWith(
        localName: key.tr(),
        date: day.date.toLocal().copyWith(hour: 0, second: 0),
      );
    }
  }
  return day.copyWith(date: day.date.toLocal().copyWith(hour: 0, second: 0));
}

@riverpod
Future<SnFortuneSaying> randomFortuneSaying(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getRandomFortuneSaying();
}

class CheckInWidget extends ConsumerWidget {
  final EdgeInsets? margin;
  final VoidCallback? onChecked;
  const CheckInWidget({super.key, this.margin, this.onChecked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayResult = ref.watch(checkInResultTodayProvider);

    return Card(
      margin:
          margin ?? EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) {
                      return Text(
                        result == null
                            ? 'checkInNone'
                            : 'checkInResultLevel${result.level}',
                        textAlign: TextAlign.start,
                      ).tr().fontSize(15).bold();
                    },
                    loading: () => Text('checkInNone').tr().fontSize(15).bold(),
                    error: (err, stack) =>
                        Text('error').tr().fontSize(15).bold(),
                  ),
                ).padding(right: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) {
                      if (result == null) {
                        return Text('checkInNoneHint').tr().fontSize(11);
                      }
                      final report = result.fortuneReport;
                      return Text(
                        report?.summary ??
                            report?.poem ??
                            'checkInViewTemple'.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).fontSize(11);
                    },
                    loading: () => Text('checkInNoneHint').tr().fontSize(11),
                    error: (err, stack) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('error').tr().fontSize(15).bold(),
                        Text(err.toString()).fontSize(11),
                      ],
                    ),
                  ),
                ).alignment(Alignment.centerLeft),
              ],
            ),
          ),
          Row(
            spacing: 8,
            children: [
              IconButton.outlined(
                iconSize: 16,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -2,
                ),
                onPressed: () {
                  showCheckInSheet(context);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: todayResult.when(
                    data: (result) => Icon(
                      result == null
                          ? Symbols.local_fire_department
                          : Symbols.temple_buddhist,
                      key: ValueKey(result != null),
                    ),
                    loading: () => const Icon(Symbols.refresh),
                    error: (_, _) => const Icon(Symbols.error),
                  ),
                ),
              ),
              IconButton.outlined(
                iconSize: 16,
                visualDensity: const VisualDensity(
                  horizontal: -3,
                  vertical: -2,
                ),
                onPressed: () {
                  context.router.push(EventHubRoute(name: 'me'));
                },
                icon: const Icon(Symbols.event),
              ),
            ],
          ),
        ],
      ).padding(horizontal: 16, vertical: 12),
    );
  }
}

class CheckInActivityWidget extends StatelessWidget {
  final SnTimelineEvent item;
  const CheckInActivityWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final result = SnCheckInResult.fromJson(item.data);
    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePictureWidget(
          file: result.account!.profile.picture,
          fallbackName: result.account!.nick,
          radius: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Symbols.local_fire_department, size: 14),
                  const Gap(4),
                  Text('checkIn').fontSize(11).tr(),
                ],
              ).opacity(0.85),
              Text('checkInActivityTitle')
                  .tr(
                    args: [
                      result.account!.nick,
                      DateFormat.yMd().format(result.createdAt),
                      'checkInResultLevel${result.level}'.tr(),
                    ],
                  )
                  .fontSize(13)
                  .padding(left: 2),
            ],
          ),
        ),
      ],
    ).padding(horizontal: 16, vertical: 12);
  }
}
