// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaskLink {

 int get id; int get taskId; String get title; String get url;
/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskLinkCopyWith<TaskLink> get copyWith => _$TaskLinkCopyWithImpl<TaskLink>(this as TaskLink, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaskLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskLink&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.url, _this.url) || other.url == _this.url));
}


@override
int get hashCode {
  final _this = this as TaskLink;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.title,_this.url);
}

@override
String toString() {
  final _this = this as TaskLink;
  return 'TaskLink(id: ${_this.id}, taskId: ${_this.taskId}, title: ${_this.title}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $TaskLinkCopyWith<$Res>  {
  factory $TaskLinkCopyWith(TaskLink value, $Res Function(TaskLink) _then) = _$TaskLinkCopyWithImpl;
@useResult
$Res call({
 int id, int taskId, String title, String url
});




}
/// @nodoc
class _$TaskLinkCopyWithImpl<$Res>
    implements $TaskLinkCopyWith<$Res> {
  _$TaskLinkCopyWithImpl(this._self, this._then);

  final TaskLink _self;
  final $Res Function(TaskLink) _then;

/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? url = null,}) {
  return _then(TaskLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskLink].
extension TaskLinkPatterns on TaskLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskLink value)  $default,){
final _that = this;
switch (_that) {
case _TaskLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskLink value)?  $default,){
final _that = this;
switch (_that) {
case _TaskLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int taskId,  String title,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskLink() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int taskId,  String title,  String url)  $default,) {final _that = this;
switch (_that) {
case _TaskLink():
return $default(_that.id,_that.taskId,_that.title,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int taskId,  String title,  String url)?  $default,) {final _that = this;
switch (_that) {
case _TaskLink() when $default != null:
return $default(_that.id,_that.taskId,_that.title,_that.url);case _:
  return null;

}
}

}

/// @nodoc


class _TaskLink implements TaskLink {
  const _TaskLink({required this.id, required this.taskId, required this.title, required this.url});
  

@override final  int id;
@override final  int taskId;
@override final  String title;
@override final  String url;

/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskLinkCopyWith<_TaskLink> get copyWith => __$TaskLinkCopyWithImpl<_TaskLink>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskLink&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,title,url);
}

@override
String toString() {
    return 'TaskLink(id: $id, taskId: $taskId, title: $title, url: $url)';
}


}

/// @nodoc
abstract mixin class _$TaskLinkCopyWith<$Res> implements $TaskLinkCopyWith<$Res> {
  factory _$TaskLinkCopyWith(_TaskLink value, $Res Function(_TaskLink) _then) = __$TaskLinkCopyWithImpl;
@override @useResult
$Res call({
 int id, int taskId, String title, String url
});




}
/// @nodoc
class __$TaskLinkCopyWithImpl<$Res>
    implements _$TaskLinkCopyWith<$Res> {
  __$TaskLinkCopyWithImpl(this._self, this._then);

  final _TaskLink _self;
  final $Res Function(_TaskLink) _then;

/// Create a copy of TaskLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? title = null,Object? url = null,}) {
  return _then(_TaskLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
