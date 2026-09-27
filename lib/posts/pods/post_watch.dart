import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The current user's effective post watch filters, one entry per source.
///
/// Post watches are implicit: bookmarking, reacting to, or replying to a post
/// subscribes the account to that post's updates, and the filters decide which
/// updates are delivered. The server already resolves the defaults, so the
/// returned list always holds all three sources.
final postWatchPreferencesProvider =
    FutureProvider<List<SnPostWatchPreference>>((ref) {
      final client = ref.read(solarNetworkClientProvider);
      return client.sphere.getPostWatchPreferences();
    });

/// Writes [preferences] back to the server and refreshes the cached filters.
///
/// Only the sources present in [preferences] are written; pass the full value
/// of each edited source. Returns the effective filters after the write.
Future<List<SnPostWatchPreference>> savePostWatchPreferences(
  WidgetRef ref,
  List<SnPostWatchPreference> preferences,
) async {
  final client = ref.read(solarNetworkClientProvider);
  final updated = await client.sphere.updatePostWatchPreferences(preferences);
  ref.invalidate(postWatchPreferencesProvider);
  return updated;
}
