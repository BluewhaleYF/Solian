// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IpOverride implements DiagnosticableTreeMixin {

 String get ip; int? get port;
/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpOverrideCopyWith<IpOverride> get copyWith => _$IpOverrideCopyWithImpl<IpOverride>(this as IpOverride, _$identity);

  /// Serializes this IpOverride to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as IpOverride;
  properties
    ..add(DiagnosticsProperty('type', 'IpOverride'))
    ..add(DiagnosticsProperty('ip', _this.ip))..add(DiagnosticsProperty('port', _this.port));
}

@override
bool operator ==(Object other) {
  final _this = this as IpOverride;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpOverride&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.port, _this.port) || other.port == _this.port));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpOverride;
  return Object.hash(runtimeType,_this.ip,_this.port);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as IpOverride;
  return 'IpOverride(ip: ${_this.ip}, port: ${_this.port})';
}


}

/// @nodoc
abstract mixin class $IpOverrideCopyWith<$Res>  {
  factory $IpOverrideCopyWith(IpOverride value, $Res Function(IpOverride) _then) = _$IpOverrideCopyWithImpl;
@useResult
$Res call({
 String ip, int? port
});




}
/// @nodoc
class _$IpOverrideCopyWithImpl<$Res>
    implements $IpOverrideCopyWith<$Res> {
  _$IpOverrideCopyWithImpl(this._self, this._then);

  final IpOverride _self;
  final $Res Function(IpOverride) _then;

/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? port = freezed,}) {
  return _then(IpOverride(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpOverride].
extension IpOverridePatterns on IpOverride {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpOverride value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpOverride value)  $default,){
final _that = this;
switch (_that) {
case _IpOverride():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpOverride value)?  $default,){
final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  int? port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
return $default(_that.ip,_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  int? port)  $default,) {final _that = this;
switch (_that) {
case _IpOverride():
return $default(_that.ip,_that.port);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  int? port)?  $default,) {final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
return $default(_that.ip,_that.port);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpOverride with DiagnosticableTreeMixin implements IpOverride {
  const _IpOverride({required this.ip, this.port});
  factory _IpOverride.fromJson(Map<String, dynamic> json) => _$IpOverrideFromJson(json);

@override final  String ip;
@override final  int? port;

/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpOverrideCopyWith<_IpOverride> get copyWith => __$IpOverrideCopyWithImpl<_IpOverride>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpOverrideToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'IpOverride'))
    ..add(DiagnosticsProperty('ip', ip))..add(DiagnosticsProperty('port', port));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpOverride&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.port, port) || other.port == port));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ip,port);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'IpOverride(ip: $ip, port: $port)';
}


}

/// @nodoc
abstract mixin class _$IpOverrideCopyWith<$Res> implements $IpOverrideCopyWith<$Res> {
  factory _$IpOverrideCopyWith(_IpOverride value, $Res Function(_IpOverride) _then) = __$IpOverrideCopyWithImpl;
@override @useResult
$Res call({
 String ip, int? port
});




}
/// @nodoc
class __$IpOverrideCopyWithImpl<$Res>
    implements _$IpOverrideCopyWith<$Res> {
  __$IpOverrideCopyWithImpl(this._self, this._then);

  final _IpOverride _self;
  final $Res Function(_IpOverride) _then;

/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? port = freezed,}) {
  return _then(_IpOverride(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$IpOverrideSettings implements DiagnosticableTreeMixin {

 bool get enabled; List<IpOverride> get overrides;
/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpOverrideSettingsCopyWith<IpOverrideSettings> get copyWith => _$IpOverrideSettingsCopyWithImpl<IpOverrideSettings>(this as IpOverrideSettings, _$identity);

  /// Serializes this IpOverrideSettings to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as IpOverrideSettings;
  properties
    ..add(DiagnosticsProperty('type', 'IpOverrideSettings'))
    ..add(DiagnosticsProperty('enabled', _this.enabled))..add(DiagnosticsProperty('overrides', _this.overrides));
}

@override
bool operator ==(Object other) {
  final _this = this as IpOverrideSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpOverrideSettings&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&const DeepCollectionEquality().equals(other.overrides, _this.overrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IpOverrideSettings;
  return Object.hash(runtimeType,_this.enabled,const DeepCollectionEquality().hash(_this.overrides));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as IpOverrideSettings;
  return 'IpOverrideSettings(enabled: ${_this.enabled}, overrides: ${_this.overrides})';
}


}

/// @nodoc
abstract mixin class $IpOverrideSettingsCopyWith<$Res>  {
  factory $IpOverrideSettingsCopyWith(IpOverrideSettings value, $Res Function(IpOverrideSettings) _then) = _$IpOverrideSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, List<IpOverride> overrides
});




}
/// @nodoc
class _$IpOverrideSettingsCopyWithImpl<$Res>
    implements $IpOverrideSettingsCopyWith<$Res> {
  _$IpOverrideSettingsCopyWithImpl(this._self, this._then);

  final IpOverrideSettings _self;
  final $Res Function(IpOverrideSettings) _then;

/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? overrides = null,}) {
  return _then(IpOverrideSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as List<IpOverride>,
  ));
}

}


/// Adds pattern-matching-related methods to [IpOverrideSettings].
extension IpOverrideSettingsPatterns on IpOverrideSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpOverrideSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpOverrideSettings value)  $default,){
final _that = this;
switch (_that) {
case _IpOverrideSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpOverrideSettings value)?  $default,){
final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  List<IpOverride> overrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
return $default(_that.enabled,_that.overrides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  List<IpOverride> overrides)  $default,) {final _that = this;
switch (_that) {
case _IpOverrideSettings():
return $default(_that.enabled,_that.overrides);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  List<IpOverride> overrides)?  $default,) {final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
return $default(_that.enabled,_that.overrides);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpOverrideSettings with DiagnosticableTreeMixin implements IpOverrideSettings {
  const _IpOverrideSettings({required this.enabled, required  List<IpOverride> overrides}): _overrides = overrides;
  factory _IpOverrideSettings.fromJson(Map<String, dynamic> json) => _$IpOverrideSettingsFromJson(json);

@override final  bool enabled;
 final  List<IpOverride> _overrides;
@override List<IpOverride> get overrides {
  if (_overrides is EqualUnmodifiableListView) return _overrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_overrides);
}


/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpOverrideSettingsCopyWith<_IpOverrideSettings> get copyWith => __$IpOverrideSettingsCopyWithImpl<_IpOverrideSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpOverrideSettingsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'IpOverrideSettings'))
    ..add(DiagnosticsProperty('enabled', enabled))..add(DiagnosticsProperty('overrides', overrides));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpOverrideSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.overrides, _overrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,const DeepCollectionEquality().hash(_overrides));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'IpOverrideSettings(enabled: $enabled, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class _$IpOverrideSettingsCopyWith<$Res> implements $IpOverrideSettingsCopyWith<$Res> {
  factory _$IpOverrideSettingsCopyWith(_IpOverrideSettings value, $Res Function(_IpOverrideSettings) _then) = __$IpOverrideSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, List<IpOverride> overrides
});




}
/// @nodoc
class __$IpOverrideSettingsCopyWithImpl<$Res>
    implements _$IpOverrideSettingsCopyWith<$Res> {
  __$IpOverrideSettingsCopyWithImpl(this._self, this._then);

  final _IpOverrideSettings _self;
  final $Res Function(_IpOverrideSettings) _then;

/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? overrides = null,}) {
  return _then(_IpOverrideSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,overrides: null == overrides ? _self._overrides : overrides // ignore: cast_nullable_to_non_nullable
as List<IpOverride>,
  ));
}


}


/// @nodoc
mixin _$ThemeColors implements DiagnosticableTreeMixin {

 int? get primary; int? get onPrimary; int? get primaryContainer; int? get secondary; int? get onSecondary; int? get secondaryContainer; int? get tertiary; int? get onTertiary; int? get tertiaryContainer; int? get surface; int? get surfaceContainerHighest; int? get background; int? get outline; int? get shadow; int? get error;
/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<ThemeColors> get copyWith => _$ThemeColorsCopyWithImpl<ThemeColors>(this as ThemeColors, _$identity);

  /// Serializes this ThemeColors to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as ThemeColors;
  properties
    ..add(DiagnosticsProperty('type', 'ThemeColors'))
    ..add(DiagnosticsProperty('primary', _this.primary))..add(DiagnosticsProperty('onPrimary', _this.onPrimary))..add(DiagnosticsProperty('primaryContainer', _this.primaryContainer))..add(DiagnosticsProperty('secondary', _this.secondary))..add(DiagnosticsProperty('onSecondary', _this.onSecondary))..add(DiagnosticsProperty('secondaryContainer', _this.secondaryContainer))..add(DiagnosticsProperty('tertiary', _this.tertiary))..add(DiagnosticsProperty('onTertiary', _this.onTertiary))..add(DiagnosticsProperty('tertiaryContainer', _this.tertiaryContainer))..add(DiagnosticsProperty('surface', _this.surface))..add(DiagnosticsProperty('surfaceContainerHighest', _this.surfaceContainerHighest))..add(DiagnosticsProperty('background', _this.background))..add(DiagnosticsProperty('outline', _this.outline))..add(DiagnosticsProperty('shadow', _this.shadow))..add(DiagnosticsProperty('error', _this.error));
}

@override
bool operator ==(Object other) {
  final _this = this as ThemeColors;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeColors&&(identical(other.primary, _this.primary) || other.primary == _this.primary)&&(identical(other.onPrimary, _this.onPrimary) || other.onPrimary == _this.onPrimary)&&(identical(other.primaryContainer, _this.primaryContainer) || other.primaryContainer == _this.primaryContainer)&&(identical(other.secondary, _this.secondary) || other.secondary == _this.secondary)&&(identical(other.onSecondary, _this.onSecondary) || other.onSecondary == _this.onSecondary)&&(identical(other.secondaryContainer, _this.secondaryContainer) || other.secondaryContainer == _this.secondaryContainer)&&(identical(other.tertiary, _this.tertiary) || other.tertiary == _this.tertiary)&&(identical(other.onTertiary, _this.onTertiary) || other.onTertiary == _this.onTertiary)&&(identical(other.tertiaryContainer, _this.tertiaryContainer) || other.tertiaryContainer == _this.tertiaryContainer)&&(identical(other.surface, _this.surface) || other.surface == _this.surface)&&(identical(other.surfaceContainerHighest, _this.surfaceContainerHighest) || other.surfaceContainerHighest == _this.surfaceContainerHighest)&&(identical(other.background, _this.background) || other.background == _this.background)&&(identical(other.outline, _this.outline) || other.outline == _this.outline)&&(identical(other.shadow, _this.shadow) || other.shadow == _this.shadow)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThemeColors;
  return Object.hash(runtimeType,_this.primary,_this.onPrimary,_this.primaryContainer,_this.secondary,_this.onSecondary,_this.secondaryContainer,_this.tertiary,_this.onTertiary,_this.tertiaryContainer,_this.surface,_this.surfaceContainerHighest,_this.background,_this.outline,_this.shadow,_this.error);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as ThemeColors;
  return 'ThemeColors(primary: ${_this.primary}, onPrimary: ${_this.onPrimary}, primaryContainer: ${_this.primaryContainer}, secondary: ${_this.secondary}, onSecondary: ${_this.onSecondary}, secondaryContainer: ${_this.secondaryContainer}, tertiary: ${_this.tertiary}, onTertiary: ${_this.onTertiary}, tertiaryContainer: ${_this.tertiaryContainer}, surface: ${_this.surface}, surfaceContainerHighest: ${_this.surfaceContainerHighest}, background: ${_this.background}, outline: ${_this.outline}, shadow: ${_this.shadow}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ThemeColorsCopyWith<$Res>  {
  factory $ThemeColorsCopyWith(ThemeColors value, $Res Function(ThemeColors) _then) = _$ThemeColorsCopyWithImpl;
@useResult
$Res call({
 int? primary, int? onPrimary, int? primaryContainer, int? secondary, int? onSecondary, int? secondaryContainer, int? tertiary, int? onTertiary, int? tertiaryContainer, int? surface, int? surfaceContainerHighest, int? background, int? outline, int? shadow, int? error
});




}
/// @nodoc
class _$ThemeColorsCopyWithImpl<$Res>
    implements $ThemeColorsCopyWith<$Res> {
  _$ThemeColorsCopyWithImpl(this._self, this._then);

  final ThemeColors _self;
  final $Res Function(ThemeColors) _then;

/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primary = freezed,Object? onPrimary = freezed,Object? primaryContainer = freezed,Object? secondary = freezed,Object? onSecondary = freezed,Object? secondaryContainer = freezed,Object? tertiary = freezed,Object? onTertiary = freezed,Object? tertiaryContainer = freezed,Object? surface = freezed,Object? surfaceContainerHighest = freezed,Object? background = freezed,Object? outline = freezed,Object? shadow = freezed,Object? error = freezed,}) {
  return _then(ThemeColors(
primary: freezed == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int?,onPrimary: freezed == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as int?,primaryContainer: freezed == primaryContainer ? _self.primaryContainer : primaryContainer // ignore: cast_nullable_to_non_nullable
as int?,secondary: freezed == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as int?,onSecondary: freezed == onSecondary ? _self.onSecondary : onSecondary // ignore: cast_nullable_to_non_nullable
as int?,secondaryContainer: freezed == secondaryContainer ? _self.secondaryContainer : secondaryContainer // ignore: cast_nullable_to_non_nullable
as int?,tertiary: freezed == tertiary ? _self.tertiary : tertiary // ignore: cast_nullable_to_non_nullable
as int?,onTertiary: freezed == onTertiary ? _self.onTertiary : onTertiary // ignore: cast_nullable_to_non_nullable
as int?,tertiaryContainer: freezed == tertiaryContainer ? _self.tertiaryContainer : tertiaryContainer // ignore: cast_nullable_to_non_nullable
as int?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int?,surfaceContainerHighest: freezed == surfaceContainerHighest ? _self.surfaceContainerHighest : surfaceContainerHighest // ignore: cast_nullable_to_non_nullable
as int?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as int?,outline: freezed == outline ? _self.outline : outline // ignore: cast_nullable_to_non_nullable
as int?,shadow: freezed == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeColors].
extension ThemeColorsPatterns on ThemeColors {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeColors value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeColors value)  $default,){
final _that = this;
switch (_that) {
case _ThemeColors():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeColors value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primary,  int? onPrimary,  int? primaryContainer,  int? secondary,  int? onSecondary,  int? secondaryContainer,  int? tertiary,  int? onTertiary,  int? tertiaryContainer,  int? surface,  int? surfaceContainerHighest,  int? background,  int? outline,  int? shadow,  int? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
return $default(_that.primary,_that.onPrimary,_that.primaryContainer,_that.secondary,_that.onSecondary,_that.secondaryContainer,_that.tertiary,_that.onTertiary,_that.tertiaryContainer,_that.surface,_that.surfaceContainerHighest,_that.background,_that.outline,_that.shadow,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primary,  int? onPrimary,  int? primaryContainer,  int? secondary,  int? onSecondary,  int? secondaryContainer,  int? tertiary,  int? onTertiary,  int? tertiaryContainer,  int? surface,  int? surfaceContainerHighest,  int? background,  int? outline,  int? shadow,  int? error)  $default,) {final _that = this;
switch (_that) {
case _ThemeColors():
return $default(_that.primary,_that.onPrimary,_that.primaryContainer,_that.secondary,_that.onSecondary,_that.secondaryContainer,_that.tertiary,_that.onTertiary,_that.tertiaryContainer,_that.surface,_that.surfaceContainerHighest,_that.background,_that.outline,_that.shadow,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primary,  int? onPrimary,  int? primaryContainer,  int? secondary,  int? onSecondary,  int? secondaryContainer,  int? tertiary,  int? onTertiary,  int? tertiaryContainer,  int? surface,  int? surfaceContainerHighest,  int? background,  int? outline,  int? shadow,  int? error)?  $default,) {final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
return $default(_that.primary,_that.onPrimary,_that.primaryContainer,_that.secondary,_that.onSecondary,_that.secondaryContainer,_that.tertiary,_that.onTertiary,_that.tertiaryContainer,_that.surface,_that.surfaceContainerHighest,_that.background,_that.outline,_that.shadow,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeColors with DiagnosticableTreeMixin implements ThemeColors {
   _ThemeColors({this.primary, this.onPrimary, this.primaryContainer, this.secondary, this.onSecondary, this.secondaryContainer, this.tertiary, this.onTertiary, this.tertiaryContainer, this.surface, this.surfaceContainerHighest, this.background, this.outline, this.shadow, this.error});
  factory _ThemeColors.fromJson(Map<String, dynamic> json) => _$ThemeColorsFromJson(json);

@override final  int? primary;
@override final  int? onPrimary;
@override final  int? primaryContainer;
@override final  int? secondary;
@override final  int? onSecondary;
@override final  int? secondaryContainer;
@override final  int? tertiary;
@override final  int? onTertiary;
@override final  int? tertiaryContainer;
@override final  int? surface;
@override final  int? surfaceContainerHighest;
@override final  int? background;
@override final  int? outline;
@override final  int? shadow;
@override final  int? error;

/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeColorsCopyWith<_ThemeColors> get copyWith => __$ThemeColorsCopyWithImpl<_ThemeColors>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemeColorsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'ThemeColors'))
    ..add(DiagnosticsProperty('primary', primary))..add(DiagnosticsProperty('onPrimary', onPrimary))..add(DiagnosticsProperty('primaryContainer', primaryContainer))..add(DiagnosticsProperty('secondary', secondary))..add(DiagnosticsProperty('onSecondary', onSecondary))..add(DiagnosticsProperty('secondaryContainer', secondaryContainer))..add(DiagnosticsProperty('tertiary', tertiary))..add(DiagnosticsProperty('onTertiary', onTertiary))..add(DiagnosticsProperty('tertiaryContainer', tertiaryContainer))..add(DiagnosticsProperty('surface', surface))..add(DiagnosticsProperty('surfaceContainerHighest', surfaceContainerHighest))..add(DiagnosticsProperty('background', background))..add(DiagnosticsProperty('outline', outline))..add(DiagnosticsProperty('shadow', shadow))..add(DiagnosticsProperty('error', error));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.onPrimary, onPrimary) || other.onPrimary == onPrimary)&&(identical(other.primaryContainer, primaryContainer) || other.primaryContainer == primaryContainer)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.onSecondary, onSecondary) || other.onSecondary == onSecondary)&&(identical(other.secondaryContainer, secondaryContainer) || other.secondaryContainer == secondaryContainer)&&(identical(other.tertiary, tertiary) || other.tertiary == tertiary)&&(identical(other.onTertiary, onTertiary) || other.onTertiary == onTertiary)&&(identical(other.tertiaryContainer, tertiaryContainer) || other.tertiaryContainer == tertiaryContainer)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.surfaceContainerHighest, surfaceContainerHighest) || other.surfaceContainerHighest == surfaceContainerHighest)&&(identical(other.background, background) || other.background == background)&&(identical(other.outline, outline) || other.outline == outline)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,primary,onPrimary,primaryContainer,secondary,onSecondary,secondaryContainer,tertiary,onTertiary,tertiaryContainer,surface,surfaceContainerHighest,background,outline,shadow,error);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'ThemeColors(primary: $primary, onPrimary: $onPrimary, primaryContainer: $primaryContainer, secondary: $secondary, onSecondary: $onSecondary, secondaryContainer: $secondaryContainer, tertiary: $tertiary, onTertiary: $onTertiary, tertiaryContainer: $tertiaryContainer, surface: $surface, surfaceContainerHighest: $surfaceContainerHighest, background: $background, outline: $outline, shadow: $shadow, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ThemeColorsCopyWith<$Res> implements $ThemeColorsCopyWith<$Res> {
  factory _$ThemeColorsCopyWith(_ThemeColors value, $Res Function(_ThemeColors) _then) = __$ThemeColorsCopyWithImpl;
@override @useResult
$Res call({
 int? primary, int? onPrimary, int? primaryContainer, int? secondary, int? onSecondary, int? secondaryContainer, int? tertiary, int? onTertiary, int? tertiaryContainer, int? surface, int? surfaceContainerHighest, int? background, int? outline, int? shadow, int? error
});




}
/// @nodoc
class __$ThemeColorsCopyWithImpl<$Res>
    implements _$ThemeColorsCopyWith<$Res> {
  __$ThemeColorsCopyWithImpl(this._self, this._then);

  final _ThemeColors _self;
  final $Res Function(_ThemeColors) _then;

/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primary = freezed,Object? onPrimary = freezed,Object? primaryContainer = freezed,Object? secondary = freezed,Object? onSecondary = freezed,Object? secondaryContainer = freezed,Object? tertiary = freezed,Object? onTertiary = freezed,Object? tertiaryContainer = freezed,Object? surface = freezed,Object? surfaceContainerHighest = freezed,Object? background = freezed,Object? outline = freezed,Object? shadow = freezed,Object? error = freezed,}) {
  return _then(_ThemeColors(
primary: freezed == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int?,onPrimary: freezed == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as int?,primaryContainer: freezed == primaryContainer ? _self.primaryContainer : primaryContainer // ignore: cast_nullable_to_non_nullable
as int?,secondary: freezed == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as int?,onSecondary: freezed == onSecondary ? _self.onSecondary : onSecondary // ignore: cast_nullable_to_non_nullable
as int?,secondaryContainer: freezed == secondaryContainer ? _self.secondaryContainer : secondaryContainer // ignore: cast_nullable_to_non_nullable
as int?,tertiary: freezed == tertiary ? _self.tertiary : tertiary // ignore: cast_nullable_to_non_nullable
as int?,onTertiary: freezed == onTertiary ? _self.onTertiary : onTertiary // ignore: cast_nullable_to_non_nullable
as int?,tertiaryContainer: freezed == tertiaryContainer ? _self.tertiaryContainer : tertiaryContainer // ignore: cast_nullable_to_non_nullable
as int?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int?,surfaceContainerHighest: freezed == surfaceContainerHighest ? _self.surfaceContainerHighest : surfaceContainerHighest // ignore: cast_nullable_to_non_nullable
as int?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as int?,outline: freezed == outline ? _self.outline : outline // ignore: cast_nullable_to_non_nullable
as int?,shadow: freezed == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DashboardConfig implements DiagnosticableTreeMixin {

 List<String> get verticalLayouts; List<String> get horizontalLayouts; bool get showSearchBar; bool get showClockAndCountdown; bool get countdownIncludeNotableDays;
/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<DashboardConfig> get copyWith => _$DashboardConfigCopyWithImpl<DashboardConfig>(this as DashboardConfig, _$identity);

  /// Serializes this DashboardConfig to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as DashboardConfig;
  properties
    ..add(DiagnosticsProperty('type', 'DashboardConfig'))
    ..add(DiagnosticsProperty('verticalLayouts', _this.verticalLayouts))..add(DiagnosticsProperty('horizontalLayouts', _this.horizontalLayouts))..add(DiagnosticsProperty('showSearchBar', _this.showSearchBar))..add(DiagnosticsProperty('showClockAndCountdown', _this.showClockAndCountdown))..add(DiagnosticsProperty('countdownIncludeNotableDays', _this.countdownIncludeNotableDays));
}

@override
bool operator ==(Object other) {
  final _this = this as DashboardConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardConfig&&const DeepCollectionEquality().equals(other.verticalLayouts, _this.verticalLayouts)&&const DeepCollectionEquality().equals(other.horizontalLayouts, _this.horizontalLayouts)&&(identical(other.showSearchBar, _this.showSearchBar) || other.showSearchBar == _this.showSearchBar)&&(identical(other.showClockAndCountdown, _this.showClockAndCountdown) || other.showClockAndCountdown == _this.showClockAndCountdown)&&(identical(other.countdownIncludeNotableDays, _this.countdownIncludeNotableDays) || other.countdownIncludeNotableDays == _this.countdownIncludeNotableDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.verticalLayouts),const DeepCollectionEquality().hash(_this.horizontalLayouts),_this.showSearchBar,_this.showClockAndCountdown,_this.countdownIncludeNotableDays);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as DashboardConfig;
  return 'DashboardConfig(verticalLayouts: ${_this.verticalLayouts}, horizontalLayouts: ${_this.horizontalLayouts}, showSearchBar: ${_this.showSearchBar}, showClockAndCountdown: ${_this.showClockAndCountdown}, countdownIncludeNotableDays: ${_this.countdownIncludeNotableDays})';
}


}

/// @nodoc
abstract mixin class $DashboardConfigCopyWith<$Res>  {
  factory $DashboardConfigCopyWith(DashboardConfig value, $Res Function(DashboardConfig) _then) = _$DashboardConfigCopyWithImpl;
@useResult
$Res call({
 List<String> verticalLayouts, List<String> horizontalLayouts, bool showSearchBar, bool showClockAndCountdown, bool countdownIncludeNotableDays
});




}
/// @nodoc
class _$DashboardConfigCopyWithImpl<$Res>
    implements $DashboardConfigCopyWith<$Res> {
  _$DashboardConfigCopyWithImpl(this._self, this._then);

  final DashboardConfig _self;
  final $Res Function(DashboardConfig) _then;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verticalLayouts = null,Object? horizontalLayouts = null,Object? showSearchBar = null,Object? showClockAndCountdown = null,Object? countdownIncludeNotableDays = null,}) {
  return _then(DashboardConfig(
verticalLayouts: null == verticalLayouts ? _self.verticalLayouts : verticalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,horizontalLayouts: null == horizontalLayouts ? _self.horizontalLayouts : horizontalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,showSearchBar: null == showSearchBar ? _self.showSearchBar : showSearchBar // ignore: cast_nullable_to_non_nullable
as bool,showClockAndCountdown: null == showClockAndCountdown ? _self.showClockAndCountdown : showClockAndCountdown // ignore: cast_nullable_to_non_nullable
as bool,countdownIncludeNotableDays: null == countdownIncludeNotableDays ? _self.countdownIncludeNotableDays : countdownIncludeNotableDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardConfig].
extension DashboardConfigPatterns on DashboardConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardConfig value)  $default,){
final _that = this;
switch (_that) {
case _DashboardConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> verticalLayouts,  List<String> horizontalLayouts,  bool showSearchBar,  bool showClockAndCountdown,  bool countdownIncludeNotableDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
return $default(_that.verticalLayouts,_that.horizontalLayouts,_that.showSearchBar,_that.showClockAndCountdown,_that.countdownIncludeNotableDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> verticalLayouts,  List<String> horizontalLayouts,  bool showSearchBar,  bool showClockAndCountdown,  bool countdownIncludeNotableDays)  $default,) {final _that = this;
switch (_that) {
case _DashboardConfig():
return $default(_that.verticalLayouts,_that.horizontalLayouts,_that.showSearchBar,_that.showClockAndCountdown,_that.countdownIncludeNotableDays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> verticalLayouts,  List<String> horizontalLayouts,  bool showSearchBar,  bool showClockAndCountdown,  bool countdownIncludeNotableDays)?  $default,) {final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
return $default(_that.verticalLayouts,_that.horizontalLayouts,_that.showSearchBar,_that.showClockAndCountdown,_that.countdownIncludeNotableDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardConfig with DiagnosticableTreeMixin implements DashboardConfig {
   _DashboardConfig({required  List<String> verticalLayouts, required  List<String> horizontalLayouts, required this.showSearchBar, required this.showClockAndCountdown, this.countdownIncludeNotableDays = true}): _verticalLayouts = verticalLayouts,_horizontalLayouts = horizontalLayouts;
  factory _DashboardConfig.fromJson(Map<String, dynamic> json) => _$DashboardConfigFromJson(json);

 final  List<String> _verticalLayouts;
@override List<String> get verticalLayouts {
  if (_verticalLayouts is EqualUnmodifiableListView) return _verticalLayouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verticalLayouts);
}

 final  List<String> _horizontalLayouts;
@override List<String> get horizontalLayouts {
  if (_horizontalLayouts is EqualUnmodifiableListView) return _horizontalLayouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_horizontalLayouts);
}

@override final  bool showSearchBar;
@override final  bool showClockAndCountdown;
@override@JsonKey() final  bool countdownIncludeNotableDays;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardConfigCopyWith<_DashboardConfig> get copyWith => __$DashboardConfigCopyWithImpl<_DashboardConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardConfigToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'DashboardConfig'))
    ..add(DiagnosticsProperty('verticalLayouts', verticalLayouts))..add(DiagnosticsProperty('horizontalLayouts', horizontalLayouts))..add(DiagnosticsProperty('showSearchBar', showSearchBar))..add(DiagnosticsProperty('showClockAndCountdown', showClockAndCountdown))..add(DiagnosticsProperty('countdownIncludeNotableDays', countdownIncludeNotableDays));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardConfig&&const DeepCollectionEquality().equals(other.verticalLayouts, _verticalLayouts)&&const DeepCollectionEquality().equals(other.horizontalLayouts, _horizontalLayouts)&&(identical(other.showSearchBar, showSearchBar) || other.showSearchBar == showSearchBar)&&(identical(other.showClockAndCountdown, showClockAndCountdown) || other.showClockAndCountdown == showClockAndCountdown)&&(identical(other.countdownIncludeNotableDays, countdownIncludeNotableDays) || other.countdownIncludeNotableDays == countdownIncludeNotableDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_verticalLayouts),const DeepCollectionEquality().hash(_horizontalLayouts),showSearchBar,showClockAndCountdown,countdownIncludeNotableDays);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'DashboardConfig(verticalLayouts: $verticalLayouts, horizontalLayouts: $horizontalLayouts, showSearchBar: $showSearchBar, showClockAndCountdown: $showClockAndCountdown, countdownIncludeNotableDays: $countdownIncludeNotableDays)';
}


}

/// @nodoc
abstract mixin class _$DashboardConfigCopyWith<$Res> implements $DashboardConfigCopyWith<$Res> {
  factory _$DashboardConfigCopyWith(_DashboardConfig value, $Res Function(_DashboardConfig) _then) = __$DashboardConfigCopyWithImpl;
@override @useResult
$Res call({
 List<String> verticalLayouts, List<String> horizontalLayouts, bool showSearchBar, bool showClockAndCountdown, bool countdownIncludeNotableDays
});




}
/// @nodoc
class __$DashboardConfigCopyWithImpl<$Res>
    implements _$DashboardConfigCopyWith<$Res> {
  __$DashboardConfigCopyWithImpl(this._self, this._then);

  final _DashboardConfig _self;
  final $Res Function(_DashboardConfig) _then;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verticalLayouts = null,Object? horizontalLayouts = null,Object? showSearchBar = null,Object? showClockAndCountdown = null,Object? countdownIncludeNotableDays = null,}) {
  return _then(_DashboardConfig(
verticalLayouts: null == verticalLayouts ? _self._verticalLayouts : verticalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,horizontalLayouts: null == horizontalLayouts ? _self._horizontalLayouts : horizontalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,showSearchBar: null == showSearchBar ? _self.showSearchBar : showSearchBar // ignore: cast_nullable_to_non_nullable
as bool,showClockAndCountdown: null == showClockAndCountdown ? _self.showClockAndCountdown : showClockAndCountdown // ignore: cast_nullable_to_non_nullable
as bool,countdownIncludeNotableDays: null == countdownIncludeNotableDays ? _self.countdownIncludeNotableDays : countdownIncludeNotableDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ExploreSettings implements DiagnosticableTreeMixin {

 String get mode; bool get aggressiveMode; List<String> get selectedPublisherNames; List<String> get selectedCategoryIds; List<String> get selectedTagIds;
/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreSettingsCopyWith<ExploreSettings> get copyWith => _$ExploreSettingsCopyWithImpl<ExploreSettings>(this as ExploreSettings, _$identity);

  /// Serializes this ExploreSettings to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as ExploreSettings;
  properties
    ..add(DiagnosticsProperty('type', 'ExploreSettings'))
    ..add(DiagnosticsProperty('mode', _this.mode))..add(DiagnosticsProperty('aggressiveMode', _this.aggressiveMode))..add(DiagnosticsProperty('selectedPublisherNames', _this.selectedPublisherNames))..add(DiagnosticsProperty('selectedCategoryIds', _this.selectedCategoryIds))..add(DiagnosticsProperty('selectedTagIds', _this.selectedTagIds));
}

@override
bool operator ==(Object other) {
  final _this = this as ExploreSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreSettings&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.aggressiveMode, _this.aggressiveMode) || other.aggressiveMode == _this.aggressiveMode)&&const DeepCollectionEquality().equals(other.selectedPublisherNames, _this.selectedPublisherNames)&&const DeepCollectionEquality().equals(other.selectedCategoryIds, _this.selectedCategoryIds)&&const DeepCollectionEquality().equals(other.selectedTagIds, _this.selectedTagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExploreSettings;
  return Object.hash(runtimeType,_this.mode,_this.aggressiveMode,const DeepCollectionEquality().hash(_this.selectedPublisherNames),const DeepCollectionEquality().hash(_this.selectedCategoryIds),const DeepCollectionEquality().hash(_this.selectedTagIds));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as ExploreSettings;
  return 'ExploreSettings(mode: ${_this.mode}, aggressiveMode: ${_this.aggressiveMode}, selectedPublisherNames: ${_this.selectedPublisherNames}, selectedCategoryIds: ${_this.selectedCategoryIds}, selectedTagIds: ${_this.selectedTagIds})';
}


}

/// @nodoc
abstract mixin class $ExploreSettingsCopyWith<$Res>  {
  factory $ExploreSettingsCopyWith(ExploreSettings value, $Res Function(ExploreSettings) _then) = _$ExploreSettingsCopyWithImpl;
@useResult
$Res call({
 String mode, bool aggressiveMode, List<String> selectedPublisherNames, List<String> selectedCategoryIds, List<String> selectedTagIds
});




}
/// @nodoc
class _$ExploreSettingsCopyWithImpl<$Res>
    implements $ExploreSettingsCopyWith<$Res> {
  _$ExploreSettingsCopyWithImpl(this._self, this._then);

  final ExploreSettings _self;
  final $Res Function(ExploreSettings) _then;

/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? aggressiveMode = null,Object? selectedPublisherNames = null,Object? selectedCategoryIds = null,Object? selectedTagIds = null,}) {
  return _then(ExploreSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,aggressiveMode: null == aggressiveMode ? _self.aggressiveMode : aggressiveMode // ignore: cast_nullable_to_non_nullable
as bool,selectedPublisherNames: null == selectedPublisherNames ? _self.selectedPublisherNames : selectedPublisherNames // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategoryIds: null == selectedCategoryIds ? _self.selectedCategoryIds : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedTagIds: null == selectedTagIds ? _self.selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreSettings].
extension ExploreSettingsPatterns on ExploreSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreSettings value)  $default,){
final _that = this;
switch (_that) {
case _ExploreSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mode,  bool aggressiveMode,  List<String> selectedPublisherNames,  List<String> selectedCategoryIds,  List<String> selectedTagIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
return $default(_that.mode,_that.aggressiveMode,_that.selectedPublisherNames,_that.selectedCategoryIds,_that.selectedTagIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mode,  bool aggressiveMode,  List<String> selectedPublisherNames,  List<String> selectedCategoryIds,  List<String> selectedTagIds)  $default,) {final _that = this;
switch (_that) {
case _ExploreSettings():
return $default(_that.mode,_that.aggressiveMode,_that.selectedPublisherNames,_that.selectedCategoryIds,_that.selectedTagIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mode,  bool aggressiveMode,  List<String> selectedPublisherNames,  List<String> selectedCategoryIds,  List<String> selectedTagIds)?  $default,) {final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
return $default(_that.mode,_that.aggressiveMode,_that.selectedPublisherNames,_that.selectedCategoryIds,_that.selectedTagIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExploreSettings with DiagnosticableTreeMixin implements ExploreSettings {
  const _ExploreSettings({this.mode = 'personalized', this.aggressiveMode = true,  List<String> selectedPublisherNames = const <String>[],  List<String> selectedCategoryIds = const <String>[],  List<String> selectedTagIds = const <String>[]}): _selectedPublisherNames = selectedPublisherNames,_selectedCategoryIds = selectedCategoryIds,_selectedTagIds = selectedTagIds;
  factory _ExploreSettings.fromJson(Map<String, dynamic> json) => _$ExploreSettingsFromJson(json);

@override@JsonKey() final  String mode;
@override@JsonKey() final  bool aggressiveMode;
 final  List<String> _selectedPublisherNames;
@override@JsonKey() List<String> get selectedPublisherNames {
  if (_selectedPublisherNames is EqualUnmodifiableListView) return _selectedPublisherNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedPublisherNames);
}

 final  List<String> _selectedCategoryIds;
@override@JsonKey() List<String> get selectedCategoryIds {
  if (_selectedCategoryIds is EqualUnmodifiableListView) return _selectedCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedCategoryIds);
}

 final  List<String> _selectedTagIds;
@override@JsonKey() List<String> get selectedTagIds {
  if (_selectedTagIds is EqualUnmodifiableListView) return _selectedTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagIds);
}


/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreSettingsCopyWith<_ExploreSettings> get copyWith => __$ExploreSettingsCopyWithImpl<_ExploreSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExploreSettingsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'ExploreSettings'))
    ..add(DiagnosticsProperty('mode', mode))..add(DiagnosticsProperty('aggressiveMode', aggressiveMode))..add(DiagnosticsProperty('selectedPublisherNames', selectedPublisherNames))..add(DiagnosticsProperty('selectedCategoryIds', selectedCategoryIds))..add(DiagnosticsProperty('selectedTagIds', selectedTagIds));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.aggressiveMode, aggressiveMode) || other.aggressiveMode == aggressiveMode)&&const DeepCollectionEquality().equals(other.selectedPublisherNames, _selectedPublisherNames)&&const DeepCollectionEquality().equals(other.selectedCategoryIds, _selectedCategoryIds)&&const DeepCollectionEquality().equals(other.selectedTagIds, _selectedTagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mode,aggressiveMode,const DeepCollectionEquality().hash(_selectedPublisherNames),const DeepCollectionEquality().hash(_selectedCategoryIds),const DeepCollectionEquality().hash(_selectedTagIds));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'ExploreSettings(mode: $mode, aggressiveMode: $aggressiveMode, selectedPublisherNames: $selectedPublisherNames, selectedCategoryIds: $selectedCategoryIds, selectedTagIds: $selectedTagIds)';
}


}

/// @nodoc
abstract mixin class _$ExploreSettingsCopyWith<$Res> implements $ExploreSettingsCopyWith<$Res> {
  factory _$ExploreSettingsCopyWith(_ExploreSettings value, $Res Function(_ExploreSettings) _then) = __$ExploreSettingsCopyWithImpl;
@override @useResult
$Res call({
 String mode, bool aggressiveMode, List<String> selectedPublisherNames, List<String> selectedCategoryIds, List<String> selectedTagIds
});




}
/// @nodoc
class __$ExploreSettingsCopyWithImpl<$Res>
    implements _$ExploreSettingsCopyWith<$Res> {
  __$ExploreSettingsCopyWithImpl(this._self, this._then);

  final _ExploreSettings _self;
  final $Res Function(_ExploreSettings) _then;

/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? aggressiveMode = null,Object? selectedPublisherNames = null,Object? selectedCategoryIds = null,Object? selectedTagIds = null,}) {
  return _then(_ExploreSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,aggressiveMode: null == aggressiveMode ? _self.aggressiveMode : aggressiveMode // ignore: cast_nullable_to_non_nullable
as bool,selectedPublisherNames: null == selectedPublisherNames ? _self._selectedPublisherNames : selectedPublisherNames // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategoryIds: null == selectedCategoryIds ? _self._selectedCategoryIds : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedTagIds: null == selectedTagIds ? _self._selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$AppSettings implements DiagnosticableTreeMixin {

 bool get dataSavingMode; bool get weakConnectionMode; bool get soundEffects; bool get festivalFeatures; bool get enterToSend; bool get appBarTransparent; bool get showBackgroundImage; bool get notifyWithHaptic; String? get customFonts; int? get appColorScheme; ThemeColors? get customColors; Rect? get windowBounds; bool get windowMaximized; Size? get windowSize; double get windowOpacity; double get cardTransparency; String? get defaultPoolId; String get messageDisplayStyle; String get attachmentsListStyle; String get attachmentPreviewMode; String get linkCollapseMode; String? get themeMode; bool get disableAnimation; bool get groupedChatList; String? get firstLaunchAt; bool get askedReview; String? get dashSearchEngine; String? get defaultScreen; String get realmDisplayMode; String get chatEventMessageMode; bool get showChatSystemMessages; DashboardConfig? get dashboardConfig; ExploreSettings get exploreSettings; bool get mediaProxyEnabled; bool get imageCompressionEnabled; int get imageCompressionQuality; bool get friendStatusDesktopNotification; bool get outgoingCallKitEnabled; bool get weatherNoGeolocation; bool get autoUploadAttachments;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as AppSettings;
  properties
    ..add(DiagnosticsProperty('type', 'AppSettings'))
    ..add(DiagnosticsProperty('dataSavingMode', _this.dataSavingMode))..add(DiagnosticsProperty('weakConnectionMode', _this.weakConnectionMode))..add(DiagnosticsProperty('soundEffects', _this.soundEffects))..add(DiagnosticsProperty('festivalFeatures', _this.festivalFeatures))..add(DiagnosticsProperty('enterToSend', _this.enterToSend))..add(DiagnosticsProperty('appBarTransparent', _this.appBarTransparent))..add(DiagnosticsProperty('showBackgroundImage', _this.showBackgroundImage))..add(DiagnosticsProperty('notifyWithHaptic', _this.notifyWithHaptic))..add(DiagnosticsProperty('customFonts', _this.customFonts))..add(DiagnosticsProperty('appColorScheme', _this.appColorScheme))..add(DiagnosticsProperty('customColors', _this.customColors))..add(DiagnosticsProperty('windowBounds', _this.windowBounds))..add(DiagnosticsProperty('windowMaximized', _this.windowMaximized))..add(DiagnosticsProperty('windowSize', _this.windowSize))..add(DiagnosticsProperty('windowOpacity', _this.windowOpacity))..add(DiagnosticsProperty('cardTransparency', _this.cardTransparency))..add(DiagnosticsProperty('defaultPoolId', _this.defaultPoolId))..add(DiagnosticsProperty('messageDisplayStyle', _this.messageDisplayStyle))..add(DiagnosticsProperty('attachmentsListStyle', _this.attachmentsListStyle))..add(DiagnosticsProperty('attachmentPreviewMode', _this.attachmentPreviewMode))..add(DiagnosticsProperty('linkCollapseMode', _this.linkCollapseMode))..add(DiagnosticsProperty('themeMode', _this.themeMode))..add(DiagnosticsProperty('disableAnimation', _this.disableAnimation))..add(DiagnosticsProperty('groupedChatList', _this.groupedChatList))..add(DiagnosticsProperty('firstLaunchAt', _this.firstLaunchAt))..add(DiagnosticsProperty('askedReview', _this.askedReview))..add(DiagnosticsProperty('dashSearchEngine', _this.dashSearchEngine))..add(DiagnosticsProperty('defaultScreen', _this.defaultScreen))..add(DiagnosticsProperty('realmDisplayMode', _this.realmDisplayMode))..add(DiagnosticsProperty('chatEventMessageMode', _this.chatEventMessageMode))..add(DiagnosticsProperty('showChatSystemMessages', _this.showChatSystemMessages))..add(DiagnosticsProperty('dashboardConfig', _this.dashboardConfig))..add(DiagnosticsProperty('exploreSettings', _this.exploreSettings))..add(DiagnosticsProperty('mediaProxyEnabled', _this.mediaProxyEnabled))..add(DiagnosticsProperty('imageCompressionEnabled', _this.imageCompressionEnabled))..add(DiagnosticsProperty('imageCompressionQuality', _this.imageCompressionQuality))..add(DiagnosticsProperty('friendStatusDesktopNotification', _this.friendStatusDesktopNotification))..add(DiagnosticsProperty('outgoingCallKitEnabled', _this.outgoingCallKitEnabled))..add(DiagnosticsProperty('weatherNoGeolocation', _this.weatherNoGeolocation))..add(DiagnosticsProperty('autoUploadAttachments', _this.autoUploadAttachments));
}

@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.dataSavingMode, _this.dataSavingMode) || other.dataSavingMode == _this.dataSavingMode)&&(identical(other.weakConnectionMode, _this.weakConnectionMode) || other.weakConnectionMode == _this.weakConnectionMode)&&(identical(other.soundEffects, _this.soundEffects) || other.soundEffects == _this.soundEffects)&&(identical(other.festivalFeatures, _this.festivalFeatures) || other.festivalFeatures == _this.festivalFeatures)&&(identical(other.enterToSend, _this.enterToSend) || other.enterToSend == _this.enterToSend)&&(identical(other.appBarTransparent, _this.appBarTransparent) || other.appBarTransparent == _this.appBarTransparent)&&(identical(other.showBackgroundImage, _this.showBackgroundImage) || other.showBackgroundImage == _this.showBackgroundImage)&&(identical(other.notifyWithHaptic, _this.notifyWithHaptic) || other.notifyWithHaptic == _this.notifyWithHaptic)&&(identical(other.customFonts, _this.customFonts) || other.customFonts == _this.customFonts)&&(identical(other.appColorScheme, _this.appColorScheme) || other.appColorScheme == _this.appColorScheme)&&(identical(other.customColors, _this.customColors) || other.customColors == _this.customColors)&&(identical(other.windowBounds, _this.windowBounds) || other.windowBounds == _this.windowBounds)&&(identical(other.windowMaximized, _this.windowMaximized) || other.windowMaximized == _this.windowMaximized)&&(identical(other.windowSize, _this.windowSize) || other.windowSize == _this.windowSize)&&(identical(other.windowOpacity, _this.windowOpacity) || other.windowOpacity == _this.windowOpacity)&&(identical(other.cardTransparency, _this.cardTransparency) || other.cardTransparency == _this.cardTransparency)&&(identical(other.defaultPoolId, _this.defaultPoolId) || other.defaultPoolId == _this.defaultPoolId)&&(identical(other.messageDisplayStyle, _this.messageDisplayStyle) || other.messageDisplayStyle == _this.messageDisplayStyle)&&(identical(other.attachmentsListStyle, _this.attachmentsListStyle) || other.attachmentsListStyle == _this.attachmentsListStyle)&&(identical(other.attachmentPreviewMode, _this.attachmentPreviewMode) || other.attachmentPreviewMode == _this.attachmentPreviewMode)&&(identical(other.linkCollapseMode, _this.linkCollapseMode) || other.linkCollapseMode == _this.linkCollapseMode)&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.disableAnimation, _this.disableAnimation) || other.disableAnimation == _this.disableAnimation)&&(identical(other.groupedChatList, _this.groupedChatList) || other.groupedChatList == _this.groupedChatList)&&(identical(other.firstLaunchAt, _this.firstLaunchAt) || other.firstLaunchAt == _this.firstLaunchAt)&&(identical(other.askedReview, _this.askedReview) || other.askedReview == _this.askedReview)&&(identical(other.dashSearchEngine, _this.dashSearchEngine) || other.dashSearchEngine == _this.dashSearchEngine)&&(identical(other.defaultScreen, _this.defaultScreen) || other.defaultScreen == _this.defaultScreen)&&(identical(other.realmDisplayMode, _this.realmDisplayMode) || other.realmDisplayMode == _this.realmDisplayMode)&&(identical(other.chatEventMessageMode, _this.chatEventMessageMode) || other.chatEventMessageMode == _this.chatEventMessageMode)&&(identical(other.showChatSystemMessages, _this.showChatSystemMessages) || other.showChatSystemMessages == _this.showChatSystemMessages)&&(identical(other.dashboardConfig, _this.dashboardConfig) || other.dashboardConfig == _this.dashboardConfig)&&(identical(other.exploreSettings, _this.exploreSettings) || other.exploreSettings == _this.exploreSettings)&&(identical(other.mediaProxyEnabled, _this.mediaProxyEnabled) || other.mediaProxyEnabled == _this.mediaProxyEnabled)&&(identical(other.imageCompressionEnabled, _this.imageCompressionEnabled) || other.imageCompressionEnabled == _this.imageCompressionEnabled)&&(identical(other.imageCompressionQuality, _this.imageCompressionQuality) || other.imageCompressionQuality == _this.imageCompressionQuality)&&(identical(other.friendStatusDesktopNotification, _this.friendStatusDesktopNotification) || other.friendStatusDesktopNotification == _this.friendStatusDesktopNotification)&&(identical(other.outgoingCallKitEnabled, _this.outgoingCallKitEnabled) || other.outgoingCallKitEnabled == _this.outgoingCallKitEnabled)&&(identical(other.weatherNoGeolocation, _this.weatherNoGeolocation) || other.weatherNoGeolocation == _this.weatherNoGeolocation)&&(identical(other.autoUploadAttachments, _this.autoUploadAttachments) || other.autoUploadAttachments == _this.autoUploadAttachments));
}


@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hashAll([runtimeType,_this.dataSavingMode,_this.weakConnectionMode,_this.soundEffects,_this.festivalFeatures,_this.enterToSend,_this.appBarTransparent,_this.showBackgroundImage,_this.notifyWithHaptic,_this.customFonts,_this.appColorScheme,_this.customColors,_this.windowBounds,_this.windowMaximized,_this.windowSize,_this.windowOpacity,_this.cardTransparency,_this.defaultPoolId,_this.messageDisplayStyle,_this.attachmentsListStyle,_this.attachmentPreviewMode,_this.linkCollapseMode,_this.themeMode,_this.disableAnimation,_this.groupedChatList,_this.firstLaunchAt,_this.askedReview,_this.dashSearchEngine,_this.defaultScreen,_this.realmDisplayMode,_this.chatEventMessageMode,_this.showChatSystemMessages,_this.dashboardConfig,_this.exploreSettings,_this.mediaProxyEnabled,_this.imageCompressionEnabled,_this.imageCompressionQuality,_this.friendStatusDesktopNotification,_this.outgoingCallKitEnabled,_this.weatherNoGeolocation,_this.autoUploadAttachments]);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as AppSettings;
  return 'AppSettings(dataSavingMode: ${_this.dataSavingMode}, weakConnectionMode: ${_this.weakConnectionMode}, soundEffects: ${_this.soundEffects}, festivalFeatures: ${_this.festivalFeatures}, enterToSend: ${_this.enterToSend}, appBarTransparent: ${_this.appBarTransparent}, showBackgroundImage: ${_this.showBackgroundImage}, notifyWithHaptic: ${_this.notifyWithHaptic}, customFonts: ${_this.customFonts}, appColorScheme: ${_this.appColorScheme}, customColors: ${_this.customColors}, windowBounds: ${_this.windowBounds}, windowMaximized: ${_this.windowMaximized}, windowSize: ${_this.windowSize}, windowOpacity: ${_this.windowOpacity}, cardTransparency: ${_this.cardTransparency}, defaultPoolId: ${_this.defaultPoolId}, messageDisplayStyle: ${_this.messageDisplayStyle}, attachmentsListStyle: ${_this.attachmentsListStyle}, attachmentPreviewMode: ${_this.attachmentPreviewMode}, linkCollapseMode: ${_this.linkCollapseMode}, themeMode: ${_this.themeMode}, disableAnimation: ${_this.disableAnimation}, groupedChatList: ${_this.groupedChatList}, firstLaunchAt: ${_this.firstLaunchAt}, askedReview: ${_this.askedReview}, dashSearchEngine: ${_this.dashSearchEngine}, defaultScreen: ${_this.defaultScreen}, realmDisplayMode: ${_this.realmDisplayMode}, chatEventMessageMode: ${_this.chatEventMessageMode}, showChatSystemMessages: ${_this.showChatSystemMessages}, dashboardConfig: ${_this.dashboardConfig}, exploreSettings: ${_this.exploreSettings}, mediaProxyEnabled: ${_this.mediaProxyEnabled}, imageCompressionEnabled: ${_this.imageCompressionEnabled}, imageCompressionQuality: ${_this.imageCompressionQuality}, friendStatusDesktopNotification: ${_this.friendStatusDesktopNotification}, outgoingCallKitEnabled: ${_this.outgoingCallKitEnabled}, weatherNoGeolocation: ${_this.weatherNoGeolocation}, autoUploadAttachments: ${_this.autoUploadAttachments})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool dataSavingMode, bool weakConnectionMode, bool soundEffects, bool festivalFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, bool notifyWithHaptic, String? customFonts, int? appColorScheme, ThemeColors? customColors, Rect? windowBounds, bool windowMaximized, Size? windowSize, double windowOpacity, double cardTransparency, String? defaultPoolId, String messageDisplayStyle, String attachmentsListStyle, String attachmentPreviewMode, String linkCollapseMode, String? themeMode, bool disableAnimation, bool groupedChatList, String? firstLaunchAt, bool askedReview, String? dashSearchEngine, String? defaultScreen, String realmDisplayMode, String chatEventMessageMode, bool showChatSystemMessages, DashboardConfig? dashboardConfig, ExploreSettings exploreSettings, bool mediaProxyEnabled, bool imageCompressionEnabled, int imageCompressionQuality, bool friendStatusDesktopNotification, bool outgoingCallKitEnabled, bool weatherNoGeolocation, bool autoUploadAttachments
});


$ThemeColorsCopyWith<$Res>? get customColors;$DashboardConfigCopyWith<$Res>? get dashboardConfig;$ExploreSettingsCopyWith<$Res> get exploreSettings;

}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dataSavingMode = null,Object? weakConnectionMode = null,Object? soundEffects = null,Object? festivalFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? notifyWithHaptic = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? customColors = freezed,Object? windowBounds = freezed,Object? windowMaximized = null,Object? windowSize = freezed,Object? windowOpacity = null,Object? cardTransparency = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? attachmentsListStyle = null,Object? attachmentPreviewMode = null,Object? linkCollapseMode = null,Object? themeMode = freezed,Object? disableAnimation = null,Object? groupedChatList = null,Object? firstLaunchAt = freezed,Object? askedReview = null,Object? dashSearchEngine = freezed,Object? defaultScreen = freezed,Object? realmDisplayMode = null,Object? chatEventMessageMode = null,Object? showChatSystemMessages = null,Object? dashboardConfig = freezed,Object? exploreSettings = null,Object? mediaProxyEnabled = null,Object? imageCompressionEnabled = null,Object? imageCompressionQuality = null,Object? friendStatusDesktopNotification = null,Object? outgoingCallKitEnabled = null,Object? weatherNoGeolocation = null,Object? autoUploadAttachments = null,}) {
  return _then(AppSettings(
dataSavingMode: null == dataSavingMode ? _self.dataSavingMode : dataSavingMode // ignore: cast_nullable_to_non_nullable
as bool,weakConnectionMode: null == weakConnectionMode ? _self.weakConnectionMode : weakConnectionMode // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,festivalFeatures: null == festivalFeatures ? _self.festivalFeatures : festivalFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,appBarTransparent: null == appBarTransparent ? _self.appBarTransparent : appBarTransparent // ignore: cast_nullable_to_non_nullable
as bool,showBackgroundImage: null == showBackgroundImage ? _self.showBackgroundImage : showBackgroundImage // ignore: cast_nullable_to_non_nullable
as bool,notifyWithHaptic: null == notifyWithHaptic ? _self.notifyWithHaptic : notifyWithHaptic // ignore: cast_nullable_to_non_nullable
as bool,customFonts: freezed == customFonts ? _self.customFonts : customFonts // ignore: cast_nullable_to_non_nullable
as String?,appColorScheme: freezed == appColorScheme ? _self.appColorScheme : appColorScheme // ignore: cast_nullable_to_non_nullable
as int?,customColors: freezed == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as ThemeColors?,windowBounds: freezed == windowBounds ? _self.windowBounds : windowBounds // ignore: cast_nullable_to_non_nullable
as Rect?,windowMaximized: null == windowMaximized ? _self.windowMaximized : windowMaximized // ignore: cast_nullable_to_non_nullable
as bool,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,cardTransparency: null == cardTransparency ? _self.cardTransparency : cardTransparency // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,attachmentsListStyle: null == attachmentsListStyle ? _self.attachmentsListStyle : attachmentsListStyle // ignore: cast_nullable_to_non_nullable
as String,attachmentPreviewMode: null == attachmentPreviewMode ? _self.attachmentPreviewMode : attachmentPreviewMode // ignore: cast_nullable_to_non_nullable
as String,linkCollapseMode: null == linkCollapseMode ? _self.linkCollapseMode : linkCollapseMode // ignore: cast_nullable_to_non_nullable
as String,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String?,disableAnimation: null == disableAnimation ? _self.disableAnimation : disableAnimation // ignore: cast_nullable_to_non_nullable
as bool,groupedChatList: null == groupedChatList ? _self.groupedChatList : groupedChatList // ignore: cast_nullable_to_non_nullable
as bool,firstLaunchAt: freezed == firstLaunchAt ? _self.firstLaunchAt : firstLaunchAt // ignore: cast_nullable_to_non_nullable
as String?,askedReview: null == askedReview ? _self.askedReview : askedReview // ignore: cast_nullable_to_non_nullable
as bool,dashSearchEngine: freezed == dashSearchEngine ? _self.dashSearchEngine : dashSearchEngine // ignore: cast_nullable_to_non_nullable
as String?,defaultScreen: freezed == defaultScreen ? _self.defaultScreen : defaultScreen // ignore: cast_nullable_to_non_nullable
as String?,realmDisplayMode: null == realmDisplayMode ? _self.realmDisplayMode : realmDisplayMode // ignore: cast_nullable_to_non_nullable
as String,chatEventMessageMode: null == chatEventMessageMode ? _self.chatEventMessageMode : chatEventMessageMode // ignore: cast_nullable_to_non_nullable
as String,showChatSystemMessages: null == showChatSystemMessages ? _self.showChatSystemMessages : showChatSystemMessages // ignore: cast_nullable_to_non_nullable
as bool,dashboardConfig: freezed == dashboardConfig ? _self.dashboardConfig : dashboardConfig // ignore: cast_nullable_to_non_nullable
as DashboardConfig?,exploreSettings: null == exploreSettings ? _self.exploreSettings : exploreSettings // ignore: cast_nullable_to_non_nullable
as ExploreSettings,mediaProxyEnabled: null == mediaProxyEnabled ? _self.mediaProxyEnabled : mediaProxyEnabled // ignore: cast_nullable_to_non_nullable
as bool,imageCompressionEnabled: null == imageCompressionEnabled ? _self.imageCompressionEnabled : imageCompressionEnabled // ignore: cast_nullable_to_non_nullable
as bool,imageCompressionQuality: null == imageCompressionQuality ? _self.imageCompressionQuality : imageCompressionQuality // ignore: cast_nullable_to_non_nullable
as int,friendStatusDesktopNotification: null == friendStatusDesktopNotification ? _self.friendStatusDesktopNotification : friendStatusDesktopNotification // ignore: cast_nullable_to_non_nullable
as bool,outgoingCallKitEnabled: null == outgoingCallKitEnabled ? _self.outgoingCallKitEnabled : outgoingCallKitEnabled // ignore: cast_nullable_to_non_nullable
as bool,weatherNoGeolocation: null == weatherNoGeolocation ? _self.weatherNoGeolocation : weatherNoGeolocation // ignore: cast_nullable_to_non_nullable
as bool,autoUploadAttachments: null == autoUploadAttachments ? _self.autoUploadAttachments : autoUploadAttachments // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<$Res>? get customColors {
    if (_self.customColors == null) {
    return null;
  }

  return $ThemeColorsCopyWith<$Res>(_self.customColors!, (value) {
    return _then(_self.copyWith(customColors: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<$Res>? get dashboardConfig {
    if (_self.dashboardConfig == null) {
    return null;
  }

  return $DashboardConfigCopyWith<$Res>(_self.dashboardConfig!, (value) {
    return _then(_self.copyWith(dashboardConfig: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExploreSettingsCopyWith<$Res> get exploreSettings {
  
  return $ExploreSettingsCopyWith<$Res>(_self.exploreSettings, (value) {
    return _then(_self.copyWith(exploreSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool dataSavingMode,  bool weakConnectionMode,  bool soundEffects,  bool festivalFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  bool notifyWithHaptic,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Rect? windowBounds,  bool windowMaximized,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String attachmentsListStyle,  String attachmentPreviewMode,  String linkCollapseMode,  String? themeMode,  bool disableAnimation,  bool groupedChatList,  String? firstLaunchAt,  bool askedReview,  String? dashSearchEngine,  String? defaultScreen,  String realmDisplayMode,  String chatEventMessageMode,  bool showChatSystemMessages,  DashboardConfig? dashboardConfig,  ExploreSettings exploreSettings,  bool mediaProxyEnabled,  bool imageCompressionEnabled,  int imageCompressionQuality,  bool friendStatusDesktopNotification,  bool outgoingCallKitEnabled,  bool weatherNoGeolocation,  bool autoUploadAttachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.dataSavingMode,_that.weakConnectionMode,_that.soundEffects,_that.festivalFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.notifyWithHaptic,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowBounds,_that.windowMaximized,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.attachmentsListStyle,_that.attachmentPreviewMode,_that.linkCollapseMode,_that.themeMode,_that.disableAnimation,_that.groupedChatList,_that.firstLaunchAt,_that.askedReview,_that.dashSearchEngine,_that.defaultScreen,_that.realmDisplayMode,_that.chatEventMessageMode,_that.showChatSystemMessages,_that.dashboardConfig,_that.exploreSettings,_that.mediaProxyEnabled,_that.imageCompressionEnabled,_that.imageCompressionQuality,_that.friendStatusDesktopNotification,_that.outgoingCallKitEnabled,_that.weatherNoGeolocation,_that.autoUploadAttachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool dataSavingMode,  bool weakConnectionMode,  bool soundEffects,  bool festivalFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  bool notifyWithHaptic,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Rect? windowBounds,  bool windowMaximized,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String attachmentsListStyle,  String attachmentPreviewMode,  String linkCollapseMode,  String? themeMode,  bool disableAnimation,  bool groupedChatList,  String? firstLaunchAt,  bool askedReview,  String? dashSearchEngine,  String? defaultScreen,  String realmDisplayMode,  String chatEventMessageMode,  bool showChatSystemMessages,  DashboardConfig? dashboardConfig,  ExploreSettings exploreSettings,  bool mediaProxyEnabled,  bool imageCompressionEnabled,  int imageCompressionQuality,  bool friendStatusDesktopNotification,  bool outgoingCallKitEnabled,  bool weatherNoGeolocation,  bool autoUploadAttachments)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.dataSavingMode,_that.weakConnectionMode,_that.soundEffects,_that.festivalFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.notifyWithHaptic,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowBounds,_that.windowMaximized,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.attachmentsListStyle,_that.attachmentPreviewMode,_that.linkCollapseMode,_that.themeMode,_that.disableAnimation,_that.groupedChatList,_that.firstLaunchAt,_that.askedReview,_that.dashSearchEngine,_that.defaultScreen,_that.realmDisplayMode,_that.chatEventMessageMode,_that.showChatSystemMessages,_that.dashboardConfig,_that.exploreSettings,_that.mediaProxyEnabled,_that.imageCompressionEnabled,_that.imageCompressionQuality,_that.friendStatusDesktopNotification,_that.outgoingCallKitEnabled,_that.weatherNoGeolocation,_that.autoUploadAttachments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool dataSavingMode,  bool weakConnectionMode,  bool soundEffects,  bool festivalFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  bool notifyWithHaptic,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Rect? windowBounds,  bool windowMaximized,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String attachmentsListStyle,  String attachmentPreviewMode,  String linkCollapseMode,  String? themeMode,  bool disableAnimation,  bool groupedChatList,  String? firstLaunchAt,  bool askedReview,  String? dashSearchEngine,  String? defaultScreen,  String realmDisplayMode,  String chatEventMessageMode,  bool showChatSystemMessages,  DashboardConfig? dashboardConfig,  ExploreSettings exploreSettings,  bool mediaProxyEnabled,  bool imageCompressionEnabled,  int imageCompressionQuality,  bool friendStatusDesktopNotification,  bool outgoingCallKitEnabled,  bool weatherNoGeolocation,  bool autoUploadAttachments)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.dataSavingMode,_that.weakConnectionMode,_that.soundEffects,_that.festivalFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.notifyWithHaptic,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowBounds,_that.windowMaximized,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.attachmentsListStyle,_that.attachmentPreviewMode,_that.linkCollapseMode,_that.themeMode,_that.disableAnimation,_that.groupedChatList,_that.firstLaunchAt,_that.askedReview,_that.dashSearchEngine,_that.defaultScreen,_that.realmDisplayMode,_that.chatEventMessageMode,_that.showChatSystemMessages,_that.dashboardConfig,_that.exploreSettings,_that.mediaProxyEnabled,_that.imageCompressionEnabled,_that.imageCompressionQuality,_that.friendStatusDesktopNotification,_that.outgoingCallKitEnabled,_that.weatherNoGeolocation,_that.autoUploadAttachments);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings with DiagnosticableTreeMixin implements AppSettings {
  const _AppSettings({required this.dataSavingMode, required this.weakConnectionMode, required this.soundEffects, required this.festivalFeatures, required this.enterToSend, required this.appBarTransparent, required this.showBackgroundImage, required this.notifyWithHaptic, required this.customFonts, required this.appColorScheme, required this.customColors, required this.windowBounds, required this.windowMaximized, required this.windowSize, required this.windowOpacity, required this.cardTransparency, required this.defaultPoolId, required this.messageDisplayStyle, required this.attachmentsListStyle, required this.attachmentPreviewMode, required this.linkCollapseMode, required this.themeMode, required this.disableAnimation, required this.groupedChatList, required this.firstLaunchAt, required this.askedReview, required this.dashSearchEngine, required this.defaultScreen, required this.realmDisplayMode, required this.chatEventMessageMode, required this.showChatSystemMessages, required this.dashboardConfig, required this.exploreSettings, required this.mediaProxyEnabled, required this.imageCompressionEnabled, required this.imageCompressionQuality, required this.friendStatusDesktopNotification, required this.outgoingCallKitEnabled, required this.weatherNoGeolocation, required this.autoUploadAttachments});
  

@override final  bool dataSavingMode;
@override final  bool weakConnectionMode;
@override final  bool soundEffects;
@override final  bool festivalFeatures;
@override final  bool enterToSend;
@override final  bool appBarTransparent;
@override final  bool showBackgroundImage;
@override final  bool notifyWithHaptic;
@override final  String? customFonts;
@override final  int? appColorScheme;
@override final  ThemeColors? customColors;
@override final  Rect? windowBounds;
@override final  bool windowMaximized;
@override final  Size? windowSize;
@override final  double windowOpacity;
@override final  double cardTransparency;
@override final  String? defaultPoolId;
@override final  String messageDisplayStyle;
@override final  String attachmentsListStyle;
@override final  String attachmentPreviewMode;
@override final  String linkCollapseMode;
@override final  String? themeMode;
@override final  bool disableAnimation;
@override final  bool groupedChatList;
@override final  String? firstLaunchAt;
@override final  bool askedReview;
@override final  String? dashSearchEngine;
@override final  String? defaultScreen;
@override final  String realmDisplayMode;
@override final  String chatEventMessageMode;
@override final  bool showChatSystemMessages;
@override final  DashboardConfig? dashboardConfig;
@override final  ExploreSettings exploreSettings;
@override final  bool mediaProxyEnabled;
@override final  bool imageCompressionEnabled;
@override final  int imageCompressionQuality;
@override final  bool friendStatusDesktopNotification;
@override final  bool outgoingCallKitEnabled;
@override final  bool weatherNoGeolocation;
@override final  bool autoUploadAttachments;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'AppSettings'))
    ..add(DiagnosticsProperty('dataSavingMode', dataSavingMode))..add(DiagnosticsProperty('weakConnectionMode', weakConnectionMode))..add(DiagnosticsProperty('soundEffects', soundEffects))..add(DiagnosticsProperty('festivalFeatures', festivalFeatures))..add(DiagnosticsProperty('enterToSend', enterToSend))..add(DiagnosticsProperty('appBarTransparent', appBarTransparent))..add(DiagnosticsProperty('showBackgroundImage', showBackgroundImage))..add(DiagnosticsProperty('notifyWithHaptic', notifyWithHaptic))..add(DiagnosticsProperty('customFonts', customFonts))..add(DiagnosticsProperty('appColorScheme', appColorScheme))..add(DiagnosticsProperty('customColors', customColors))..add(DiagnosticsProperty('windowBounds', windowBounds))..add(DiagnosticsProperty('windowMaximized', windowMaximized))..add(DiagnosticsProperty('windowSize', windowSize))..add(DiagnosticsProperty('windowOpacity', windowOpacity))..add(DiagnosticsProperty('cardTransparency', cardTransparency))..add(DiagnosticsProperty('defaultPoolId', defaultPoolId))..add(DiagnosticsProperty('messageDisplayStyle', messageDisplayStyle))..add(DiagnosticsProperty('attachmentsListStyle', attachmentsListStyle))..add(DiagnosticsProperty('attachmentPreviewMode', attachmentPreviewMode))..add(DiagnosticsProperty('linkCollapseMode', linkCollapseMode))..add(DiagnosticsProperty('themeMode', themeMode))..add(DiagnosticsProperty('disableAnimation', disableAnimation))..add(DiagnosticsProperty('groupedChatList', groupedChatList))..add(DiagnosticsProperty('firstLaunchAt', firstLaunchAt))..add(DiagnosticsProperty('askedReview', askedReview))..add(DiagnosticsProperty('dashSearchEngine', dashSearchEngine))..add(DiagnosticsProperty('defaultScreen', defaultScreen))..add(DiagnosticsProperty('realmDisplayMode', realmDisplayMode))..add(DiagnosticsProperty('chatEventMessageMode', chatEventMessageMode))..add(DiagnosticsProperty('showChatSystemMessages', showChatSystemMessages))..add(DiagnosticsProperty('dashboardConfig', dashboardConfig))..add(DiagnosticsProperty('exploreSettings', exploreSettings))..add(DiagnosticsProperty('mediaProxyEnabled', mediaProxyEnabled))..add(DiagnosticsProperty('imageCompressionEnabled', imageCompressionEnabled))..add(DiagnosticsProperty('imageCompressionQuality', imageCompressionQuality))..add(DiagnosticsProperty('friendStatusDesktopNotification', friendStatusDesktopNotification))..add(DiagnosticsProperty('outgoingCallKitEnabled', outgoingCallKitEnabled))..add(DiagnosticsProperty('weatherNoGeolocation', weatherNoGeolocation))..add(DiagnosticsProperty('autoUploadAttachments', autoUploadAttachments));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.weakConnectionMode, weakConnectionMode) || other.weakConnectionMode == weakConnectionMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.festivalFeatures, festivalFeatures) || other.festivalFeatures == festivalFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.notifyWithHaptic, notifyWithHaptic) || other.notifyWithHaptic == notifyWithHaptic)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.customColors, customColors) || other.customColors == customColors)&&(identical(other.windowBounds, windowBounds) || other.windowBounds == windowBounds)&&(identical(other.windowMaximized, windowMaximized) || other.windowMaximized == windowMaximized)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.cardTransparency, cardTransparency) || other.cardTransparency == cardTransparency)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle)&&(identical(other.attachmentsListStyle, attachmentsListStyle) || other.attachmentsListStyle == attachmentsListStyle)&&(identical(other.attachmentPreviewMode, attachmentPreviewMode) || other.attachmentPreviewMode == attachmentPreviewMode)&&(identical(other.linkCollapseMode, linkCollapseMode) || other.linkCollapseMode == linkCollapseMode)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.disableAnimation, disableAnimation) || other.disableAnimation == disableAnimation)&&(identical(other.groupedChatList, groupedChatList) || other.groupedChatList == groupedChatList)&&(identical(other.firstLaunchAt, firstLaunchAt) || other.firstLaunchAt == firstLaunchAt)&&(identical(other.askedReview, askedReview) || other.askedReview == askedReview)&&(identical(other.dashSearchEngine, dashSearchEngine) || other.dashSearchEngine == dashSearchEngine)&&(identical(other.defaultScreen, defaultScreen) || other.defaultScreen == defaultScreen)&&(identical(other.realmDisplayMode, realmDisplayMode) || other.realmDisplayMode == realmDisplayMode)&&(identical(other.chatEventMessageMode, chatEventMessageMode) || other.chatEventMessageMode == chatEventMessageMode)&&(identical(other.showChatSystemMessages, showChatSystemMessages) || other.showChatSystemMessages == showChatSystemMessages)&&(identical(other.dashboardConfig, dashboardConfig) || other.dashboardConfig == dashboardConfig)&&(identical(other.exploreSettings, exploreSettings) || other.exploreSettings == exploreSettings)&&(identical(other.mediaProxyEnabled, mediaProxyEnabled) || other.mediaProxyEnabled == mediaProxyEnabled)&&(identical(other.imageCompressionEnabled, imageCompressionEnabled) || other.imageCompressionEnabled == imageCompressionEnabled)&&(identical(other.imageCompressionQuality, imageCompressionQuality) || other.imageCompressionQuality == imageCompressionQuality)&&(identical(other.friendStatusDesktopNotification, friendStatusDesktopNotification) || other.friendStatusDesktopNotification == friendStatusDesktopNotification)&&(identical(other.outgoingCallKitEnabled, outgoingCallKitEnabled) || other.outgoingCallKitEnabled == outgoingCallKitEnabled)&&(identical(other.weatherNoGeolocation, weatherNoGeolocation) || other.weatherNoGeolocation == weatherNoGeolocation)&&(identical(other.autoUploadAttachments, autoUploadAttachments) || other.autoUploadAttachments == autoUploadAttachments));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,dataSavingMode,weakConnectionMode,soundEffects,festivalFeatures,enterToSend,appBarTransparent,showBackgroundImage,notifyWithHaptic,customFonts,appColorScheme,customColors,windowBounds,windowMaximized,windowSize,windowOpacity,cardTransparency,defaultPoolId,messageDisplayStyle,attachmentsListStyle,attachmentPreviewMode,linkCollapseMode,themeMode,disableAnimation,groupedChatList,firstLaunchAt,askedReview,dashSearchEngine,defaultScreen,realmDisplayMode,chatEventMessageMode,showChatSystemMessages,dashboardConfig,exploreSettings,mediaProxyEnabled,imageCompressionEnabled,imageCompressionQuality,friendStatusDesktopNotification,outgoingCallKitEnabled,weatherNoGeolocation,autoUploadAttachments]);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'AppSettings(dataSavingMode: $dataSavingMode, weakConnectionMode: $weakConnectionMode, soundEffects: $soundEffects, festivalFeatures: $festivalFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, notifyWithHaptic: $notifyWithHaptic, customFonts: $customFonts, appColorScheme: $appColorScheme, customColors: $customColors, windowBounds: $windowBounds, windowMaximized: $windowMaximized, windowSize: $windowSize, windowOpacity: $windowOpacity, cardTransparency: $cardTransparency, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle, attachmentsListStyle: $attachmentsListStyle, attachmentPreviewMode: $attachmentPreviewMode, linkCollapseMode: $linkCollapseMode, themeMode: $themeMode, disableAnimation: $disableAnimation, groupedChatList: $groupedChatList, firstLaunchAt: $firstLaunchAt, askedReview: $askedReview, dashSearchEngine: $dashSearchEngine, defaultScreen: $defaultScreen, realmDisplayMode: $realmDisplayMode, chatEventMessageMode: $chatEventMessageMode, showChatSystemMessages: $showChatSystemMessages, dashboardConfig: $dashboardConfig, exploreSettings: $exploreSettings, mediaProxyEnabled: $mediaProxyEnabled, imageCompressionEnabled: $imageCompressionEnabled, imageCompressionQuality: $imageCompressionQuality, friendStatusDesktopNotification: $friendStatusDesktopNotification, outgoingCallKitEnabled: $outgoingCallKitEnabled, weatherNoGeolocation: $weatherNoGeolocation, autoUploadAttachments: $autoUploadAttachments)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool dataSavingMode, bool weakConnectionMode, bool soundEffects, bool festivalFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, bool notifyWithHaptic, String? customFonts, int? appColorScheme, ThemeColors? customColors, Rect? windowBounds, bool windowMaximized, Size? windowSize, double windowOpacity, double cardTransparency, String? defaultPoolId, String messageDisplayStyle, String attachmentsListStyle, String attachmentPreviewMode, String linkCollapseMode, String? themeMode, bool disableAnimation, bool groupedChatList, String? firstLaunchAt, bool askedReview, String? dashSearchEngine, String? defaultScreen, String realmDisplayMode, String chatEventMessageMode, bool showChatSystemMessages, DashboardConfig? dashboardConfig, ExploreSettings exploreSettings, bool mediaProxyEnabled, bool imageCompressionEnabled, int imageCompressionQuality, bool friendStatusDesktopNotification, bool outgoingCallKitEnabled, bool weatherNoGeolocation, bool autoUploadAttachments
});


@override $ThemeColorsCopyWith<$Res>? get customColors;@override $DashboardConfigCopyWith<$Res>? get dashboardConfig;@override $ExploreSettingsCopyWith<$Res> get exploreSettings;

}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dataSavingMode = null,Object? weakConnectionMode = null,Object? soundEffects = null,Object? festivalFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? notifyWithHaptic = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? customColors = freezed,Object? windowBounds = freezed,Object? windowMaximized = null,Object? windowSize = freezed,Object? windowOpacity = null,Object? cardTransparency = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? attachmentsListStyle = null,Object? attachmentPreviewMode = null,Object? linkCollapseMode = null,Object? themeMode = freezed,Object? disableAnimation = null,Object? groupedChatList = null,Object? firstLaunchAt = freezed,Object? askedReview = null,Object? dashSearchEngine = freezed,Object? defaultScreen = freezed,Object? realmDisplayMode = null,Object? chatEventMessageMode = null,Object? showChatSystemMessages = null,Object? dashboardConfig = freezed,Object? exploreSettings = null,Object? mediaProxyEnabled = null,Object? imageCompressionEnabled = null,Object? imageCompressionQuality = null,Object? friendStatusDesktopNotification = null,Object? outgoingCallKitEnabled = null,Object? weatherNoGeolocation = null,Object? autoUploadAttachments = null,}) {
  return _then(_AppSettings(
dataSavingMode: null == dataSavingMode ? _self.dataSavingMode : dataSavingMode // ignore: cast_nullable_to_non_nullable
as bool,weakConnectionMode: null == weakConnectionMode ? _self.weakConnectionMode : weakConnectionMode // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,festivalFeatures: null == festivalFeatures ? _self.festivalFeatures : festivalFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,appBarTransparent: null == appBarTransparent ? _self.appBarTransparent : appBarTransparent // ignore: cast_nullable_to_non_nullable
as bool,showBackgroundImage: null == showBackgroundImage ? _self.showBackgroundImage : showBackgroundImage // ignore: cast_nullable_to_non_nullable
as bool,notifyWithHaptic: null == notifyWithHaptic ? _self.notifyWithHaptic : notifyWithHaptic // ignore: cast_nullable_to_non_nullable
as bool,customFonts: freezed == customFonts ? _self.customFonts : customFonts // ignore: cast_nullable_to_non_nullable
as String?,appColorScheme: freezed == appColorScheme ? _self.appColorScheme : appColorScheme // ignore: cast_nullable_to_non_nullable
as int?,customColors: freezed == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as ThemeColors?,windowBounds: freezed == windowBounds ? _self.windowBounds : windowBounds // ignore: cast_nullable_to_non_nullable
as Rect?,windowMaximized: null == windowMaximized ? _self.windowMaximized : windowMaximized // ignore: cast_nullable_to_non_nullable
as bool,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,cardTransparency: null == cardTransparency ? _self.cardTransparency : cardTransparency // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,attachmentsListStyle: null == attachmentsListStyle ? _self.attachmentsListStyle : attachmentsListStyle // ignore: cast_nullable_to_non_nullable
as String,attachmentPreviewMode: null == attachmentPreviewMode ? _self.attachmentPreviewMode : attachmentPreviewMode // ignore: cast_nullable_to_non_nullable
as String,linkCollapseMode: null == linkCollapseMode ? _self.linkCollapseMode : linkCollapseMode // ignore: cast_nullable_to_non_nullable
as String,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String?,disableAnimation: null == disableAnimation ? _self.disableAnimation : disableAnimation // ignore: cast_nullable_to_non_nullable
as bool,groupedChatList: null == groupedChatList ? _self.groupedChatList : groupedChatList // ignore: cast_nullable_to_non_nullable
as bool,firstLaunchAt: freezed == firstLaunchAt ? _self.firstLaunchAt : firstLaunchAt // ignore: cast_nullable_to_non_nullable
as String?,askedReview: null == askedReview ? _self.askedReview : askedReview // ignore: cast_nullable_to_non_nullable
as bool,dashSearchEngine: freezed == dashSearchEngine ? _self.dashSearchEngine : dashSearchEngine // ignore: cast_nullable_to_non_nullable
as String?,defaultScreen: freezed == defaultScreen ? _self.defaultScreen : defaultScreen // ignore: cast_nullable_to_non_nullable
as String?,realmDisplayMode: null == realmDisplayMode ? _self.realmDisplayMode : realmDisplayMode // ignore: cast_nullable_to_non_nullable
as String,chatEventMessageMode: null == chatEventMessageMode ? _self.chatEventMessageMode : chatEventMessageMode // ignore: cast_nullable_to_non_nullable
as String,showChatSystemMessages: null == showChatSystemMessages ? _self.showChatSystemMessages : showChatSystemMessages // ignore: cast_nullable_to_non_nullable
as bool,dashboardConfig: freezed == dashboardConfig ? _self.dashboardConfig : dashboardConfig // ignore: cast_nullable_to_non_nullable
as DashboardConfig?,exploreSettings: null == exploreSettings ? _self.exploreSettings : exploreSettings // ignore: cast_nullable_to_non_nullable
as ExploreSettings,mediaProxyEnabled: null == mediaProxyEnabled ? _self.mediaProxyEnabled : mediaProxyEnabled // ignore: cast_nullable_to_non_nullable
as bool,imageCompressionEnabled: null == imageCompressionEnabled ? _self.imageCompressionEnabled : imageCompressionEnabled // ignore: cast_nullable_to_non_nullable
as bool,imageCompressionQuality: null == imageCompressionQuality ? _self.imageCompressionQuality : imageCompressionQuality // ignore: cast_nullable_to_non_nullable
as int,friendStatusDesktopNotification: null == friendStatusDesktopNotification ? _self.friendStatusDesktopNotification : friendStatusDesktopNotification // ignore: cast_nullable_to_non_nullable
as bool,outgoingCallKitEnabled: null == outgoingCallKitEnabled ? _self.outgoingCallKitEnabled : outgoingCallKitEnabled // ignore: cast_nullable_to_non_nullable
as bool,weatherNoGeolocation: null == weatherNoGeolocation ? _self.weatherNoGeolocation : weatherNoGeolocation // ignore: cast_nullable_to_non_nullable
as bool,autoUploadAttachments: null == autoUploadAttachments ? _self.autoUploadAttachments : autoUploadAttachments // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<$Res>? get customColors {
    if (_self.customColors == null) {
    return null;
  }

  return $ThemeColorsCopyWith<$Res>(_self.customColors!, (value) {
    return _then(_self.copyWith(customColors: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<$Res>? get dashboardConfig {
    if (_self.dashboardConfig == null) {
    return null;
  }

  return $DashboardConfigCopyWith<$Res>(_self.dashboardConfig!, (value) {
    return _then(_self.copyWith(dashboardConfig: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExploreSettingsCopyWith<$Res> get exploreSettings {
  
  return $ExploreSettingsCopyWith<$Res>(_self.exploreSettings, (value) {
    return _then(_self.copyWith(exploreSettings: value));
  });
}
}

// dart format on
