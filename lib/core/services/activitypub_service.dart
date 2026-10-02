import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final activityPubServiceProvider = Provider<ActivityPubService>((ref) {
  final client = ref.watch(solarNetworkClientProvider);
  return ActivityPubService(client);
});

/// ActivityPub operations of the signed-in account.
///
/// Remote actors are publishers now, so every actor-shaped result is an
/// [SnPublisher] with [SnPublisher.isFediverse] set.
class ActivityPubService {
  final SolarNetworkClient _client;

  ActivityPubService(this._client);

  /// Follows a remote actor by its local publisher id.
  Future<void> followActor(String actorId) => _client.sphere.followActor(actorId);

  /// Undoes a follow of a remote actor.
  Future<void> unfollowActor(String actorId) =>
      _client.sphere.unfollowActor(actorId);

  /// Lists the remote actors the account follows.
  Future<List<SnPublisher>> getFollowing({int limit = 50}) async {
    final response = await _client.dio.get(
      '/sphere/activitypub/following',
      queryParameters: {'take': limit},
    );
    return (response.data as List<dynamic>)
        .map((json) => SnPublisher.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Lists the remote actors following the account.
  Future<List<SnPublisher>> getFollowers({int limit = 50}) async {
    final response = await _client.dio.get(
      '/sphere/activitypub/followers',
      queryParameters: {'take': limit},
    );
    return (response.data as List<dynamic>)
        .map((json) => SnPublisher.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Searches remote actors, discovering them from the network when needed.
  Future<List<SnPublisher>> searchActors(
    String query, {
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      '/sphere/activitypub/search',
      queryParameters: {'query': query, 'limit': limit},
    );
    return (response.data as List<dynamic>)
        .map((json) => SnPublisher.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<SnActorStatusResponse> getPublisherActorStatus(
    String publisherName,
  ) async {
    final response = await _client.dio.get(
      '/sphere/publishers/$publisherName/fediverse',
    );
    return SnActorStatusResponse.fromJson(response.data);
  }

  Future<void> enablePublisherActor(String publisherName) async {
    await _client.dio.post('/sphere/publishers/$publisherName/fediverse');
  }

  Future<void> disablePublisherActor(String publisherName) async {
    await _client.dio.delete('/sphere/publishers/$publisherName/fediverse');
  }
}
