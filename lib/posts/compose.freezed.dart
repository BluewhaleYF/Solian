// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostComposeInitialState {

 String? get cloudDraftId; String? get title; String? get description; String? get content; List<UniversalFile> get attachments; int? get visibility; SnPost? get replyingTo; SnPost? get forwardingTo; SnPost? get chainingTo; String? get calendarEventId; String? get notableDayId;
/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostComposeInitialStateCopyWith<PostComposeInitialState> get copyWith => _$PostComposeInitialStateCopyWithImpl<PostComposeInitialState>(this as PostComposeInitialState, _$identity);

  /// Serializes this PostComposeInitialState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PostComposeInitialState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostComposeInitialState&&(identical(other.cloudDraftId, _this.cloudDraftId) || other.cloudDraftId == _this.cloudDraftId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.content, _this.content) || other.content == _this.content)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.replyingTo, _this.replyingTo) || other.replyingTo == _this.replyingTo)&&(identical(other.forwardingTo, _this.forwardingTo) || other.forwardingTo == _this.forwardingTo)&&(identical(other.chainingTo, _this.chainingTo) || other.chainingTo == _this.chainingTo)&&(identical(other.calendarEventId, _this.calendarEventId) || other.calendarEventId == _this.calendarEventId)&&(identical(other.notableDayId, _this.notableDayId) || other.notableDayId == _this.notableDayId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PostComposeInitialState;
  return Object.hash(runtimeType,_this.cloudDraftId,_this.title,_this.description,_this.content,const DeepCollectionEquality().hash(_this.attachments),_this.visibility,_this.replyingTo,_this.forwardingTo,_this.chainingTo,_this.calendarEventId,_this.notableDayId);
}

@override
String toString() {
  final _this = this as PostComposeInitialState;
  return 'PostComposeInitialState(cloudDraftId: ${_this.cloudDraftId}, title: ${_this.title}, description: ${_this.description}, content: ${_this.content}, attachments: ${_this.attachments}, visibility: ${_this.visibility}, replyingTo: ${_this.replyingTo}, forwardingTo: ${_this.forwardingTo}, chainingTo: ${_this.chainingTo}, calendarEventId: ${_this.calendarEventId}, notableDayId: ${_this.notableDayId})';
}


}

/// @nodoc
abstract mixin class $PostComposeInitialStateCopyWith<$Res>  {
  factory $PostComposeInitialStateCopyWith(PostComposeInitialState value, $Res Function(PostComposeInitialState) _then) = _$PostComposeInitialStateCopyWithImpl;
@useResult
$Res call({
 String? cloudDraftId, String? title, String? description, String? content, List<UniversalFile> attachments, int? visibility, SnPost? replyingTo, SnPost? forwardingTo, SnPost? chainingTo, String? calendarEventId, String? notableDayId
});


$SnPostCopyWith<$Res>? get replyingTo;$SnPostCopyWith<$Res>? get forwardingTo;$SnPostCopyWith<$Res>? get chainingTo;

}
/// @nodoc
class _$PostComposeInitialStateCopyWithImpl<$Res>
    implements $PostComposeInitialStateCopyWith<$Res> {
  _$PostComposeInitialStateCopyWithImpl(this._self, this._then);

  final PostComposeInitialState _self;
  final $Res Function(PostComposeInitialState) _then;

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cloudDraftId = freezed,Object? title = freezed,Object? description = freezed,Object? content = freezed,Object? attachments = null,Object? visibility = freezed,Object? replyingTo = freezed,Object? forwardingTo = freezed,Object? chainingTo = freezed,Object? calendarEventId = freezed,Object? notableDayId = freezed,}) {
  return _then(PostComposeInitialState(
cloudDraftId: freezed == cloudDraftId ? _self.cloudDraftId : cloudDraftId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<UniversalFile>,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int?,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as SnPost?,forwardingTo: freezed == forwardingTo ? _self.forwardingTo : forwardingTo // ignore: cast_nullable_to_non_nullable
as SnPost?,chainingTo: freezed == chainingTo ? _self.chainingTo : chainingTo // ignore: cast_nullable_to_non_nullable
as SnPost?,calendarEventId: freezed == calendarEventId ? _self.calendarEventId : calendarEventId // ignore: cast_nullable_to_non_nullable
as String?,notableDayId: freezed == notableDayId ? _self.notableDayId : notableDayId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get replyingTo {
    if (_self.replyingTo == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.replyingTo!, (value) {
    return _then(_self.copyWith(replyingTo: value));
  });
}/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get forwardingTo {
    if (_self.forwardingTo == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.forwardingTo!, (value) {
    return _then(_self.copyWith(forwardingTo: value));
  });
}/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get chainingTo {
    if (_self.chainingTo == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.chainingTo!, (value) {
    return _then(_self.copyWith(chainingTo: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostComposeInitialState].
extension PostComposeInitialStatePatterns on PostComposeInitialState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostComposeInitialState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostComposeInitialState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostComposeInitialState value)  $default,){
final _that = this;
switch (_that) {
case _PostComposeInitialState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostComposeInitialState value)?  $default,){
final _that = this;
switch (_that) {
case _PostComposeInitialState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? cloudDraftId,  String? title,  String? description,  String? content,  List<UniversalFile> attachments,  int? visibility,  SnPost? replyingTo,  SnPost? forwardingTo,  SnPost? chainingTo,  String? calendarEventId,  String? notableDayId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostComposeInitialState() when $default != null:
return $default(_that.cloudDraftId,_that.title,_that.description,_that.content,_that.attachments,_that.visibility,_that.replyingTo,_that.forwardingTo,_that.chainingTo,_that.calendarEventId,_that.notableDayId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? cloudDraftId,  String? title,  String? description,  String? content,  List<UniversalFile> attachments,  int? visibility,  SnPost? replyingTo,  SnPost? forwardingTo,  SnPost? chainingTo,  String? calendarEventId,  String? notableDayId)  $default,) {final _that = this;
switch (_that) {
case _PostComposeInitialState():
return $default(_that.cloudDraftId,_that.title,_that.description,_that.content,_that.attachments,_that.visibility,_that.replyingTo,_that.forwardingTo,_that.chainingTo,_that.calendarEventId,_that.notableDayId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? cloudDraftId,  String? title,  String? description,  String? content,  List<UniversalFile> attachments,  int? visibility,  SnPost? replyingTo,  SnPost? forwardingTo,  SnPost? chainingTo,  String? calendarEventId,  String? notableDayId)?  $default,) {final _that = this;
switch (_that) {
case _PostComposeInitialState() when $default != null:
return $default(_that.cloudDraftId,_that.title,_that.description,_that.content,_that.attachments,_that.visibility,_that.replyingTo,_that.forwardingTo,_that.chainingTo,_that.calendarEventId,_that.notableDayId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostComposeInitialState implements PostComposeInitialState {
  const _PostComposeInitialState({this.cloudDraftId, this.title, this.description, this.content,  List<UniversalFile> attachments = const [], this.visibility, this.replyingTo, this.forwardingTo, this.chainingTo, this.calendarEventId, this.notableDayId}): _attachments = attachments;
  factory _PostComposeInitialState.fromJson(Map<String, dynamic> json) => _$PostComposeInitialStateFromJson(json);

@override final  String? cloudDraftId;
@override final  String? title;
@override final  String? description;
@override final  String? content;
 final  List<UniversalFile> _attachments;
@override@JsonKey() List<UniversalFile> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  int? visibility;
@override final  SnPost? replyingTo;
@override final  SnPost? forwardingTo;
@override final  SnPost? chainingTo;
@override final  String? calendarEventId;
@override final  String? notableDayId;

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostComposeInitialStateCopyWith<_PostComposeInitialState> get copyWith => __$PostComposeInitialStateCopyWithImpl<_PostComposeInitialState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostComposeInitialStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostComposeInitialState&&(identical(other.cloudDraftId, cloudDraftId) || other.cloudDraftId == cloudDraftId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.replyingTo, replyingTo) || other.replyingTo == replyingTo)&&(identical(other.forwardingTo, forwardingTo) || other.forwardingTo == forwardingTo)&&(identical(other.chainingTo, chainingTo) || other.chainingTo == chainingTo)&&(identical(other.calendarEventId, calendarEventId) || other.calendarEventId == calendarEventId)&&(identical(other.notableDayId, notableDayId) || other.notableDayId == notableDayId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,cloudDraftId,title,description,content,const DeepCollectionEquality().hash(_attachments),visibility,replyingTo,forwardingTo,chainingTo,calendarEventId,notableDayId);
}

@override
String toString() {
    return 'PostComposeInitialState(cloudDraftId: $cloudDraftId, title: $title, description: $description, content: $content, attachments: $attachments, visibility: $visibility, replyingTo: $replyingTo, forwardingTo: $forwardingTo, chainingTo: $chainingTo, calendarEventId: $calendarEventId, notableDayId: $notableDayId)';
}


}

/// @nodoc
abstract mixin class _$PostComposeInitialStateCopyWith<$Res> implements $PostComposeInitialStateCopyWith<$Res> {
  factory _$PostComposeInitialStateCopyWith(_PostComposeInitialState value, $Res Function(_PostComposeInitialState) _then) = __$PostComposeInitialStateCopyWithImpl;
@override @useResult
$Res call({
 String? cloudDraftId, String? title, String? description, String? content, List<UniversalFile> attachments, int? visibility, SnPost? replyingTo, SnPost? forwardingTo, SnPost? chainingTo, String? calendarEventId, String? notableDayId
});


@override $SnPostCopyWith<$Res>? get replyingTo;@override $SnPostCopyWith<$Res>? get forwardingTo;@override $SnPostCopyWith<$Res>? get chainingTo;

}
/// @nodoc
class __$PostComposeInitialStateCopyWithImpl<$Res>
    implements _$PostComposeInitialStateCopyWith<$Res> {
  __$PostComposeInitialStateCopyWithImpl(this._self, this._then);

  final _PostComposeInitialState _self;
  final $Res Function(_PostComposeInitialState) _then;

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cloudDraftId = freezed,Object? title = freezed,Object? description = freezed,Object? content = freezed,Object? attachments = null,Object? visibility = freezed,Object? replyingTo = freezed,Object? forwardingTo = freezed,Object? chainingTo = freezed,Object? calendarEventId = freezed,Object? notableDayId = freezed,}) {
  return _then(_PostComposeInitialState(
cloudDraftId: freezed == cloudDraftId ? _self.cloudDraftId : cloudDraftId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<UniversalFile>,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int?,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as SnPost?,forwardingTo: freezed == forwardingTo ? _self.forwardingTo : forwardingTo // ignore: cast_nullable_to_non_nullable
as SnPost?,chainingTo: freezed == chainingTo ? _self.chainingTo : chainingTo // ignore: cast_nullable_to_non_nullable
as SnPost?,calendarEventId: freezed == calendarEventId ? _self.calendarEventId : calendarEventId // ignore: cast_nullable_to_non_nullable
as String?,notableDayId: freezed == notableDayId ? _self.notableDayId : notableDayId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get replyingTo {
    if (_self.replyingTo == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.replyingTo!, (value) {
    return _then(_self.copyWith(replyingTo: value));
  });
}/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get forwardingTo {
    if (_self.forwardingTo == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.forwardingTo!, (value) {
    return _then(_self.copyWith(forwardingTo: value));
  });
}/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get chainingTo {
    if (_self.chainingTo == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.chainingTo!, (value) {
    return _then(_self.copyWith(chainingTo: value));
  });
}
}

// dart format on
