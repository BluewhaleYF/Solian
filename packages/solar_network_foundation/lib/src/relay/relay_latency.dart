import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import 'relay_catalog.dart';
import 'relay_connection.dart';

/// Where a probe dials, and how it trusts the origin.
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

/// Raised when a candidate cannot carry a probe at all.
class RelayProbeException implements Exception {
  final String message;

  const RelayProbeException(this.message);

  @override
  String toString() => 'RelayProbeException: $message';
}

/// What one candidate answered.
class RelayProbeResult {
  /// The relay that was probed, or null for the direct connection.
  final RelayRoute? route;

  /// Time from dialing to a completed TLS handshake with the server, or null
  /// when the probe did not get that far.
  final Duration? latency;

  /// Why the probe failed, or null when it answered.
  final Object? error;

  const RelayProbeResult({this.route, this.latency, this.error});

  /// Whether this measured the connection the client makes without a relay.
  bool get isDirect => route == null;

  /// Whether the candidate carried a usable connection.
  bool get reachable => latency != null;

  @override
  String toString() => reachable
      ? 'RelayProbeResult(${route ?? 'direct'}, ${latency!.inMilliseconds} ms)'
      : 'RelayProbeResult(${route ?? 'direct'}, failed: $error)';
}

/// What every candidate measured: the direct connection, and each relay.
class RelayProbeReport {
  /// The connection with no relay in the path.
  final RelayProbeResult direct;

  /// Every relay that was probed, in the order it was asked for.
  final List<RelayProbeResult> relays;

  const RelayProbeReport({required this.direct, required this.relays});

  /// The reachable candidate with the lowest round trip, direct included.
  ///
  /// A picker takes this as its answer: when it is [RelayProbeResult.isDirect],
  /// the direct connection is the fastest one available.
  RelayProbeResult? get fastest => fastestRelay([direct, ...relays]);

  /// What the relay [id] measured, or null when it was not probed.
  RelayProbeResult? forId(String id) {
    for (final result in relays) {
      if (result.route?.id == id) return result;
    }
    return null;
  }
}

/// Times a direct connection to the server, with no relay in the path.
///
/// This is the alternative a picker offers beside the relays, measured through
/// the very factory the client would use for it ([fallback], its IP override),
/// so the numbers compare fairly.
Future<RelayProbeResult> probeDirect({
  required RelayProbeTarget target,
  NetworkConnectionFactory? fallback,
  Duration timeout = const Duration(seconds: 5),
}) => _measure(
  route: null,
  target: target,
  fallback: fallback,
  timeout: timeout,
);

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
}) => _measure(route: route, target: target, timeout: timeout);

/// Probes the direct connection and every route in [routes] at once.
Future<RelayProbeReport> probeAll(
  Iterable<RelayRoute> routes, {
  required RelayProbeTarget target,
  NetworkConnectionFactory? fallback,
  Duration timeout = const Duration(seconds: 5),
}) async {
  final measured = await Future.wait([
    probeDirect(target: target, fallback: fallback, timeout: timeout),
    for (final route in routes)
      probeRelay(route, target: target, timeout: timeout),
  ]);
  return RelayProbeReport(direct: measured.first, relays: measured.sublist(1));
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

/// The reachable candidate with the lowest latency, or null when none answered.
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

/// Times one candidate, [route] being null for the direct connection.
Future<RelayProbeResult> _measure({
  required RelayRoute? route,
  required RelayProbeTarget target,
  NetworkConnectionFactory? fallback,
  required Duration timeout,
}) async {
  final uri = Uri(
    scheme: 'https',
    host: target.serverHost,
    port: target.serverPort,
    path: '/',
  );
  final applies =
      target.serverHost.trim().isNotEmpty &&
      (route == null ||
          (route.isValid &&
              resolveRelayDialTarget(
                    uri: uri,
                    serverHost: target.serverHost,
                    serverPort: target.serverPort,
                    route: route,
                  ) !=
                  null));
  if (!applies) {
    // Dialing anyway would measure a different connection and call it this
    // candidate's.
    return RelayProbeResult(
      route: route,
      error: const RelayProbeException(
        'the candidate does not apply to this server',
      ),
    );
  }

  final factory = createRelayConnectionFactory(
    serverHost: target.serverHost,
    serverPort: target.serverPort,
    route: route,
    fallback: fallback,
    allowUntrustedCertificate: target.allowUntrustedCertificate,
    // A probe measures the candidate, never the direct path a broken node
    // would fall back to.
    failOpen: false,
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
      '[relay] Probe of ${route ?? 'direct'} failed after '
      '${stopwatch.elapsedMilliseconds} ms: $error',
    );
    return RelayProbeResult(route: route, error: error);
  }
}
