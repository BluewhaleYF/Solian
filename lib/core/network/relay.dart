import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

/// SharedPreferences key holding the selected [RelayRoute] as JSON.
///
/// Absent when traffic goes straight to the configured server. The model, the
/// catalog client, and the dial logic live in `solar_network_foundation` so
/// other Solar Network clients can route through the same relays.
const kNetworkRelayRouteStoreKey = 'app_relay_route';

/// SharedPreferences key holding the last catalog read per server, as JSON.
const kNetworkRelayCatalogStoreKey = 'app_relay_catalog';

/// How long a cached catalog is served before the server is asked again.
///
/// Relays are announced rarely and the picker refetches on request, so a client
/// that starts many times a day should not ask the server every time.
const kRelayCatalogMaxAge = Duration(hours: 6);

/// Reads the persisted relay route, ignoring malformed values.
RelayRoute? readRelayRoute(SharedPreferences prefs) {
  final raw = prefs.getString(kNetworkRelayRouteStoreKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final route = RelayRoute.fromJson(Map<String, dynamic>.from(decoded));
    return route.isValid ? route : null;
  } catch (error) {
    Logger.root.warning('[relay] Ignoring malformed relay route: $error');
    return null;
  }
}

/// The cached catalog for [serverUrl], or null when there is nothing usable.
///
/// The server is part of the entry: two servers announce different relays, and
/// serving one server's catalog for another would route traffic through a node
/// that never agreed to carry it.
List<RelayEntry>? readCachedRelayCatalog(
  SharedPreferences prefs,
  String serverUrl, {
  Duration maxAge = kRelayCatalogMaxAge,
}) {
  final raw = prefs.getString(kNetworkRelayCatalogStoreKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final cached = Map<String, dynamic>.from(decoded);
    if (cached['server'] != serverUrl) return null;
    final fetchedAt = (cached['fetched_at'] as num?)?.toInt() ?? 0;
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(fetchedAt),
    );
    if (age > maxAge) return null;
    final relays = cached['relays'];
    if (relays is! List) return null;
    return [
      for (final item in relays)
        if (item is Map)
          RelayEntry.fromJson(Map<String, dynamic>.from(item)),
    ].where((entry) => entry.isDialable).toList();
  } catch (error) {
    Logger.root.fine('[relay] Ignoring an unreadable cached catalog: $error');
    return null;
  }
}

/// Stores [entries] as the catalog [serverUrl] announced.
Future<void> writeCachedRelayCatalog(
  SharedPreferences prefs,
  String serverUrl,
  List<RelayEntry> entries,
) => prefs.setString(
  kNetworkRelayCatalogStoreKey,
  jsonEncode({
    'server': serverUrl,
    'fetched_at': DateTime.now().millisecondsSinceEpoch,
    'relays': [for (final entry in entries) entry.toJson()],
  }),
);

class RelayRouteNotifier extends Notifier<RelayRoute?> {
  @override
  RelayRoute? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return readRelayRoute(prefs);
  }

  /// Selects [route], or clears the selection when null (direct traffic).
  ///
  /// Picking a relay is also the retry: a node the app disabled after a failed
  /// connection is tried again.
  void select(RelayRoute? route) {
    ref.read(relaySuspensionProvider.notifier).resume();
    final prefs = ref.read(sharedPreferencesProvider);
    if (route == null || !route.isValid) {
      prefs.remove(kNetworkRelayRouteStoreKey);
      state = null;
      return;
    }
    prefs.setString(kNetworkRelayRouteStoreKey, jsonEncode(route.toJson()));
    state = route;
  }
}

/// The relay the user chose, or null for direct. Persisted across launches.
///
/// The logical server URL is untouched: only the socket is re-routed, so SNI,
/// `Host`, and certificate verification still belong to the configured server.
final relayRouteProvider = NotifierProvider<RelayRouteNotifier, RelayRoute?>(
  RelayRouteNotifier.new,
);

/// [RelayDialFailure.certificate] strikes to drop a node; see
/// [RelaySuspensionNotifier.report].
const kRelayFailureStrikes = 3;

/// How far back failures are counted before a node is dropped.
const kRelayFailureWindow = Duration(minutes: 1);

/// A relay the app stopped dialing, and why.
class RelaySuspension {
  /// The route that was dropped.
  final RelayRoute route;

  /// What kind of failure dropped it.
  final RelayDialFailure failure;

  /// The error the dial reported.
  final Object error;

  /// When it was dropped.
  final DateTime at;

  const RelaySuspension({
    required this.route,
    required this.failure,
    required this.error,
    required this.at,
  });
}

/// Drops a relay the app can no longer dial, so traffic goes direct.
///
/// The dial path reports every failed relay dial here. A certificate the server
/// does not cover is a misconfiguration — retrying cannot fix it — so one is
/// enough; anything else has to fail [kRelayFailureStrikes] times inside
/// [kRelayFailureWindow] first, because one timeout is what a moving network
/// looks like. Direct is the fallback, so a broken node costs a little latency
/// instead of the connection.
class RelaySuspensionNotifier extends Notifier<RelaySuspension?> {
  final _failures = <DateTime>[];

  @override
  RelaySuspension? build() => null;

  /// Counts a failed dial through [route], dropping it when it cannot work.
  void report(RelayRoute route, RelayDialFailure failure, Object error) {
    if (state != null) return;
    if (failure == RelayDialFailure.certificate) {
      _suspend(route, failure, error);
      return;
    }
    final now = DateTime.now();
    _failures
      ..removeWhere((at) => now.difference(at) > kRelayFailureWindow)
      ..add(now);
    if (_failures.length >= kRelayFailureStrikes) {
      _suspend(route, failure, error);
    }
  }

  /// Clears the suspension, so the node is tried again.
  void resume() {
    _failures.clear();
    state = null;
  }

  void _suspend(RelayRoute route, RelayDialFailure failure, Object error) {
    Logger.root.warning(
      '[relay] Disabled ${route.id} (${failure.name}) after $error; '
      'traffic goes direct',
    );
    state = RelaySuspension(
      route: route,
      failure: failure,
      error: error,
      at: DateTime.now(),
    );
  }
}

/// The relay the app stopped dialing this session, or null.
final relaySuspensionProvider =
    NotifierProvider<RelaySuspensionNotifier, RelaySuspension?>(
      RelaySuspensionNotifier.new,
    );

/// The route the app actually dials: the chosen route, reconciled with the
/// catalog the server announces right now and dropped when the node failed.
///
/// A stored route is a snapshot, so the announced entry with the same id wins
/// while the catalog is loaded: a node that changes its public host or port — a
/// relay that moved behind a different port forward, a fleet that
/// re-registers — would otherwise keep being dialed at the old address until
/// the user picks it again, and every dial would fail on a certificate or a
/// refusal that has nothing to do with the app. The stored route stays the
/// fallback when the catalog cannot be read or no longer lists the node.
final activeRelayRouteProvider = Provider<RelayRoute?>((ref) {
  final stored = ref.watch(relayRouteProvider);
  if (stored == null) return null;

  final suspended = ref.watch(relaySuspensionProvider);
  if (suspended != null && suspended.route.id == stored.id) return null;

  final announced = ref.watch(relayCatalogProvider).value;
  if (announced == null) return stored;

  for (final entry in announced) {
    if (entry.id == stored.id && entry.isDialable) {
      return RelayRoute.fromEntry(entry);
    }
  }
  return stored;
});

/// Relays announced by the configured server through `GET /relays`.
///
/// Served from the cached catalog while it is younger than
/// [kRelayCatalogMaxAge]; the read is still a direct connection — a selected
/// relay must never be able to hide its own picker. Call
/// [RelayCatalogNotifier.refresh] to ask the server regardless.
class RelayCatalogNotifier extends AsyncNotifier<List<RelayEntry>> {
  @override
  Future<List<RelayEntry>> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final serverUrl = ref.watch(serverUrlProvider);
    final cached = readCachedRelayCatalog(prefs, serverUrl);
    if (cached != null) {
      Logger.root.fine(
        '[relay] Using the ${cached.length} relay(s) cached for $serverUrl',
      );
      return cached;
    }
    return _load(prefs, serverUrl);
  }

  /// Asks the server for the catalog, cache or not.
  Future<void> refresh() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final serverUrl = ref.read(serverUrlProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _load(prefs, serverUrl));
  }

  Future<List<RelayEntry>> _load(
    SharedPreferences prefs,
    String serverUrl,
  ) async {
    final entries = await fetchRelayCatalog(serverUrl);
    await writeCachedRelayCatalog(prefs, serverUrl, entries);
    Logger.root.info(
      '[relay] Catalog: ${entries.length} relay(s) announced by $serverUrl',
    );
    return entries;
  }
}

final relayCatalogProvider =
    AsyncNotifierProvider<RelayCatalogNotifier, List<RelayEntry>>(
      RelayCatalogNotifier.new,
    );
