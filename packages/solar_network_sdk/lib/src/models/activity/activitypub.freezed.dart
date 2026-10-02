// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activitypub.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnActivityPubInstance {

/// Synthetic remote instances may omit id (Guid.Empty / null).
 String get id; String get domain; String? get name; String? get description; String? get software; String? get version; String? get iconUrl; String? get thumbnailUrl; String? get contactEmail; String? get contactAccountUsername; int? get activeUsers; bool get isBlocked; bool get isSilenced; String? get blockReason; Map<String, dynamic>? get metadata; DateTime? get lastFetchedAt; DateTime? get lastActivityAt; DateTime? get metadataFetchedAt;
/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubInstanceCopyWith<SnActivityPubInstance> get copyWith => _$SnActivityPubInstanceCopyWithImpl<SnActivityPubInstance>(this as SnActivityPubInstance, _$identity);

  /// Serializes this SnActivityPubInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnActivityPubInstance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubInstance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.domain, _this.domain) || other.domain == _this.domain)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.software, _this.software) || other.software == _this.software)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.iconUrl, _this.iconUrl) || other.iconUrl == _this.iconUrl)&&(identical(other.thumbnailUrl, _this.thumbnailUrl) || other.thumbnailUrl == _this.thumbnailUrl)&&(identical(other.contactEmail, _this.contactEmail) || other.contactEmail == _this.contactEmail)&&(identical(other.contactAccountUsername, _this.contactAccountUsername) || other.contactAccountUsername == _this.contactAccountUsername)&&(identical(other.activeUsers, _this.activeUsers) || other.activeUsers == _this.activeUsers)&&(identical(other.isBlocked, _this.isBlocked) || other.isBlocked == _this.isBlocked)&&(identical(other.isSilenced, _this.isSilenced) || other.isSilenced == _this.isSilenced)&&(identical(other.blockReason, _this.blockReason) || other.blockReason == _this.blockReason)&&const DeepCollectionEquality().equals(other.metadata, _this.metadata)&&(identical(other.lastFetchedAt, _this.lastFetchedAt) || other.lastFetchedAt == _this.lastFetchedAt)&&(identical(other.lastActivityAt, _this.lastActivityAt) || other.lastActivityAt == _this.lastActivityAt)&&(identical(other.metadataFetchedAt, _this.metadataFetchedAt) || other.metadataFetchedAt == _this.metadataFetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnActivityPubInstance;
  return Object.hash(runtimeType,_this.id,_this.domain,_this.name,_this.description,_this.software,_this.version,_this.iconUrl,_this.thumbnailUrl,_this.contactEmail,_this.contactAccountUsername,_this.activeUsers,_this.isBlocked,_this.isSilenced,_this.blockReason,const DeepCollectionEquality().hash(_this.metadata),_this.lastFetchedAt,_this.lastActivityAt,_this.metadataFetchedAt);
}

@override
String toString() {
  final _this = this as SnActivityPubInstance;
  return 'SnActivityPubInstance(id: ${_this.id}, domain: ${_this.domain}, name: ${_this.name}, description: ${_this.description}, software: ${_this.software}, version: ${_this.version}, iconUrl: ${_this.iconUrl}, thumbnailUrl: ${_this.thumbnailUrl}, contactEmail: ${_this.contactEmail}, contactAccountUsername: ${_this.contactAccountUsername}, activeUsers: ${_this.activeUsers}, isBlocked: ${_this.isBlocked}, isSilenced: ${_this.isSilenced}, blockReason: ${_this.blockReason}, metadata: ${_this.metadata}, lastFetchedAt: ${_this.lastFetchedAt}, lastActivityAt: ${_this.lastActivityAt}, metadataFetchedAt: ${_this.metadataFetchedAt})';
}


}

/// @nodoc
abstract mixin class $SnActivityPubInstanceCopyWith<$Res>  {
  factory $SnActivityPubInstanceCopyWith(SnActivityPubInstance value, $Res Function(SnActivityPubInstance) _then) = _$SnActivityPubInstanceCopyWithImpl;
@useResult
$Res call({
 String id, String domain, String? name, String? description, String? software, String? version, String? iconUrl, String? thumbnailUrl, String? contactEmail, String? contactAccountUsername, int? activeUsers, bool isBlocked, bool isSilenced, String? blockReason, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt, DateTime? metadataFetchedAt
});




}
/// @nodoc
class _$SnActivityPubInstanceCopyWithImpl<$Res>
    implements $SnActivityPubInstanceCopyWith<$Res> {
  _$SnActivityPubInstanceCopyWithImpl(this._self, this._then);

  final SnActivityPubInstance _self;
  final $Res Function(SnActivityPubInstance) _then;

/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? domain = null,Object? name = freezed,Object? description = freezed,Object? software = freezed,Object? version = freezed,Object? iconUrl = freezed,Object? thumbnailUrl = freezed,Object? contactEmail = freezed,Object? contactAccountUsername = freezed,Object? activeUsers = freezed,Object? isBlocked = null,Object? isSilenced = null,Object? blockReason = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? metadataFetchedAt = freezed,}) {
  return _then(SnActivityPubInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,software: freezed == software ? _self.software : software // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contactAccountUsername: freezed == contactAccountUsername ? _self.contactAccountUsername : contactAccountUsername // ignore: cast_nullable_to_non_nullable
as String?,activeUsers: freezed == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isSilenced: null == isSilenced ? _self.isSilenced : isSilenced // ignore: cast_nullable_to_non_nullable
as bool,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadataFetchedAt: freezed == metadataFetchedAt ? _self.metadataFetchedAt : metadataFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnActivityPubInstance].
extension SnActivityPubInstancePatterns on SnActivityPubInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActivityPubInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActivityPubInstance value)  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActivityPubInstance value)?  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String domain,  String? name,  String? description,  String? software,  String? version,  String? iconUrl,  String? thumbnailUrl,  String? contactEmail,  String? contactAccountUsername,  int? activeUsers,  bool isBlocked,  bool isSilenced,  String? blockReason,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? metadataFetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
return $default(_that.id,_that.domain,_that.name,_that.description,_that.software,_that.version,_that.iconUrl,_that.thumbnailUrl,_that.contactEmail,_that.contactAccountUsername,_that.activeUsers,_that.isBlocked,_that.isSilenced,_that.blockReason,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.metadataFetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String domain,  String? name,  String? description,  String? software,  String? version,  String? iconUrl,  String? thumbnailUrl,  String? contactEmail,  String? contactAccountUsername,  int? activeUsers,  bool isBlocked,  bool isSilenced,  String? blockReason,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? metadataFetchedAt)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubInstance():
return $default(_that.id,_that.domain,_that.name,_that.description,_that.software,_that.version,_that.iconUrl,_that.thumbnailUrl,_that.contactEmail,_that.contactAccountUsername,_that.activeUsers,_that.isBlocked,_that.isSilenced,_that.blockReason,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.metadataFetchedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String domain,  String? name,  String? description,  String? software,  String? version,  String? iconUrl,  String? thumbnailUrl,  String? contactEmail,  String? contactAccountUsername,  int? activeUsers,  bool isBlocked,  bool isSilenced,  String? blockReason,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? metadataFetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
return $default(_that.id,_that.domain,_that.name,_that.description,_that.software,_that.version,_that.iconUrl,_that.thumbnailUrl,_that.contactEmail,_that.contactAccountUsername,_that.activeUsers,_that.isBlocked,_that.isSilenced,_that.blockReason,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.metadataFetchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubInstance implements SnActivityPubInstance {
  const _SnActivityPubInstance({this.id = '', this.domain = 'unknown', this.name, this.description, this.software, this.version, this.iconUrl, this.thumbnailUrl, this.contactEmail, this.contactAccountUsername, this.activeUsers, this.isBlocked = false, this.isSilenced = false, this.blockReason,  Map<String, dynamic>? metadata, this.lastFetchedAt, this.lastActivityAt, this.metadataFetchedAt}): _metadata = metadata;
  factory _SnActivityPubInstance.fromJson(Map<String, dynamic> json) => _$SnActivityPubInstanceFromJson(json);

/// Synthetic remote instances may omit id (Guid.Empty / null).
@override@JsonKey() final  String id;
@override@JsonKey() final  String domain;
@override final  String? name;
@override final  String? description;
@override final  String? software;
@override final  String? version;
@override final  String? iconUrl;
@override final  String? thumbnailUrl;
@override final  String? contactEmail;
@override final  String? contactAccountUsername;
@override final  int? activeUsers;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool isSilenced;
@override final  String? blockReason;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? lastFetchedAt;
@override final  DateTime? lastActivityAt;
@override final  DateTime? metadataFetchedAt;

/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActivityPubInstanceCopyWith<_SnActivityPubInstance> get copyWith => __$SnActivityPubInstanceCopyWithImpl<_SnActivityPubInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActivityPubInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.software, software) || other.software == software)&&(identical(other.version, version) || other.version == version)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactAccountUsername, contactAccountUsername) || other.contactAccountUsername == contactAccountUsername)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isSilenced, isSilenced) || other.isSilenced == isSilenced)&&(identical(other.blockReason, blockReason) || other.blockReason == blockReason)&&const DeepCollectionEquality().equals(other.metadata, _metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.metadataFetchedAt, metadataFetchedAt) || other.metadataFetchedAt == metadataFetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,domain,name,description,software,version,iconUrl,thumbnailUrl,contactEmail,contactAccountUsername,activeUsers,isBlocked,isSilenced,blockReason,const DeepCollectionEquality().hash(_metadata),lastFetchedAt,lastActivityAt,metadataFetchedAt);
}

@override
String toString() {
    return 'SnActivityPubInstance(id: $id, domain: $domain, name: $name, description: $description, software: $software, version: $version, iconUrl: $iconUrl, thumbnailUrl: $thumbnailUrl, contactEmail: $contactEmail, contactAccountUsername: $contactAccountUsername, activeUsers: $activeUsers, isBlocked: $isBlocked, isSilenced: $isSilenced, blockReason: $blockReason, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt, metadataFetchedAt: $metadataFetchedAt)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubInstanceCopyWith<$Res> implements $SnActivityPubInstanceCopyWith<$Res> {
  factory _$SnActivityPubInstanceCopyWith(_SnActivityPubInstance value, $Res Function(_SnActivityPubInstance) _then) = __$SnActivityPubInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String domain, String? name, String? description, String? software, String? version, String? iconUrl, String? thumbnailUrl, String? contactEmail, String? contactAccountUsername, int? activeUsers, bool isBlocked, bool isSilenced, String? blockReason, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt, DateTime? metadataFetchedAt
});




}
/// @nodoc
class __$SnActivityPubInstanceCopyWithImpl<$Res>
    implements _$SnActivityPubInstanceCopyWith<$Res> {
  __$SnActivityPubInstanceCopyWithImpl(this._self, this._then);

  final _SnActivityPubInstance _self;
  final $Res Function(_SnActivityPubInstance) _then;

/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? domain = null,Object? name = freezed,Object? description = freezed,Object? software = freezed,Object? version = freezed,Object? iconUrl = freezed,Object? thumbnailUrl = freezed,Object? contactEmail = freezed,Object? contactAccountUsername = freezed,Object? activeUsers = freezed,Object? isBlocked = null,Object? isSilenced = null,Object? blockReason = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? metadataFetchedAt = freezed,}) {
  return _then(_SnActivityPubInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,software: freezed == software ? _self.software : software // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contactAccountUsername: freezed == contactAccountUsername ? _self.contactAccountUsername : contactAccountUsername // ignore: cast_nullable_to_non_nullable
as String?,activeUsers: freezed == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isSilenced: null == isSilenced ? _self.isSilenced : isSilenced // ignore: cast_nullable_to_non_nullable
as bool,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadataFetchedAt: freezed == metadataFetchedAt ? _self.metadataFetchedAt : metadataFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnActorStatusResponse {

 bool get enabled; int get followerCount; SnPublisher? get actor; String? get actorUri;
/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActorStatusResponseCopyWith<SnActorStatusResponse> get copyWith => _$SnActorStatusResponseCopyWithImpl<SnActorStatusResponse>(this as SnActorStatusResponse, _$identity);

  /// Serializes this SnActorStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnActorStatusResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActorStatusResponse&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.followerCount, _this.followerCount) || other.followerCount == _this.followerCount)&&(identical(other.actor, _this.actor) || other.actor == _this.actor)&&(identical(other.actorUri, _this.actorUri) || other.actorUri == _this.actorUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnActorStatusResponse;
  return Object.hash(runtimeType,_this.enabled,_this.followerCount,_this.actor,_this.actorUri);
}

@override
String toString() {
  final _this = this as SnActorStatusResponse;
  return 'SnActorStatusResponse(enabled: ${_this.enabled}, followerCount: ${_this.followerCount}, actor: ${_this.actor}, actorUri: ${_this.actorUri})';
}


}

/// @nodoc
abstract mixin class $SnActorStatusResponseCopyWith<$Res>  {
  factory $SnActorStatusResponseCopyWith(SnActorStatusResponse value, $Res Function(SnActorStatusResponse) _then) = _$SnActorStatusResponseCopyWithImpl;
@useResult
$Res call({
 bool enabled, int followerCount, SnPublisher? actor, String? actorUri
});


$SnPublisherCopyWith<$Res>? get actor;

}
/// @nodoc
class _$SnActorStatusResponseCopyWithImpl<$Res>
    implements $SnActorStatusResponseCopyWith<$Res> {
  _$SnActorStatusResponseCopyWithImpl(this._self, this._then);

  final SnActorStatusResponse _self;
  final $Res Function(SnActorStatusResponse) _then;

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? followerCount = null,Object? actor = freezed,Object? actorUri = freezed,}) {
  return _then(SnActorStatusResponse(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnPublisher?,actorUri: freezed == actorUri ? _self.actorUri : actorUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnActorStatusResponse].
extension SnActorStatusResponsePatterns on SnActorStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActorStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActorStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _SnActorStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActorStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int followerCount,  SnPublisher? actor,  String? actorUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
return $default(_that.enabled,_that.followerCount,_that.actor,_that.actorUri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int followerCount,  SnPublisher? actor,  String? actorUri)  $default,) {final _that = this;
switch (_that) {
case _SnActorStatusResponse():
return $default(_that.enabled,_that.followerCount,_that.actor,_that.actorUri);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int followerCount,  SnPublisher? actor,  String? actorUri)?  $default,) {final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
return $default(_that.enabled,_that.followerCount,_that.actor,_that.actorUri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActorStatusResponse implements SnActorStatusResponse {
  const _SnActorStatusResponse({required this.enabled, this.followerCount = 0, this.actor, this.actorUri});
  factory _SnActorStatusResponse.fromJson(Map<String, dynamic> json) => _$SnActorStatusResponseFromJson(json);

@override final  bool enabled;
@override@JsonKey() final  int followerCount;
@override final  SnPublisher? actor;
@override final  String? actorUri;

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActorStatusResponseCopyWith<_SnActorStatusResponse> get copyWith => __$SnActorStatusResponseCopyWithImpl<_SnActorStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActorStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActorStatusResponse&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.actorUri, actorUri) || other.actorUri == actorUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,followerCount,actor,actorUri);
}

@override
String toString() {
    return 'SnActorStatusResponse(enabled: $enabled, followerCount: $followerCount, actor: $actor, actorUri: $actorUri)';
}


}

/// @nodoc
abstract mixin class _$SnActorStatusResponseCopyWith<$Res> implements $SnActorStatusResponseCopyWith<$Res> {
  factory _$SnActorStatusResponseCopyWith(_SnActorStatusResponse value, $Res Function(_SnActorStatusResponse) _then) = __$SnActorStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int followerCount, SnPublisher? actor, String? actorUri
});


@override $SnPublisherCopyWith<$Res>? get actor;

}
/// @nodoc
class __$SnActorStatusResponseCopyWithImpl<$Res>
    implements _$SnActorStatusResponseCopyWith<$Res> {
  __$SnActorStatusResponseCopyWithImpl(this._self, this._then);

  final _SnActorStatusResponse _self;
  final $Res Function(_SnActorStatusResponse) _then;

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? followerCount = null,Object? actor = freezed,Object? actorUri = freezed,}) {
  return _then(_SnActorStatusResponse(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnPublisher?,actorUri: freezed == actorUri ? _self.actorUri : actorUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}

// dart format on
