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

/// Why a relay could not carry a connection.
///
/// The two cases call for different reactions: a certificate the node does not
/// cover is a misconfiguration that retrying cannot fix, while an unreachable
/// node may be a passing network problem.
enum RelayDialFailure {
  /// The node handed over a certificate that does not belong to the server.
  certificate,

  /// The node could not be reached, or stopped answering mid-handshake.
  unreachable,
}

/// One-line description of the route being dialed, for startup logs and support
/// reports: who the node is, where it is dialed, and what it has to carry.
String describeRelayConfig({
  required RelayRoute route,
  required String serverHost,
  required int serverPort,
  bool allowUntrustedCertificate = false,
}) {
  final region = route.region.trim();
  return 'route=${route.id}'
      '${region.isEmpty ? '' : ' region=$region'}'
      ' dials=${route.displayHost}'
      ' carries=$serverHost:$serverPort'
      ' certificate=${allowUntrustedCertificate ? 'unverified' : 'verified'}';
}

/// The addresses [host] resolves to, as one line for a startup log.
///
/// A relay destination is a hostname, so writing down the addresses it resolved
/// to is what separates "the node is down" from "the name points somewhere
/// else" — the difference between the two is invisible in a socket error.
Future<String> describeRelayDestination(String host) async {
  try {
    final addresses = await InternetAddress.lookup(host);
    if (addresses.isEmpty) return 'no address';
    return addresses.map((address) => address.address).join(', ');
  } catch (error) {
    return 'unresolved ($error)';
  }
}

/// Builds a connection factory that dials [route] for traffic to [serverHost]
/// on [serverPort] — the host and port of the configured server URL.
///
/// [fallback] handles every other connection — pass the factory already in use
/// (for example an IP-override factory) to compose behaviours; without one,
/// non-relay connections are dialed directly, exactly like the default client.
///
/// With [failOpen] a node that cannot carry the connection is skipped for that
/// connection and the request is dialed directly instead, so a broken relay
/// degrades the route rather than breaking the request; [onRelayFailure] hears
/// about each such failure, which is how a client decides to stop using the
/// node. Pass `failOpen: false` to measure a node as it is.
///
/// TLS is established after dialing with [Uri.host] as the server name, so the
/// relay sees the logical SNI and the certificate is verified against the real
/// server, not against the relay. A certificate the server does not cover
/// aborts the handshake and is logged with its subject and issuer — the relay
/// copies bytes, so that certificate is whatever its origin served.
///
/// Pass [allowUntrustedCertificate] only to keep a client's existing "accept
/// any certificate" posture.
NetworkConnectionFactory createRelayConnectionFactory({
  required String serverHost,
  int serverPort = 443,
  RelayRoute? route,
  NetworkConnectionFactory? fallback,
  bool allowUntrustedCertificate = false,
  bool failOpen = true,
  void Function(RelayDialFailure failure, Object error)? onRelayFailure,
}) {
  Future<ConnectionTask<Socket>> direct(
    Uri uri,
    String? proxyHost,
    int? proxyPort,
  ) {
    final next = fallback;
    if (next != null) return next(uri, proxyHost, proxyPort);
    // Nothing else is layered under this factory: the direct dial is this
    // client's own, so it carries the posture the relay dials would have.
    return _openConnection(
      uri,
      allowUntrustedCertificate: allowUntrustedCertificate,
    );
  }

  return (uri, proxyHost, proxyPort) async {
    final target = resolveRelayDialTarget(
      uri: uri,
      serverHost: serverHost,
      serverPort: serverPort,
      route: route,
    );
    if (target == null) {
      return direct(uri, proxyHost, proxyPort);
    }
    Logger.root.fine(
      '[relay] Routing ${uri.host}:${relayRequestPort(uri)} through '
      '${target.host}:${target.port}',
    );

    var rejectedCertificate = false;
    try {
      final task = await _openConnection(
        uri,
        targetHost: target.host,
        targetPort: target.port,
        allowUntrustedCertificate: allowUntrustedCertificate,
        onCertificateRejected: () => rejectedCertificate = true,
      );
      if (!failOpen) return task;

      // The handshake is awaited here so a node that fails it can be skipped
      // before the request is bound to this connection.
      final socket = await task.socket;
      return ConnectionTask.fromSocket(Future.value(socket), socket.destroy);
    } catch (error) {
      if (!failOpen) rethrow;
      final failure = rejectedCertificate
          ? RelayDialFailure.certificate
          : RelayDialFailure.unreachable;
      Logger.root.warning(
        '[relay] ${target.host}:${target.port} did not carry ${uri.host} '
        '(${failure.name}): $error — dialing ${uri.host} directly',
      );
      onRelayFailure?.call(failure, error);
      return direct(uri, proxyHost, proxyPort);
    }
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
  void Function()? onCertificateRejected,
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
      onBadCertificate: allowUntrustedCertificate
          ? (_) => true
          : (certificate) {
              // A relay copies bytes and never terminates TLS, so a
              // certificate that does not cover [Uri.host] means something
              // other than the server answered the handshake — a node wired to
              // the wrong origin, or TLS terminated in front of the relay.
              // Naming it turns "handshake failed" into something actionable.
              Logger.root.warning(
                '[relay] Rejected the certificate presented for ${uri.host}: '
                'subject=${certificate.subject} '
                'issuer=${certificate.issuer}',
              );
              onCertificateRejected?.call();
              return false;
            },
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
