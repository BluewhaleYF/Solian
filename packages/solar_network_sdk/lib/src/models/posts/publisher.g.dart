// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) => _SnPublisher(
  id: json['id'] as String? ?? '',
  type: (json['type'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  nick: json['nick'] as String? ?? '',
  bio: json['bio'] as String? ?? '',
  realmNick: json['realm_nick'] as String?,
  realmBio: json['realm_bio'] as String?,
  realmExperience: (json['realm_experience'] as num?)?.toInt(),
  realmLevel: (json['realm_level'] as num?)?.toInt(),
  realmLevelingProgress: (json['realm_leveling_progress'] as num?)?.toDouble(),
  realmLabel: json['realm_label'] == null
      ? null
      : SnRealmLabel.fromJson(json['realm_label'] as Map<String, dynamic>),
  picture: json['picture'] == null
      ? null
      : SnCloudFileReference.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFileReference.fromJson(
          json['background'] as Map<String, dynamic>,
        ),
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  accountId: json['account_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  realmId: json['realm_id'] as String?,
  realm: json['realm'] == null
      ? null
      : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
  verification: json['verification'] == null
      ? null
      : SnVerificationMark.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
  isShadowbanned: json['is_shadowbanned'] as bool? ?? false,
  isGatekept: json['is_gatekept'] as bool? ?? false,
  isModerateSubscription: json['is_moderate_subscription'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toDouble() ?? 100.0,
  ratingLevel: (json['rating_level'] as num?)?.toInt() ?? 0,
  shadowbanReason: (json['shadowban_reason'] as num?)?.toInt(),
  shadowbannedAt: json['shadowbanned_at'] == null
      ? null
      : DateTime.parse(json['shadowbanned_at'] as String),
  gatekeptFollows: json['gatekept_follows'] as bool?,
  moderateSubscription: json['moderate_subscription'] as bool?,
  payoutWalletId: json['payout_wallet_id'] as String?,
  uri: json['uri'] as String?,
  actorType: json['actor_type'] as String?,
  username: json['username'] as String?,
  displayName: json['display_name'] as String?,
  instanceId: json['instance_id'] as String?,
  instance: json['instance'] == null
      ? null
      : SnActivityPubInstance.fromJson(
          json['instance'] as Map<String, dynamic>,
        ),
  instanceDomain: json['instance_domain'] as String?,
  inboxUri: json['inbox_uri'] as String?,
  outboxUri: json['outbox_uri'] as String?,
  followersUri: json['followers_uri'] as String?,
  followingUri: json['following_uri'] as String?,
  featuredUri: json['featured_uri'] as String?,
  publicKeyId: json['public_key_id'] as String?,
  publicKey: json['public_key'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  headerUrl: json['header_url'] as String?,
  isBot: json['is_bot'] as bool? ?? false,
  isLocked: json['is_locked'] as bool? ?? false,
  isDiscoverable: json['is_discoverable'] as bool? ?? true,
  isCommunity: json['is_community'] as bool? ?? false,
  lastFetchedAt: json['last_fetched_at'] == null
      ? null
      : DateTime.parse(json['last_fetched_at'] as String),
  lastActivityAt: json['last_activity_at'] == null
      ? null
      : DateTime.parse(json['last_activity_at'] as String),
  outboxFetchedAt: json['outbox_fetched_at'] == null
      ? null
      : DateTime.parse(json['outbox_fetched_at'] as String),
  fullHandle: json['full_handle'] as String?,
  webUrl: json['web_url'] as String?,
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  postCount: (json['post_count'] as num?)?.toInt() ?? 0,
  totalPostCount: (json['total_post_count'] as num?)?.toInt(),
  meta: json['meta'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  isFollowing: json['is_following'] as bool? ?? false,
);

Map<String, dynamic> _$SnPublisherToJson(_SnPublisher instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'nick': instance.nick,
      'bio': instance.bio,
      'realm_nick': instance.realmNick,
      'realm_bio': instance.realmBio,
      'realm_experience': instance.realmExperience,
      'realm_level': instance.realmLevel,
      'realm_leveling_progress': instance.realmLevelingProgress,
      'realm_label': instance.realmLabel?.toJson(),
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'account': instance.account?.toJson(),
      'account_id': instance.accountId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'realm_id': instance.realmId,
      'realm': instance.realm?.toJson(),
      'verification': instance.verification?.toJson(),
      'is_shadowbanned': instance.isShadowbanned,
      'is_gatekept': instance.isGatekept,
      'is_moderate_subscription': instance.isModerateSubscription,
      'rating': instance.rating,
      'rating_level': instance.ratingLevel,
      'shadowban_reason': instance.shadowbanReason,
      'shadowbanned_at': instance.shadowbannedAt?.toIso8601String(),
      'gatekept_follows': instance.gatekeptFollows,
      'moderate_subscription': instance.moderateSubscription,
      'payout_wallet_id': instance.payoutWalletId,
      'uri': instance.uri,
      'actor_type': instance.actorType,
      'username': instance.username,
      'display_name': instance.displayName,
      'instance_id': instance.instanceId,
      'instance': instance.instance?.toJson(),
      'instance_domain': instance.instanceDomain,
      'inbox_uri': instance.inboxUri,
      'outbox_uri': instance.outboxUri,
      'followers_uri': instance.followersUri,
      'following_uri': instance.followingUri,
      'featured_uri': instance.featuredUri,
      'public_key_id': instance.publicKeyId,
      'public_key': instance.publicKey,
      'avatar_url': instance.avatarUrl,
      'header_url': instance.headerUrl,
      'is_bot': instance.isBot,
      'is_locked': instance.isLocked,
      'is_discoverable': instance.isDiscoverable,
      'is_community': instance.isCommunity,
      'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
      'outbox_fetched_at': instance.outboxFetchedAt?.toIso8601String(),
      'full_handle': instance.fullHandle,
      'web_url': instance.webUrl,
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'post_count': instance.postCount,
      'total_post_count': instance.totalPostCount,
      'meta': instance.meta,
      'metadata': instance.metadata,
      'is_following': instance.isFollowing,
    };

_SnPublisherMember _$SnPublisherMemberFromJson(Map<String, dynamic> json) =>
    _SnPublisherMember(
      publisherId: json['publisher_id'] as String,
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      role: (json['role'] as num).toInt(),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPublisherMemberToJson(_SnPublisherMember instance) =>
    <String, dynamic>{
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'role': instance.role,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnPublisherSubscription _$SnPublisherSubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscription(
  id: json['id'] as String,
  accountId: json['account_id'] as String?,
  followerPublisherId: json['follower_publisher_id'] as String?,
  followerPublisher: json['follower_publisher'] == null
      ? null
      : SnPublisher.fromJson(
          json['follower_publisher'] as Map<String, dynamic>,
        ),
  publisherId: json['publisher_id'] as String,
  publisher: json['publisher'] == null
      ? null
      : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
  state:
      $enumDecodeNullable(_$PublisherSubscriptionStateEnumMap, json['state']) ??
      PublisherSubscriptionState.accepted,
  followedAt: json['followed_at'] == null
      ? null
      : DateTime.parse(json['followed_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  reviewedByAccountId: json['reviewed_by_account_id'] as String?,
  rejectReason: json['reject_reason'] as String?,
  isMuting: json['is_muting'] as bool? ?? false,
  isBlocking: json['is_blocking'] as bool? ?? false,
  notify: json['notify'] as bool? ?? true,
  lastReadAt: json['last_read_at'] == null
      ? null
      : DateTime.parse(json['last_read_at'] as String),
  realmId: json['realm_id'] as String?,
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  endReason: $enumDecodeNullable(
    _$SubscriptionEndReasonEnumMap,
    json['end_reason'],
  ),
  endedByAccountId: json['ended_by_account_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  isPending: json['is_pending'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnPublisherSubscriptionToJson(
  _SnPublisherSubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'follower_publisher_id': instance.followerPublisherId,
  'follower_publisher': instance.followerPublisher?.toJson(),
  'publisher_id': instance.publisherId,
  'publisher': instance.publisher?.toJson(),
  'state': _$PublisherSubscriptionStateEnumMap[instance.state]!,
  'followed_at': instance.followedAt?.toIso8601String(),
  'reviewed_at': instance.reviewedAt?.toIso8601String(),
  'reviewed_by_account_id': instance.reviewedByAccountId,
  'reject_reason': instance.rejectReason,
  'is_muting': instance.isMuting,
  'is_blocking': instance.isBlocking,
  'notify': instance.notify,
  'last_read_at': instance.lastReadAt?.toIso8601String(),
  'realm_id': instance.realmId,
  'account': instance.account?.toJson(),
  'ended_at': instance.endedAt?.toIso8601String(),
  'end_reason': _$SubscriptionEndReasonEnumMap[instance.endReason],
  'ended_by_account_id': instance.endedByAccountId,
  'is_active': instance.isActive,
  'is_pending': instance.isPending,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

const _$PublisherSubscriptionStateEnumMap = {
  PublisherSubscriptionState.pending: 0,
  PublisherSubscriptionState.accepted: 1,
  PublisherSubscriptionState.rejected: 2,
};

const _$SubscriptionEndReasonEnumMap = {
  SubscriptionEndReason.userLeft: 0,
  SubscriptionEndReason.removedByPublisher: 1,
};

_SnPublisherSubscriptionStatus _$SnPublisherSubscriptionStatusFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscriptionStatus(
  subscription: json['subscription'] == null
      ? null
      : SnPublisherSubscription.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  followRequest: json['follow_request'] == null
      ? null
      : SnPublisherSubscription.fromJson(
          json['follow_request'] as Map<String, dynamic>,
        ),
  requiresApproval: json['requires_approval'] as bool? ?? false,
  status: json['status'] as String? ?? 'none',
  message: json['message'] as String? ?? '',
  isPending: json['is_pending'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? false,
  notify: json['notify'] as bool? ?? true,
);

Map<String, dynamic> _$SnPublisherSubscriptionStatusToJson(
  _SnPublisherSubscriptionStatus instance,
) => <String, dynamic>{
  'subscription': instance.subscription?.toJson(),
  'follow_request': instance.followRequest?.toJson(),
  'requires_approval': instance.requiresApproval,
  'status': instance.status,
  'message': instance.message,
  'is_pending': instance.isPending,
  'is_active': instance.isActive,
  'notify': instance.notify,
};

_SnPublisherSubscriber _$SnPublisherSubscriberFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscriber(
  subscription: SnPublisherSubscription.fromJson(
    json['subscription'] as Map<String, dynamic>,
  ),
  account: json['account'] == null
      ? null
      : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnPublisherSubscriberToJson(
  _SnPublisherSubscriber instance,
) => <String, dynamic>{
  'subscription': instance.subscription.toJson(),
  'account': instance.account?.toJson(),
};

_SnPublisherRelationship _$SnPublisherRelationshipFromJson(
  Map<String, dynamic> json,
) => _SnPublisherRelationship(
  subscription: json['subscription'] == null
      ? null
      : SnPublisherSubscription.fromJson(
          json['subscription'] as Map<String, dynamic>,
        ),
  isBlocking: json['is_blocking'] as bool? ?? false,
  isMuting: json['is_muting'] as bool? ?? false,
  isSubscribed: json['is_subscribed'] as bool? ?? false,
);

Map<String, dynamic> _$SnPublisherRelationshipToJson(
  _SnPublisherRelationship instance,
) => <String, dynamic>{
  'subscription': instance.subscription?.toJson(),
  'is_blocking': instance.isBlocking,
  'is_muting': instance.isMuting,
  'is_subscribed': instance.isSubscribed,
};

_SnPublisherSubscriptionReadStatus _$SnPublisherSubscriptionReadStatusFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscriptionReadStatus(
  subscription: SnPublisherSubscription.fromJson(
    json['subscription'] as Map<String, dynamic>,
  ),
  latestContentAt: json['latest_content_at'] == null
      ? null
      : DateTime.parse(json['latest_content_at'] as String),
  hasNewContent: json['has_new_content'] as bool? ?? false,
);

Map<String, dynamic> _$SnPublisherSubscriptionReadStatusToJson(
  _SnPublisherSubscriptionReadStatus instance,
) => <String, dynamic>{
  'subscription': instance.subscription.toJson(),
  'latest_content_at': instance.latestContentAt?.toIso8601String(),
  'has_new_content': instance.hasNewContent,
};

_SnPublisherSubscriptionWithStatus _$SnPublisherSubscriptionWithStatusFromJson(
  Map<String, dynamic> json,
) => _SnPublisherSubscriptionWithStatus(
  subscription: SnPublisherSubscription.fromJson(
    json['subscription'] as Map<String, dynamic>,
  ),
  isLive: json['is_live'] as bool? ?? false,
  latestContentAt: json['latest_content_at'] == null
      ? null
      : DateTime.parse(json['latest_content_at'] as String),
  hasNewContent: json['has_new_content'] as bool? ?? false,
);

Map<String, dynamic> _$SnPublisherSubscriptionWithStatusToJson(
  _SnPublisherSubscriptionWithStatus instance,
) => <String, dynamic>{
  'subscription': instance.subscription.toJson(),
  'is_live': instance.isLive,
  'latest_content_at': instance.latestContentAt?.toIso8601String(),
  'has_new_content': instance.hasNewContent,
};

_FediverseActorRelationship _$FediverseActorRelationshipFromJson(
  Map<String, dynamic> json,
) => _FediverseActorRelationship(
  actorId: json['actor_id'] as String? ?? '',
  actorUsername: json['actor_username'] as String? ?? '',
  actorInstance: json['actor_instance'] as String?,
  actorHandle: json['actor_handle'] as String? ?? '',
  isFollowing: json['is_following'] as bool? ?? false,
  isFollowedBy: json['is_followed_by'] as bool? ?? false,
  isPending: json['is_pending'] as bool? ?? false,
);

Map<String, dynamic> _$FediverseActorRelationshipToJson(
  _FediverseActorRelationship instance,
) => <String, dynamic>{
  'actor_id': instance.actorId,
  'actor_username': instance.actorUsername,
  'actor_instance': instance.actorInstance,
  'actor_handle': instance.actorHandle,
  'is_following': instance.isFollowing,
  'is_followed_by': instance.isFollowedBy,
  'is_pending': instance.isPending,
};
