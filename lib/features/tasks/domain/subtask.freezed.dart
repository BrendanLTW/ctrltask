// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Subtask {

 int get id; int get taskId; String get title; int get sortOrder; bool get done;
/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtaskCopyWith<Subtask> get copyWith => _$SubtaskCopyWithImpl<Subtask>(this as Subtask, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Subtask;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Subtask&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.done, _this.done) || other.done == _this.done));
}


@override
int get hashCode {
  final _this = this as Subtask;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.title,_this.sortOrder,_this.done);
}

@override
String toString() {
  final _this = this as Subtask;
  return 'Subtask(id: ${_this.id}, taskId: ${_this.taskId}, title: ${_this.title}, sortOrder: ${_this.sortOrder}, done: ${_this.done})';
}


}

/// @nodoc
abstract mixin class $SubtaskCopyWith<$Res>  {
  factory $SubtaskCopyWith(Subtask value, $Res Function(Subtask) _then) = _$SubtaskCopyWithImpl;
@useResult
$Res call({
 int id, int taskId, String title, int sortOrder, bool done
});




}
/// @nodoc
class _$SubtaskCopyWithImpl<$Res>
    implements $SubtaskCopyWith<$Res> {
  _$SubtaskCopyWithImpl(this._self, this._then);

  final Subtask _self;
  final $Res Function(Subtask) _then;

/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? sortOrder = null,Object? done = null,}) {
  return _then(Subtask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Subtask].
extension SubtaskPatterns on Subtask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Subtask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Subtask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Subtask value)  $default,){
final _that = this;
switch (_that) {
case _Subtask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Subtask value)?  $default,){
final _that = this;
switch (_that) {
case _Subtask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int taskId,  String title,  int sortOrder,  bool done)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Subtask() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.sortOrder,_that.done);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int taskId,  String title,  int sortOrder,  bool done)  $default,) {final _that = this;
switch (_that) {
case _Subtask():
return $default(_that.id,_that.taskId,_that.title,_that.sortOrder,_that.done);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int taskId,  String title,  int sortOrder,  bool done)?  $default,) {final _that = this;
switch (_that) {
case _Subtask() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.sortOrder,_that.done);case _:
  return null;

}
}

}

/// @nodoc


class _Subtask implements Subtask {
  const _Subtask({required this.id, required this.taskId, required this.title, required this.sortOrder, this.done = false});
  

@override final  int id;
@override final  int taskId;
@override final  String title;
@override final  int sortOrder;
@override@JsonKey() final  bool done;

/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtaskCopyWith<_Subtask> get copyWith => __$SubtaskCopyWithImpl<_Subtask>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Subtask&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.done, done) || other.done == done));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,title,sortOrder,done);
}

@override
String toString() {
    return 'Subtask(id: $id, taskId: $taskId, title: $title, sortOrder: $sortOrder, done: $done)';
}


}

/// @nodoc
abstract mixin class _$SubtaskCopyWith<$Res> implements $SubtaskCopyWith<$Res> {
  factory _$SubtaskCopyWith(_Subtask value, $Res Function(_Subtask) _then) = __$SubtaskCopyWithImpl;
@override @useResult
$Res call({
 int id, int taskId, String title, int sortOrder, bool done
});




}
/// @nodoc
class __$SubtaskCopyWithImpl<$Res>
    implements _$SubtaskCopyWith<$Res> {
  __$SubtaskCopyWithImpl(this._self, this._then);

  final _Subtask _self;
  final $Res Function(_Subtask) _then;

/// Create a copy of Subtask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? sortOrder = null,Object? done = null,}) {
  return _then(_Subtask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
