// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDraft {

 String get title; String? get description; DateTime? get dueDate; int? get dueMinute; TaskPriority get priority; int? get projectId; ReminderOffset get reminder; RepeatRule? get repeat; Set<int> get tagIds; List<String> get subtasks; List<({String title, String url,})> get links;
/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDraftCopyWith<TaskDraft> get copyWith => _$TaskDraftCopyWithImpl<TaskDraft>(this as TaskDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDraft&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.dueMinute, _this.dueMinute) || other.dueMinute == _this.dueMinute)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.projectId, _this.projectId) || other.projectId == _this.projectId)&&(identical(other.reminder, _this.reminder) || other.reminder == _this.reminder)&&(identical(other.repeat, _this.repeat) || other.repeat == _this.repeat)&&const DeepCollectionEquality().equals(other.tagIds, _this.tagIds)&&const DeepCollectionEquality().equals(other.subtasks, _this.subtasks)&&const DeepCollectionEquality().equals(other.links, _this.links));
}


@override
int get hashCode {
  final _this = this as TaskDraft;
  return Object.hash(runtimeType,_this.title,_this.description,_this.dueDate,_this.dueMinute,_this.priority,_this.projectId,_this.reminder,_this.repeat,const DeepCollectionEquality().hash(_this.tagIds),const DeepCollectionEquality().hash(_this.subtasks),const DeepCollectionEquality().hash(_this.links));
}

@override
String toString() {
  final _this = this as TaskDraft;
  return 'TaskDraft(title: ${_this.title}, description: ${_this.description}, dueDate: ${_this.dueDate}, dueMinute: ${_this.dueMinute}, priority: ${_this.priority}, projectId: ${_this.projectId}, reminder: ${_this.reminder}, repeat: ${_this.repeat}, tagIds: ${_this.tagIds}, subtasks: ${_this.subtasks}, links: ${_this.links})';
}


}

/// @nodoc
abstract mixin class $TaskDraftCopyWith<$Res>  {
  factory $TaskDraftCopyWith(TaskDraft value, $Res Function(TaskDraft) _then) = _$TaskDraftCopyWithImpl;
@useResult
$Res call({
 String title, String? description, DateTime? dueDate, int? dueMinute, TaskPriority priority, int? projectId, ReminderOffset reminder, RepeatRule? repeat, Set<int> tagIds, List<String> subtasks, List<({String title, String url,})> links
});


$RepeatRuleCopyWith<$Res>? get repeat;

}
/// @nodoc
class _$TaskDraftCopyWithImpl<$Res>
    implements $TaskDraftCopyWith<$Res> {
  _$TaskDraftCopyWithImpl(this._self, this._then);

  final TaskDraft _self;
  final $Res Function(TaskDraft) _then;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = freezed,Object? dueDate = freezed,Object? dueMinute = freezed,Object? priority = null,Object? projectId = freezed,Object? reminder = null,Object? repeat = freezed,Object? tagIds = null,Object? subtasks = null,Object? links = null,}) {
  return _then(TaskDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueMinute: freezed == dueMinute ? _self.dueMinute : dueMinute // ignore: cast_nullable_to_non_nullable
as int?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,reminder: null == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset,repeat: freezed == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatRule?,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as Set<int>,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<String>,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<({String title, String url,})>,
  ));
}
/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepeatRuleCopyWith<$Res>? get repeat {
    if (_self.repeat == null) {
    return null;
  }

  return $RepeatRuleCopyWith<$Res>(_self.repeat!, (value) {
    return _then(_self.copyWith(repeat: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaskDraft].
extension TaskDraftPatterns on TaskDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDraft value)  $default,){
final _that = this;
switch (_that) {
case _TaskDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDraft value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String? description,  DateTime? dueDate,  int? dueMinute,  TaskPriority priority,  int? projectId,  ReminderOffset reminder,  RepeatRule? repeat,  Set<int> tagIds,  List<String> subtasks,  List<({String title, String url,})> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
return $default(_that.title,_that.description,_that.dueDate,_that.dueMinute,_that.priority,_that.projectId,_that.reminder,_that.repeat,_that.tagIds,_that.subtasks,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String? description,  DateTime? dueDate,  int? dueMinute,  TaskPriority priority,  int? projectId,  ReminderOffset reminder,  RepeatRule? repeat,  Set<int> tagIds,  List<String> subtasks,  List<({String title, String url,})> links)  $default,) {final _that = this;
switch (_that) {
case _TaskDraft():
return $default(_that.title,_that.description,_that.dueDate,_that.dueMinute,_that.priority,_that.projectId,_that.reminder,_that.repeat,_that.tagIds,_that.subtasks,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String? description,  DateTime? dueDate,  int? dueMinute,  TaskPriority priority,  int? projectId,  ReminderOffset reminder,  RepeatRule? repeat,  Set<int> tagIds,  List<String> subtasks,  List<({String title, String url,})> links)?  $default,) {final _that = this;
switch (_that) {
case _TaskDraft() when $default != null:
return $default(_that.title,_that.description,_that.dueDate,_that.dueMinute,_that.priority,_that.projectId,_that.reminder,_that.repeat,_that.tagIds,_that.subtasks,_that.links);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDraft implements TaskDraft {
  const _TaskDraft({required this.title, this.description, this.dueDate, this.dueMinute, this.priority = TaskPriority.medium, this.projectId, this.reminder = ReminderOffset.none, this.repeat,  Set<int> tagIds = const <int>{},  List<String> subtasks = const <String>[],  List<({String title, String url,})> links = const <({String title, String url})>[]}): _tagIds = tagIds,_subtasks = subtasks,_links = links;
  

@override final  String title;
@override final  String? description;
@override final  DateTime? dueDate;
@override final  int? dueMinute;
@override@JsonKey() final  TaskPriority priority;
@override final  int? projectId;
@override@JsonKey() final  ReminderOffset reminder;
@override final  RepeatRule? repeat;
 final  Set<int> _tagIds;
@override@JsonKey() Set<int> get tagIds {
  if (_tagIds is EqualUnmodifiableSetView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_tagIds);
}

 final  List<String> _subtasks;
@override@JsonKey() List<String> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

 final  List<({String title, String url,})> _links;
@override@JsonKey() List<({String title, String url,})> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDraftCopyWith<_TaskDraft> get copyWith => __$TaskDraftCopyWithImpl<_TaskDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDraft&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.dueMinute, dueMinute) || other.dueMinute == dueMinute)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.reminder, reminder) || other.reminder == reminder)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&const DeepCollectionEquality().equals(other.tagIds, _tagIds)&&const DeepCollectionEquality().equals(other.subtasks, _subtasks)&&const DeepCollectionEquality().equals(other.links, _links));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,description,dueDate,dueMinute,priority,projectId,reminder,repeat,const DeepCollectionEquality().hash(_tagIds),const DeepCollectionEquality().hash(_subtasks),const DeepCollectionEquality().hash(_links));
}

@override
String toString() {
    return 'TaskDraft(title: $title, description: $description, dueDate: $dueDate, dueMinute: $dueMinute, priority: $priority, projectId: $projectId, reminder: $reminder, repeat: $repeat, tagIds: $tagIds, subtasks: $subtasks, links: $links)';
}


}

/// @nodoc
abstract mixin class _$TaskDraftCopyWith<$Res> implements $TaskDraftCopyWith<$Res> {
  factory _$TaskDraftCopyWith(_TaskDraft value, $Res Function(_TaskDraft) _then) = __$TaskDraftCopyWithImpl;
@override @useResult
$Res call({
 String title, String? description, DateTime? dueDate, int? dueMinute, TaskPriority priority, int? projectId, ReminderOffset reminder, RepeatRule? repeat, Set<int> tagIds, List<String> subtasks, List<({String title, String url,})> links
});


@override $RepeatRuleCopyWith<$Res>? get repeat;

}
/// @nodoc
class __$TaskDraftCopyWithImpl<$Res>
    implements _$TaskDraftCopyWith<$Res> {
  __$TaskDraftCopyWithImpl(this._self, this._then);

  final _TaskDraft _self;
  final $Res Function(_TaskDraft) _then;

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = freezed,Object? dueDate = freezed,Object? dueMinute = freezed,Object? priority = null,Object? projectId = freezed,Object? reminder = null,Object? repeat = freezed,Object? tagIds = null,Object? subtasks = null,Object? links = null,}) {
  return _then(_TaskDraft(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueMinute: freezed == dueMinute ? _self.dueMinute : dueMinute // ignore: cast_nullable_to_non_nullable
as int?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,reminder: null == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset,repeat: freezed == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatRule?,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as Set<int>,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<String>,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<({String title, String url,})>,
  ));
}

/// Create a copy of TaskDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepeatRuleCopyWith<$Res>? get repeat {
    if (_self.repeat == null) {
    return null;
  }

  return $RepeatRuleCopyWith<$Res>(_self.repeat!, (value) {
    return _then(_self.copyWith(repeat: value));
  });
}
}

// dart format on
