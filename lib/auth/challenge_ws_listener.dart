import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final challengeWsListenerProvider = Provider<ChallengeWsListener>((ref) {
  final listener = ChallengeWsListener(ref);
  ref.onDispose(() => listener.dispose());
  return listener;
});

/// Surfaces cross-device login challenges to the UI from two sources:
///
/// * the `auth.challenge.pending` WebSocket push, which can only be delivered
///   while the socket is up, and
/// * a catch-up fetch of `GET /stargate/auth/challenge/pending`, run on cold
///   start, on socket (re)connect, and on resume while the socket is down, so a
///   challenge created during a socket gap still reaches the user.
///
/// Both paths publish [ChallengePendingEvent], and listeners deduplicate by
/// challenge id. The fetch is event-driven — a session that stays online with a
/// healthy socket is never polled.
class ChallengeWsListener {
  static const _pendingType = 'auth.challenge.pending';

  final _logger = Logger('ChallengeWsListener');
  final Ref _ref;
  StreamSubscription<WebSocketPacket>? _subscription;
  bool _refreshInFlight = false;
  WebSocketState? _lastSocketState;

  ChallengeWsListener(this._ref);

  void start() {
    _subscription?.cancel();
    final ws = _ref.read(websocketProvider);
    _subscription = ws.dataStream.listen(_handlePacket);
    _logger.info('Started listening for challenge WebSocket packets');
  }

  /// Catch-up entry point for the socket state. A transition into `connected`
  /// means everything pushed during the gap was lost, so fetch what is pending
  /// now. Feed it the current state on startup as well.
  void handleSocketState(WebSocketState state) {
    final wasConnected = _isConnected(_lastSocketState);
    _lastSocketState = state;
    if (!_isConnected(state)) return;
    if (wasConnected) return;
    unawaited(refreshPending());
  }

  /// Catch-up entry point for the app lifecycle. A resume with the socket down
  /// may have missed a push while suspended; a resume with a healthy socket
  /// cannot have missed anything, and a later socket death is covered by
  /// [handleSocketState].
  void handleLifecycle(AppLifecycleState? state) {
    if (state != AppLifecycleState.resumed) return;
    if (_isConnected(_ref.read(websocketStateProvider))) return;
    unawaited(refreshPending());
  }

  /// Fetches the pending challenges the push path could not deliver and
  /// publishes them on the event bus. Best effort: a failure while
  /// unauthenticated or offline is recovered by the next trigger.
  Future<void> refreshPending() async {
    if (_refreshInFlight) return;
    if (_ref.read(tokenProvider) == null) return;
    _refreshInFlight = true;
    try {
      final pending = await _ref
          .read(solarNetworkClientProvider)
          .auth
          .getPendingChallenges();
      for (final challenge in pending) {
        eventBus.fire(ChallengePendingEvent(challenge));
      }
    } catch (err) {
      _logger.fine('Pending challenge catch-up fetch failed: $err');
    } finally {
      _refreshInFlight = false;
    }
  }

  void _handlePacket(WebSocketPacket packet) {
    if (packet.type != _pendingType) return;
    if (packet.data == null) return;

    _logger.info('Received challenge pending packet');
    eventBus.fire(ChallengePendingEvent(SnAuthChallenge.fromJson(packet.data!)));
  }

  static bool _isConnected(WebSocketState? state) =>
      state != null &&
      state.maybeWhen(connected: () => true, orElse: () => false);

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
