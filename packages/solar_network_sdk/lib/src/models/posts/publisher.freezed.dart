// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publisher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublisher {

 String get id; int get type; String get name; String get nick; String get bio; String? get realmNick; String? get realmBio; int? get realmExperience; int? get realmLevel; double? get realmLevelingProgress; SnRealmLabel? get realmLabel; SnCloudFileReference? get picture; SnCloudFileReference? get background; SnAccount? get account; String? get accountId; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; String? get realmId; SnRealm? get realm; SnVerificationMark? get verification; bool get isShadowbanned; bool get isGatekept; bool get isModerateSubscription; double get rating;@JsonKey(name: 'rating_level') int get ratingLevel; int? get shadowbanReason; DateTime? get shadowbannedAt; bool? get gatekeptFollows; bool? get moderateSubscription; String? get payoutWalletId; String? get uri; String? get actorType; String? get username; String? get displayName; String? get instanceId; SnActivityPubInstance? get instance; String? get instanceDomain; String? get inboxUri; String? get outboxUri; String? get followersUri; String? get followingUri; String? get featuredUri; String? get publicKeyId; String? get publicKey; String? get avatarUrl; String? get headerUrl; bool get isBot; bool get isLocked; bool get isDiscoverable; bool get isCommunity; DateTime? get lastFetchedAt; DateTime? get lastActivityAt; DateTime? get outboxFetchedAt; String? get fullHandle; String? get webUrl; int get followersCount; int get followingCount; int get postCount; int? get totalPostCount; Map<String, dynamic>? get meta; Map<String, dynamic>? get metadata; bool get isFollowing;
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<SnPublisher> get copyWith => _$SnPublisherCopyWithImpl<SnPublisher>(this as SnPublisher, _$identity);

  /// Serializes this SnPublisher to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisher;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisher&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.nick, _this.nick) || other.nick == _this.nick)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.realmNick, _this.realmNick) || other.realmNick == _this.realmNick)&&(identical(other.realmBio, _this.realmBio) || other.realmBio == _this.realmBio)&&(identical(other.realmExperience, _this.realmExperience) || other.realmExperience == _this.realmExperience)&&(identical(other.realmLevel, _this.realmLevel) || other.realmLevel == _this.realmLevel)&&(identical(other.realmLevelingProgress, _this.realmLevelingProgress) || other.realmLevelingProgress == _this.realmLevelingProgress)&&(identical(other.realmLabel, _this.realmLabel) || other.realmLabel == _this.realmLabel)&&(identical(other.picture, _this.picture) || other.picture == _this.picture)&&(identical(other.background, _this.background) || other.background == _this.background)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.realmId, _this.realmId) || other.realmId == _this.realmId)&&(identical(other.realm, _this.realm) || other.realm == _this.realm)&&(identical(other.verification, _this.verification) || other.verification == _this.verification)&&(identical(other.isShadowbanned, _this.isShadowbanned) || other.isShadowbanned == _this.isShadowbanned)&&(identical(other.isGatekept, _this.isGatekept) || other.isGatekept == _this.isGatekept)&&(identical(other.isModerateSubscription, _this.isModerateSubscription) || other.isModerateSubscription == _this.isModerateSubscription)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.ratingLevel, _this.ratingLevel) || other.ratingLevel == _this.ratingLevel)&&(identical(other.shadowbanReason, _this.shadowbanReason) || other.shadowbanReason == _this.shadowbanReason)&&(identical(other.shadowbannedAt, _this.shadowbannedAt) || other.shadowbannedAt == _this.shadowbannedAt)&&(identical(other.gatekeptFollows, _this.gatekeptFollows) || other.gatekeptFollows == _this.gatekeptFollows)&&(identical(other.moderateSubscription, _this.moderateSubscription) || other.moderateSubscription == _this.moderateSubscription)&&(identical(other.payoutWalletId, _this.payoutWalletId) || other.payoutWalletId == _this.payoutWalletId)&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.actorType, _this.actorType) || other.actorType == _this.actorType)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.instanceId, _this.instanceId) || other.instanceId == _this.instanceId)&&(identical(other.instance, _this.instance) || other.instance == _this.instance)&&(identical(other.instanceDomain, _this.instanceDomain) || other.instanceDomain == _this.instanceDomain)&&(identical(other.inboxUri, _this.inboxUri) || other.inboxUri == _this.inboxUri)&&(identical(other.outboxUri, _this.outboxUri) || other.outboxUri == _this.outboxUri)&&(identical(other.followersUri, _this.followersUri) || other.followersUri == _this.followersUri)&&(identical(other.followingUri, _this.followingUri) || other.followingUri == _this.followingUri)&&(identical(other.featuredUri, _this.featuredUri) || other.featuredUri == _this.featuredUri)&&(identical(other.publicKeyId, _this.publicKeyId) || other.publicKeyId == _this.publicKeyId)&&(identical(other.publicKey, _this.publicKey) || other.publicKey == _this.publicKey)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.headerUrl, _this.headerUrl) || other.headerUrl == _this.headerUrl)&&(identical(other.isBot, _this.isBot) || other.isBot == _this.isBot)&&(identical(other.isLocked, _this.isLocked) || other.isLocked == _this.isLocked)&&(identical(other.isDiscoverable, _this.isDiscoverable) || other.isDiscoverable == _this.isDiscoverable)&&(identical(other.isCommunity, _this.isCommunity) || other.isCommunity == _this.isCommunity)&&(identical(other.lastFetchedAt, _this.lastFetchedAt) || other.lastFetchedAt == _this.lastFetchedAt)&&(identical(other.lastActivityAt, _this.lastActivityAt) || other.lastActivityAt == _this.lastActivityAt)&&(identical(other.outboxFetchedAt, _this.outboxFetchedAt) || other.outboxFetchedAt == _this.outboxFetchedAt)&&(identical(other.fullHandle, _this.fullHandle) || other.fullHandle == _this.fullHandle)&&(identical(other.webUrl, _this.webUrl) || other.webUrl == _this.webUrl)&&(identical(other.followersCount, _this.followersCount) || other.followersCount == _this.followersCount)&&(identical(other.followingCount, _this.followingCount) || other.followingCount == _this.followingCount)&&(identical(other.postCount, _this.postCount) || other.postCount == _this.postCount)&&(identical(other.totalPostCount, _this.totalPostCount) || other.totalPostCount == _this.totalPostCount)&&const DeepCollectionEquality().equals(other.meta, _this.meta)&&const DeepCollectionEquality().equals(other.metadata, _this.metadata)&&(identical(other.isFollowing, _this.isFollowing) || other.isFollowing == _this.isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisher;
  return Object.hashAll([runtimeType,_this.id,_this.type,_this.name,_this.nick,_this.bio,_this.realmNick,_this.realmBio,_this.realmExperience,_this.realmLevel,_this.realmLevelingProgress,_this.realmLabel,_this.picture,_this.background,_this.account,_this.accountId,_this.createdAt,_this.updatedAt,_this.deletedAt,_this.realmId,_this.realm,_this.verification,_this.isShadowbanned,_this.isGatekept,_this.isModerateSubscription,_this.rating,_this.ratingLevel,_this.shadowbanReason,_this.shadowbannedAt,_this.gatekeptFollows,_this.moderateSubscription,_this.payoutWalletId,_this.uri,_this.actorType,_this.username,_this.displayName,_this.instanceId,_this.instance,_this.instanceDomain,_this.inboxUri,_this.outboxUri,_this.followersUri,_this.followingUri,_this.featuredUri,_this.publicKeyId,_this.publicKey,_this.avatarUrl,_this.headerUrl,_this.isBot,_this.isLocked,_this.isDiscoverable,_this.isCommunity,_this.lastFetchedAt,_this.lastActivityAt,_this.outboxFetchedAt,_this.fullHandle,_this.webUrl,_this.followersCount,_this.followingCount,_this.postCount,_this.totalPostCount,const DeepCollectionEquality().hash(_this.meta),const DeepCollectionEquality().hash(_this.metadata),_this.isFollowing]);
}

@override
String toString() {
  final _this = this as SnPublisher;
  return 'SnPublisher(id: ${_this.id}, type: ${_this.type}, name: ${_this.name}, nick: ${_this.nick}, bio: ${_this.bio}, realmNick: ${_this.realmNick}, realmBio: ${_this.realmBio}, realmExperience: ${_this.realmExperience}, realmLevel: ${_this.realmLevel}, realmLevelingProgress: ${_this.realmLevelingProgress}, realmLabel: ${_this.realmLabel}, picture: ${_this.picture}, background: ${_this.background}, account: ${_this.account}, accountId: ${_this.accountId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt}, realmId: ${_this.realmId}, realm: ${_this.realm}, verification: ${_this.verification}, isShadowbanned: ${_this.isShadowbanned}, isGatekept: ${_this.isGatekept}, isModerateSubscription: ${_this.isModerateSubscription}, rating: ${_this.rating}, ratingLevel: ${_this.ratingLevel}, shadowbanReason: ${_this.shadowbanReason}, shadowbannedAt: ${_this.shadowbannedAt}, gatekeptFollows: ${_this.gatekeptFollows}, moderateSubscription: ${_this.moderateSubscription}, payoutWalletId: ${_this.payoutWalletId}, uri: ${_this.uri}, actorType: ${_this.actorType}, username: ${_this.username}, displayName: ${_this.displayName}, instanceId: ${_this.instanceId}, instance: ${_this.instance}, instanceDomain: ${_this.instanceDomain}, inboxUri: ${_this.inboxUri}, outboxUri: ${_this.outboxUri}, followersUri: ${_this.followersUri}, followingUri: ${_this.followingUri}, featuredUri: ${_this.featuredUri}, publicKeyId: ${_this.publicKeyId}, publicKey: ${_this.publicKey}, avatarUrl: ${_this.avatarUrl}, headerUrl: ${_this.headerUrl}, isBot: ${_this.isBot}, isLocked: ${_this.isLocked}, isDiscoverable: ${_this.isDiscoverable}, isCommunity: ${_this.isCommunity}, lastFetchedAt: ${_this.lastFetchedAt}, lastActivityAt: ${_this.lastActivityAt}, outboxFetchedAt: ${_this.outboxFetchedAt}, fullHandle: ${_this.fullHandle}, webUrl: ${_this.webUrl}, followersCount: ${_this.followersCount}, followingCount: ${_this.followingCount}, postCount: ${_this.postCount}, totalPostCount: ${_this.totalPostCount}, meta: ${_this.meta}, metadata: ${_this.metadata}, isFollowing: ${_this.isFollowing})';
}


}

/// @nodoc
abstract mixin class $SnPublisherCopyWith<$Res>  {
  factory $SnPublisherCopyWith(SnPublisher value, $Res Function(SnPublisher) _then) = _$SnPublisherCopyWithImpl;
@useResult
$Res call({
 String id, int type, String name, String nick, String bio, String? realmNick, String? realmBio, int? realmExperience, int? realmLevel, double? realmLevelingProgress, SnRealmLabel? realmLabel, SnCloudFileReference? picture, SnCloudFileReference? background, SnAccount? account, String? accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? realmId, SnRealm? realm, SnVerificationMark? verification, bool isShadowbanned, bool isGatekept, bool isModerateSubscription, double rating,@JsonKey(name: 'rating_level') int ratingLevel, int? shadowbanReason, DateTime? shadowbannedAt, bool? gatekeptFollows, bool? moderateSubscription, String? payoutWalletId, String? uri, String? actorType, String? username, String? displayName, String? instanceId, SnActivityPubInstance? instance, String? instanceDomain, String? inboxUri, String? outboxUri, String? followersUri, String? followingUri, String? featuredUri, String? publicKeyId, String? publicKey, String? avatarUrl, String? headerUrl, bool isBot, bool isLocked, bool isDiscoverable, bool isCommunity, DateTime? lastFetchedAt, DateTime? lastActivityAt, DateTime? outboxFetchedAt, String? fullHandle, String? webUrl, int followersCount, int followingCount, int postCount, int? totalPostCount, Map<String, dynamic>? meta, Map<String, dynamic>? metadata, bool isFollowing
});


$SnRealmLabelCopyWith<$Res>? get realmLabel;$SnCloudFileReferenceCopyWith<$Res>? get picture;$SnCloudFileReferenceCopyWith<$Res>? get background;$SnAccountCopyWith<$Res>? get account;$SnRealmCopyWith<$Res>? get realm;$SnVerificationMarkCopyWith<$Res>? get verification;$SnActivityPubInstanceCopyWith<$Res>? get instance;

}
/// @nodoc
class _$SnPublisherCopyWithImpl<$Res>
    implements $SnPublisherCopyWith<$Res> {
  _$SnPublisherCopyWithImpl(this._self, this._then);

  final SnPublisher _self;
  final $Res Function(SnPublisher) _then;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? nick = null,Object? bio = null,Object? realmNick = freezed,Object? realmBio = freezed,Object? realmExperience = freezed,Object? realmLevel = freezed,Object? realmLevelingProgress = freezed,Object? realmLabel = freezed,Object? picture = freezed,Object? background = freezed,Object? account = freezed,Object? accountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? realmId = freezed,Object? realm = freezed,Object? verification = freezed,Object? isShadowbanned = null,Object? isGatekept = null,Object? isModerateSubscription = null,Object? rating = null,Object? ratingLevel = null,Object? shadowbanReason = freezed,Object? shadowbannedAt = freezed,Object? gatekeptFollows = freezed,Object? moderateSubscription = freezed,Object? payoutWalletId = freezed,Object? uri = freezed,Object? actorType = freezed,Object? username = freezed,Object? displayName = freezed,Object? instanceId = freezed,Object? instance = freezed,Object? instanceDomain = freezed,Object? inboxUri = freezed,Object? outboxUri = freezed,Object? followersUri = freezed,Object? followingUri = freezed,Object? featuredUri = freezed,Object? publicKeyId = freezed,Object? publicKey = freezed,Object? avatarUrl = freezed,Object? headerUrl = freezed,Object? isBot = null,Object? isLocked = null,Object? isDiscoverable = null,Object? isCommunity = null,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? outboxFetchedAt = freezed,Object? fullHandle = freezed,Object? webUrl = freezed,Object? followersCount = null,Object? followingCount = null,Object? postCount = null,Object? totalPostCount = freezed,Object? meta = freezed,Object? metadata = freezed,Object? isFollowing = null,}) {
  return _then(SnPublisher(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,realmNick: freezed == realmNick ? _self.realmNick : realmNick // ignore: cast_nullable_to_non_nullable
as String?,realmBio: freezed == realmBio ? _self.realmBio : realmBio // ignore: cast_nullable_to_non_nullable
as String?,realmExperience: freezed == realmExperience ? _self.realmExperience : realmExperience // ignore: cast_nullable_to_non_nullable
as int?,realmLevel: freezed == realmLevel ? _self.realmLevel : realmLevel // ignore: cast_nullable_to_non_nullable
as int?,realmLevelingProgress: freezed == realmLevelingProgress ? _self.realmLevelingProgress : realmLevelingProgress // ignore: cast_nullable_to_non_nullable
as double?,realmLabel: freezed == realmLabel ? _self.realmLabel : realmLabel // ignore: cast_nullable_to_non_nullable
as SnRealmLabel?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,isShadowbanned: null == isShadowbanned ? _self.isShadowbanned : isShadowbanned // ignore: cast_nullable_to_non_nullable
as bool,isGatekept: null == isGatekept ? _self.isGatekept : isGatekept // ignore: cast_nullable_to_non_nullable
as bool,isModerateSubscription: null == isModerateSubscription ? _self.isModerateSubscription : isModerateSubscription // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingLevel: null == ratingLevel ? _self.ratingLevel : ratingLevel // ignore: cast_nullable_to_non_nullable
as int,shadowbanReason: freezed == shadowbanReason ? _self.shadowbanReason : shadowbanReason // ignore: cast_nullable_to_non_nullable
as int?,shadowbannedAt: freezed == shadowbannedAt ? _self.shadowbannedAt : shadowbannedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gatekeptFollows: freezed == gatekeptFollows ? _self.gatekeptFollows : gatekeptFollows // ignore: cast_nullable_to_non_nullable
as bool?,moderateSubscription: freezed == moderateSubscription ? _self.moderateSubscription : moderateSubscription // ignore: cast_nullable_to_non_nullable
as bool?,payoutWalletId: freezed == payoutWalletId ? _self.payoutWalletId : payoutWalletId // ignore: cast_nullable_to_non_nullable
as String?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,actorType: freezed == actorType ? _self.actorType : actorType // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,instanceId: freezed == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as SnActivityPubInstance?,instanceDomain: freezed == instanceDomain ? _self.instanceDomain : instanceDomain // ignore: cast_nullable_to_non_nullable
as String?,inboxUri: freezed == inboxUri ? _self.inboxUri : inboxUri // ignore: cast_nullable_to_non_nullable
as String?,outboxUri: freezed == outboxUri ? _self.outboxUri : outboxUri // ignore: cast_nullable_to_non_nullable
as String?,followersUri: freezed == followersUri ? _self.followersUri : followersUri // ignore: cast_nullable_to_non_nullable
as String?,followingUri: freezed == followingUri ? _self.followingUri : followingUri // ignore: cast_nullable_to_non_nullable
as String?,featuredUri: freezed == featuredUri ? _self.featuredUri : featuredUri // ignore: cast_nullable_to_non_nullable
as String?,publicKeyId: freezed == publicKeyId ? _self.publicKeyId : publicKeyId // ignore: cast_nullable_to_non_nullable
as String?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,headerUrl: freezed == headerUrl ? _self.headerUrl : headerUrl // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isDiscoverable: null == isDiscoverable ? _self.isDiscoverable : isDiscoverable // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outboxFetchedAt: freezed == outboxFetchedAt ? _self.outboxFetchedAt : outboxFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fullHandle: freezed == fullHandle ? _self.fullHandle : fullHandle // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,totalPostCount: freezed == totalPostCount ? _self.totalPostCount : totalPostCount // ignore: cast_nullable_to_non_nullable
as int?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<$Res>? get realmLabel {
    if (_self.realmLabel == null) {
    return null;
  }

  return $SnRealmLabelCopyWith<$Res>(_self.realmLabel!, (value) {
    return _then(_self.copyWith(realmLabel: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
    return null;
  }

  return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
    return _then(_self.copyWith(realm: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubInstanceCopyWith<$Res>? get instance {
    if (_self.instance == null) {
    return null;
  }

  return $SnActivityPubInstanceCopyWith<$Res>(_self.instance!, (value) {
    return _then(_self.copyWith(instance: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisher].
extension SnPublisherPatterns on SnPublisher {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisher value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisher value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisher():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisher value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  String name,  String nick,  String bio,  String? realmNick,  String? realmBio,  int? realmExperience,  int? realmLevel,  double? realmLevelingProgress,  SnRealmLabel? realmLabel,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnRealm? realm,  SnVerificationMark? verification,  bool isShadowbanned,  bool isGatekept,  bool isModerateSubscription,  double rating, @JsonKey(name: 'rating_level')  int ratingLevel,  int? shadowbanReason,  DateTime? shadowbannedAt,  bool? gatekeptFollows,  bool? moderateSubscription,  String? payoutWalletId,  String? uri,  String? actorType,  String? username,  String? displayName,  String? instanceId,  SnActivityPubInstance? instance,  String? instanceDomain,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? publicKeyId,  String? publicKey,  String? avatarUrl,  String? headerUrl,  bool isBot,  bool isLocked,  bool isDiscoverable,  bool isCommunity,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? outboxFetchedAt,  String? fullHandle,  String? webUrl,  int followersCount,  int followingCount,  int postCount,  int? totalPostCount,  Map<String, dynamic>? meta,  Map<String, dynamic>? metadata,  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.realmNick,_that.realmBio,_that.realmExperience,_that.realmLevel,_that.realmLevelingProgress,_that.realmLabel,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.realm,_that.verification,_that.isShadowbanned,_that.isGatekept,_that.isModerateSubscription,_that.rating,_that.ratingLevel,_that.shadowbanReason,_that.shadowbannedAt,_that.gatekeptFollows,_that.moderateSubscription,_that.payoutWalletId,_that.uri,_that.actorType,_that.username,_that.displayName,_that.instanceId,_that.instance,_that.instanceDomain,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.publicKeyId,_that.publicKey,_that.avatarUrl,_that.headerUrl,_that.isBot,_that.isLocked,_that.isDiscoverable,_that.isCommunity,_that.lastFetchedAt,_that.lastActivityAt,_that.outboxFetchedAt,_that.fullHandle,_that.webUrl,_that.followersCount,_that.followingCount,_that.postCount,_that.totalPostCount,_that.meta,_that.metadata,_that.isFollowing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  String name,  String nick,  String bio,  String? realmNick,  String? realmBio,  int? realmExperience,  int? realmLevel,  double? realmLevelingProgress,  SnRealmLabel? realmLabel,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnRealm? realm,  SnVerificationMark? verification,  bool isShadowbanned,  bool isGatekept,  bool isModerateSubscription,  double rating, @JsonKey(name: 'rating_level')  int ratingLevel,  int? shadowbanReason,  DateTime? shadowbannedAt,  bool? gatekeptFollows,  bool? moderateSubscription,  String? payoutWalletId,  String? uri,  String? actorType,  String? username,  String? displayName,  String? instanceId,  SnActivityPubInstance? instance,  String? instanceDomain,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? publicKeyId,  String? publicKey,  String? avatarUrl,  String? headerUrl,  bool isBot,  bool isLocked,  bool isDiscoverable,  bool isCommunity,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? outboxFetchedAt,  String? fullHandle,  String? webUrl,  int followersCount,  int followingCount,  int postCount,  int? totalPostCount,  Map<String, dynamic>? meta,  Map<String, dynamic>? metadata,  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _SnPublisher():
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.realmNick,_that.realmBio,_that.realmExperience,_that.realmLevel,_that.realmLevelingProgress,_that.realmLabel,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.realm,_that.verification,_that.isShadowbanned,_that.isGatekept,_that.isModerateSubscription,_that.rating,_that.ratingLevel,_that.shadowbanReason,_that.shadowbannedAt,_that.gatekeptFollows,_that.moderateSubscription,_that.payoutWalletId,_that.uri,_that.actorType,_that.username,_that.displayName,_that.instanceId,_that.instance,_that.instanceDomain,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.publicKeyId,_that.publicKey,_that.avatarUrl,_that.headerUrl,_that.isBot,_that.isLocked,_that.isDiscoverable,_that.isCommunity,_that.lastFetchedAt,_that.lastActivityAt,_that.outboxFetchedAt,_that.fullHandle,_that.webUrl,_that.followersCount,_that.followingCount,_that.postCount,_that.totalPostCount,_that.meta,_that.metadata,_that.isFollowing);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  String name,  String nick,  String bio,  String? realmNick,  String? realmBio,  int? realmExperience,  int? realmLevel,  double? realmLevelingProgress,  SnRealmLabel? realmLabel,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnRealm? realm,  SnVerificationMark? verification,  bool isShadowbanned,  bool isGatekept,  bool isModerateSubscription,  double rating, @JsonKey(name: 'rating_level')  int ratingLevel,  int? shadowbanReason,  DateTime? shadowbannedAt,  bool? gatekeptFollows,  bool? moderateSubscription,  String? payoutWalletId,  String? uri,  String? actorType,  String? username,  String? displayName,  String? instanceId,  SnActivityPubInstance? instance,  String? instanceDomain,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? publicKeyId,  String? publicKey,  String? avatarUrl,  String? headerUrl,  bool isBot,  bool isLocked,  bool isDiscoverable,  bool isCommunity,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? outboxFetchedAt,  String? fullHandle,  String? webUrl,  int followersCount,  int followingCount,  int postCount,  int? totalPostCount,  Map<String, dynamic>? meta,  Map<String, dynamic>? metadata,  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.realmNick,_that.realmBio,_that.realmExperience,_that.realmLevel,_that.realmLevelingProgress,_that.realmLabel,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.realm,_that.verification,_that.isShadowbanned,_that.isGatekept,_that.isModerateSubscription,_that.rating,_that.ratingLevel,_that.shadowbanReason,_that.shadowbannedAt,_that.gatekeptFollows,_that.moderateSubscription,_that.payoutWalletId,_that.uri,_that.actorType,_that.username,_that.displayName,_that.instanceId,_that.instance,_that.instanceDomain,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.publicKeyId,_that.publicKey,_that.avatarUrl,_that.headerUrl,_that.isBot,_that.isLocked,_that.isDiscoverable,_that.isCommunity,_that.lastFetchedAt,_that.lastActivityAt,_that.outboxFetchedAt,_that.fullHandle,_that.webUrl,_that.followersCount,_that.followingCount,_that.postCount,_that.totalPostCount,_that.meta,_that.metadata,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisher extends SnPublisher {
  const _SnPublisher({this.id = '', this.type = 0, this.name = '', this.nick = '', this.bio = '', this.realmNick, this.realmBio, this.realmExperience, this.realmLevel, this.realmLevelingProgress, this.realmLabel, this.picture, this.background, this.account, this.accountId, this.createdAt = null, this.updatedAt = null, this.deletedAt, this.realmId, this.realm, this.verification, this.isShadowbanned = false, this.isGatekept = false, this.isModerateSubscription = false, this.rating = 100.0, @JsonKey(name: 'rating_level') this.ratingLevel = 0, this.shadowbanReason, this.shadowbannedAt, this.gatekeptFollows, this.moderateSubscription, this.payoutWalletId, this.uri, this.actorType, this.username, this.displayName, this.instanceId, this.instance, this.instanceDomain, this.inboxUri, this.outboxUri, this.followersUri, this.followingUri, this.featuredUri, this.publicKeyId, this.publicKey, this.avatarUrl, this.headerUrl, this.isBot = false, this.isLocked = false, this.isDiscoverable = true, this.isCommunity = false, this.lastFetchedAt, this.lastActivityAt, this.outboxFetchedAt, this.fullHandle, this.webUrl, this.followersCount = 0, this.followingCount = 0, this.postCount = 0, this.totalPostCount,  Map<String, dynamic>? meta,  Map<String, dynamic>? metadata, this.isFollowing = false}): _meta = meta,_metadata = metadata,super._();
  factory _SnPublisher.fromJson(Map<String, dynamic> json) => _$SnPublisherFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  int type;
@override@JsonKey() final  String name;
@override@JsonKey() final  String nick;
@override@JsonKey() final  String bio;
@override final  String? realmNick;
@override final  String? realmBio;
@override final  int? realmExperience;
@override final  int? realmLevel;
@override final  double? realmLevelingProgress;
@override final  SnRealmLabel? realmLabel;
@override final  SnCloudFileReference? picture;
@override final  SnCloudFileReference? background;
@override final  SnAccount? account;
@override final  String? accountId;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;
@override final  DateTime? deletedAt;
@override final  String? realmId;
@override final  SnRealm? realm;
@override final  SnVerificationMark? verification;
@override@JsonKey() final  bool isShadowbanned;
@override@JsonKey() final  bool isGatekept;
@override@JsonKey() final  bool isModerateSubscription;
@override@JsonKey() final  double rating;
@override@JsonKey(name: 'rating_level') final  int ratingLevel;
@override final  int? shadowbanReason;
@override final  DateTime? shadowbannedAt;
@override final  bool? gatekeptFollows;
@override final  bool? moderateSubscription;
@override final  String? payoutWalletId;
@override final  String? uri;
@override final  String? actorType;
@override final  String? username;
@override final  String? displayName;
@override final  String? instanceId;
@override final  SnActivityPubInstance? instance;
@override final  String? instanceDomain;
@override final  String? inboxUri;
@override final  String? outboxUri;
@override final  String? followersUri;
@override final  String? followingUri;
@override final  String? featuredUri;
@override final  String? publicKeyId;
@override final  String? publicKey;
@override final  String? avatarUrl;
@override final  String? headerUrl;
@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool isLocked;
@override@JsonKey() final  bool isDiscoverable;
@override@JsonKey() final  bool isCommunity;
@override final  DateTime? lastFetchedAt;
@override final  DateTime? lastActivityAt;
@override final  DateTime? outboxFetchedAt;
@override final  String? fullHandle;
@override final  String? webUrl;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  int postCount;
@override final  int? totalPostCount;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  bool isFollowing;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherCopyWith<_SnPublisher> get copyWith => __$SnPublisherCopyWithImpl<_SnPublisher>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.realmNick, realmNick) || other.realmNick == realmNick)&&(identical(other.realmBio, realmBio) || other.realmBio == realmBio)&&(identical(other.realmExperience, realmExperience) || other.realmExperience == realmExperience)&&(identical(other.realmLevel, realmLevel) || other.realmLevel == realmLevel)&&(identical(other.realmLevelingProgress, realmLevelingProgress) || other.realmLevelingProgress == realmLevelingProgress)&&(identical(other.realmLabel, realmLabel) || other.realmLabel == realmLabel)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.isShadowbanned, isShadowbanned) || other.isShadowbanned == isShadowbanned)&&(identical(other.isGatekept, isGatekept) || other.isGatekept == isGatekept)&&(identical(other.isModerateSubscription, isModerateSubscription) || other.isModerateSubscription == isModerateSubscription)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingLevel, ratingLevel) || other.ratingLevel == ratingLevel)&&(identical(other.shadowbanReason, shadowbanReason) || other.shadowbanReason == shadowbanReason)&&(identical(other.shadowbannedAt, shadowbannedAt) || other.shadowbannedAt == shadowbannedAt)&&(identical(other.gatekeptFollows, gatekeptFollows) || other.gatekeptFollows == gatekeptFollows)&&(identical(other.moderateSubscription, moderateSubscription) || other.moderateSubscription == moderateSubscription)&&(identical(other.payoutWalletId, payoutWalletId) || other.payoutWalletId == payoutWalletId)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.actorType, actorType) || other.actorType == actorType)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.instanceDomain, instanceDomain) || other.instanceDomain == instanceDomain)&&(identical(other.inboxUri, inboxUri) || other.inboxUri == inboxUri)&&(identical(other.outboxUri, outboxUri) || other.outboxUri == outboxUri)&&(identical(other.followersUri, followersUri) || other.followersUri == followersUri)&&(identical(other.followingUri, followingUri) || other.followingUri == followingUri)&&(identical(other.featuredUri, featuredUri) || other.featuredUri == featuredUri)&&(identical(other.publicKeyId, publicKeyId) || other.publicKeyId == publicKeyId)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.headerUrl, headerUrl) || other.headerUrl == headerUrl)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isDiscoverable, isDiscoverable) || other.isDiscoverable == isDiscoverable)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.outboxFetchedAt, outboxFetchedAt) || other.outboxFetchedAt == outboxFetchedAt)&&(identical(other.fullHandle, fullHandle) || other.fullHandle == fullHandle)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.totalPostCount, totalPostCount) || other.totalPostCount == totalPostCount)&&const DeepCollectionEquality().equals(other.meta, _meta)&&const DeepCollectionEquality().equals(other.metadata, _metadata)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,type,name,nick,bio,realmNick,realmBio,realmExperience,realmLevel,realmLevelingProgress,realmLabel,picture,background,account,accountId,createdAt,updatedAt,deletedAt,realmId,realm,verification,isShadowbanned,isGatekept,isModerateSubscription,rating,ratingLevel,shadowbanReason,shadowbannedAt,gatekeptFollows,moderateSubscription,payoutWalletId,uri,actorType,username,displayName,instanceId,instance,instanceDomain,inboxUri,outboxUri,followersUri,followingUri,featuredUri,publicKeyId,publicKey,avatarUrl,headerUrl,isBot,isLocked,isDiscoverable,isCommunity,lastFetchedAt,lastActivityAt,outboxFetchedAt,fullHandle,webUrl,followersCount,followingCount,postCount,totalPostCount,const DeepCollectionEquality().hash(_meta),const DeepCollectionEquality().hash(_metadata),isFollowing]);
}

@override
String toString() {
    return 'SnPublisher(id: $id, type: $type, name: $name, nick: $nick, bio: $bio, realmNick: $realmNick, realmBio: $realmBio, realmExperience: $realmExperience, realmLevel: $realmLevel, realmLevelingProgress: $realmLevelingProgress, realmLabel: $realmLabel, picture: $picture, background: $background, account: $account, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, realm: $realm, verification: $verification, isShadowbanned: $isShadowbanned, isGatekept: $isGatekept, isModerateSubscription: $isModerateSubscription, rating: $rating, ratingLevel: $ratingLevel, shadowbanReason: $shadowbanReason, shadowbannedAt: $shadowbannedAt, gatekeptFollows: $gatekeptFollows, moderateSubscription: $moderateSubscription, payoutWalletId: $payoutWalletId, uri: $uri, actorType: $actorType, username: $username, displayName: $displayName, instanceId: $instanceId, instance: $instance, instanceDomain: $instanceDomain, inboxUri: $inboxUri, outboxUri: $outboxUri, followersUri: $followersUri, followingUri: $followingUri, featuredUri: $featuredUri, publicKeyId: $publicKeyId, publicKey: $publicKey, avatarUrl: $avatarUrl, headerUrl: $headerUrl, isBot: $isBot, isLocked: $isLocked, isDiscoverable: $isDiscoverable, isCommunity: $isCommunity, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt, outboxFetchedAt: $outboxFetchedAt, fullHandle: $fullHandle, webUrl: $webUrl, followersCount: $followersCount, followingCount: $followingCount, postCount: $postCount, totalPostCount: $totalPostCount, meta: $meta, metadata: $metadata, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherCopyWith<$Res> implements $SnPublisherCopyWith<$Res> {
  factory _$SnPublisherCopyWith(_SnPublisher value, $Res Function(_SnPublisher) _then) = __$SnPublisherCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, String name, String nick, String bio, String? realmNick, String? realmBio, int? realmExperience, int? realmLevel, double? realmLevelingProgress, SnRealmLabel? realmLabel, SnCloudFileReference? picture, SnCloudFileReference? background, SnAccount? account, String? accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? realmId, SnRealm? realm, SnVerificationMark? verification, bool isShadowbanned, bool isGatekept, bool isModerateSubscription, double rating,@JsonKey(name: 'rating_level') int ratingLevel, int? shadowbanReason, DateTime? shadowbannedAt, bool? gatekeptFollows, bool? moderateSubscription, String? payoutWalletId, String? uri, String? actorType, String? username, String? displayName, String? instanceId, SnActivityPubInstance? instance, String? instanceDomain, String? inboxUri, String? outboxUri, String? followersUri, String? followingUri, String? featuredUri, String? publicKeyId, String? publicKey, String? avatarUrl, String? headerUrl, bool isBot, bool isLocked, bool isDiscoverable, bool isCommunity, DateTime? lastFetchedAt, DateTime? lastActivityAt, DateTime? outboxFetchedAt, String? fullHandle, String? webUrl, int followersCount, int followingCount, int postCount, int? totalPostCount, Map<String, dynamic>? meta, Map<String, dynamic>? metadata, bool isFollowing
});


@override $SnRealmLabelCopyWith<$Res>? get realmLabel;@override $SnCloudFileReferenceCopyWith<$Res>? get picture;@override $SnCloudFileReferenceCopyWith<$Res>? get background;@override $SnAccountCopyWith<$Res>? get account;@override $SnRealmCopyWith<$Res>? get realm;@override $SnVerificationMarkCopyWith<$Res>? get verification;@override $SnActivityPubInstanceCopyWith<$Res>? get instance;

}
/// @nodoc
class __$SnPublisherCopyWithImpl<$Res>
    implements _$SnPublisherCopyWith<$Res> {
  __$SnPublisherCopyWithImpl(this._self, this._then);

  final _SnPublisher _self;
  final $Res Function(_SnPublisher) _then;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? nick = null,Object? bio = null,Object? realmNick = freezed,Object? realmBio = freezed,Object? realmExperience = freezed,Object? realmLevel = freezed,Object? realmLevelingProgress = freezed,Object? realmLabel = freezed,Object? picture = freezed,Object? background = freezed,Object? account = freezed,Object? accountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? realmId = freezed,Object? realm = freezed,Object? verification = freezed,Object? isShadowbanned = null,Object? isGatekept = null,Object? isModerateSubscription = null,Object? rating = null,Object? ratingLevel = null,Object? shadowbanReason = freezed,Object? shadowbannedAt = freezed,Object? gatekeptFollows = freezed,Object? moderateSubscription = freezed,Object? payoutWalletId = freezed,Object? uri = freezed,Object? actorType = freezed,Object? username = freezed,Object? displayName = freezed,Object? instanceId = freezed,Object? instance = freezed,Object? instanceDomain = freezed,Object? inboxUri = freezed,Object? outboxUri = freezed,Object? followersUri = freezed,Object? followingUri = freezed,Object? featuredUri = freezed,Object? publicKeyId = freezed,Object? publicKey = freezed,Object? avatarUrl = freezed,Object? headerUrl = freezed,Object? isBot = null,Object? isLocked = null,Object? isDiscoverable = null,Object? isCommunity = null,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? outboxFetchedAt = freezed,Object? fullHandle = freezed,Object? webUrl = freezed,Object? followersCount = null,Object? followingCount = null,Object? postCount = null,Object? totalPostCount = freezed,Object? meta = freezed,Object? metadata = freezed,Object? isFollowing = null,}) {
  return _then(_SnPublisher(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,realmNick: freezed == realmNick ? _self.realmNick : realmNick // ignore: cast_nullable_to_non_nullable
as String?,realmBio: freezed == realmBio ? _self.realmBio : realmBio // ignore: cast_nullable_to_non_nullable
as String?,realmExperience: freezed == realmExperience ? _self.realmExperience : realmExperience // ignore: cast_nullable_to_non_nullable
as int?,realmLevel: freezed == realmLevel ? _self.realmLevel : realmLevel // ignore: cast_nullable_to_non_nullable
as int?,realmLevelingProgress: freezed == realmLevelingProgress ? _self.realmLevelingProgress : realmLevelingProgress // ignore: cast_nullable_to_non_nullable
as double?,realmLabel: freezed == realmLabel ? _self.realmLabel : realmLabel // ignore: cast_nullable_to_non_nullable
as SnRealmLabel?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,isShadowbanned: null == isShadowbanned ? _self.isShadowbanned : isShadowbanned // ignore: cast_nullable_to_non_nullable
as bool,isGatekept: null == isGatekept ? _self.isGatekept : isGatekept // ignore: cast_nullable_to_non_nullable
as bool,isModerateSubscription: null == isModerateSubscription ? _self.isModerateSubscription : isModerateSubscription // ignore: cast_nullable_to_non_nullable
as bool,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingLevel: null == ratingLevel ? _self.ratingLevel : ratingLevel // ignore: cast_nullable_to_non_nullable
as int,shadowbanReason: freezed == shadowbanReason ? _self.shadowbanReason : shadowbanReason // ignore: cast_nullable_to_non_nullable
as int?,shadowbannedAt: freezed == shadowbannedAt ? _self.shadowbannedAt : shadowbannedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gatekeptFollows: freezed == gatekeptFollows ? _self.gatekeptFollows : gatekeptFollows // ignore: cast_nullable_to_non_nullable
as bool?,moderateSubscription: freezed == moderateSubscription ? _self.moderateSubscription : moderateSubscription // ignore: cast_nullable_to_non_nullable
as bool?,payoutWalletId: freezed == payoutWalletId ? _self.payoutWalletId : payoutWalletId // ignore: cast_nullable_to_non_nullable
as String?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,actorType: freezed == actorType ? _self.actorType : actorType // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,instanceId: freezed == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as SnActivityPubInstance?,instanceDomain: freezed == instanceDomain ? _self.instanceDomain : instanceDomain // ignore: cast_nullable_to_non_nullable
as String?,inboxUri: freezed == inboxUri ? _self.inboxUri : inboxUri // ignore: cast_nullable_to_non_nullable
as String?,outboxUri: freezed == outboxUri ? _self.outboxUri : outboxUri // ignore: cast_nullable_to_non_nullable
as String?,followersUri: freezed == followersUri ? _self.followersUri : followersUri // ignore: cast_nullable_to_non_nullable
as String?,followingUri: freezed == followingUri ? _self.followingUri : followingUri // ignore: cast_nullable_to_non_nullable
as String?,featuredUri: freezed == featuredUri ? _self.featuredUri : featuredUri // ignore: cast_nullable_to_non_nullable
as String?,publicKeyId: freezed == publicKeyId ? _self.publicKeyId : publicKeyId // ignore: cast_nullable_to_non_nullable
as String?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,headerUrl: freezed == headerUrl ? _self.headerUrl : headerUrl // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isDiscoverable: null == isDiscoverable ? _self.isDiscoverable : isDiscoverable // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outboxFetchedAt: freezed == outboxFetchedAt ? _self.outboxFetchedAt : outboxFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fullHandle: freezed == fullHandle ? _self.fullHandle : fullHandle // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,totalPostCount: freezed == totalPostCount ? _self.totalPostCount : totalPostCount // ignore: cast_nullable_to_non_nullable
as int?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<$Res>? get realmLabel {
    if (_self.realmLabel == null) {
    return null;
  }

  return $SnRealmLabelCopyWith<$Res>(_self.realmLabel!, (value) {
    return _then(_self.copyWith(realmLabel: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
    return null;
  }

  return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
    return _then(_self.copyWith(realm: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubInstanceCopyWith<$Res>? get instance {
    if (_self.instance == null) {
    return null;
  }

  return $SnActivityPubInstanceCopyWith<$Res>(_self.instance!, (value) {
    return _then(_self.copyWith(instance: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherMember {

 String get publisherId; SnPublisher? get publisher; String get accountId; SnAccount? get account; int get role; DateTime? get joinedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherMemberCopyWith<SnPublisherMember> get copyWith => _$SnPublisherMemberCopyWithImpl<SnPublisherMember>(this as SnPublisherMember, _$identity);

  /// Serializes this SnPublisherMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherMember&&(identical(other.publisherId, _this.publisherId) || other.publisherId == _this.publisherId)&&(identical(other.publisher, _this.publisher) || other.publisher == _this.publisher)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherMember;
  return Object.hash(runtimeType,_this.publisherId,_this.publisher,_this.accountId,_this.account,_this.role,_this.joinedAt,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnPublisherMember;
  return 'SnPublisherMember(publisherId: ${_this.publisherId}, publisher: ${_this.publisher}, accountId: ${_this.accountId}, account: ${_this.account}, role: ${_this.role}, joinedAt: ${_this.joinedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $SnPublisherMemberCopyWith<$Res>  {
  factory $SnPublisherMemberCopyWith(SnPublisherMember value, $Res Function(SnPublisherMember) _then) = _$SnPublisherMemberCopyWithImpl;
@useResult
$Res call({
 String publisherId, SnPublisher? publisher, String accountId, SnAccount? account, int role, DateTime? joinedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnPublisherCopyWith<$Res>? get publisher;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPublisherMemberCopyWithImpl<$Res>
    implements $SnPublisherMemberCopyWith<$Res> {
  _$SnPublisherMemberCopyWithImpl(this._self, this._then);

  final SnPublisherMember _self;
  final $Res Function(SnPublisherMember) _then;

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publisherId = null,Object? publisher = freezed,Object? accountId = null,Object? account = freezed,Object? role = null,Object? joinedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(SnPublisherMember(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherMember].
extension SnPublisherMemberPatterns on SnPublisherMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherMember value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherMember():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherMember value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String publisherId,  SnPublisher? publisher,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
return $default(_that.publisherId,_that.publisher,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String publisherId,  SnPublisher? publisher,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherMember():
return $default(_that.publisherId,_that.publisher,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String publisherId,  SnPublisher? publisher,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
return $default(_that.publisherId,_that.publisher,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherMember implements SnPublisherMember {
  const _SnPublisherMember({required this.publisherId, required this.publisher, required this.accountId, required this.account, required this.role, required this.joinedAt, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnPublisherMember.fromJson(Map<String, dynamic> json) => _$SnPublisherMemberFromJson(json);

@override final  String publisherId;
@override final  SnPublisher? publisher;
@override final  String accountId;
@override final  SnAccount? account;
@override final  int role;
@override final  DateTime? joinedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherMemberCopyWith<_SnPublisherMember> get copyWith => __$SnPublisherMemberCopyWithImpl<_SnPublisherMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherMember&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,publisherId,publisher,accountId,account,role,joinedAt,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'SnPublisherMember(publisherId: $publisherId, publisher: $publisher, accountId: $accountId, account: $account, role: $role, joinedAt: $joinedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherMemberCopyWith<$Res> implements $SnPublisherMemberCopyWith<$Res> {
  factory _$SnPublisherMemberCopyWith(_SnPublisherMember value, $Res Function(_SnPublisherMember) _then) = __$SnPublisherMemberCopyWithImpl;
@override @useResult
$Res call({
 String publisherId, SnPublisher? publisher, String accountId, SnAccount? account, int role, DateTime? joinedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnPublisherCopyWith<$Res>? get publisher;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPublisherMemberCopyWithImpl<$Res>
    implements _$SnPublisherMemberCopyWith<$Res> {
  __$SnPublisherMemberCopyWithImpl(this._self, this._then);

  final _SnPublisherMember _self;
  final $Res Function(_SnPublisherMember) _then;

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publisherId = null,Object? publisher = freezed,Object? accountId = null,Object? account = freezed,Object? role = null,Object? joinedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPublisherMember(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherSubscription {

 String get id; String? get accountId; String? get followerPublisherId; SnPublisher? get followerPublisher; String get publisherId; SnPublisher? get publisher; PublisherSubscriptionState get state; DateTime? get followedAt; DateTime? get reviewedAt; String? get reviewedByAccountId; String? get rejectReason; bool get isMuting; bool get isBlocking; bool get notify; DateTime? get lastReadAt; String? get realmId; SnAccount? get account; DateTime? get endedAt; SubscriptionEndReason? get endReason; String? get endedByAccountId; bool get isActive; bool get isPending; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<SnPublisherSubscription> get copyWith => _$SnPublisherSubscriptionCopyWithImpl<SnPublisherSubscription>(this as SnPublisherSubscription, _$identity);

  /// Serializes this SnPublisherSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherSubscription;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscription&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.followerPublisherId, _this.followerPublisherId) || other.followerPublisherId == _this.followerPublisherId)&&(identical(other.followerPublisher, _this.followerPublisher) || other.followerPublisher == _this.followerPublisher)&&(identical(other.publisherId, _this.publisherId) || other.publisherId == _this.publisherId)&&(identical(other.publisher, _this.publisher) || other.publisher == _this.publisher)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.followedAt, _this.followedAt) || other.followedAt == _this.followedAt)&&(identical(other.reviewedAt, _this.reviewedAt) || other.reviewedAt == _this.reviewedAt)&&(identical(other.reviewedByAccountId, _this.reviewedByAccountId) || other.reviewedByAccountId == _this.reviewedByAccountId)&&(identical(other.rejectReason, _this.rejectReason) || other.rejectReason == _this.rejectReason)&&(identical(other.isMuting, _this.isMuting) || other.isMuting == _this.isMuting)&&(identical(other.isBlocking, _this.isBlocking) || other.isBlocking == _this.isBlocking)&&(identical(other.notify, _this.notify) || other.notify == _this.notify)&&(identical(other.lastReadAt, _this.lastReadAt) || other.lastReadAt == _this.lastReadAt)&&(identical(other.realmId, _this.realmId) || other.realmId == _this.realmId)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.endReason, _this.endReason) || other.endReason == _this.endReason)&&(identical(other.endedByAccountId, _this.endedByAccountId) || other.endedByAccountId == _this.endedByAccountId)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.isPending, _this.isPending) || other.isPending == _this.isPending)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherSubscription;
  return Object.hashAll([runtimeType,_this.id,_this.accountId,_this.followerPublisherId,_this.followerPublisher,_this.publisherId,_this.publisher,_this.state,_this.followedAt,_this.reviewedAt,_this.reviewedByAccountId,_this.rejectReason,_this.isMuting,_this.isBlocking,_this.notify,_this.lastReadAt,_this.realmId,_this.account,_this.endedAt,_this.endReason,_this.endedByAccountId,_this.isActive,_this.isPending,_this.createdAt,_this.updatedAt,_this.deletedAt]);
}

@override
String toString() {
  final _this = this as SnPublisherSubscription;
  return 'SnPublisherSubscription(id: ${_this.id}, accountId: ${_this.accountId}, followerPublisherId: ${_this.followerPublisherId}, followerPublisher: ${_this.followerPublisher}, publisherId: ${_this.publisherId}, publisher: ${_this.publisher}, state: ${_this.state}, followedAt: ${_this.followedAt}, reviewedAt: ${_this.reviewedAt}, reviewedByAccountId: ${_this.reviewedByAccountId}, rejectReason: ${_this.rejectReason}, isMuting: ${_this.isMuting}, isBlocking: ${_this.isBlocking}, notify: ${_this.notify}, lastReadAt: ${_this.lastReadAt}, realmId: ${_this.realmId}, account: ${_this.account}, endedAt: ${_this.endedAt}, endReason: ${_this.endReason}, endedByAccountId: ${_this.endedByAccountId}, isActive: ${_this.isActive}, isPending: ${_this.isPending}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriptionCopyWith<$Res>  {
  factory $SnPublisherSubscriptionCopyWith(SnPublisherSubscription value, $Res Function(SnPublisherSubscription) _then) = _$SnPublisherSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String? accountId, String? followerPublisherId, SnPublisher? followerPublisher, String publisherId, SnPublisher? publisher, PublisherSubscriptionState state, DateTime? followedAt, DateTime? reviewedAt, String? reviewedByAccountId, String? rejectReason, bool isMuting, bool isBlocking, bool notify, DateTime? lastReadAt, String? realmId, SnAccount? account, DateTime? endedAt, SubscriptionEndReason? endReason, String? endedByAccountId, bool isActive, bool isPending, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnPublisherCopyWith<$Res>? get followerPublisher;$SnPublisherCopyWith<$Res>? get publisher;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPublisherSubscriptionCopyWithImpl<$Res>
    implements $SnPublisherSubscriptionCopyWith<$Res> {
  _$SnPublisherSubscriptionCopyWithImpl(this._self, this._then);

  final SnPublisherSubscription _self;
  final $Res Function(SnPublisherSubscription) _then;

/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = freezed,Object? followerPublisherId = freezed,Object? followerPublisher = freezed,Object? publisherId = null,Object? publisher = freezed,Object? state = null,Object? followedAt = freezed,Object? reviewedAt = freezed,Object? reviewedByAccountId = freezed,Object? rejectReason = freezed,Object? isMuting = null,Object? isBlocking = null,Object? notify = null,Object? lastReadAt = freezed,Object? realmId = freezed,Object? account = freezed,Object? endedAt = freezed,Object? endReason = freezed,Object? endedByAccountId = freezed,Object? isActive = null,Object? isPending = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(SnPublisherSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,followerPublisherId: freezed == followerPublisherId ? _self.followerPublisherId : followerPublisherId // ignore: cast_nullable_to_non_nullable
as String?,followerPublisher: freezed == followerPublisher ? _self.followerPublisher : followerPublisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as PublisherSubscriptionState,followedAt: freezed == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByAccountId: freezed == reviewedByAccountId ? _self.reviewedByAccountId : reviewedByAccountId // ignore: cast_nullable_to_non_nullable
as String?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,isMuting: null == isMuting ? _self.isMuting : isMuting // ignore: cast_nullable_to_non_nullable
as bool,isBlocking: null == isBlocking ? _self.isBlocking : isBlocking // ignore: cast_nullable_to_non_nullable
as bool,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as bool,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as SubscriptionEndReason?,endedByAccountId: freezed == endedByAccountId ? _self.endedByAccountId : endedByAccountId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get followerPublisher {
    if (_self.followerPublisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.followerPublisher!, (value) {
    return _then(_self.copyWith(followerPublisher: value));
  });
}/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscription].
extension SnPublisherSubscriptionPatterns on SnPublisherSubscription {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscription() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscription value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscription():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscription() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? accountId,  String? followerPublisherId,  SnPublisher? followerPublisher,  String publisherId,  SnPublisher? publisher,  PublisherSubscriptionState state,  DateTime? followedAt,  DateTime? reviewedAt,  String? reviewedByAccountId,  String? rejectReason,  bool isMuting,  bool isBlocking,  bool notify,  DateTime? lastReadAt,  String? realmId,  SnAccount? account,  DateTime? endedAt,  SubscriptionEndReason? endReason,  String? endedByAccountId,  bool isActive,  bool isPending,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.followerPublisherId,_that.followerPublisher,_that.publisherId,_that.publisher,_that.state,_that.followedAt,_that.reviewedAt,_that.reviewedByAccountId,_that.rejectReason,_that.isMuting,_that.isBlocking,_that.notify,_that.lastReadAt,_that.realmId,_that.account,_that.endedAt,_that.endReason,_that.endedByAccountId,_that.isActive,_that.isPending,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? accountId,  String? followerPublisherId,  SnPublisher? followerPublisher,  String publisherId,  SnPublisher? publisher,  PublisherSubscriptionState state,  DateTime? followedAt,  DateTime? reviewedAt,  String? reviewedByAccountId,  String? rejectReason,  bool isMuting,  bool isBlocking,  bool notify,  DateTime? lastReadAt,  String? realmId,  SnAccount? account,  DateTime? endedAt,  SubscriptionEndReason? endReason,  String? endedByAccountId,  bool isActive,  bool isPending,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscription():
return $default(_that.id,_that.accountId,_that.followerPublisherId,_that.followerPublisher,_that.publisherId,_that.publisher,_that.state,_that.followedAt,_that.reviewedAt,_that.reviewedByAccountId,_that.rejectReason,_that.isMuting,_that.isBlocking,_that.notify,_that.lastReadAt,_that.realmId,_that.account,_that.endedAt,_that.endReason,_that.endedByAccountId,_that.isActive,_that.isPending,_that.createdAt,_that.updatedAt,_that.deletedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? accountId,  String? followerPublisherId,  SnPublisher? followerPublisher,  String publisherId,  SnPublisher? publisher,  PublisherSubscriptionState state,  DateTime? followedAt,  DateTime? reviewedAt,  String? reviewedByAccountId,  String? rejectReason,  bool isMuting,  bool isBlocking,  bool notify,  DateTime? lastReadAt,  String? realmId,  SnAccount? account,  DateTime? endedAt,  SubscriptionEndReason? endReason,  String? endedByAccountId,  bool isActive,  bool isPending,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.followerPublisherId,_that.followerPublisher,_that.publisherId,_that.publisher,_that.state,_that.followedAt,_that.reviewedAt,_that.reviewedByAccountId,_that.rejectReason,_that.isMuting,_that.isBlocking,_that.notify,_that.lastReadAt,_that.realmId,_that.account,_that.endedAt,_that.endReason,_that.endedByAccountId,_that.isActive,_that.isPending,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscription extends SnPublisherSubscription {
  const _SnPublisherSubscription({required this.id, this.accountId, this.followerPublisherId, this.followerPublisher, required this.publisherId, this.publisher, this.state = PublisherSubscriptionState.accepted, this.followedAt, this.reviewedAt, this.reviewedByAccountId, this.rejectReason, this.isMuting = false, this.isBlocking = false, this.notify = true, this.lastReadAt, this.realmId, this.account, this.endedAt, this.endReason, this.endedByAccountId, this.isActive = true, this.isPending = false, required this.createdAt, required this.updatedAt, this.deletedAt}): super._();
  factory _SnPublisherSubscription.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriptionFromJson(json);

@override final  String id;
@override final  String? accountId;
@override final  String? followerPublisherId;
@override final  SnPublisher? followerPublisher;
@override final  String publisherId;
@override final  SnPublisher? publisher;
@override@JsonKey() final  PublisherSubscriptionState state;
@override final  DateTime? followedAt;
@override final  DateTime? reviewedAt;
@override final  String? reviewedByAccountId;
@override final  String? rejectReason;
@override@JsonKey() final  bool isMuting;
@override@JsonKey() final  bool isBlocking;
@override@JsonKey() final  bool notify;
@override final  DateTime? lastReadAt;
@override final  String? realmId;
@override final  SnAccount? account;
@override final  DateTime? endedAt;
@override final  SubscriptionEndReason? endReason;
@override final  String? endedByAccountId;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isPending;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriptionCopyWith<_SnPublisherSubscription> get copyWith => __$SnPublisherSubscriptionCopyWithImpl<_SnPublisherSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.followerPublisherId, followerPublisherId) || other.followerPublisherId == followerPublisherId)&&(identical(other.followerPublisher, followerPublisher) || other.followerPublisher == followerPublisher)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.state, state) || other.state == state)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByAccountId, reviewedByAccountId) || other.reviewedByAccountId == reviewedByAccountId)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.isMuting, isMuting) || other.isMuting == isMuting)&&(identical(other.isBlocking, isBlocking) || other.isBlocking == isBlocking)&&(identical(other.notify, notify) || other.notify == notify)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.account, account) || other.account == account)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&(identical(other.endedByAccountId, endedByAccountId) || other.endedByAccountId == endedByAccountId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,accountId,followerPublisherId,followerPublisher,publisherId,publisher,state,followedAt,reviewedAt,reviewedByAccountId,rejectReason,isMuting,isBlocking,notify,lastReadAt,realmId,account,endedAt,endReason,endedByAccountId,isActive,isPending,createdAt,updatedAt,deletedAt]);
}

@override
String toString() {
    return 'SnPublisherSubscription(id: $id, accountId: $accountId, followerPublisherId: $followerPublisherId, followerPublisher: $followerPublisher, publisherId: $publisherId, publisher: $publisher, state: $state, followedAt: $followedAt, reviewedAt: $reviewedAt, reviewedByAccountId: $reviewedByAccountId, rejectReason: $rejectReason, isMuting: $isMuting, isBlocking: $isBlocking, notify: $notify, lastReadAt: $lastReadAt, realmId: $realmId, account: $account, endedAt: $endedAt, endReason: $endReason, endedByAccountId: $endedByAccountId, isActive: $isActive, isPending: $isPending, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriptionCopyWith<$Res> implements $SnPublisherSubscriptionCopyWith<$Res> {
  factory _$SnPublisherSubscriptionCopyWith(_SnPublisherSubscription value, $Res Function(_SnPublisherSubscription) _then) = __$SnPublisherSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? accountId, String? followerPublisherId, SnPublisher? followerPublisher, String publisherId, SnPublisher? publisher, PublisherSubscriptionState state, DateTime? followedAt, DateTime? reviewedAt, String? reviewedByAccountId, String? rejectReason, bool isMuting, bool isBlocking, bool notify, DateTime? lastReadAt, String? realmId, SnAccount? account, DateTime? endedAt, SubscriptionEndReason? endReason, String? endedByAccountId, bool isActive, bool isPending, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnPublisherCopyWith<$Res>? get followerPublisher;@override $SnPublisherCopyWith<$Res>? get publisher;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPublisherSubscriptionCopyWithImpl<$Res>
    implements _$SnPublisherSubscriptionCopyWith<$Res> {
  __$SnPublisherSubscriptionCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscription _self;
  final $Res Function(_SnPublisherSubscription) _then;

/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = freezed,Object? followerPublisherId = freezed,Object? followerPublisher = freezed,Object? publisherId = null,Object? publisher = freezed,Object? state = null,Object? followedAt = freezed,Object? reviewedAt = freezed,Object? reviewedByAccountId = freezed,Object? rejectReason = freezed,Object? isMuting = null,Object? isBlocking = null,Object? notify = null,Object? lastReadAt = freezed,Object? realmId = freezed,Object? account = freezed,Object? endedAt = freezed,Object? endReason = freezed,Object? endedByAccountId = freezed,Object? isActive = null,Object? isPending = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPublisherSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,followerPublisherId: freezed == followerPublisherId ? _self.followerPublisherId : followerPublisherId // ignore: cast_nullable_to_non_nullable
as String?,followerPublisher: freezed == followerPublisher ? _self.followerPublisher : followerPublisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as PublisherSubscriptionState,followedAt: freezed == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByAccountId: freezed == reviewedByAccountId ? _self.reviewedByAccountId : reviewedByAccountId // ignore: cast_nullable_to_non_nullable
as String?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,isMuting: null == isMuting ? _self.isMuting : isMuting // ignore: cast_nullable_to_non_nullable
as bool,isBlocking: null == isBlocking ? _self.isBlocking : isBlocking // ignore: cast_nullable_to_non_nullable
as bool,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as bool,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as SubscriptionEndReason?,endedByAccountId: freezed == endedByAccountId ? _self.endedByAccountId : endedByAccountId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get followerPublisher {
    if (_self.followerPublisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.followerPublisher!, (value) {
    return _then(_self.copyWith(followerPublisher: value));
  });
}/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPublisherSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherSubscriptionStatus {

 SnPublisherSubscription? get subscription; SnPublisherSubscription? get followRequest; bool get requiresApproval; String get status; String get message; bool get isPending; bool get isActive; bool get notify;
/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionStatusCopyWith<SnPublisherSubscriptionStatus> get copyWith => _$SnPublisherSubscriptionStatusCopyWithImpl<SnPublisherSubscriptionStatus>(this as SnPublisherSubscriptionStatus, _$identity);

  /// Serializes this SnPublisherSubscriptionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherSubscriptionStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscriptionStatus&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.followRequest, _this.followRequest) || other.followRequest == _this.followRequest)&&(identical(other.requiresApproval, _this.requiresApproval) || other.requiresApproval == _this.requiresApproval)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.isPending, _this.isPending) || other.isPending == _this.isPending)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.notify, _this.notify) || other.notify == _this.notify));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherSubscriptionStatus;
  return Object.hash(runtimeType,_this.subscription,_this.followRequest,_this.requiresApproval,_this.status,_this.message,_this.isPending,_this.isActive,_this.notify);
}

@override
String toString() {
  final _this = this as SnPublisherSubscriptionStatus;
  return 'SnPublisherSubscriptionStatus(subscription: ${_this.subscription}, followRequest: ${_this.followRequest}, requiresApproval: ${_this.requiresApproval}, status: ${_this.status}, message: ${_this.message}, isPending: ${_this.isPending}, isActive: ${_this.isActive}, notify: ${_this.notify})';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriptionStatusCopyWith<$Res>  {
  factory $SnPublisherSubscriptionStatusCopyWith(SnPublisherSubscriptionStatus value, $Res Function(SnPublisherSubscriptionStatus) _then) = _$SnPublisherSubscriptionStatusCopyWithImpl;
@useResult
$Res call({
 SnPublisherSubscription? subscription, SnPublisherSubscription? followRequest, bool requiresApproval, String status, String message, bool isPending, bool isActive, bool notify
});


$SnPublisherSubscriptionCopyWith<$Res>? get subscription;$SnPublisherSubscriptionCopyWith<$Res>? get followRequest;

}
/// @nodoc
class _$SnPublisherSubscriptionStatusCopyWithImpl<$Res>
    implements $SnPublisherSubscriptionStatusCopyWith<$Res> {
  _$SnPublisherSubscriptionStatusCopyWithImpl(this._self, this._then);

  final SnPublisherSubscriptionStatus _self;
  final $Res Function(SnPublisherSubscriptionStatus) _then;

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = freezed,Object? followRequest = freezed,Object? requiresApproval = null,Object? status = null,Object? message = null,Object? isPending = null,Object? isActive = null,Object? notify = null,}) {
  return _then(SnPublisherSubscriptionStatus(
subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription?,followRequest: freezed == followRequest ? _self.followRequest : followRequest // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription?,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res>? get followRequest {
    if (_self.followRequest == null) {
    return null;
  }

  return $SnPublisherSubscriptionCopyWith<$Res>(_self.followRequest!, (value) {
    return _then(_self.copyWith(followRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscriptionStatus].
extension SnPublisherSubscriptionStatusPatterns on SnPublisherSubscriptionStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscriptionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPublisherSubscription? subscription,  SnPublisherSubscription? followRequest,  bool requiresApproval,  String status,  String message,  bool isPending,  bool isActive,  bool notify)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
return $default(_that.subscription,_that.followRequest,_that.requiresApproval,_that.status,_that.message,_that.isPending,_that.isActive,_that.notify);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPublisherSubscription? subscription,  SnPublisherSubscription? followRequest,  bool requiresApproval,  String status,  String message,  bool isPending,  bool isActive,  bool notify)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus():
return $default(_that.subscription,_that.followRequest,_that.requiresApproval,_that.status,_that.message,_that.isPending,_that.isActive,_that.notify);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPublisherSubscription? subscription,  SnPublisherSubscription? followRequest,  bool requiresApproval,  String status,  String message,  bool isPending,  bool isActive,  bool notify)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
return $default(_that.subscription,_that.followRequest,_that.requiresApproval,_that.status,_that.message,_that.isPending,_that.isActive,_that.notify);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscriptionStatus implements SnPublisherSubscriptionStatus {
  const _SnPublisherSubscriptionStatus({this.subscription, this.followRequest, this.requiresApproval = false, this.status = 'none', this.message = '', this.isPending = false, this.isActive = false, this.notify = true});
  factory _SnPublisherSubscriptionStatus.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriptionStatusFromJson(json);

@override final  SnPublisherSubscription? subscription;
@override final  SnPublisherSubscription? followRequest;
@override@JsonKey() final  bool requiresApproval;
@override@JsonKey() final  String status;
@override@JsonKey() final  String message;
@override@JsonKey() final  bool isPending;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool notify;

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriptionStatusCopyWith<_SnPublisherSubscriptionStatus> get copyWith => __$SnPublisherSubscriptionStatusCopyWithImpl<_SnPublisherSubscriptionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriptionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscriptionStatus&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.followRequest, followRequest) || other.followRequest == followRequest)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.isPending, isPending) || other.isPending == isPending)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.notify, notify) || other.notify == notify));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,subscription,followRequest,requiresApproval,status,message,isPending,isActive,notify);
}

@override
String toString() {
    return 'SnPublisherSubscriptionStatus(subscription: $subscription, followRequest: $followRequest, requiresApproval: $requiresApproval, status: $status, message: $message, isPending: $isPending, isActive: $isActive, notify: $notify)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriptionStatusCopyWith<$Res> implements $SnPublisherSubscriptionStatusCopyWith<$Res> {
  factory _$SnPublisherSubscriptionStatusCopyWith(_SnPublisherSubscriptionStatus value, $Res Function(_SnPublisherSubscriptionStatus) _then) = __$SnPublisherSubscriptionStatusCopyWithImpl;
@override @useResult
$Res call({
 SnPublisherSubscription? subscription, SnPublisherSubscription? followRequest, bool requiresApproval, String status, String message, bool isPending, bool isActive, bool notify
});


@override $SnPublisherSubscriptionCopyWith<$Res>? get subscription;@override $SnPublisherSubscriptionCopyWith<$Res>? get followRequest;

}
/// @nodoc
class __$SnPublisherSubscriptionStatusCopyWithImpl<$Res>
    implements _$SnPublisherSubscriptionStatusCopyWith<$Res> {
  __$SnPublisherSubscriptionStatusCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscriptionStatus _self;
  final $Res Function(_SnPublisherSubscriptionStatus) _then;

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = freezed,Object? followRequest = freezed,Object? requiresApproval = null,Object? status = null,Object? message = null,Object? isPending = null,Object? isActive = null,Object? notify = null,}) {
  return _then(_SnPublisherSubscriptionStatus(
subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription?,followRequest: freezed == followRequest ? _self.followRequest : followRequest // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription?,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res>? get followRequest {
    if (_self.followRequest == null) {
    return null;
  }

  return $SnPublisherSubscriptionCopyWith<$Res>(_self.followRequest!, (value) {
    return _then(_self.copyWith(followRequest: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherSubscriber {

 SnPublisherSubscription get subscription; SnAccount? get account;
/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriberCopyWith<SnPublisherSubscriber> get copyWith => _$SnPublisherSubscriberCopyWithImpl<SnPublisherSubscriber>(this as SnPublisherSubscriber, _$identity);

  /// Serializes this SnPublisherSubscriber to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherSubscriber;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscriber&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.account, _this.account) || other.account == _this.account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherSubscriber;
  return Object.hash(runtimeType,_this.subscription,_this.account);
}

@override
String toString() {
  final _this = this as SnPublisherSubscriber;
  return 'SnPublisherSubscriber(subscription: ${_this.subscription}, account: ${_this.account})';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriberCopyWith<$Res>  {
  factory $SnPublisherSubscriberCopyWith(SnPublisherSubscriber value, $Res Function(SnPublisherSubscriber) _then) = _$SnPublisherSubscriberCopyWithImpl;
@useResult
$Res call({
 SnPublisherSubscription subscription, SnAccount? account
});


$SnPublisherSubscriptionCopyWith<$Res> get subscription;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPublisherSubscriberCopyWithImpl<$Res>
    implements $SnPublisherSubscriberCopyWith<$Res> {
  _$SnPublisherSubscriberCopyWithImpl(this._self, this._then);

  final SnPublisherSubscriber _self;
  final $Res Function(SnPublisherSubscriber) _then;

/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = null,Object? account = freezed,}) {
  return _then(SnPublisherSubscriber(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}
/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res> get subscription {
  
  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscriber].
extension SnPublisherSubscriberPatterns on SnPublisherSubscriber {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscriber value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscriber() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscriber value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriber():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscriber value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriber() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPublisherSubscription subscription,  SnAccount? account)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscriber() when $default != null:
return $default(_that.subscription,_that.account);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPublisherSubscription subscription,  SnAccount? account)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriber():
return $default(_that.subscription,_that.account);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPublisherSubscription subscription,  SnAccount? account)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriber() when $default != null:
return $default(_that.subscription,_that.account);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscriber implements SnPublisherSubscriber {
  const _SnPublisherSubscriber({required this.subscription, required this.account});
  factory _SnPublisherSubscriber.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriberFromJson(json);

@override final  SnPublisherSubscription subscription;
@override final  SnAccount? account;

/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriberCopyWith<_SnPublisherSubscriber> get copyWith => __$SnPublisherSubscriberCopyWithImpl<_SnPublisherSubscriber>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscriber&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,subscription,account);
}

@override
String toString() {
    return 'SnPublisherSubscriber(subscription: $subscription, account: $account)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriberCopyWith<$Res> implements $SnPublisherSubscriberCopyWith<$Res> {
  factory _$SnPublisherSubscriberCopyWith(_SnPublisherSubscriber value, $Res Function(_SnPublisherSubscriber) _then) = __$SnPublisherSubscriberCopyWithImpl;
@override @useResult
$Res call({
 SnPublisherSubscription subscription, SnAccount? account
});


@override $SnPublisherSubscriptionCopyWith<$Res> get subscription;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPublisherSubscriberCopyWithImpl<$Res>
    implements _$SnPublisherSubscriberCopyWith<$Res> {
  __$SnPublisherSubscriberCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscriber _self;
  final $Res Function(_SnPublisherSubscriber) _then;

/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = null,Object? account = freezed,}) {
  return _then(_SnPublisherSubscriber(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res> get subscription {
  
  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SnPublisherSubscriber
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherRelationship {

 SnPublisherSubscription? get subscription; bool get isBlocking; bool get isMuting; bool get isSubscribed;
/// Create a copy of SnPublisherRelationship
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherRelationshipCopyWith<SnPublisherRelationship> get copyWith => _$SnPublisherRelationshipCopyWithImpl<SnPublisherRelationship>(this as SnPublisherRelationship, _$identity);

  /// Serializes this SnPublisherRelationship to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherRelationship;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherRelationship&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.isBlocking, _this.isBlocking) || other.isBlocking == _this.isBlocking)&&(identical(other.isMuting, _this.isMuting) || other.isMuting == _this.isMuting)&&(identical(other.isSubscribed, _this.isSubscribed) || other.isSubscribed == _this.isSubscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherRelationship;
  return Object.hash(runtimeType,_this.subscription,_this.isBlocking,_this.isMuting,_this.isSubscribed);
}

@override
String toString() {
  final _this = this as SnPublisherRelationship;
  return 'SnPublisherRelationship(subscription: ${_this.subscription}, isBlocking: ${_this.isBlocking}, isMuting: ${_this.isMuting}, isSubscribed: ${_this.isSubscribed})';
}


}

/// @nodoc
abstract mixin class $SnPublisherRelationshipCopyWith<$Res>  {
  factory $SnPublisherRelationshipCopyWith(SnPublisherRelationship value, $Res Function(SnPublisherRelationship) _then) = _$SnPublisherRelationshipCopyWithImpl;
@useResult
$Res call({
 SnPublisherSubscription? subscription, bool isBlocking, bool isMuting, bool isSubscribed
});


$SnPublisherSubscriptionCopyWith<$Res>? get subscription;

}
/// @nodoc
class _$SnPublisherRelationshipCopyWithImpl<$Res>
    implements $SnPublisherRelationshipCopyWith<$Res> {
  _$SnPublisherRelationshipCopyWithImpl(this._self, this._then);

  final SnPublisherRelationship _self;
  final $Res Function(SnPublisherRelationship) _then;

/// Create a copy of SnPublisherRelationship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = freezed,Object? isBlocking = null,Object? isMuting = null,Object? isSubscribed = null,}) {
  return _then(SnPublisherRelationship(
subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription?,isBlocking: null == isBlocking ? _self.isBlocking : isBlocking // ignore: cast_nullable_to_non_nullable
as bool,isMuting: null == isMuting ? _self.isMuting : isMuting // ignore: cast_nullable_to_non_nullable
as bool,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnPublisherRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherRelationship].
extension SnPublisherRelationshipPatterns on SnPublisherRelationship {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherRelationship value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherRelationship() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherRelationship value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherRelationship():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherRelationship value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherRelationship() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPublisherSubscription? subscription,  bool isBlocking,  bool isMuting,  bool isSubscribed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherRelationship() when $default != null:
return $default(_that.subscription,_that.isBlocking,_that.isMuting,_that.isSubscribed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPublisherSubscription? subscription,  bool isBlocking,  bool isMuting,  bool isSubscribed)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherRelationship():
return $default(_that.subscription,_that.isBlocking,_that.isMuting,_that.isSubscribed);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPublisherSubscription? subscription,  bool isBlocking,  bool isMuting,  bool isSubscribed)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherRelationship() when $default != null:
return $default(_that.subscription,_that.isBlocking,_that.isMuting,_that.isSubscribed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherRelationship implements SnPublisherRelationship {
  const _SnPublisherRelationship({this.subscription, this.isBlocking = false, this.isMuting = false, this.isSubscribed = false});
  factory _SnPublisherRelationship.fromJson(Map<String, dynamic> json) => _$SnPublisherRelationshipFromJson(json);

@override final  SnPublisherSubscription? subscription;
@override@JsonKey() final  bool isBlocking;
@override@JsonKey() final  bool isMuting;
@override@JsonKey() final  bool isSubscribed;

/// Create a copy of SnPublisherRelationship
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherRelationshipCopyWith<_SnPublisherRelationship> get copyWith => __$SnPublisherRelationshipCopyWithImpl<_SnPublisherRelationship>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherRelationshipToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherRelationship&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.isBlocking, isBlocking) || other.isBlocking == isBlocking)&&(identical(other.isMuting, isMuting) || other.isMuting == isMuting)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,subscription,isBlocking,isMuting,isSubscribed);
}

@override
String toString() {
    return 'SnPublisherRelationship(subscription: $subscription, isBlocking: $isBlocking, isMuting: $isMuting, isSubscribed: $isSubscribed)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherRelationshipCopyWith<$Res> implements $SnPublisherRelationshipCopyWith<$Res> {
  factory _$SnPublisherRelationshipCopyWith(_SnPublisherRelationship value, $Res Function(_SnPublisherRelationship) _then) = __$SnPublisherRelationshipCopyWithImpl;
@override @useResult
$Res call({
 SnPublisherSubscription? subscription, bool isBlocking, bool isMuting, bool isSubscribed
});


@override $SnPublisherSubscriptionCopyWith<$Res>? get subscription;

}
/// @nodoc
class __$SnPublisherRelationshipCopyWithImpl<$Res>
    implements _$SnPublisherRelationshipCopyWith<$Res> {
  __$SnPublisherRelationshipCopyWithImpl(this._self, this._then);

  final _SnPublisherRelationship _self;
  final $Res Function(_SnPublisherRelationship) _then;

/// Create a copy of SnPublisherRelationship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = freezed,Object? isBlocking = null,Object? isMuting = null,Object? isSubscribed = null,}) {
  return _then(_SnPublisherRelationship(
subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription?,isBlocking: null == isBlocking ? _self.isBlocking : isBlocking // ignore: cast_nullable_to_non_nullable
as bool,isMuting: null == isMuting ? _self.isMuting : isMuting // ignore: cast_nullable_to_non_nullable
as bool,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnPublisherRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherSubscriptionReadStatus {

 SnPublisherSubscription get subscription; DateTime? get latestContentAt; bool get hasNewContent;
/// Create a copy of SnPublisherSubscriptionReadStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionReadStatusCopyWith<SnPublisherSubscriptionReadStatus> get copyWith => _$SnPublisherSubscriptionReadStatusCopyWithImpl<SnPublisherSubscriptionReadStatus>(this as SnPublisherSubscriptionReadStatus, _$identity);

  /// Serializes this SnPublisherSubscriptionReadStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherSubscriptionReadStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscriptionReadStatus&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.latestContentAt, _this.latestContentAt) || other.latestContentAt == _this.latestContentAt)&&(identical(other.hasNewContent, _this.hasNewContent) || other.hasNewContent == _this.hasNewContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherSubscriptionReadStatus;
  return Object.hash(runtimeType,_this.subscription,_this.latestContentAt,_this.hasNewContent);
}

@override
String toString() {
  final _this = this as SnPublisherSubscriptionReadStatus;
  return 'SnPublisherSubscriptionReadStatus(subscription: ${_this.subscription}, latestContentAt: ${_this.latestContentAt}, hasNewContent: ${_this.hasNewContent})';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriptionReadStatusCopyWith<$Res>  {
  factory $SnPublisherSubscriptionReadStatusCopyWith(SnPublisherSubscriptionReadStatus value, $Res Function(SnPublisherSubscriptionReadStatus) _then) = _$SnPublisherSubscriptionReadStatusCopyWithImpl;
@useResult
$Res call({
 SnPublisherSubscription subscription, DateTime? latestContentAt, bool hasNewContent
});


$SnPublisherSubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class _$SnPublisherSubscriptionReadStatusCopyWithImpl<$Res>
    implements $SnPublisherSubscriptionReadStatusCopyWith<$Res> {
  _$SnPublisherSubscriptionReadStatusCopyWithImpl(this._self, this._then);

  final SnPublisherSubscriptionReadStatus _self;
  final $Res Function(SnPublisherSubscriptionReadStatus) _then;

/// Create a copy of SnPublisherSubscriptionReadStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = null,Object? latestContentAt = freezed,Object? hasNewContent = null,}) {
  return _then(SnPublisherSubscriptionReadStatus(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription,latestContentAt: freezed == latestContentAt ? _self.latestContentAt : latestContentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasNewContent: null == hasNewContent ? _self.hasNewContent : hasNewContent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnPublisherSubscriptionReadStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res> get subscription {
  
  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscriptionReadStatus].
extension SnPublisherSubscriptionReadStatusPatterns on SnPublisherSubscriptionReadStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionReadStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionReadStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionReadStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionReadStatus():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscriptionReadStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionReadStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPublisherSubscription subscription,  DateTime? latestContentAt,  bool hasNewContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionReadStatus() when $default != null:
return $default(_that.subscription,_that.latestContentAt,_that.hasNewContent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPublisherSubscription subscription,  DateTime? latestContentAt,  bool hasNewContent)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionReadStatus():
return $default(_that.subscription,_that.latestContentAt,_that.hasNewContent);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPublisherSubscription subscription,  DateTime? latestContentAt,  bool hasNewContent)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionReadStatus() when $default != null:
return $default(_that.subscription,_that.latestContentAt,_that.hasNewContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscriptionReadStatus implements SnPublisherSubscriptionReadStatus {
  const _SnPublisherSubscriptionReadStatus({required this.subscription, this.latestContentAt, this.hasNewContent = false});
  factory _SnPublisherSubscriptionReadStatus.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriptionReadStatusFromJson(json);

@override final  SnPublisherSubscription subscription;
@override final  DateTime? latestContentAt;
@override@JsonKey() final  bool hasNewContent;

/// Create a copy of SnPublisherSubscriptionReadStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriptionReadStatusCopyWith<_SnPublisherSubscriptionReadStatus> get copyWith => __$SnPublisherSubscriptionReadStatusCopyWithImpl<_SnPublisherSubscriptionReadStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriptionReadStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscriptionReadStatus&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.latestContentAt, latestContentAt) || other.latestContentAt == latestContentAt)&&(identical(other.hasNewContent, hasNewContent) || other.hasNewContent == hasNewContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,subscription,latestContentAt,hasNewContent);
}

@override
String toString() {
    return 'SnPublisherSubscriptionReadStatus(subscription: $subscription, latestContentAt: $latestContentAt, hasNewContent: $hasNewContent)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriptionReadStatusCopyWith<$Res> implements $SnPublisherSubscriptionReadStatusCopyWith<$Res> {
  factory _$SnPublisherSubscriptionReadStatusCopyWith(_SnPublisherSubscriptionReadStatus value, $Res Function(_SnPublisherSubscriptionReadStatus) _then) = __$SnPublisherSubscriptionReadStatusCopyWithImpl;
@override @useResult
$Res call({
 SnPublisherSubscription subscription, DateTime? latestContentAt, bool hasNewContent
});


@override $SnPublisherSubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class __$SnPublisherSubscriptionReadStatusCopyWithImpl<$Res>
    implements _$SnPublisherSubscriptionReadStatusCopyWith<$Res> {
  __$SnPublisherSubscriptionReadStatusCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscriptionReadStatus _self;
  final $Res Function(_SnPublisherSubscriptionReadStatus) _then;

/// Create a copy of SnPublisherSubscriptionReadStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = null,Object? latestContentAt = freezed,Object? hasNewContent = null,}) {
  return _then(_SnPublisherSubscriptionReadStatus(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription,latestContentAt: freezed == latestContentAt ? _self.latestContentAt : latestContentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasNewContent: null == hasNewContent ? _self.hasNewContent : hasNewContent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnPublisherSubscriptionReadStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res> get subscription {
  
  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherSubscriptionWithStatus {

 SnPublisherSubscription get subscription; bool get isLive; DateTime? get latestContentAt; bool get hasNewContent;
/// Create a copy of SnPublisherSubscriptionWithStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionWithStatusCopyWith<SnPublisherSubscriptionWithStatus> get copyWith => _$SnPublisherSubscriptionWithStatusCopyWithImpl<SnPublisherSubscriptionWithStatus>(this as SnPublisherSubscriptionWithStatus, _$identity);

  /// Serializes this SnPublisherSubscriptionWithStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPublisherSubscriptionWithStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscriptionWithStatus&&(identical(other.subscription, _this.subscription) || other.subscription == _this.subscription)&&(identical(other.isLive, _this.isLive) || other.isLive == _this.isLive)&&(identical(other.latestContentAt, _this.latestContentAt) || other.latestContentAt == _this.latestContentAt)&&(identical(other.hasNewContent, _this.hasNewContent) || other.hasNewContent == _this.hasNewContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPublisherSubscriptionWithStatus;
  return Object.hash(runtimeType,_this.subscription,_this.isLive,_this.latestContentAt,_this.hasNewContent);
}

@override
String toString() {
  final _this = this as SnPublisherSubscriptionWithStatus;
  return 'SnPublisherSubscriptionWithStatus(subscription: ${_this.subscription}, isLive: ${_this.isLive}, latestContentAt: ${_this.latestContentAt}, hasNewContent: ${_this.hasNewContent})';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriptionWithStatusCopyWith<$Res>  {
  factory $SnPublisherSubscriptionWithStatusCopyWith(SnPublisherSubscriptionWithStatus value, $Res Function(SnPublisherSubscriptionWithStatus) _then) = _$SnPublisherSubscriptionWithStatusCopyWithImpl;
@useResult
$Res call({
 SnPublisherSubscription subscription, bool isLive, DateTime? latestContentAt, bool hasNewContent
});


$SnPublisherSubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class _$SnPublisherSubscriptionWithStatusCopyWithImpl<$Res>
    implements $SnPublisherSubscriptionWithStatusCopyWith<$Res> {
  _$SnPublisherSubscriptionWithStatusCopyWithImpl(this._self, this._then);

  final SnPublisherSubscriptionWithStatus _self;
  final $Res Function(SnPublisherSubscriptionWithStatus) _then;

/// Create a copy of SnPublisherSubscriptionWithStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = null,Object? isLive = null,Object? latestContentAt = freezed,Object? hasNewContent = null,}) {
  return _then(SnPublisherSubscriptionWithStatus(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,latestContentAt: freezed == latestContentAt ? _self.latestContentAt : latestContentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasNewContent: null == hasNewContent ? _self.hasNewContent : hasNewContent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnPublisherSubscriptionWithStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res> get subscription {
  
  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscriptionWithStatus].
extension SnPublisherSubscriptionWithStatusPatterns on SnPublisherSubscriptionWithStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionWithStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionWithStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionWithStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionWithStatus():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscriptionWithStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionWithStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPublisherSubscription subscription,  bool isLive,  DateTime? latestContentAt,  bool hasNewContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionWithStatus() when $default != null:
return $default(_that.subscription,_that.isLive,_that.latestContentAt,_that.hasNewContent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPublisherSubscription subscription,  bool isLive,  DateTime? latestContentAt,  bool hasNewContent)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionWithStatus():
return $default(_that.subscription,_that.isLive,_that.latestContentAt,_that.hasNewContent);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPublisherSubscription subscription,  bool isLive,  DateTime? latestContentAt,  bool hasNewContent)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionWithStatus() when $default != null:
return $default(_that.subscription,_that.isLive,_that.latestContentAt,_that.hasNewContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscriptionWithStatus implements SnPublisherSubscriptionWithStatus {
  const _SnPublisherSubscriptionWithStatus({required this.subscription, this.isLive = false, this.latestContentAt, this.hasNewContent = false});
  factory _SnPublisherSubscriptionWithStatus.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriptionWithStatusFromJson(json);

@override final  SnPublisherSubscription subscription;
@override@JsonKey() final  bool isLive;
@override final  DateTime? latestContentAt;
@override@JsonKey() final  bool hasNewContent;

/// Create a copy of SnPublisherSubscriptionWithStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriptionWithStatusCopyWith<_SnPublisherSubscriptionWithStatus> get copyWith => __$SnPublisherSubscriptionWithStatusCopyWithImpl<_SnPublisherSubscriptionWithStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriptionWithStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscriptionWithStatus&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.latestContentAt, latestContentAt) || other.latestContentAt == latestContentAt)&&(identical(other.hasNewContent, hasNewContent) || other.hasNewContent == hasNewContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,subscription,isLive,latestContentAt,hasNewContent);
}

@override
String toString() {
    return 'SnPublisherSubscriptionWithStatus(subscription: $subscription, isLive: $isLive, latestContentAt: $latestContentAt, hasNewContent: $hasNewContent)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriptionWithStatusCopyWith<$Res> implements $SnPublisherSubscriptionWithStatusCopyWith<$Res> {
  factory _$SnPublisherSubscriptionWithStatusCopyWith(_SnPublisherSubscriptionWithStatus value, $Res Function(_SnPublisherSubscriptionWithStatus) _then) = __$SnPublisherSubscriptionWithStatusCopyWithImpl;
@override @useResult
$Res call({
 SnPublisherSubscription subscription, bool isLive, DateTime? latestContentAt, bool hasNewContent
});


@override $SnPublisherSubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class __$SnPublisherSubscriptionWithStatusCopyWithImpl<$Res>
    implements _$SnPublisherSubscriptionWithStatusCopyWith<$Res> {
  __$SnPublisherSubscriptionWithStatusCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscriptionWithStatus _self;
  final $Res Function(_SnPublisherSubscriptionWithStatus) _then;

/// Create a copy of SnPublisherSubscriptionWithStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = null,Object? isLive = null,Object? latestContentAt = freezed,Object? hasNewContent = null,}) {
  return _then(_SnPublisherSubscriptionWithStatus(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherSubscription,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,latestContentAt: freezed == latestContentAt ? _self.latestContentAt : latestContentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hasNewContent: null == hasNewContent ? _self.hasNewContent : hasNewContent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnPublisherSubscriptionWithStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCopyWith<$Res> get subscription {
  
  return $SnPublisherSubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// @nodoc
mixin _$FediverseActorRelationship {

 String get actorId; String get actorUsername; String? get actorInstance; String get actorHandle; bool get isFollowing; bool get isFollowedBy; bool get isPending;
/// Create a copy of FediverseActorRelationship
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FediverseActorRelationshipCopyWith<FediverseActorRelationship> get copyWith => _$FediverseActorRelationshipCopyWithImpl<FediverseActorRelationship>(this as FediverseActorRelationship, _$identity);

  /// Serializes this FediverseActorRelationship to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FediverseActorRelationship;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FediverseActorRelationship&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&(identical(other.actorUsername, _this.actorUsername) || other.actorUsername == _this.actorUsername)&&(identical(other.actorInstance, _this.actorInstance) || other.actorInstance == _this.actorInstance)&&(identical(other.actorHandle, _this.actorHandle) || other.actorHandle == _this.actorHandle)&&(identical(other.isFollowing, _this.isFollowing) || other.isFollowing == _this.isFollowing)&&(identical(other.isFollowedBy, _this.isFollowedBy) || other.isFollowedBy == _this.isFollowedBy)&&(identical(other.isPending, _this.isPending) || other.isPending == _this.isPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FediverseActorRelationship;
  return Object.hash(runtimeType,_this.actorId,_this.actorUsername,_this.actorInstance,_this.actorHandle,_this.isFollowing,_this.isFollowedBy,_this.isPending);
}

@override
String toString() {
  final _this = this as FediverseActorRelationship;
  return 'FediverseActorRelationship(actorId: ${_this.actorId}, actorUsername: ${_this.actorUsername}, actorInstance: ${_this.actorInstance}, actorHandle: ${_this.actorHandle}, isFollowing: ${_this.isFollowing}, isFollowedBy: ${_this.isFollowedBy}, isPending: ${_this.isPending})';
}


}

/// @nodoc
abstract mixin class $FediverseActorRelationshipCopyWith<$Res>  {
  factory $FediverseActorRelationshipCopyWith(FediverseActorRelationship value, $Res Function(FediverseActorRelationship) _then) = _$FediverseActorRelationshipCopyWithImpl;
@useResult
$Res call({
 String actorId, String actorUsername, String? actorInstance, String actorHandle, bool isFollowing, bool isFollowedBy, bool isPending
});




}
/// @nodoc
class _$FediverseActorRelationshipCopyWithImpl<$Res>
    implements $FediverseActorRelationshipCopyWith<$Res> {
  _$FediverseActorRelationshipCopyWithImpl(this._self, this._then);

  final FediverseActorRelationship _self;
  final $Res Function(FediverseActorRelationship) _then;

/// Create a copy of FediverseActorRelationship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actorId = null,Object? actorUsername = null,Object? actorInstance = freezed,Object? actorHandle = null,Object? isFollowing = null,Object? isFollowedBy = null,Object? isPending = null,}) {
  return _then(FediverseActorRelationship(
actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorUsername: null == actorUsername ? _self.actorUsername : actorUsername // ignore: cast_nullable_to_non_nullable
as String,actorInstance: freezed == actorInstance ? _self.actorInstance : actorInstance // ignore: cast_nullable_to_non_nullable
as String?,actorHandle: null == actorHandle ? _self.actorHandle : actorHandle // ignore: cast_nullable_to_non_nullable
as String,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isFollowedBy: null == isFollowedBy ? _self.isFollowedBy : isFollowedBy // ignore: cast_nullable_to_non_nullable
as bool,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FediverseActorRelationship].
extension FediverseActorRelationshipPatterns on FediverseActorRelationship {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FediverseActorRelationship value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FediverseActorRelationship() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FediverseActorRelationship value)  $default,){
final _that = this;
switch (_that) {
case _FediverseActorRelationship():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FediverseActorRelationship value)?  $default,){
final _that = this;
switch (_that) {
case _FediverseActorRelationship() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actorId,  String actorUsername,  String? actorInstance,  String actorHandle,  bool isFollowing,  bool isFollowedBy,  bool isPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FediverseActorRelationship() when $default != null:
return $default(_that.actorId,_that.actorUsername,_that.actorInstance,_that.actorHandle,_that.isFollowing,_that.isFollowedBy,_that.isPending);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actorId,  String actorUsername,  String? actorInstance,  String actorHandle,  bool isFollowing,  bool isFollowedBy,  bool isPending)  $default,) {final _that = this;
switch (_that) {
case _FediverseActorRelationship():
return $default(_that.actorId,_that.actorUsername,_that.actorInstance,_that.actorHandle,_that.isFollowing,_that.isFollowedBy,_that.isPending);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actorId,  String actorUsername,  String? actorInstance,  String actorHandle,  bool isFollowing,  bool isFollowedBy,  bool isPending)?  $default,) {final _that = this;
switch (_that) {
case _FediverseActorRelationship() when $default != null:
return $default(_that.actorId,_that.actorUsername,_that.actorInstance,_that.actorHandle,_that.isFollowing,_that.isFollowedBy,_that.isPending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FediverseActorRelationship implements FediverseActorRelationship {
  const _FediverseActorRelationship({this.actorId = '', this.actorUsername = '', this.actorInstance, this.actorHandle = '', this.isFollowing = false, this.isFollowedBy = false, this.isPending = false});
  factory _FediverseActorRelationship.fromJson(Map<String, dynamic> json) => _$FediverseActorRelationshipFromJson(json);

@override@JsonKey() final  String actorId;
@override@JsonKey() final  String actorUsername;
@override final  String? actorInstance;
@override@JsonKey() final  String actorHandle;
@override@JsonKey() final  bool isFollowing;
@override@JsonKey() final  bool isFollowedBy;
@override@JsonKey() final  bool isPending;

/// Create a copy of FediverseActorRelationship
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FediverseActorRelationshipCopyWith<_FediverseActorRelationship> get copyWith => __$FediverseActorRelationshipCopyWithImpl<_FediverseActorRelationship>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FediverseActorRelationshipToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FediverseActorRelationship&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorUsername, actorUsername) || other.actorUsername == actorUsername)&&(identical(other.actorInstance, actorInstance) || other.actorInstance == actorInstance)&&(identical(other.actorHandle, actorHandle) || other.actorHandle == actorHandle)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isFollowedBy, isFollowedBy) || other.isFollowedBy == isFollowedBy)&&(identical(other.isPending, isPending) || other.isPending == isPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,actorId,actorUsername,actorInstance,actorHandle,isFollowing,isFollowedBy,isPending);
}

@override
String toString() {
    return 'FediverseActorRelationship(actorId: $actorId, actorUsername: $actorUsername, actorInstance: $actorInstance, actorHandle: $actorHandle, isFollowing: $isFollowing, isFollowedBy: $isFollowedBy, isPending: $isPending)';
}


}

/// @nodoc
abstract mixin class _$FediverseActorRelationshipCopyWith<$Res> implements $FediverseActorRelationshipCopyWith<$Res> {
  factory _$FediverseActorRelationshipCopyWith(_FediverseActorRelationship value, $Res Function(_FediverseActorRelationship) _then) = __$FediverseActorRelationshipCopyWithImpl;
@override @useResult
$Res call({
 String actorId, String actorUsername, String? actorInstance, String actorHandle, bool isFollowing, bool isFollowedBy, bool isPending
});




}
/// @nodoc
class __$FediverseActorRelationshipCopyWithImpl<$Res>
    implements _$FediverseActorRelationshipCopyWith<$Res> {
  __$FediverseActorRelationshipCopyWithImpl(this._self, this._then);

  final _FediverseActorRelationship _self;
  final $Res Function(_FediverseActorRelationship) _then;

/// Create a copy of FediverseActorRelationship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actorId = null,Object? actorUsername = null,Object? actorInstance = freezed,Object? actorHandle = null,Object? isFollowing = null,Object? isFollowedBy = null,Object? isPending = null,}) {
  return _then(_FediverseActorRelationship(
actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorUsername: null == actorUsername ? _self.actorUsername : actorUsername // ignore: cast_nullable_to_non_nullable
as String,actorInstance: freezed == actorInstance ? _self.actorInstance : actorInstance // ignore: cast_nullable_to_non_nullable
as String?,actorHandle: null == actorHandle ? _self.actorHandle : actorHandle // ignore: cast_nullable_to_non_nullable
as String,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isFollowedBy: null == isFollowedBy ? _self.isFollowedBy : isFollowedBy // ignore: cast_nullable_to_non_nullable
as bool,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
