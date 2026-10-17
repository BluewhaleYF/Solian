import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/websocket.dart';

/// A gateway client whose status stream the test drives directly.
class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  final _status = StreamController<WebSocketState>.broadcast();

  @override
  Stream<WebSocketState> get statusStream => _status.stream;

  void emit(WebSocketState state) => _status.add(state);

  @override
  void close() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
