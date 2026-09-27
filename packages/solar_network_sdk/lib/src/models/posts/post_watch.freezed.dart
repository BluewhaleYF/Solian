// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_watch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPostWatchPreference {

 PostWatchSource get source; bool get notifyReactions; bool get notifyReplies; bool get notifyChains; bool get notifyForwards; bool get notifyEdits;
/// Create a copy of SnPostWatchPreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostWatchPreferenceCopyWith<SnPostWatchPreference> get copyWith => _$SnPostWatchPreferenceCopyWithImpl<SnPostWatchPreference>(this as SnPostWatchPreference, _$identity);

  /// Serializes this SnPostWatchPreference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnPostWatchPreference;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostWatchPreference&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.notifyReactions, _this.notifyReactions) || other.notifyReactions == _this.notifyReactions)&&(identical(other.notifyReplies, _this.notifyReplies) || other.notifyReplies == _this.notifyReplies)&&(identical(other.notifyChains, _this.notifyChains) || other.notifyChains == _this.notifyChains)&&(identical(other.notifyForwards, _this.notifyForwards) || other.notifyForwards == _this.notifyForwards)&&(identical(other.notifyEdits, _this.notifyEdits) || other.notifyEdits == _this.notifyEdits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnPostWatchPreference;
  return Object.hash(runtimeType,_this.source,_this.notifyReactions,_this.notifyReplies,_this.notifyChains,_this.notifyForwards,_this.notifyEdits);
}

@override
String toString() {
  final _this = this as SnPostWatchPreference;
  return 'SnPostWatchPreference(source: ${_this.source}, notifyReactions: ${_this.notifyReactions}, notifyReplies: ${_this.notifyReplies}, notifyChains: ${_this.notifyChains}, notifyForwards: ${_this.notifyForwards}, notifyEdits: ${_this.notifyEdits})';
}


}

/// @nodoc
abstract mixin class $SnPostWatchPreferenceCopyWith<$Res>  {
  factory $SnPostWatchPreferenceCopyWith(SnPostWatchPreference value, $Res Function(SnPostWatchPreference) _then) = _$SnPostWatchPreferenceCopyWithImpl;
@useResult
$Res call({
 PostWatchSource source, bool notifyReactions, bool notifyReplies, bool notifyChains, bool notifyForwards, bool notifyEdits
});




}
/// @nodoc
class _$SnPostWatchPreferenceCopyWithImpl<$Res>
    implements $SnPostWatchPreferenceCopyWith<$Res> {
  _$SnPostWatchPreferenceCopyWithImpl(this._self, this._then);

  final SnPostWatchPreference _self;
  final $Res Function(SnPostWatchPreference) _then;

/// Create a copy of SnPostWatchPreference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? notifyReactions = null,Object? notifyReplies = null,Object? notifyChains = null,Object? notifyForwards = null,Object? notifyEdits = null,}) {
  return _then(SnPostWatchPreference(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PostWatchSource,notifyReactions: null == notifyReactions ? _self.notifyReactions : notifyReactions // ignore: cast_nullable_to_non_nullable
as bool,notifyReplies: null == notifyReplies ? _self.notifyReplies : notifyReplies // ignore: cast_nullable_to_non_nullable
as bool,notifyChains: null == notifyChains ? _self.notifyChains : notifyChains // ignore: cast_nullable_to_non_nullable
as bool,notifyForwards: null == notifyForwards ? _self.notifyForwards : notifyForwards // ignore: cast_nullable_to_non_nullable
as bool,notifyEdits: null == notifyEdits ? _self.notifyEdits : notifyEdits // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPostWatchPreference].
extension SnPostWatchPreferencePatterns on SnPostWatchPreference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostWatchPreference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostWatchPreference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostWatchPreference value)  $default,){
final _that = this;
switch (_that) {
case _SnPostWatchPreference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostWatchPreference value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostWatchPreference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostWatchSource source,  bool notifyReactions,  bool notifyReplies,  bool notifyChains,  bool notifyForwards,  bool notifyEdits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostWatchPreference() when $default != null:
return $default(_that.source,_that.notifyReactions,_that.notifyReplies,_that.notifyChains,_that.notifyForwards,_that.notifyEdits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostWatchSource source,  bool notifyReactions,  bool notifyReplies,  bool notifyChains,  bool notifyForwards,  bool notifyEdits)  $default,) {final _that = this;
switch (_that) {
case _SnPostWatchPreference():
return $default(_that.source,_that.notifyReactions,_that.notifyReplies,_that.notifyChains,_that.notifyForwards,_that.notifyEdits);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostWatchSource source,  bool notifyReactions,  bool notifyReplies,  bool notifyChains,  bool notifyForwards,  bool notifyEdits)?  $default,) {final _that = this;
switch (_that) {
case _SnPostWatchPreference() when $default != null:
return $default(_that.source,_that.notifyReactions,_that.notifyReplies,_that.notifyChains,_that.notifyForwards,_that.notifyEdits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostWatchPreference implements SnPostWatchPreference {
  const _SnPostWatchPreference({required this.source, this.notifyReactions = true, this.notifyReplies = true, this.notifyChains = true, this.notifyForwards = true, this.notifyEdits = true});
  factory _SnPostWatchPreference.fromJson(Map<String, dynamic> json) => _$SnPostWatchPreferenceFromJson(json);

@override final  PostWatchSource source;
@override@JsonKey() final  bool notifyReactions;
@override@JsonKey() final  bool notifyReplies;
@override@JsonKey() final  bool notifyChains;
@override@JsonKey() final  bool notifyForwards;
@override@JsonKey() final  bool notifyEdits;

/// Create a copy of SnPostWatchPreference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostWatchPreferenceCopyWith<_SnPostWatchPreference> get copyWith => __$SnPostWatchPreferenceCopyWithImpl<_SnPostWatchPreference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostWatchPreferenceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostWatchPreference&&(identical(other.source, source) || other.source == source)&&(identical(other.notifyReactions, notifyReactions) || other.notifyReactions == notifyReactions)&&(identical(other.notifyReplies, notifyReplies) || other.notifyReplies == notifyReplies)&&(identical(other.notifyChains, notifyChains) || other.notifyChains == notifyChains)&&(identical(other.notifyForwards, notifyForwards) || other.notifyForwards == notifyForwards)&&(identical(other.notifyEdits, notifyEdits) || other.notifyEdits == notifyEdits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,source,notifyReactions,notifyReplies,notifyChains,notifyForwards,notifyEdits);
}

@override
String toString() {
    return 'SnPostWatchPreference(source: $source, notifyReactions: $notifyReactions, notifyReplies: $notifyReplies, notifyChains: $notifyChains, notifyForwards: $notifyForwards, notifyEdits: $notifyEdits)';
}


}

/// @nodoc
abstract mixin class _$SnPostWatchPreferenceCopyWith<$Res> implements $SnPostWatchPreferenceCopyWith<$Res> {
  factory _$SnPostWatchPreferenceCopyWith(_SnPostWatchPreference value, $Res Function(_SnPostWatchPreference) _then) = __$SnPostWatchPreferenceCopyWithImpl;
@override @useResult
$Res call({
 PostWatchSource source, bool notifyReactions, bool notifyReplies, bool notifyChains, bool notifyForwards, bool notifyEdits
});




}
/// @nodoc
class __$SnPostWatchPreferenceCopyWithImpl<$Res>
    implements _$SnPostWatchPreferenceCopyWith<$Res> {
  __$SnPostWatchPreferenceCopyWithImpl(this._self, this._then);

  final _SnPostWatchPreference _self;
  final $Res Function(_SnPostWatchPreference) _then;

/// Create a copy of SnPostWatchPreference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? notifyReactions = null,Object? notifyReplies = null,Object? notifyChains = null,Object? notifyForwards = null,Object? notifyEdits = null,}) {
  return _then(_SnPostWatchPreference(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PostWatchSource,notifyReactions: null == notifyReactions ? _self.notifyReactions : notifyReactions // ignore: cast_nullable_to_non_nullable
as bool,notifyReplies: null == notifyReplies ? _self.notifyReplies : notifyReplies // ignore: cast_nullable_to_non_nullable
as bool,notifyChains: null == notifyChains ? _self.notifyChains : notifyChains // ignore: cast_nullable_to_non_nullable
as bool,notifyForwards: null == notifyForwards ? _self.notifyForwards : notifyForwards // ignore: cast_nullable_to_non_nullable
as bool,notifyEdits: null == notifyEdits ? _self.notifyEdits : notifyEdits // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
