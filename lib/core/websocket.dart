import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/relay.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'package:solar_network_sdk/solar_network_sdk.dart'
    show
        SolarWebSocketService,
        WebSocketAuthTransport,
        WebSocketPacket,
        WebSocketPacketPatterns,
        WebSocketState,
        WebSocketStatePatterns,
        ackIdForFrame,
        isWebSocketReconnect,
        kAckPacketType,
        kResumePacketType;

/// The app's gateway client: the SDK service wired to this app's server URL,
/// auth token, relay route and connectivity source.
///
/// The protocol itself — at-least-once ack and buffer resume, heartbeat,
/// backoff, connectivity re-dial — lives in `solar_network_sdk`. This file only
/// supplies the app-specific inputs and exposes the service as Riverpod
/// providers.
class WebSocketService extends SolarWebSocketService {
  WebSocketService(Ref ref)
    : super(
        uri: () => gatewayUri(ref),
        token: () => getValidAuthToken(ref),
        // A browser owns the handshake and cannot set a custom header.
        authTransport: kIsWeb
            ? WebSocketAuthTransport.query
            : WebSocketAuthTransport.header,
        channelFactory: (uri, headers) => _dial(ref, uri, headers),
        networkMonitor: _AppNetworkMonitor(ref),
      );
}

/// The gateway URL for the configured server, in the product's namespace.
///
/// Blade multi-tenant isolation: the same product id as Ring `app` / `app_id`.
/// An empty namespace would land in the gateway DefaultNamespace and mix with
/// other clients (e.g. SolWatt). See Blade docs/WEBSOCKET_GATEWAY.md.
Uri gatewayUri(Ref ref) {
  final baseUrl = ref.read(serverUrlProvider);
  return Uri.parse(
    '$baseUrl/ws'.replaceFirst('http', 'ws'),
  ).replace(queryParameters: {'namespace': kWebsocketNamespace});
}

/// Dials the gateway, applying the relay/IP route in force for this attempt.
///
/// A fresh `HttpClient` per connect: dart:io's WebSocket caches a process-wide
/// HttpClient created under whichever HttpOverrides existed at first use, so
/// without this the realtime channel would keep dialing the original route and
/// ignore a later relay selection or IP override.
WebSocketChannel _dial(Ref ref, Uri uri, Map<String, String>? headers) {
  if (kIsWeb) return WebSocketChannel.connect(uri);

  // A web build dials with the browser's own stack, which never sees the
  // connection factory, so the route only applies to the io platforms.
  Logger.root.info(
    '[WebSocket] Trying connecting to $uri (namespace=$kWebsocketNamespace)'
    '${_relayLogSuffix(ref, uri)}',
  );
  return IOWebSocketChannel.connect(
    uri,
    headers: headers,
    customClient: HttpClient(),
  );
}

/// The ` via <relay>` suffix for a dial, or `''` when the dial goes direct.
///
/// Best effort: a dial can outlive the provider scope that asked for it.
String _relayLogSuffix(Ref ref, Uri uri) {
  try {
    return relayLogSuffix(
      uri: uri,
      serverUrl: ref.read(serverUrlProvider),
      route: ref.read(activeRelayRouteProvider),
    );
  } catch (error) {
    Logger.root.fine('[WebSocket] Dropped a stale route lookup: $error');
    return '';
  }
}

/// The app's connectivity as the SDK's transport signal.
class _AppNetworkMonitor implements NetworkMonitor {
  _AppNetworkMonitor(this._ref);

  final Ref _ref;

  NetworkChange _change(List<ConnectivityResult> results) => NetworkChange(
    connected: hasNetworkConnectivity(results),
    // The set, not just "usable": a wifi→mobile switch must re-dial.
    fingerprint: (results.toSet().toList()..sort()).join(','),
  );

  @override
  Future<NetworkChange> current() async {
    final connectivity = _ref.read(connectivityProvider);
    return _change(await connectivity.checkConnectivity());
  }

  @override
  Stream<NetworkChange> get changes =>
      _ref.read(connectivityProvider).onConnectivityChanged.map(_change);
}

/// The app's gateway client.
///
/// Typed as the SDK service, not the app subclass, so a test can substitute a
/// plain [SolarWebSocketService] (or a fake over its streams) without
/// constructing this app's dial/auth wiring.
final websocketProvider = Provider<SolarWebSocketService>((ref) {
  final service = WebSocketService(ref);
  ref.onDispose(() => service.close());
  return service;
});

final weakInternetModeProvider = Provider<bool>((ref) {
  final hasConnectivity = hasNetworkConnectivityValue(
    ref.watch(connectivityStatusProvider),
  );
  if (!hasConnectivity) return false;

  final websocketState = ref.watch(websocketStateProvider);
  return websocketState.maybeWhen(connected: () => false, orElse: () => true);
});

final websocketStateProvider =
    NotifierProvider<WebSocketStateNotifier, WebSocketState>(
      WebSocketStateNotifier.new,
    );

/// True while the socket is connected.
///
/// Anything that has to react to a connect/disconnect *transition* watches
/// this instead of reading [websocketStateProvider]: a read inside an effect
/// never re-runs when the socket comes back, which is how the room's
/// reconnect resync silently stopped firing.
final websocketConnectedProvider = Provider<bool>((ref) {
  return ref.watch(
    websocketStateProvider.select(
      (wsState) =>
          wsState.maybeWhen(connected: () => true, orElse: () => false),
    ),
  );
});

class WebSocketStateNotifier extends Notifier<WebSocketState> {
  StreamSubscription<WebSocketState>? _statusSubscription;

  @override
  WebSocketState build() {
    _statusSubscription?.cancel();
    final service = ref.read(websocketProvider);
    _statusSubscription = service.statusStream.listen((event) {
      state = event;
    });

    ref.onDispose(() {
      _statusSubscription?.cancel();
      // Captured during build: `ref.read` is invalid once the element is
      // disposing, which made this callback throw instead of closing.
      service.close();
    });
    return const WebSocketState.disconnected();
  }

  Future<void> connect() async {
    final service = ref.read(websocketProvider);
    await service.connect();
  }

  void sendMessage(String message) {
    final service = ref.read(websocketProvider);
    service.sendMessage(message);
  }

  void close() {
    final service = ref.read(websocketProvider);
    service.close();
    state = const WebSocketState.disconnected();
  }

  void manualReconnect() {
    final service = ref.read(websocketProvider);
    service.manualReconnect();
  }
}
