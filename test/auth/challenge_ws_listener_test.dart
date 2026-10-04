import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/auth/challenge_ws_listener.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers `GET /stargate/auth/challenge/pending` with a fixed list and counts
/// how many times it was hit.
class _PendingChallengeAdapter implements HttpClientAdapter {
  _PendingChallengeAdapter(this.challenges);

  final List<Map<String, dynamic>> challenges;
  int requests = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    return ResponseBody.fromString(
      jsonEncode(challenges),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

/// Keeps the socket state under test control instead of the real service's
/// status stream.
class _TestWebSocketStateNotifier extends WebSocketStateNotifier {
  @override
  WebSocketState build() => const WebSocketState.disconnected();

  void emit(WebSocketState value) => state = value;
}

Map<String, dynamic> _challenge(String id) => {
  'id': id,
  'step_remain': 1,
  'step_total': 1,
  'failed_attempts': 0,
  'blacklist_factors': <String>[],
  'audiences': <dynamic>[],
  'scopes': <dynamic>[],
  'ip_address': '203.0.113.7',
  'user_agent': 'Mozilla/5.0',
  'account_id': 'acc-1',
  'created_at': '2026-10-05T00:00:00.000Z',
  'updated_at': '2026-10-05T00:00:00.000Z',
};

void main() {
  late _PendingChallengeAdapter adapter;
  late ProviderContainer container;
  late ChallengeWsListener listener;
  late List<SnAuthChallenge> published;
  late StreamSubscription<ChallengePendingEvent> busSub;

  void setUpListener({
    bool signedIn = true,
    List<Map<String, dynamic>>? challenges,
  }) {
    adapter = _PendingChallengeAdapter(challenges ?? [_challenge('ch-1')]);
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(
          Dio(BaseOptions(baseUrl: 'https://example.test'))
            ..httpClientAdapter = adapter,
        ),
        tokenProvider.overrideWithValue(
          signedIn ? const AppToken(token: 'token') : null,
        ),
        websocketStateProvider.overrideWith(_TestWebSocketStateNotifier.new),
      ],
    );
    published = [];
    busSub = eventBus
        .on<ChallengePendingEvent>()
        .listen((event) => published.add(event.challenge));
    listener = container.read(challengeWsListenerProvider)..start();

    addTearDown(() async {
      await busSub.cancel();
      listener.dispose();
      container.dispose();
    });
  }

  void emitSocketState(WebSocketState value) =>
      (container.read(websocketStateProvider.notifier)
              as _TestWebSocketStateNotifier)
          .emit(value);

  /// Waits until the adapter recorded at least [count] hits, so the assertions
  /// do not race the in-flight request.
  Future<void> waitForRequests(int count) async {
    for (var i = 0; i < 400 && adapter.requests < count; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  /// Waits until at least [count] challenges were published on the bus; the
  /// response body is decoded after the request itself has been recorded.
  Future<void> waitForEvents(int count) async {
    for (var i = 0; i < 400 && published.length < count; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  test('cold start with a live socket recovers pending challenges once', () async {
    setUpListener();

    listener.handleSocketState(const WebSocketState.connected());
    await waitForRequests(1);
    await waitForEvents(1);

    expect(adapter.requests, 1);
    expect(published.map((challenge) => challenge.id), ['ch-1']);
    expect(published.single.ipAddress, '203.0.113.7');
  });

  test('a socket that stays connected is never re-fetched', () async {
    setUpListener();

    listener.handleSocketState(const WebSocketState.connected());
    await waitForRequests(1);
    await waitForEvents(1);
    // Repeated `connected` signals without an intervening gap (e.g. a
    // redundant status emission) must not re-run the fetch.
    listener.handleSocketState(const WebSocketState.connected());
    listener.handleSocketState(const WebSocketState.connected());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(adapter.requests, 1);
    expect(published, hasLength(1));
  });

  test('a reconnect after a socket gap fetches again', () async {
    setUpListener();

    listener.handleSocketState(const WebSocketState.connected());
    await waitForRequests(1);
    listener.handleSocketState(const WebSocketState.disconnected());
    listener.handleSocketState(const WebSocketState.connected());
    await waitForRequests(2);

    expect(adapter.requests, 2);
  });

  test('resuming with a dead socket fetches, with a live socket it does not', () async {
    setUpListener();

    emitSocketState(const WebSocketState.connected());
    listener.handleLifecycle(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(adapter.requests, 0);

    emitSocketState(const WebSocketState.disconnected());
    listener.handleLifecycle(AppLifecycleState.resumed);
    await waitForRequests(1);
    await waitForEvents(1);

    expect(adapter.requests, 1);
    expect(published.map((challenge) => challenge.id), ['ch-1']);
  });

  test('resuming mid-flight does not issue a second request', () async {
    setUpListener();

    listener.handleSocketState(const WebSocketState.connected());
    emitSocketState(const WebSocketState.disconnected());
    listener.handleLifecycle(AppLifecycleState.resumed);
    await waitForRequests(1);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(adapter.requests, 1);
  });

  test('signed out: no fetch, no events', () async {
    setUpListener(signedIn: false);

    listener.handleSocketState(const WebSocketState.connected());
    listener.handleLifecycle(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(adapter.requests, 0);
    expect(published, isEmpty);
  });

  test('a signed-in client with nothing pending publishes nothing', () async {
    setUpListener(challenges: const []);

    listener.handleSocketState(const WebSocketState.connected());
    await waitForRequests(1);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(adapter.requests, 1);
    expect(published, isEmpty);
  });
}
