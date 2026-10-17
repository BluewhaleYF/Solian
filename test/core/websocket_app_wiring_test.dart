import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A gateway that records the upgrade request and the frames the app puts on
/// the wire.
class _FakeGateway {
  _FakeGateway._(this._server);

  final HttpServer _server;
  final List<Map<String, dynamic>> received = [];
  final List<HttpRequest> upgrades = [];
  final _frames = StreamController<Map<String, dynamic>>.broadcast();
  WebSocket? _socket;

  static Future<_FakeGateway> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final gateway = _FakeGateway._(server);
    server.listen(gateway._handle);
    return gateway;
  }

  String get baseUrl => 'http://${_server.address.host}:${_server.port}';

  Future<void> _handle(HttpRequest request) async {
    upgrades.add(request);
    final socket = await WebSocketTransformer.upgrade(request);
    _socket = socket;
    socket.listen((data) {
      final decoded = jsonDecode(data as String);
      if (decoded is! Map<String, dynamic>) return;
      received.add(decoded);
      _frames.add(decoded);
    }, onDone: () => _socket = null);
  }

  Future<void> push(Map<String, dynamic> frame) async {
    final socket = _socket;
    if (socket == null) throw StateError('no client connected');
    socket.add(jsonEncode(frame));
  }

  Future<void> waitFor(
    bool Function(List<Map<String, dynamic>>) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (predicate(received)) return;
    final completer = Completer<void>();
    late StreamSubscription<Map<String, dynamic>> sub;
    sub = _frames.stream.listen((_) {
      if (!completer.isCompleted && predicate(received)) completer.complete();
    });
    try {
      await completer.future.timeout(timeout);
    } finally {
      await sub.cancel();
    }
  }

  Iterable<Map<String, dynamic>> acks() =>
      received.where((frame) => frame['type'] == kAckPacketType);

  Future<void> close() async {
    await _socket?.close();
    await _frames.close();
    await _server.close(force: true);
  }
}

class _FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();
}

/// An unsigned JWT whose `exp` is [duration] from now.
String _jwtExpiringIn(Duration duration) {
  final expiresAt = DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': expiresAt})));
  return '$header.$payload.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The app's wiring, not the SDK: the provider must build a real socket with
  // the configured server, the product namespace, and header auth, and its
  // state providers must reflect the connection.
  group('app gateway wiring', () {
    late _FakeGateway gateway;
    late ProviderContainer container;
    HttpOverrides? previousHttpOverrides;

    setUp(() async {
      // The test binding installs an HttpClient that answers 400 to everything
      // so widget tests cannot reach the network. This is a socket test.
      previousHttpOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      gateway = await _FakeGateway.start();
      SharedPreferences.setMockInitialValues({
        kTokenPairStoreKey: jsonEncode({
          'token': _jwtExpiringIn(const Duration(hours: 1)),
        }),
      });
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) => prefs),
          serverUrlProvider.overrideWith((ref) => gateway.baseUrl),
          connectivityProvider.overrideWith((ref) => _FakeConnectivity()),
          connectivityStatusProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.wifi]),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    tearDown(() async {
      await gateway.close();
      HttpOverrides.global = previousHttpOverrides;
    });

    test('dials the configured server in the product namespace', () async {
      await container.read(websocketStateProvider.notifier).connect();
      await gateway.waitFor(
        (frames) => frames.any((f) => f['type'] == kResumePacketType),
      );

      expect(gateway.upgrades, isNotEmpty);
      final request = gateway.upgrades.single;
      expect(request.uri.path, '/ws');
      expect(
        request.uri.queryParameters['namespace'],
        kWebsocketNamespace,
        reason: 'presence and pushes must stay in this product tenant',
      );
      expect(
        request.headers.value(HttpHeaders.authorizationHeader),
        startsWith('Bearer '),
        reason: 'io platforms carry the token as a header',
      );
      expect(
        request.uri.queryParameters.containsKey('tk'),
        isFalse,
        reason: 'the token must not be duplicated into the URL',
      );
    });

    test('state providers follow the live connection', () async {
      final states = <WebSocketState>[];
      final connected = <bool>[];
      container.listen(websocketStateProvider, (_, next) => states.add(next));
      container.listen(
        websocketConnectedProvider,
        (_, next) => connected.add(next),
        fireImmediately: true,
      );

      await container.read(websocketStateProvider.notifier).connect();
      await gateway.waitFor(
        (frames) => frames.any((f) => f['type'] == kResumePacketType),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states.last, const WebSocketState.connected());
      expect(connected, [false, true]);
      expect(container.read(websocketProvider).isConnected, isTrue);
    });

    test('acks a stamped push delivered through the app provider', () async {
      await container.read(websocketStateProvider.notifier).connect();
      await gateway.waitFor(
        (frames) => frames.any((f) => f['type'] == kResumePacketType),
      );

      final packets = <WebSocketPacket>[];
      container.read(websocketProvider).dataStream.listen(packets.add);

      await gateway.push({
        'type': 'messages.new',
        'data': {'id': 'm1'},
        '_ack_id': 'ack-1',
      });
      await gateway.waitFor((frames) => gateway.acks().isNotEmpty);

      expect((gateway.acks().single['data'] as Map)['ack_id'], 'ack-1');
      expect(packets.map((p) => p.type), contains('messages.new'));
      expect(packets.firstWhere((p) => p.type == 'messages.new').data, {
        'id': 'm1',
      });
    });
  });
}
