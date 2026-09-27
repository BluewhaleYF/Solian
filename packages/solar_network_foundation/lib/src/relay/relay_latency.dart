import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import 'relay_catalog.dart';
import 'relay_connection.dart';

/// Where a relay probe dials, and how it trusts the origin.
///
/// The host and port are the configured server URL's, and
/// [allowUntrustedCertificate] mirrors the posture the client's own dials use —
/// a probe has to measure the connection this client would really get, not a
/// stricter one.
class RelayProbeTarget {
  /// Host of the configured server, the SNI a probe presents to the relay.
  final String serverHost;

  /// Port the configured server answers on; the only port that relays.
  final int serverPort;

  /// Whether the origin's certificate is accepted without verification, as the
  /// installed overrides do when an IP override is active.
  final bool allowUntrustedCertificate;

  const RelayProbeTarget({
    required this.serverHost,
    this.serverPort = 443,
    this.allowUntrustedCertificate = false,
  });

  @override
  String toString() =>
      '$serverHost:$serverPort'
      '${allowUntrustedCertificate ? ' (untrusted certificates allowed)' : ''}';
}

/// Raised when a route cannot carry a probe at all.
class RelayProbeException implements Exception {
  final String message;

  const RelayProbeException(this.message);

  @override
  String toString() => 'RelayProbeException: $message';
}

/// What one relay answered.
class RelayProbeResult {
  /// The relay that was probed.
  final RelayRoute route;

  /// Time from dialing the relay to a completed TLS handshake with the server,
  /// or null when the probe did not get that far.
  final Duration? latency;

  /// Why the probe failed, or null when it answered.
  final Object? error;

  const RelayProbeResult({required this.route, this.latency, this.error});

  /// Whether the relay carried a usable connection.
  bool get reachable => latency != null;

  @override
  String toString() => reachable
      ? 'RelayProbeResult($route, ${latency!.inMilliseconds} ms)'
      : 'RelayProbeResult($route, failed: $error)';
}

/// Times a connection through [route] up to a completed TLS handshake with the
/// configured server.
///
/// This dials the relay exactly like real traffic does — same SNI, same
/// certificate verification — so a result says the node is usable for this
/// client right now, not merely that its TCP port is open: a node whose SNI
/// matches no upstream, or whose origin is down, fails the handshake instead of
/// reporting a fast connect. The socket is closed as soon as the handshake
/// completes, so a probe sends the server nothing beyond TLS.
///
/// One probe is one handshake; call it again to sample again. Never throws: a
/// failure is reported in [RelayProbeResult.error].
///
/// [timeout] bounds how long the probe waits, not a socket the peer has
/// stopped answering: dart:io cannot abort a TLS handshake in flight, so that
/// connection is released by the peer closing it — every relay closes a client
/// that never finishes its ClientHello.
Future<RelayProbeResult> probeRelay(
  RelayRoute route, {
  required RelayProbeTarget target,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final uri = Uri(
    scheme: 'https',
    host: target.serverHost,
    port: target.serverPort,
    path: '/',
  );
  final dialable =
      resolveRelayDialTarget(
        uri: uri,
        serverHost: target.serverHost,
        serverPort: target.serverPort,
        route: route,
      ) !=
      null;
  if (!dialable) {
    // Dialing anyway would measure the direct route and call it a relay.
    return RelayProbeResult(
      route: route,
      error: const RelayProbeException(
        'the route does not apply to this server',
      ),
    );
  }

  final factory = createRelayConnectionFactory(
    serverHost: target.serverHost,
    serverPort: target.serverPort,
    route: route,
    allowUntrustedCertificate: target.allowUntrustedCertificate,
  );

  final stopwatch = Stopwatch()..start();
  ConnectionTask<Socket>? task;
  try {
    final dial = () async {
      final pending = await factory(uri, null, null);
      task = pending;
      return pending.socket;
    }();
    final socket = await dial.timeout(
      timeout,
      onTimeout: () {
        // A dial that finishes after the timeout has nobody else to close it.
        unawaited(dial.then((late) => late.destroy(), onError: (_) {}));
        throw TimeoutException('relay probe timed out', timeout);
      },
    );
    stopwatch.stop();
    socket.destroy();
    return RelayProbeResult(route: route, latency: stopwatch.elapsed);
  } catch (error) {
    stopwatch.stop();
    task?.cancel();
    Logger.root.fine(
      '[relay] Probe of $route failed after ${stopwatch.elapsedMilliseconds} ms: '
      '$error',
    );
    return RelayProbeResult(route: route, error: error);
  }
}

/// Probes every route in [routes] at once, preserving their order.
Future<List<RelayProbeResult>> probeRelays(
  Iterable<RelayRoute> routes, {
  required RelayProbeTarget target,
  Duration timeout = const Duration(seconds: 5),
}) => Future.wait([
  for (final route in routes)
    probeRelay(route, target: target, timeout: timeout),
]);

/// The reachable relay with the lowest latency, or null when none answered.
///
/// A failed probe never wins a race, so an unreachable node cannot be picked
/// for being quiet.
RelayProbeResult? fastestRelay(Iterable<RelayProbeResult> results) {
  RelayProbeResult? best;
  for (final result in results) {
    final latency = result.latency;
    if (latency == null) continue;
    if (best == null || latency < best.latency!) best = result;
  }
  return best;
}
