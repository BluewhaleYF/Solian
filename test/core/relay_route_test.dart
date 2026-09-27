import 'dart:async';
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
        relay: relay,
      ),
      isA<HttpOverrides>(),
    );
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
        relay: const RelayRoute(id: 'broken', host: '', port: 0),
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
              relay: RelayRoute(
                id: 'local',
                host: relayServer.address.address,
                port: relayServer.port,
              ),
            )
            as ConnectionFactoryHttpOverrides;

    final task = await overrides.connectionFactory!(
      Uri.parse('https://api.solian.app:8443/probe'),
      null,
      null,
    );
    // The dial landing on the relay is the proof; the handshake is not.
    task.socket.ignore();

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

  test('an API log line names the relay the request travels through', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => prefs),
        serverUrlProvider.overrideWith((ref) => 'https://api.solian.app'),
        relayRouteProvider.overrideWith(_RelayRouteNotifier.new),
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

/// A route that is always selected, so the tests need no shared preferences
/// state to describe one.
class _RelayRouteNotifier extends RelayRouteNotifier {
  @override
  RelayRoute? build() =>
      const RelayRoute(id: 'jp-01', host: 'relay-jp.example', port: 7443);
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
