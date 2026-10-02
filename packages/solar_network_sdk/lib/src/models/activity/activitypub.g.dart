// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activitypub.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnActivityPubInstance _$SnActivityPubInstanceFromJson(
  Map<String, dynamic> json,
) => _SnActivityPubInstance(
  id: json['id'] as String? ?? '',
  domain: json['domain'] as String? ?? 'unknown',
  name: json['name'] as String?,
  description: json['description'] as String?,
  software: json['software'] as String?,
  version: json['version'] as String?,
  iconUrl: json['icon_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  contactEmail: json['contact_email'] as String?,
  contactAccountUsername: json['contact_account_username'] as String?,
  activeUsers: (json['active_users'] as num?)?.toInt(),
  isBlocked: json['is_blocked'] as bool? ?? false,
  isSilenced: json['is_silenced'] as bool? ?? false,
  blockReason: json['block_reason'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  lastFetchedAt: json['last_fetched_at'] == null
      ? null
      : DateTime.parse(json['last_fetched_at'] as String),
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
  metadataFetchedAt: json['metadata_fetched_at'] == null
      ? null
      : DateTime.parse(json['metadata_fetched_at'] as String),
);

Map<String, dynamic> _$SnActivityPubInstanceToJson(
  _SnActivityPubInstance instance,
) => <String, dynamic>{
  'id': instance.id,
  'domain': instance.domain,
  'name': instance.name,
  'description': instance.description,
  'software': instance.software,
  'version': instance.version,
  'icon_url': instance.iconUrl,
  'thumbnail_url': instance.thumbnailUrl,
  'contact_email': instance.contactEmail,
  'contact_account_username': instance.contactAccountUsername,
  'active_users': instance.activeUsers,
  'is_blocked': instance.isBlocked,
  'is_silenced': instance.isSilenced,
  'block_reason': instance.blockReason,
  'metadata': instance.metadata,
  'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
  'last_activity_at': instance.lastActivityAt?.toIso8601String(),
  'metadata_fetched_at': instance.metadataFetchedAt?.toIso8601String(),
};

_SnActorStatusResponse _$SnActorStatusResponseFromJson(
  Map<String, dynamic> json,
) => _SnActorStatusResponse(
  enabled: json['enabled'] as bool,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
  actor: json['actor'] == null
      ? null
      : SnPublisher.fromJson(json['actor'] as Map<String, dynamic>),
  actorUri: json['actor_uri'] as String?,
);

Map<String, dynamic> _$SnActorStatusResponseToJson(
  _SnActorStatusResponse instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'follower_count': instance.followerCount,
  'actor': instance.actor?.toJson(),
  'actor_uri': instance.actorUri,
};
