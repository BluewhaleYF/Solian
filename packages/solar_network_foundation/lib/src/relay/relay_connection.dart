import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import 'relay_catalog.dart';

/// Signature of `HttpClient.connectionFactory`.
///
/// A factory returns a connected [Socket] — TLS-wrapped for `https` — and the
/// HTTP layer takes it from there, which is what lets a client change the
/// socket it dials without touching the URL, SNI, or `Host` header.
typedef NetworkConnectionFactory =
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    );

/// The socket destination a request resolves to.
class RelayDialTarget {
  final String host;
  final int port;

  const RelayDialTarget({required this.host, required this.port});

  @override
  bool operator ==(Object other) =>
      other is RelayDialTarget && other.host == host && other.port == port;

  @override
  int get hashCode => Object.hash(host, port);

  @override
  String toString() => '$host:$port';
}

/// The TCP port a request for [uri] is dialed on.
///
/// [Uri] reports `0` for a scheme it knows no default port for — `ws`/`wss`
/// above all, and `WebSocket.connect` hands exactly such a URI to `HttpClient`
/// (`wss://host/ws` becomes `https://host:0/ws`). `HttpClient` dials the scheme
/// default anyway, so read the port the same way: this is what the relay gate
/// must compare against, and what a caller reads off its configured server URL.
int relayRequestPort(Uri uri) {
  final port = uri.port;
  if (port != 0) return port;
  return uri.scheme.toLowerCase() == 'http' ? 80 : 443;
}

/// Whether [uri] should be dialed through [route], and where.
///
/// Only TLS requests to [serverHost] on [serverPort] are re-routed: everything
/// else (other hosts, other ports, plain HTTP, a different server configured by
/// the user) must keep its default path. The relay forwards to the origin its
/// SNI rule points at, so the request port has to be the one the configured
/// server answers on — [serverPort] is read from the server URL, and a request
/// to any other port stays direct. Returns null when the request goes direct.
RelayDialTarget? resolveRelayDialTarget({
  required Uri uri,
  required String serverHost,
  int serverPort = 443,
  RelayRoute? route,
}) {
  if (route == null || !route.isValid) return null;
  if (uri.scheme.toLowerCase() != 'https') return null;
  if (relayRequestPort(uri) != serverPort) return null;
  final host = serverHost.trim().toLowerCase();
  if (host.isEmpty || uri.host.toLowerCase() != host) return null;
  return RelayDialTarget(host: route.host, port: route.port);
}

/// Builds a connection factory that dials [route] for traffic to [serverHost]
/// on [serverPort] — the host and port of the configured server URL.
///
/// [fallback] handles every other connection — pass the factory already in use
/// (for example an IP-override factory) to compose behaviours; without one,
/// non-relay connections are dialed directly, exactly like the default client.
///
/// TLS is established after dialing with [Uri.host] as the server name, so the
/// relay sees the logical SNI and the certificate is verified against the real
/// server, not against the relay. Pass [allowUntrustedCertificate] only to keep
/// a client's existing "accept any certificate" posture.
NetworkConnectionFactory createRelayConnectionFactory({
  required String serverHost,
  int serverPort = 443,
  RelayRoute? route,
  NetworkConnectionFactory? fallback,
  bool allowUntrustedCertificate = false,
}) {
  return (uri, proxyHost, proxyPort) async {
    final target = resolveRelayDialTarget(
      uri: uri,
      serverHost: serverHost,
      serverPort: serverPort,
      route: route,
    );
    if (target == null) {
      final next = fallback;
      if (next != null) return next(uri, proxyHost, proxyPort);
      return _openConnection(uri);
    }
    Logger.root.fine(
      '[relay] Routing ${uri.host}:${relayRequestPort(uri)} through '
      '${target.host}:${target.port}',
    );
    return _openConnection(
      uri,
      targetHost: target.host,
      targetPort: target.port,
      allowUntrustedCertificate: allowUntrustedCertificate,
    );
  };
}

/// Dials (and, for `https`, TLS-wraps) a connection for [uri].
///
/// The proxy arguments of `HttpClient.connectionFactory` are ignored, matching
/// the app-side override factories this is layered with.
Future<ConnectionTask<Socket>> _openConnection(
  Uri uri, {
  String? targetHost,
  int? targetPort,
  bool allowUntrustedCertificate = false,
}) async {
  final isTls = uri.scheme.toLowerCase() == 'https';
  final host = targetHost ?? uri.host;
  final port = targetPort ?? relayRequestPort(uri);

  Socket? connected;
  final socketFuture = () async {
    final socket = await Socket.connect(host, port);
    connected = socket;
    if (!isTls) return socket;
    // `host: uri.host` keeps SNI and certificate verification on the logical
    // server, which is the whole point of an L4 relay.
    return SecureSocket.secure(
      socket,
      host: uri.host,
      onBadCertificate: allowUntrustedCertificate ? (_) => true : null,
    );
  }();

  return ConnectionTask.fromSocket(socketFuture, () {
    // Frees a plain dial at once. A TLS handshake already running has handed
    // the socket to the secure filter, which dart:io exposes only once the
    // handshake finishes, so that socket is released by the peer or when the
    // handshake completes — either way the abandoned result is consumed here.
    connected?.destroy();
    socketFuture.ignore();
    Logger.root.fine('[relay] Cancelled connection to $host:$port');
  });
}

/// [HttpOverrides] that installs a [connectionFactory] on every client.
///
/// Install once per route change:
/// ```dart
/// final server = Uri.parse(serverUrl);
/// HttpOverrides.global = ConnectionFactoryHttpOverrides(
///   connectionFactory: createRelayConnectionFactory(
///     serverHost: server.host,
///     serverPort: relayRequestPort(server),
///     route: route,
///   ),
/// );
/// ```
class ConnectionFactoryHttpOverrides extends HttpOverrides {
  final NetworkConnectionFactory? connectionFactory;

  ConnectionFactoryHttpOverrides({this.connectionFactory});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    final factory = connectionFactory;
    if (factory != null) {
      client.connectionFactory = factory;
    }
    return client;
  }
}
