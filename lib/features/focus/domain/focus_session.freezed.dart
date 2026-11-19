// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'focus_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FocusSession {

 int get id; FocusKind get kind; int get plannedSec; DateTime get startedAt; int get elapsedSec; int? get taskId; DateTime? get endedAt; bool get completed;
/// Create a copy of FocusSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FocusSessionCopyWith<FocusSession> get copyWith => _$FocusSessionCopyWithImpl<FocusSession>(this as FocusSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FocusSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FocusSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.plannedSec, _this.plannedSec) || other.plannedSec == _this.plannedSec)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.elapsedSec, _this.elapsedSec) || other.elapsedSec == _this.elapsedSec)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.completed, _this.completed) || other.completed == _this.completed));
}


@override
int get hashCode {
  final _this = this as FocusSession;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.plannedSec,_this.startedAt,_this.elapsedSec,_this.taskId,_this.endedAt,_this.completed);
}

@override
String toString() {
  final _this = this as FocusSession;
  return 'FocusSession(id: ${_this.id}, kind: ${_this.kind}, plannedSec: ${_this.plannedSec}, startedAt: ${_this.startedAt}, elapsedSec: ${_this.elapsedSec}, taskId: ${_this.taskId}, endedAt: ${_this.endedAt}, completed: ${_this.completed})';
}


}

/// @nodoc
abstract mixin class $FocusSessionCopyWith<$Res>  {
  factory $FocusSessionCopyWith(FocusSession value, $Res Function(FocusSession) _then) = _$FocusSessionCopyWithImpl;
@useResult
$Res call({
 int id, FocusKind kind, int plannedSec, DateTime startedAt, int elapsedSec, int? taskId, DateTime? endedAt, bool completed
});




}
/// @nodoc
class _$FocusSessionCopyWithImpl<$Res>
    implements $FocusSessionCopyWith<$Res> {
  _$FocusSessionCopyWithImpl(this._self, this._then);

  final FocusSession _self;
  final $Res Function(FocusSession) _then;

/// Create a copy of FocusSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? plannedSec = null,Object? startedAt = null,Object? elapsedSec = null,Object? taskId = freezed,Object? endedAt = freezed,Object? completed = null,}) {
  return _then(FocusSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FocusKind,plannedSec: null == plannedSec ? _self.plannedSec : plannedSec // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,elapsedSec: null == elapsedSec ? _self.elapsedSec : elapsedSec // ignore: cast_nullable_to_non_nullable
as int,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FocusSession].
extension FocusSessionPatterns on FocusSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FocusSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FocusSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FocusSession value)  $default,){
final _that = this;
switch (_that) {
case _FocusSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FocusSession value)?  $default,){
final _that = this;
switch (_that) {
case _FocusSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  FocusKind kind,  int plannedSec,  DateTime startedAt,  int elapsedSec,  int? taskId,  DateTime? endedAt,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FocusSession() when $default != null:
return $default(_that.id,_that.kind,_that.plannedSec,_that.startedAt,_that.elapsedSec,_that.taskId,_that.endedAt,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  FocusKind kind,  int plannedSec,  DateTime startedAt,  int elapsedSec,  int? taskId,  DateTime? endedAt,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _FocusSession():
return $default(_that.id,_that.kind,_that.plannedSec,_that.startedAt,_that.elapsedSec,_that.taskId,_that.endedAt,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  FocusKind kind,  int plannedSec,  DateTime startedAt,  int elapsedSec,  int? taskId,  DateTime? endedAt,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _FocusSession() when $default != null:
return $default(_that.id,_that.kind,_that.plannedSec,_that.startedAt,_that.elapsedSec,_that.taskId,_that.endedAt,_that.completed);case _:
  return null;

}
}

}

/// @nodoc


class _FocusSession extends FocusSession {
  const _FocusSession({required this.id, required this.kind, required this.plannedSec, required this.startedAt, required this.elapsedSec, this.taskId, this.endedAt, this.completed = false}): super._();
  

@override final  int id;
@override final  FocusKind kind;
@override final  int plannedSec;
@override final  DateTime startedAt;
@override final  int elapsedSec;
@override final  int? taskId;
@override final  DateTime? endedAt;
@override@JsonKey() final  bool completed;

/// Create a copy of FocusSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FocusSessionCopyWith<_FocusSession> get copyWith => __$FocusSessionCopyWithImpl<_FocusSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FocusSession&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.plannedSec, plannedSec) || other.plannedSec == plannedSec)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.elapsedSec, elapsedSec) || other.elapsedSec == elapsedSec)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.completed, completed) || other.completed == completed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,plannedSec,startedAt,elapsedSec,taskId,endedAt,completed);
}

@override
String toString() {
    return 'FocusSession(id: $id, kind: $kind, plannedSec: $plannedSec, startedAt: $startedAt, elapsedSec: $elapsedSec, taskId: $taskId, endedAt: $endedAt, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$FocusSessionCopyWith<$Res> implements $FocusSessionCopyWith<$Res> {
  factory _$FocusSessionCopyWith(_FocusSession value, $Res Function(_FocusSession) _then) = __$FocusSessionCopyWithImpl;
@override @useResult
$Res call({
 int id, FocusKind kind, int plannedSec, DateTime startedAt, int elapsedSec, int? taskId, DateTime? endedAt, bool completed
});




}
/// @nodoc
class __$FocusSessionCopyWithImpl<$Res>
    implements _$FocusSessionCopyWith<$Res> {
  __$FocusSessionCopyWithImpl(this._self, this._then);

  final _FocusSession _self;
  final $Res Function(_FocusSession) _then;

/// Create a copy of FocusSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? plannedSec = null,Object? startedAt = null,Object? elapsedSec = null,Object? taskId = freezed,Object? endedAt = freezed,Object? completed = null,}) {
  return _then(_FocusSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FocusKind,plannedSec: null == plannedSec ? _self.plannedSec : plannedSec // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,elapsedSec: null == elapsedSec ? _self.elapsedSec : elapsedSec // ignore: cast_nullable_to_non_nullable
as int,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
