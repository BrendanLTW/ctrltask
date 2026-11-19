// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskDetails {

 Task get task; RepeatRule? get repeat; List<Subtask> get subtasks; List<Tag> get tags; List<TaskLink> get links;
/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskDetailsCopyWith<TaskDetails> get copyWith => _$TaskDetailsCopyWithImpl<TaskDetails>(this as TaskDetails, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskDetails&&(identical(other.task, _this.task) || other.task == _this.task)&&(identical(other.repeat, _this.repeat) || other.repeat == _this.repeat)&&const DeepCollectionEquality().equals(other.subtasks, _this.subtasks)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&const DeepCollectionEquality().equals(other.links, _this.links));
}


@override
int get hashCode {
  final _this = this as TaskDetails;
  return Object.hash(runtimeType,_this.task,_this.repeat,const DeepCollectionEquality().hash(_this.subtasks),const DeepCollectionEquality().hash(_this.tags),const DeepCollectionEquality().hash(_this.links));
}

@override
String toString() {
  final _this = this as TaskDetails;
  return 'TaskDetails(task: ${_this.task}, repeat: ${_this.repeat}, subtasks: ${_this.subtasks}, tags: ${_this.tags}, links: ${_this.links})';
}


}

/// @nodoc
abstract mixin class $TaskDetailsCopyWith<$Res>  {
  factory $TaskDetailsCopyWith(TaskDetails value, $Res Function(TaskDetails) _then) = _$TaskDetailsCopyWithImpl;
@useResult
$Res call({
 Task task, RepeatRule? repeat, List<Subtask> subtasks, List<Tag> tags, List<TaskLink> links
});


$TaskCopyWith<$Res> get task;$RepeatRuleCopyWith<$Res>? get repeat;

}
/// @nodoc
class _$TaskDetailsCopyWithImpl<$Res>
    implements $TaskDetailsCopyWith<$Res> {
  _$TaskDetailsCopyWithImpl(this._self, this._then);

  final TaskDetails _self;
  final $Res Function(TaskDetails) _then;

/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? task = null,Object? repeat = freezed,Object? subtasks = null,Object? tags = null,Object? links = null,}) {
  return _then(TaskDetails(
task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task,repeat: freezed == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatRule?,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<Subtask>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<TaskLink>,
  ));
}
/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get task {
  
  return $TaskCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}/// Create a copy of TaskDetails
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


/// Adds pattern-matching-related methods to [TaskDetails].
extension TaskDetailsPatterns on TaskDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskDetails value)  $default,){
final _that = this;
switch (_that) {
case _TaskDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskDetails value)?  $default,){
final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Task task,  RepeatRule? repeat,  List<Subtask> subtasks,  List<Tag> tags,  List<TaskLink> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
return $default(_that.task,_that.repeat,_that.subtasks,_that.tags,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Task task,  RepeatRule? repeat,  List<Subtask> subtasks,  List<Tag> tags,  List<TaskLink> links)  $default,) {final _that = this;
switch (_that) {
case _TaskDetails():
return $default(_that.task,_that.repeat,_that.subtasks,_that.tags,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Task task,  RepeatRule? repeat,  List<Subtask> subtasks,  List<Tag> tags,  List<TaskLink> links)?  $default,) {final _that = this;
switch (_that) {
case _TaskDetails() when $default != null:
return $default(_that.task,_that.repeat,_that.subtasks,_that.tags,_that.links);case _:
  return null;

}
}

}

/// @nodoc


class _TaskDetails implements TaskDetails {
  const _TaskDetails({required this.task, this.repeat,  List<Subtask> subtasks = const <Subtask>[],  List<Tag> tags = const <Tag>[],  List<TaskLink> links = const <TaskLink>[]}): _subtasks = subtasks,_tags = tags,_links = links;
  

@override final  Task task;
@override final  RepeatRule? repeat;
 final  List<Subtask> _subtasks;
@override@JsonKey() List<Subtask> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

 final  List<Tag> _tags;
@override@JsonKey() List<Tag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<TaskLink> _links;
@override@JsonKey() List<TaskLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskDetailsCopyWith<_TaskDetails> get copyWith => __$TaskDetailsCopyWithImpl<_TaskDetails>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskDetails&&(identical(other.task, task) || other.task == task)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&const DeepCollectionEquality().equals(other.subtasks, _subtasks)&&const DeepCollectionEquality().equals(other.tags, _tags)&&const DeepCollectionEquality().equals(other.links, _links));
}


@override
int get hashCode {
    return Object.hash(runtimeType,task,repeat,const DeepCollectionEquality().hash(_subtasks),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_links));
}

@override
String toString() {
    return 'TaskDetails(task: $task, repeat: $repeat, subtasks: $subtasks, tags: $tags, links: $links)';
}


}

/// @nodoc
abstract mixin class _$TaskDetailsCopyWith<$Res> implements $TaskDetailsCopyWith<$Res> {
  factory _$TaskDetailsCopyWith(_TaskDetails value, $Res Function(_TaskDetails) _then) = __$TaskDetailsCopyWithImpl;
@override @useResult
$Res call({
 Task task, RepeatRule? repeat, List<Subtask> subtasks, List<Tag> tags, List<TaskLink> links
});


@override $TaskCopyWith<$Res> get task;@override $RepeatRuleCopyWith<$Res>? get repeat;

}
/// @nodoc
class __$TaskDetailsCopyWithImpl<$Res>
    implements _$TaskDetailsCopyWith<$Res> {
  __$TaskDetailsCopyWithImpl(this._self, this._then);

  final _TaskDetails _self;
  final $Res Function(_TaskDetails) _then;

/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? task = null,Object? repeat = freezed,Object? subtasks = null,Object? tags = null,Object? links = null,}) {
  return _then(_TaskDetails(
task: null == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task,repeat: freezed == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatRule?,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<Subtask>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<Tag>,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<TaskLink>,
  ));
}

/// Create a copy of TaskDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskCopyWith<$Res> get task {
  
  return $TaskCopyWith<$Res>(_self.task, (value) {
    return _then(_self.copyWith(task: value));
  });
}/// Create a copy of TaskDetails
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
