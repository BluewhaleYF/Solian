import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/websocket.dart';

/// A websocket service whose status stream the test drives directly.
class _FakeWebSocketService extends WebSocketService {
  final _status = StreamController<WebSocketState>.broadcast();

  @override
  Stream<WebSocketState> get statusStream => _status.stream;

  void emit(WebSocketState state) => _status.add(state);

  @override
  void close() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The reconnect resync in the room screen and the room subscription both key
  // on a connect/disconnect *transition* of this provider. Watching it is what
  // makes the transition observable; reading it left those branches dead.
  group('isWebSocketReconnect', () {
    test('only a false -> true transition is a reconnect', () {
      expect(
        isWebSocketReconnect(wasConnected: false, isConnected: true),
        isTrue,
      );
      expect(
        isWebSocketReconnect(wasConnected: true, isConnected: true),
        isFalse,
      );
      expect(
        isWebSocketReconnect(wasConnected: true, isConnected: false),
        isFalse,
      );
      expect(
        isWebSocketReconnect(wasConnected: null, isConnected: true),
        isFalse,
        reason: 'the first observation is the initial connect, not a reconnect',
      );
    });
  });

  group('websocketConnectedProvider', () {
    late ProviderContainer container;
    late _FakeWebSocketService service;
    late List<bool> observed;

    setUp(() {
      service = _FakeWebSocketService();
      container = ProviderContainer(
        overrides: [websocketProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      observed = [];
      container.listen(
        websocketConnectedProvider,
        (_, next) => observed.add(next),
        fireImmediately: true,
      );
    });

    test('follows connect and disconnect transitions', () async {
      expect(observed, [false]);

      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true]);

      service.emit(const WebSocketState.disconnected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true, false]);

      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true, false, true]);
    });

    test('collapses non-connected states into one value', () async {
      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true], reason: 'no rebuild without a change');

      service.emit(const WebSocketState.internetChanged());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true, false]);
    });
  });

  group('websocketStateProvider connectivity', () {
    late ProviderContainer container;
    late _FakeWebSocketService service;
    late List<bool> observed;

    setUp(() {
      service = _FakeWebSocketService();
      container = ProviderContainer(
        overrides: [websocketProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      observed = [];
      // Same expression the room screen now watches.
      container.listen(
        websocketStateProvider.select(
          (wsState) =>
              wsState.maybeWhen(connected: () => true, orElse: () => false),
        ),
        (_, next) => observed.add(next),
        fireImmediately: true,
      );
    });

    test('reports a connect transition after a disconnect', () async {
      expect(observed, [false], reason: 'starts disconnected');

      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true]);

      service.emit(const WebSocketState.disconnected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true, false]);

      // A reconnect is what the resync branches look for.
      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true, false, true]);
    });

    test('only re-emits when connectivity actually changes', () async {
      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // Still connected, so the selected value is unchanged and subscribers
      // are not rebuilt for it.
      service.emit(const WebSocketState.connected());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true]);

      // Any non-connected state reads as "not connected", which is what the
      // resync branches compare.
      service.emit(const WebSocketState.internetChanged());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(observed, [false, true, false]);
    });
  });
}
