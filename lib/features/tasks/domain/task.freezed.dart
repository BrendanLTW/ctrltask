// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Task {

 int get id; String get title; TaskPriority get priority; TaskStatus get status; BoardColumn get boardColumn; DateTime get createdAt; DateTime get updatedAt; int get sortOrder; String? get description; DateTime? get dueDate; int? get dueMinute; int? get projectId; DateTime? get completedAt; int? get repeatRuleId; ReminderOffset get reminder;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Task;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.boardColumn, _this.boardColumn) || other.boardColumn == _this.boardColumn)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.dueMinute, _this.dueMinute) || other.dueMinute == _this.dueMinute)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.repeatRuleId, _this.repeatRuleId) || other.repeatRuleId == _this.repeatRuleId)&&(identical(other.reminder, _this.reminder) || other.reminder == _this.reminder));
}


@override
int get hashCode {
  final _this = this as Task;
  return Object.hash(runtimeType,_this.id,_this.title,_this.priority,_this.status,_this.boardColumn,_this.createdAt,_this.updatedAt,_this.sortOrder,_this.description,_this.dueDate,_this.dueMinute,_this.projectId,_this.completedAt,_this.repeatRuleId,_this.reminder);
}

@override
String toString() {
  final _this = this as Task;
  return 'Task(id: ${_this.id}, title: ${_this.title}, priority: ${_this.priority}, status: ${_this.status}, boardColumn: ${_this.boardColumn}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, sortOrder: ${_this.sortOrder}, description: ${_this.description}, dueDate: ${_this.dueDate}, dueMinute: ${_this.dueMinute}, projectId: ${_this.projectId}, completedAt: ${_this.completedAt}, repeatRuleId: ${_this.repeatRuleId}, reminder: ${_this.reminder})';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 int id, String title, TaskPriority priority, TaskStatus status, BoardColumn boardColumn, DateTime createdAt, DateTime updatedAt, int sortOrder, String? description, DateTime? dueDate, int? dueMinute, int? projectId, DateTime? completedAt, int? repeatRuleId, ReminderOffset reminder
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? priority = null,Object? status = null,Object? boardColumn = null,Object? createdAt = null,Object? updatedAt = null,Object? sortOrder = null,Object? description = freezed,Object? dueDate = freezed,Object? dueMinute = freezed,Object? projectId = freezed,Object? completedAt = freezed,Object? repeatRuleId = freezed,Object? reminder = null,}) {
  return _then(Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,boardColumn: null == boardColumn ? _self.boardColumn : boardColumn // ignore: cast_nullable_to_non_nullable
as BoardColumn,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueMinute: freezed == dueMinute ? _self.dueMinute : dueMinute // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,repeatRuleId: freezed == repeatRuleId ? _self.repeatRuleId : repeatRuleId // ignore: cast_nullable_to_non_nullable
as int?,reminder: null == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  TaskPriority priority,  TaskStatus status,  BoardColumn boardColumn,  DateTime createdAt,  DateTime updatedAt,  int sortOrder,  String? description,  DateTime? dueDate,  int? dueMinute,  int? projectId,  DateTime? completedAt,  int? repeatRuleId,  ReminderOffset reminder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.priority,_that.status,_that.boardColumn,_that.createdAt,_that.updatedAt,_that.sortOrder,_that.description,_that.dueDate,_that.dueMinute,_that.projectId,_that.completedAt,_that.repeatRuleId,_that.reminder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  TaskPriority priority,  TaskStatus status,  BoardColumn boardColumn,  DateTime createdAt,  DateTime updatedAt,  int sortOrder,  String? description,  DateTime? dueDate,  int? dueMinute,  int? projectId,  DateTime? completedAt,  int? repeatRuleId,  ReminderOffset reminder)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.title,_that.priority,_that.status,_that.boardColumn,_that.createdAt,_that.updatedAt,_that.sortOrder,_that.description,_that.dueDate,_that.dueMinute,_that.projectId,_that.completedAt,_that.repeatRuleId,_that.reminder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  TaskPriority priority,  TaskStatus status,  BoardColumn boardColumn,  DateTime createdAt,  DateTime updatedAt,  int sortOrder,  String? description,  DateTime? dueDate,  int? dueMinute,  int? projectId,  DateTime? completedAt,  int? repeatRuleId,  ReminderOffset reminder)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.priority,_that.status,_that.boardColumn,_that.createdAt,_that.updatedAt,_that.sortOrder,_that.description,_that.dueDate,_that.dueMinute,_that.projectId,_that.completedAt,_that.repeatRuleId,_that.reminder);case _:
  return null;

}
}

}

/// @nodoc


class _Task implements Task {
  const _Task({required this.id, required this.title, required this.priority, required this.status, required this.boardColumn, required this.createdAt, required this.updatedAt, required this.sortOrder, this.description, this.dueDate, this.dueMinute, this.projectId, this.completedAt, this.repeatRuleId, this.reminder = ReminderOffset.none});
  

@override final  int id;
@override final  String title;
@override final  TaskPriority priority;
@override final  TaskStatus status;
@override final  BoardColumn boardColumn;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  int sortOrder;
@override final  String? description;
@override final  DateTime? dueDate;
@override final  int? dueMinute;
@override final  int? projectId;
@override final  DateTime? completedAt;
@override final  int? repeatRuleId;
@override@JsonKey() final  ReminderOffset reminder;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.boardColumn, boardColumn) || other.boardColumn == boardColumn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueMinute, dueMinute) || other.dueMinute == dueMinute)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.repeatRuleId, repeatRuleId) || other.repeatRuleId == repeatRuleId)&&(identical(other.reminder, reminder) || other.reminder == reminder));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,priority,status,boardColumn,createdAt,updatedAt,sortOrder,description,dueDate,dueMinute,projectId,completedAt,repeatRuleId,reminder);
}

@override
String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, status: $status, boardColumn: $boardColumn, createdAt: $createdAt, updatedAt: $updatedAt, sortOrder: $sortOrder, description: $description, dueDate: $dueDate, dueMinute: $dueMinute, projectId: $projectId, completedAt: $completedAt, repeatRuleId: $repeatRuleId, reminder: $reminder)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, TaskPriority priority, TaskStatus status, BoardColumn boardColumn, DateTime createdAt, DateTime updatedAt, int sortOrder, String? description, DateTime? dueDate, int? dueMinute, int? projectId, DateTime? completedAt, int? repeatRuleId, ReminderOffset reminder
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? priority = null,Object? status = null,Object? boardColumn = null,Object? createdAt = null,Object? updatedAt = null,Object? sortOrder = null,Object? description = freezed,Object? dueDate = freezed,Object? dueMinute = freezed,Object? projectId = freezed,Object? completedAt = freezed,Object? repeatRuleId = freezed,Object? reminder = null,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,boardColumn: null == boardColumn ? _self.boardColumn : boardColumn // ignore: cast_nullable_to_non_nullable
as BoardColumn,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueMinute: freezed == dueMinute ? _self.dueMinute : dueMinute // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,repeatRuleId: freezed == repeatRuleId ? _self.repeatRuleId : repeatRuleId // ignore: cast_nullable_to_non_nullable
as int?,reminder: null == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset,
  ));
}


}

// dart format on
