import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/core/check_in_debug.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'check_in.g.dart';

/// Opens the shrine sheet. [CheckInDebugOptions] replays the flow offline.
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

@riverpod
Future<SnCheckInResult?> checkInResultToday(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getCheckInResultToday();
}

@riverpod
Future<SnNotableDay?> nextNotableDay(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return _specializeNotableDay(await client.accounts.getNextNotableDay());
}

@riverpod
Future<SnNotableDay?> recentNotableDay(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return _specializeNotableDay(await client.accounts.getRecentNotableDay());
}

@riverpod
Future<SnFortuneSaying> randomFortuneSaying(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getRandomFortuneSaying();
}

/// Drops the time of day the server sends and swaps in the localized name when
/// the notable day carries a key the app ships a translation for.
SnNotableDay? _specializeNotableDay(SnNotableDay? day) {
  if (day == null) return null;
  final date = day.date.toLocal().copyWith(hour: 0, second: 0);
  final key = day.localizableKey;
  if (key == null) return day.copyWith(date: date);
  final localizedKey = 'notableDay$key';
  return localizedKey.trExists()
      ? day.copyWith(localName: localizedKey.tr(), date: date)
      : day.copyWith(date: date);
}

/// The 1:1 stamps that dress a draw, under `assets/images/check-in/`. `t{n}` is
/// the stamp for check-in tier `n`.
const checkInStampCount = 5;

String checkInStampAsset(int level) =>
    'assets/images/check-in/t${level.clamp(0, checkInStampCount - 1)}.webp';

/// Generator seeded by the draw's local date: the same day always lands its
/// stamp on the same corner at the same tilt, the next day picks another.
Random checkInStampRandom(DateTime date) {
  final local = date.toLocal();
  return Random(local.year * 10000 + local.month * 100 + local.day);
}

/// Dashboard card for today's draw: what today looks like, and the way in.
class CheckInWidget extends ConsumerWidget {
  final EdgeInsets? margin;

  const CheckInWidget({super.key, this.margin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = ref.watch(checkInResultTodayProvider);
    final view = _CheckInView.of(today);
    // A drawn day leads with the stamp of the tier it landed on.
    final level = today.value?.level;

    return Card(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Padding(
            padding: const .symmetric(vertical: 12, horizontal: 4),
            child: level == null
                ? Image.asset(
                    "assets/images/stickers/confuse.webp",
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    checkInStampAsset(level),
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
          ),
          const Gap(12),
          Expanded(
            // Keyed by state, so the three lines cross-fade as one block
            // instead of each line swapping on its own.
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Align(
                alignment: .centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Column(
                    key: ValueKey(view.state),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        view.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        view.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Gap(4),
          IconButton.filledTonal(
            onPressed: () => showCheckInSheet(context),
            tooltip: 'checkIn'.tr(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Icon(view.icon, key: ValueKey(view.icon)),
            ),
          ),
          IconButton(
            onPressed: () => context.router.push(EventHubRoute(name: 'me')),
            tooltip: 'eventCalendar'.tr(),
            icon: const Icon(Symbols.event),
          ),
          const Gap(12),
        ],
      ),
    );
  }
}

/// One rendering of the card: the eyebrow never changes, the mark, title and
/// body follow today's draw.
class _CheckInView {
  /// Which branch this is, so the switcher keys off the state, not the copy.
  final String state;
  final IconData icon;
  final String title;
  final String body;

  const _CheckInView({
    required this.state,
    required this.icon,
    required this.title,
    required this.body,
  });

  factory _CheckInView.of(AsyncValue<SnCheckInResult?> today) {
    // A refresh keeps the previous draw on screen rather than flashing the
    // "not checked in" copy at someone who already drew today.
    final result = today.value;
    if (result != null) {
      final report = result.fortuneReport;
      return _CheckInView(
        state: 'result',
        icon: Symbols.temple_buddhist,
        title: 'checkInResultLevel${result.level}'.tr(),
        body: report?.summary ?? report?.poem ?? 'checkInReportPending'.tr(),
      );
    }
    if (today.hasError) {
      return _CheckInView(
        state: 'error',
        icon: Symbols.error,
        title: 'somethingWentWrong'.tr(),
        body: today.error.toString(),
      );
    }
    return _CheckInView(
      state: 'none',
      icon: Symbols.local_fire_department,
      title: 'checkInNone'.tr(),
      body: 'checkInNoneHint'.tr(),
    );
  }
}

class CheckInActivityWidget extends StatelessWidget {
  final SnTimelineEvent item;
  const CheckInActivityWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final result = SnCheckInResult.fromJson(item.data);
    final account = result.account!;
    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePictureWidget(
          file: account.profile.picture,
          fallbackName: account.nick,
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
                      account.nick,
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
