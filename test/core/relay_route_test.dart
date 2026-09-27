import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/relay.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

void main() {
  const idleSettings = IpOverrideSettings(enabled: false, overrides: []);
  const relay = RelayRoute(
    id: 'jp-01',
    host: 'relay-jp.example',
    port: 7443,
    region: 'jp',
  );

  test('leaves the platform transport alone when nothing is configured', () {
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
      ),
      isNull,
    );
  });

  test('installs a connection factory once a relay is selected', () {
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
        relay: () => relay,
      ),
      isA<HttpOverrides>(),
    );
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
        relay: () => const RelayRoute(id: 'broken', host: '', port: 0),
      ),
      isNull,
      reason: 'an unusable route must not install anything',
    );
  });

  test('routes a server that answers on a non-standard port', () async {
    final relayServer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(relayServer.close);
    final accepted = Completer<bool>();
    relayServer.listen((socket) {
      if (!accepted.isCompleted) accepted.complete(true);
      socket.destroy();
    });

    final overrides =
        createAppHttpOverrides(
              mode: IpOverrideMode.off,
              settings: idleSettings,
              domains: const [],
              serverUrl: 'https://api.solian.app:8443',
              relay: () => RelayRoute(
                id: 'local',
                host: relayServer.address.address,
                port: relayServer.port,
              ),
            )
            as ConnectionFactoryHttpOverrides;

    _dial(
      overrides.connectionFactory!,
      Uri.parse('https://api.solian.app:8443/probe'),
    );

    expect(
      await accepted.future.timeout(const Duration(seconds: 5)),
      isTrue,
      reason: 'the port read off the server URL must reach the relay gate',
    );
  });

  group('relayLogSuffix', () {
    const route = RelayRoute(id: 'jp-01', host: 'relay-jp.example', port: 7443);
    const serverUrl = 'https://api.solian.app';

    test('marks the configured server and leaves everything else silent', () {
      expect(
        relayLogSuffix(
          uri: Uri.parse('https://api.solian.app/sphere/timeline?take=20'),
          serverUrl: serverUrl,
          route: route,
        ),
        ' via jp-01',
      );
      expect(
        relayLogSuffix(
          uri: Uri.parse('https://cdn.example.com/image.png'),
          serverUrl: serverUrl,
          route: route,
        ),
        '',
        reason: 'another host never travels through the relay',
      );
      expect(
        relayLogSuffix(
          uri: Uri.parse('https://api.solian.app/sphere/timeline'),
          serverUrl: serverUrl,
          route: null,
        ),
        '',
        reason: 'direct traffic says nothing',
      );
    });

    test('reads a WebSocket URL the way dart:io dials it', () {
      expect(
        relayLogSuffix(
          uri: Uri.parse('wss://api.solian.app/ws?namespace=app'),
          serverUrl: serverUrl,
          route: route,
        ),
        ' via jp-01',
      );
      expect(
        relayLogSuffix(
          uri: Uri.parse('ws://api.solian.app/ws'),
          serverUrl: serverUrl,
          route: route,
        ),
        '',
        reason: 'the relay only carries TLS',
      );
    });
  });

  group('logRelayConfig', () {
    /// Collects the log lines [logRelayConfig] writes.
    Future<List<String>> written(SharedPreferences prefs) async {
      final level = Logger.root.level;
      Logger.root.level = Level.ALL;
      final records = <String>[];
      final subscription = Logger.root.onRecord.listen(
        (record) => records.add(record.message),
      );
      try {
        await logRelayConfig(prefs);
      } finally {
        await subscription.cancel();
        Logger.root.level = level;
      }
      return records;
    }

    test('writes direct traffic and the port it is dialed on', () async {
      final prefs = await _prefsWith(null);
      await prefs.setString(
        kNetworkServerStoreKey,
        'https://api.solian.app:8443',
      );

      expect(await written(prefs), [
        '[relay] Config: direct, no relay selected for api.solian.app:8443',
      ]);
    });

    test('writes the node, the dial, and where the name resolves', () async {
      final prefs = await _prefsWith(
        const RelayRoute(
          id: 'local',
          host: '127.0.0.1',
          port: 12443,
          region: 'can',
        ),
      );

      expect(await written(prefs), [
        '[relay] Config: route=local region=can dials=127.0.0.1:12443 '
            'carries=api.solian.app:443 certificate=verified',
        '[relay] Destination 127.0.0.1:12443 resolves to 127.0.0.1',
      ]);
    });
  });

  group('catalog cache', () {
    const entry = RelayEntry(
      id: 'hk-01',
      endpoint: 'hk-01.relay.example',
      port: 443,
      region: 'hkg',
      healthy: true,
    );

    test('serves a cached catalog without asking the server', () async {
      final prefs = await _prefsWith(null);
      await writeCachedRelayCatalog(prefs, 'https://api.solian.app', [entry]);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          serverUrlProvider.overrideWith((ref) => 'https://api.solian.app'),
        ],
      );
      addTearDown(container.dispose);

      // A fetch would reach the network, and a test has none: the entries can
      // only have come from the cache.
      final entries = await container.read(relayCatalogProvider.future);
      expect(entries.single.id, 'hk-01');
    });

    test('ignores a catalog cached for another server', () async {
      final prefs = await _prefsWith(null);
      await writeCachedRelayCatalog(prefs, 'https://other.example', [entry]);

      expect(readCachedRelayCatalog(prefs, 'https://api.solian.app'), isNull);
    });

    test('ignores a catalog past its age limit', () async {
      final prefs = await _prefsWith(null);
      await writeCachedRelayCatalog(prefs, 'https://api.solian.app', [entry]);
      // The cache is stamped with the clock, so the read needs a later one.
      await Future<void>.delayed(const Duration(milliseconds: 2));

      expect(
        readCachedRelayCatalog(
          prefs,
          'https://api.solian.app',
          maxAge: Duration.zero,
        ),
        isNull,
      );
    });
  });

  group('fail-open', () {
    test('a node that refuses the dial is dropped after three tries', () async {
      final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = closed.port;
      await closed.close();
      const serverUrl = 'https://127.0.0.1';
      final prefs = await _prefsWith(
        RelayRoute(id: 'local', host: '127.0.0.1', port: port),
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          serverUrlProvider.overrideWith((ref) => serverUrl),
        ],
      );
      addTearDown(container.dispose);

      final overrides =
          container.read(appHttpOverridesProvider)
              as ConnectionFactoryHttpOverrides;
      Future<ConnectionTask<Socket>> dial() => overrides.connectionFactory!(
        Uri.parse('$serverUrl/probe'),
        null,
        null,
      );

      // Everything here is loopback: the node refuses, and the fallback — the
      // built-in direct dial, aimed at another closed loopback port — fails
      // too. What is asserted is that the request was not pinned to the node.
      for (var attempt = 0; attempt < kRelayFailureStrikes; attempt++) {
        final task = await dial();
        await expectLater(task.socket, throwsA(isA<SocketException>()));
        final suspended = container.read(relaySuspensionProvider);
        if (attempt < kRelayFailureStrikes - 1) {
          expect(suspended, isNull, reason: 'one refusal is a moving network');
        } else {
          expect(suspended?.route.id, 'local');
          expect(suspended?.failure, RelayDialFailure.unreachable);
        }
      }

      expect(
        container.read(activeRelayRouteProvider),
        isNull,
        reason: 'a dropped node is not dialed again: traffic goes direct',
      );
    });
  });

  group('switching back to direct', () {
    /// A server that says nothing: the tests only look at who got the dial.
    Future<(ServerSocket, Completer<bool>)> listener() async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      final accepted = Completer<bool>();
      server.listen((socket) {
        if (!accepted.isCompleted) accepted.complete(true);
      });
      return (server, accepted);
    }

    test('a client built while relaying dials direct after the switch', () async {
      final (direct, directAccepted) = await listener();
      final (relayServer, relayAccepted) = await listener();
      final serverUrl = 'https://127.0.0.1:${direct.port}';
      final prefs = await _prefsWith(
        RelayRoute(id: 'local', host: '127.0.0.1', port: relayServer.port),
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          serverUrlProvider.overrideWith((ref) => serverUrl),
        ],
      );
      addTearDown(container.dispose);

      // The client's overrides, as an HttpClient built under the relay holds
      // them: the user then switches to direct, and this instance is all that
      // client will ever dial with.
      final overrides =
          container.read(appHttpOverridesProvider)
              as ConnectionFactoryHttpOverrides;
      container.read(relayRouteProvider.notifier).select(null);

      _dial(
        overrides.connectionFactory!,
        Uri.parse('$serverUrl/probe'),
      );

      expect(
        await directAccepted.future.timeout(const Duration(seconds: 5)),
        isTrue,
        reason: 'the server has to be reached without the relay',
      );
      expect(
        relayAccepted.isCompleted,
        isFalse,
        reason: 'a dropped relay must not keep carrying the traffic',
      );
    });

    test('an API log line drops the relay after the switch', () async {
      final prefs = await _prefsWith(
        const RelayRoute(id: 'jp-01', host: 'relay-jp.example', port: 7443),
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          serverUrlProvider.overrideWith((ref) => 'https://api.solian.app'),
          relayCatalogProvider.overrideWith(
            () => _StubCatalog(
              () async => const [
                RelayEntry(
                  id: 'jp-01',
                  endpoint: 'relay-jp.example',
                  port: 7443,
                  healthy: true,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final level = Logger.root.level;
      Logger.root.level = Level.ALL;
      final records = <String>[];
      final subscription = Logger.root.onRecord.listen(
        (record) => records.add(record.message),
      );
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = level;
      });

      // The client is built while the relay is selected, which is when it used
      // to freeze the label.
      final dio = container.read(apiClientProvider);
      dio.httpClientAdapter = _StubAdapter();
      addTearDown(() => dio.close(force: true));

      await dio.get<dynamic>('/sphere/timeline');
      container.read(relayRouteProvider.notifier).select(null);
      await dio.get<dynamic>('/sphere/timeline');
      await pumpEventQueue();

      expect(
        records.where((message) => message.contains('[API] OK 200 GET')),
        [
          '[API] OK 200 GET https://api.solian.app/sphere/timeline via jp-01',
          '[API] OK 200 GET https://api.solian.app/sphere/timeline',
        ],
      );
    });
  });

  group('activeRelayRouteProvider', () {
    test('follows the endpoint the catalog announces for the same node', () async {
      // The shape of a node that moved behind a different port: the stored
      // route is a snapshot, the catalog is the truth.
      final prefs = await _prefsWith(
        const RelayRoute(
          id: 'CNlongY.Guangdong',
          host: 'net.cnlongy.cc',
          port: 443,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          relayCatalogProvider.overrideWith(
            () => _StubCatalog(
              () async => const [
                RelayEntry(
                  id: 'CNlongY.Guangdong',
                  endpoint: 'net.cnlongy.cc',
                  port: 12443,
                  healthy: true,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(relayCatalogProvider.future);

      final active = container.read(activeRelayRouteProvider);
      expect(active?.host, 'net.cnlongy.cc');
      expect(
        active?.port,
        12443,
        reason: 'the announced port must win over the stored one',
      );
    });

    test('dials the announced endpoint, not the stale stored one', () async {
      final relayServer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(relayServer.close);
      final accepted = Completer<bool>();
      relayServer.listen((socket) {
        if (!accepted.isCompleted) accepted.complete(true);
        socket.destroy();
      });

      // Port 1 is closed: dialing the stored route would never reach the relay.
      final prefs = await _prefsWith(
        const RelayRoute(id: 'jp-01', host: '127.0.0.1', port: 1),
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          serverUrlProvider.overrideWith((ref) => 'https://api.solian.app'),
          relayCatalogProvider.overrideWith(
            () => _StubCatalog(
              () async => [
                RelayEntry(
                  id: 'jp-01',
                  endpoint: '127.0.0.1',
                  port: relayServer.port,
                  healthy: true,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(relayCatalogProvider.future);
      final overrides =
          container.read(appHttpOverridesProvider)
              as ConnectionFactoryHttpOverrides;

      _dial(
        overrides.connectionFactory!,
        Uri.parse('https://api.solian.app/probe'),
      );

      expect(
        await accepted.future.timeout(const Duration(seconds: 5)),
        isTrue,
        reason: 'the announced endpoint has to reach the dial',
      );
    });

    test('keeps the stored route while the catalog cannot be read', () async {
      final prefs = await _prefsWith(
        const RelayRoute(id: 'jp-01', host: 'relay-jp.example', port: 7443),
      );
      final container = ProviderContainer(
        // Riverpod retries a failed provider on a timer by default, which
        // would keep the catalog's future pending instead of reporting.
        retry: (count, error) => null,
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          relayCatalogProvider.overrideWith(
            () => _StubCatalog(
              () async =>
                  throw RelayCatalogException('HTTP 502', statusCode: 502),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(relayCatalogProvider.future),
        throwsA(isA<RelayCatalogException>()),
      );

      final active = container.read(activeRelayRouteProvider);
      expect(active?.host, 'relay-jp.example');
      expect(
        active?.port,
        7443,
        reason: 'an unreadable catalog must not drop the chosen route',
      );
    });
  });

  test('an API log line names the relay the request travels through', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => prefs),
        serverUrlProvider.overrideWith((ref) => 'https://api.solian.app'),
        relayRouteProvider.overrideWith(_RelayRouteNotifier.new),
        // The route is reconciled against the catalog before it is dialed, so
        // the test has to say what the catalog holds — and must not fetch it.
        relayCatalogProvider.overrideWith(
          () => _StubCatalog(
            () async => const [
              RelayEntry(
                id: 'jp-01',
                endpoint: 'relay-jp.example',
                port: 7443,
                healthy: true,
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final level = Logger.root.level;
    Logger.root.level = Level.ALL;
    final records = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(records.add);
    addTearDown(() async {
      await subscription.cancel();
      Logger.root.level = level;
    });

    final dio = container.read(apiClientProvider);
    dio.httpClientAdapter = _StubAdapter();
    addTearDown(() => dio.close(force: true));

    await dio.get<dynamic>('/sphere/timeline?take=20&mode=la');
    await pumpEventQueue();

    expect(
      records.map((record) => record.message).whereType<String>(),
      contains(
        '[API] OK 200 GET https://api.solian.app/sphere/timeline?take=20&mode=la via jp-01',
      ),
    );
  });
}

/// Shared preferences holding [route] as the selected relay, or nothing.
Future<SharedPreferences> _prefsWith(RelayRoute? route) async {
  SharedPreferences.setMockInitialValues(
    route == null ? {} : {kNetworkRelayRouteStoreKey: jsonEncode(route.toJson())},
  );
  return SharedPreferences.getInstance();
}

/// A route that is always selected, so the tests need no shared preferences
/// state to describe one.
class _RelayRouteNotifier extends RelayRouteNotifier {
  @override
  RelayRoute? build() =>
      const RelayRoute(id: 'jp-01', host: 'relay-jp.example', port: 7443);
}

/// A catalog that answers from memory, [load] being what the server would say.
///
/// The real notifier fetches, and a test must not: it also has to cover the
/// retry the sheet and the picker call, which would otherwise reach the
/// network.
class _StubCatalog extends RelayCatalogNotifier {
  _StubCatalog(this.load);

  final Future<List<RelayEntry>> Function() load;

  @override
  Future<List<RelayEntry>> build() => load();

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(load);
  }
}

/// Starts a dial these tests only use as a probe.
///
/// The relay answering is the assertion, so the dial's own outcome is not
/// waited for: fail-open would hand back the fallback — a real direct
/// connection — once the node cannot carry the handshake.
void _dial(NetworkConnectionFactory factory, Uri uri) {
  unawaited(
    factory(uri, null, null).then(
      (task) => task.socket.then((socket) => socket.destroy(), onError: (_) {}),
      onError: (_) {},
    ),
  );
}

/// Answers every request without a socket, so the interceptors under test run
/// without a network.
class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
