// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'focus_timer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FocusTimer {

 FocusKind get kind; TimerPhase get phase; int get plannedSec; int? get taskId;/// When the session first started.
 DateTime? get startedAt;/// When the current run began; null unless running.
 DateTime? get runningSince;/// Seconds run before the last pause.
 int get bankedSec;
/// Create a copy of FocusTimer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusTimerCopyWith<FocusTimer> get copyWith => _$FocusTimerCopyWithImpl<FocusTimer>(this as FocusTimer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FocusTimer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusTimer&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.plannedSec, _this.plannedSec) || other.plannedSec == _this.plannedSec)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.runningSince, _this.runningSince) || other.runningSince == _this.runningSince)&&(identical(other.bankedSec, _this.bankedSec) || other.bankedSec == _this.bankedSec));
}


@override
int get hashCode {
  final _this = this as FocusTimer;
  return Object.hash(runtimeType,_this.kind,_this.phase,_this.plannedSec,_this.taskId,_this.startedAt,_this.runningSince,_this.bankedSec);
}

@override
String toString() {
  final _this = this as FocusTimer;
  return 'FocusTimer(kind: ${_this.kind}, phase: ${_this.phase}, plannedSec: ${_this.plannedSec}, taskId: ${_this.taskId}, startedAt: ${_this.startedAt}, runningSince: ${_this.runningSince}, bankedSec: ${_this.bankedSec})';
}


}

/// @nodoc
abstract mixin class $FocusTimerCopyWith<$Res>  {
  factory $FocusTimerCopyWith(FocusTimer value, $Res Function(FocusTimer) _then) = _$FocusTimerCopyWithImpl;
@useResult
$Res call({
 FocusKind kind, TimerPhase phase, int plannedSec, int? taskId, DateTime? startedAt, DateTime? runningSince, int bankedSec
});




}
/// @nodoc
class _$FocusTimerCopyWithImpl<$Res>
    implements $FocusTimerCopyWith<$Res> {
  _$FocusTimerCopyWithImpl(this._self, this._then);

  final FocusTimer _self;
  final $Res Function(FocusTimer) _then;

/// Create a copy of FocusTimer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? phase = null,Object? plannedSec = null,Object? taskId = freezed,Object? startedAt = freezed,Object? runningSince = freezed,Object? bankedSec = null,}) {
  return _then(FocusTimer(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FocusKind,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TimerPhase,plannedSec: null == plannedSec ? _self.plannedSec : plannedSec // ignore: cast_nullable_to_non_nullable
as int,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,runningSince: freezed == runningSince ? _self.runningSince : runningSince // ignore: cast_nullable_to_non_nullable
as DateTime?,bankedSec: null == bankedSec ? _self.bankedSec : bankedSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FocusTimer].
extension FocusTimerPatterns on FocusTimer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FocusTimer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FocusTimer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FocusTimer value)  $default,){
final _that = this;
switch (_that) {
case _FocusTimer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FocusTimer value)?  $default,){
final _that = this;
switch (_that) {
case _FocusTimer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FocusKind kind,  TimerPhase phase,  int plannedSec,  int? taskId,  DateTime? startedAt,  DateTime? runningSince,  int bankedSec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FocusTimer() when $default != null:
return $default(_that.kind,_that.phase,_that.plannedSec,_that.taskId,_that.startedAt,_that.runningSince,_that.bankedSec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FocusKind kind,  TimerPhase phase,  int plannedSec,  int? taskId,  DateTime? startedAt,  DateTime? runningSince,  int bankedSec)  $default,) {final _that = this;
switch (_that) {
case _FocusTimer():
return $default(_that.kind,_that.phase,_that.plannedSec,_that.taskId,_that.startedAt,_that.runningSince,_that.bankedSec);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FocusKind kind,  TimerPhase phase,  int plannedSec,  int? taskId,  DateTime? startedAt,  DateTime? runningSince,  int bankedSec)?  $default,) {final _that = this;
switch (_that) {
case _FocusTimer() when $default != null:
return $default(_that.kind,_that.phase,_that.plannedSec,_that.taskId,_that.startedAt,_that.runningSince,_that.bankedSec);case _:
  return null;

}
}

}

/// @nodoc


class _FocusTimer extends FocusTimer {
  const _FocusTimer({this.kind = FocusKind.focus, this.phase = TimerPhase.idle, this.plannedSec = 25 * 60, this.taskId, this.startedAt, this.runningSince, this.bankedSec = 0}): super._();
  

@override@JsonKey() final  FocusKind kind;
@override@JsonKey() final  TimerPhase phase;
@override@JsonKey() final  int plannedSec;
@override final  int? taskId;
/// When the session first started.
@override final  DateTime? startedAt;
/// When the current run began; null unless running.
@override final  DateTime? runningSince;
/// Seconds run before the last pause.
@override@JsonKey() final  int bankedSec;

/// Create a copy of FocusTimer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FocusTimerCopyWith<_FocusTimer> get copyWith => __$FocusTimerCopyWithImpl<_FocusTimer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FocusTimer&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.plannedSec, plannedSec) || other.plannedSec == plannedSec)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.runningSince, runningSince) || other.runningSince == runningSince)&&(identical(other.bankedSec, bankedSec) || other.bankedSec == bankedSec));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,phase,plannedSec,taskId,startedAt,runningSince,bankedSec);
}

@override
String toString() {
    return 'FocusTimer(kind: $kind, phase: $phase, plannedSec: $plannedSec, taskId: $taskId, startedAt: $startedAt, runningSince: $runningSince, bankedSec: $bankedSec)';
}


}

/// @nodoc
abstract mixin class _$FocusTimerCopyWith<$Res> implements $FocusTimerCopyWith<$Res> {
  factory _$FocusTimerCopyWith(_FocusTimer value, $Res Function(_FocusTimer) _then) = __$FocusTimerCopyWithImpl;
@override @useResult
$Res call({
 FocusKind kind, TimerPhase phase, int plannedSec, int? taskId, DateTime? startedAt, DateTime? runningSince, int bankedSec
});




}
/// @nodoc
class __$FocusTimerCopyWithImpl<$Res>
    implements _$FocusTimerCopyWith<$Res> {
  __$FocusTimerCopyWithImpl(this._self, this._then);

  final _FocusTimer _self;
  final $Res Function(_FocusTimer) _then;

/// Create a copy of FocusTimer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? phase = null,Object? plannedSec = null,Object? taskId = freezed,Object? startedAt = freezed,Object? runningSince = freezed,Object? bankedSec = null,}) {
  return _then(_FocusTimer(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FocusKind,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TimerPhase,plannedSec: null == plannedSec ? _self.plannedSec : plannedSec // ignore: cast_nullable_to_non_nullable
as int,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,runningSince: freezed == runningSince ? _self.runningSince : runningSince // ignore: cast_nullable_to_non_nullable
as DateTime?,bankedSec: null == bankedSec ? _self.bankedSec : bankedSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
