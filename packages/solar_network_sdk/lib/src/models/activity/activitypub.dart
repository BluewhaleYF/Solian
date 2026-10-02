import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'activitypub.freezed.dart';
part 'activitypub.g.dart';

/// Metadata of a fediverse instance a publisher lives on.
@freezed
sealed class SnActivityPubInstance with _$SnActivityPubInstance {
  const factory SnActivityPubInstance({
    /// Synthetic remote instances may omit id (Guid.Empty / null).
    @Default('') String id,
    @Default('unknown') String domain,
    String? name,
    String? description,
    String? software,
    String? version,
    String? iconUrl,
    String? thumbnailUrl,
    String? contactEmail,
    String? contactAccountUsername,
    int? activeUsers,
    @Default(false) bool isBlocked,
    @Default(false) bool isSilenced,
    String? blockReason,
    Map<String, dynamic>? metadata,
    DateTime? lastFetchedAt,
    DateTime? lastActivityAt,
    DateTime? metadataFetchedAt,
  }) = _SnActivityPubInstance;

  factory SnActivityPubInstance.fromJson(Map<String, dynamic> json) =>
      _$SnActivityPubInstanceFromJson(json);
}

/// Status of the ActivityPub actor attached to a local publisher.
@freezed
sealed class SnActorStatusResponse with _$SnActorStatusResponse {
  const factory SnActorStatusResponse({
    required bool enabled,
    @Default(0) int followerCount,
    SnPublisher? actor,
    String? actorUri,
  }) = _SnActorStatusResponse;

  factory SnActorStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$SnActorStatusResponseFromJson(json);
}
