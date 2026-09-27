import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

/// The origin every probe in this file dials, wrapped by a loopback relay.
///
/// `test/fixtures` holds a self-signed pair for it; probes trust it through
/// [RelayProbeTarget.allowUntrustedCertificate], the same posture the app uses
/// when an IP override is active.
class _Origin {
  final HttpServer server;

  _Origin._(this.server);

  static Future<_Origin> start() async {
    final context = SecurityContext()
      ..useCertificateChain('test/fixtures/cert.pem')
      ..usePrivateKey('test/fixtures/key.pem');
    final server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      context,
    );
    server.listen((request) async {
      await request.response.close();
    });
    return _Origin._(server);
  }

  int get port => server.port;

  Future<void> close() => server.close(force: true);
}

/// Copies bytes between a client and [upstreamPort]: an L4 relay that never
/// terminates TLS, so a probe through it still handshakes with the origin.
Future<ServerSocket> _blindRelay(int upstreamPort) async {
  final relay = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  relay.listen((client) async {
    Socket upstream;
    try {
      upstream = await Socket.connect(
        InternetAddress.loopbackIPv4,
        upstreamPort,
      );
    } catch (_) {
      client.destroy();
      return;
    }
    client.listen(
      upstream.add,
      onDone: upstream.destroy,
      onError: (_) => upstream.destroy(),
    );
    upstream.listen(
      client.add,
      onDone: client.destroy,
      onError: (_) => client.destroy(),
    );
  });
  return relay;
}

void main() {
  const serverHost = 'api.solian.test';
  const target = RelayProbeTarget(
    serverHost: serverHost,
    allowUntrustedCertificate: true,
  );

  RelayRoute routeTo(int port, {String id = 'local'}) =>
      RelayRoute(id: id, host: '127.0.0.1', port: port);

  late _Origin origin;
  late ServerSocket relay;

  setUp(() async {
    origin = await _Origin.start();
    relay = await _blindRelay(origin.port);
  });

  tearDown(() async {
    await relay.close();
    await origin.close();
  });

  group('probeRelay', () {
    test('times a connection that relays to the server', () async {
      final result = await probeRelay(routeTo(relay.port), target: target);

      expect(result.error, isNull);
      expect(result.reachable, isTrue, reason: '$result');
      expect(result.latency, isNotNull);
      // The relay forwards to a loopback origin, so the handshake cannot
      // plausibly cost what the default budget allows.
      expect(result.latency!, lessThan(const Duration(seconds: 5)));
      expect(result.route.port, relay.port);
    });

    test('fails instead of timing out when the relay port is closed', () async {
      final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = closed.port;
      await closed.close();

      final result = await probeRelay(routeTo(port), target: target);

      expect(result.reachable, isFalse);
      expect(result.latency, isNull);
      expect(result.error, isA<SocketException>());
    });

    test('bounds the wait on a relay that carries nothing back', () async {
      // A node that accepts the client and goes quiet, like a relay whose
      // origin is dead: the probe's budget must end its wait on its own, since
      // an in-flight handshake cannot be aborted.
      final stalled = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(stalled.close);
      stalled.listen((socket) {});

      final started = DateTime.now();
      final result = await probeRelay(
        routeTo(stalled.port),
        target: target,
        timeout: const Duration(milliseconds: 400),
      );
      final elapsed = DateTime.now().difference(started);

      expect(result.reachable, isFalse);
      expect(result.error, isA<TimeoutException>());
      expect(
        elapsed,
        lessThan(const Duration(seconds: 3)),
        reason: 'a node that never answers must not hold the probe open',
      );
    });

    test('reports a handshake the client cannot trust', () async {
      // Same node, strict verification: the probe has to fail it, because the
      // client itself would not accept this origin.
      final result = await probeRelay(
        routeTo(relay.port),
        target: const RelayProbeTarget(serverHost: serverHost),
      );

      expect(result.reachable, isFalse);
      expect(result.error, isA<HandshakeException>());
    });

    test('refuses to measure a route that does not apply', () async {
      // An unusable route would otherwise fall through to a direct dial, and a
      // direct dial's timing must never be reported as relay latency.
      final brokenRoute = await probeRelay(
        const RelayRoute(id: 'broken', host: '', port: 0),
        target: target,
      );
      expect(brokenRoute.reachable, isFalse);
      expect(brokenRoute.error, isA<RelayProbeException>());

      final noServer = await probeRelay(
        routeTo(relay.port),
        target: const RelayProbeTarget(serverHost: '  '),
      );
      expect(noServer.reachable, isFalse);
      expect(noServer.error, isA<RelayProbeException>());
    });
  });

  group('probeRelays', () {
    test('measures every route in parallel and keeps their order', () async {
      final results = await probeRelays(
        [routeTo(relay.port, id: 'a'), routeTo(relay.port, id: 'b')],
        target: target,
      );

      expect(results.map((result) => result.route.id), ['a', 'b']);
      expect(results.every((result) => result.reachable), isTrue);
    });
  });

  group('fastestRelay', () {
    test('picks the lowest latency and ignores failures', () {
      const slow = RelayRoute(id: 'slow', host: 'a.example', port: 443);
      const fast = RelayRoute(id: 'fast', host: 'b.example', port: 443);
      const dead = RelayRoute(id: 'dead', host: 'c.example', port: 443);

      expect(
        fastestRelay([
          const RelayProbeResult(
            route: slow,
            latency: Duration(milliseconds: 90),
          ),
          const RelayProbeResult(
            route: dead,
            error: RelayProbeException('no answer'),
          ),
          const RelayProbeResult(
            route: fast,
            latency: Duration(milliseconds: 12),
          ),
        ])?.route.id,
        'fast',
      );
    });

    test('has no answer when nothing was reachable', () {
      const route = RelayRoute(id: 'dead', host: 'c.example', port: 443);
      expect(
        fastestRelay([
          const RelayProbeResult(
            route: route,
            error: RelayProbeException('no answer'),
          ),
        ]),
        isNull,
      );
      expect(fastestRelay(const []), isNull);
    });
  });
}
