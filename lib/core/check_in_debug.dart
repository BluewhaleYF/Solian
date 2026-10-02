import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Offline replay of the temple flow for the debug tools.
///
/// A sheet opened with these options never touches the network: it skips
/// `checkInResultTodayProvider` and the event calendar, feeds the date rail from
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
