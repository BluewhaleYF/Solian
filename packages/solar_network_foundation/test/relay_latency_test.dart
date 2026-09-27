import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
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
      expect(result.route!.port, relay.port);
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
      final records = <LogRecord>[];
      final level = Logger.root.level;
      Logger.root.level = Level.ALL;
      final subscription = Logger.root.onRecord.listen(records.add);
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = level;
      });

      final result = await probeRelay(
        routeTo(relay.port),
        target: const RelayProbeTarget(serverHost: serverHost),
      );

      expect(result.reachable, isFalse);
      expect(result.error, isA<HandshakeException>());
      // The relay copies bytes, so the certificate that arrived is the one to
      // report: it says whose origin answered instead of the server's.
      expect(
        records.map((record) => '${record.message}').where(
          (message) => message.contains('Rejected the certificate presented'),
        ),
        contains(
          allOf(
            contains('presented for api.solian.test'),
            contains('subject='),
            contains('CN=api.solian.test'),
          ),
        ),
      );
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

      expect(results.map((result) => result.route!.id), ['a', 'b']);
      expect(results.every((result) => result.reachable), isTrue);
    });
  });

  group('fastestRelay', () {
    test('picks the lowest latency and ignores failures', () {
      const slow = RelayRoute(id: 'slow', host: 'a.example', port: 443);
      const fast = RelayRoute(id: 'fast', host: 'b.example', port: 443);
      const dead = RelayRoute(id: 'c', host: 'c.example', port: 443);

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
        ])?.route?.id,
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

  group('probeDirect', () {
    test('measures the connection that has no relay in the path', () async {
      final result = await probeDirect(
        target: RelayProbeTarget(
          serverHost: '127.0.0.1',
          serverPort: origin.port,
          allowUntrustedCertificate: true,
        ),
      );

      expect(result.error, isNull);
      expect(result.isDirect, isTrue);
      expect(result.reachable, isTrue);
      expect(result.latency, isNotNull);
    });

    test('measure what the client would dial, fallback included', () async {
      // The direct alternative is the IP-override path for clients that have
      // one, so a probe that ignored it would compare against the wrong dial.
      final result = await probeDirect(
        target: const RelayProbeTarget(
          serverHost: 'api.solian.test',
          allowUntrustedCertificate: true,
        ),
        fallback: (uri, proxyHost, proxyPort) async =>
            throw const RelayProbeException('the client fallback was used'),
      );

      expect(result.reachable, isFalse);
      expect(result.error, isA<RelayProbeException>());
      expect('${result.error}', contains('the client fallback was used'));
    });
  });

  group('probeAll', () {
    test('measures the direct connection beside every relay', () async {
      final report = await probeAll(
        [routeTo(relay.port, id: 'good')],
        target: target,
        fallback: (uri, proxyHost, proxyPort) async =>
            throw const RelayProbeException('direct is not measured here'),
      );

      expect(report.direct.isDirect, isTrue);
      expect(report.forId('good')?.reachable, isTrue);
      expect(report.forId('missing'), isNull);
      // Direct failed in this run, so the relay is the one to use.
      expect(report.fastest?.route?.id, 'good');
    });

    test('takes the direct connection when it is the fastest', () {
      const route = RelayRoute(id: 'slow', host: 'a.example', port: 443);
      const report = RelayProbeReport(
        direct: RelayProbeResult(latency: Duration(milliseconds: 8)),
        relays: [
          RelayProbeResult(route: route, latency: Duration(milliseconds: 90)),
        ],
      );

      final fastest = report.fastest;
      expect(fastest?.isDirect, isTrue, reason: 'direct wins on latency');
      expect(fastest?.route, isNull);
    });
  });

  group('describeRelayConfig', () {
    test('names the node, the dial, and what it has to carry', () {
      const route = RelayRoute(
        id: 'CNlongY.Guangdong',
        host: 'net.cnlongy.cc',
        port: 12443,
        region: 'can',
      );

      final described = describeRelayConfig(
        route: route,
        serverHost: 'api.solian.app',
        serverPort: 443,
      );

      expect(described, contains('route=CNlongY.Guangdong'));
      expect(described, contains('region=can'));
      expect(described, contains('dials=net.cnlongy.cc:12443'));
      expect(described, contains('carries=api.solian.app:443'));
      expect(described, contains('certificate=verified'));
    });

    test('reports the addresses a destination resolves to', () async {
      expect(await describeRelayDestination('127.0.0.1'), contains('127.0.0.1'));
      expect(
        await describeRelayDestination('no-such-relay.invalid'),
        startsWith('unresolved'),
      );
    });
  });

  group('failOpen', () {
    test('dials directly when the node cannot carry the connection', () async {
      // The node is wired to an origin whose certificate the client rejects:
      // the request has to keep working, through the fallback.
      final direct = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(direct.close);
      direct.listen((socket) => socket.destroy());

      final failures = <RelayDialFailure>[];
      final factory = createRelayConnectionFactory(
        serverHost: serverHost,
        route: routeTo(relay.port),
        fallback: (uri, proxyHost, proxyPort) async {
          final connection = await Socket.connect('127.0.0.1', direct.port);
          return ConnectionTask.fromSocket(Future.value(connection), () {});
        },
        onRelayFailure: (failure, error) => failures.add(failure),
      );

      final task = await factory(Uri.parse('https://$serverHost/probe'), null, null);
      final socket = await task.socket;
      addTearDown(socket.destroy);

      expect(socket.remotePort, direct.port);
      expect(failures, [RelayDialFailure.certificate]);
    });

    test('keeps measuring the node when the caller asks it to', () async {
      // A probe must report the node as it is, not the direct path it would
      // fall back to.
      final result = await probeRelay(
        routeTo(relay.port),
        target: const RelayProbeTarget(serverHost: serverHost),
      );

      expect(result.reachable, isFalse);
      expect(result.error, isA<HandshakeException>());
      expect(result.isDirect, isFalse);
    });
  });
}
