import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/bounded_id_set.dart';
import 'package:island/core/websocket.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A stand-in for `Connectivity` that never touches a platform channel.
class _FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();
}

/// A minimal gateway: upgrades one websocket per path and records every frame
/// the client puts on the wire.
class _FakeGateway {
  _FakeGateway._(this._server);

  final HttpServer _server;
  final List<Map<String, dynamic>> received = [];
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
    final socket = await WebSocketTransformer.upgrade(request);
    _socket = socket;
    socket.listen(
      (data) {
        final decoded = jsonDecode(data as String);
        if (decoded is! Map<String, dynamic>) return;
        received.add(decoded);
        _frames.add(decoded);
      },
      onDone: () => _socket = null,
    );
  }

  Future<void> push(Map<String, dynamic> frame) async {
    final socket = _socket;
    if (socket == null) throw StateError('no client connected');
    socket.add(jsonEncode(frame));
  }

  /// Waits until [predicate] holds for the frames received so far.
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

/// Hands the test a real `Ref` to drive [WebSocketService.connect].
final _refCaptureProvider = Provider<Ref>((ref) => ref);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ackIdForFrame', () {
    test('reads the envelope stamp, not the payload', () {
      expect(
        ackIdForFrame({'type': 'messages.new', 'data': {}, '_ack_id': 'a1'}),
        'a1',
      );
      // An untracked family carries no stamp.
      expect(ackIdForFrame({'type': 'notifications.new', 'data': {}}), isNull);
      // The payload's own id is not a delivery stamp.
      expect(
        ackIdForFrame({
          'type': 'messages.new',
          'data': {'id': 'message-id'},
        }),
        isNull,
      );
      expect(ackIdForFrame({'type': 'ping', 'data': null}), isNull);
      expect(
        ackIdForFrame({'type': 'messages.new', 'data': {}, '_ack_id': '  '}),
        isNull,
      );
    });
  });

  group('BoundedIdSet', () {
    test('reports repeats and evicts oldest first', () {
      final seen = BoundedIdSet(2);
      expect(seen.add('a'), isTrue);
      expect(seen.add('a'), isFalse);
      expect(seen.add('b'), isTrue);
      // 'a' is the oldest entry, so adding 'c' evicts it.
      expect(seen.add('c'), isTrue);
      expect(seen.length, 2);
      expect(seen.contains('a'), isFalse);
      expect(seen.add('b'), isFalse);
    });
  });

  group('WebSocketService ack tracking', () {
    late _FakeGateway gateway;
    late ProviderContainer container;
    late WebSocketService service;
    HttpOverrides? previousHttpOverrides;

    setUp(() async {
      // The test binding installs an HttpClient that answers 400 to everything
      // so widget tests cannot reach the network. This is a socket test: it
      // needs the real client the service dials with.
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
      service = container.read(websocketProvider);
      await service.connect(container.read(_refCaptureProvider));
      // Every connection generation asks for its pending buffer.
      await gateway.waitFor(
        (frames) => frames.any((f) => f['type'] == kResumePacketType),
      );
    });

    tearDown(() async {
      service.close();
      await gateway.close();
      HttpOverrides.global = previousHttpOverrides;
    });

    test('resumes exactly once per connection', () async {
      final resumes = gateway.received.where(
        (f) => f['type'] == kResumePacketType,
      );
      expect(resumes, hasLength(1));
      expect(resumes.single['data'], isNull);
      // The heartbeat is kicked immediately so the app does not wait a full
      // period for its first pong.
      await gateway.waitFor((frames) => frames.any((f) => f['type'] == 'ping'));
    });

    test('acks a stamped frame, and acks a repeat again', () async {
      await gateway.push({
        'type': 'messages.new',
        'data': {'id': 'm1'},
        '_ack_id': 'ack-1',
      });
      await gateway.waitFor((frames) => gateway.acks().isNotEmpty);
      expect((gateway.acks().single['data'] as Map)['ack_id'], 'ack-1');

      // A re-delivery means the gateway never saw the previous ack, so the
      // client must answer again rather than deduplicating the ack.
      await gateway.push({
        'type': 'messages.new',
        'data': {'id': 'm1'},
        '_ack_id': 'ack-1',
      });
      await gateway.waitFor((_) => gateway.acks().length >= 2);
      expect(
        gateway.acks().map((f) => (f['data'] as Map)['ack_id']),
        ['ack-1', 'ack-1'],
      );
    });

    test('does not ack an untracked frame', () async {
      await gateway.push({'type': 'notifications.new', 'data': {'id': 'n1'}});
      // Give the socket a chance to deliver and answer; a frame without a
      // stamp must produce no ack at all.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(gateway.acks(), isEmpty);
    });
  });
}

/// An unsigned JWT whose `exp` is [duration] from now.
String _jwtExpiringIn(Duration duration) {
  final expiresAt = DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': expiresAt})));
  return '$header.$payload.';
}
