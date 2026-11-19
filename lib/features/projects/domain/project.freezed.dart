// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Project {

 int get id; String get name; ProjectColorKey get colorKey; ProjectIconKey get iconKey; DateTime get createdAt; int get sortOrder; String? get description; DateTime? get deadline; DateTime? get archivedAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Project;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.colorKey, _this.colorKey) || other.colorKey == _this.colorKey)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt));
}


@override
int get hashCode {
  final _this = this as Project;
  return Object.hash(runtimeType,_this.id,_this.name,_this.colorKey,_this.iconKey,_this.createdAt,_this.sortOrder,_this.description,_this.deadline,_this.archivedAt);
}

@override
String toString() {
  final _this = this as Project;
  return 'Project(id: ${_this.id}, name: ${_this.name}, colorKey: ${_this.colorKey}, iconKey: ${_this.iconKey}, createdAt: ${_this.createdAt}, sortOrder: ${_this.sortOrder}, description: ${_this.description}, deadline: ${_this.deadline}, archivedAt: ${_this.archivedAt})';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 int id, String name, ProjectColorKey colorKey, ProjectIconKey iconKey, DateTime createdAt, int sortOrder, String? description, DateTime? deadline, DateTime? archivedAt
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? colorKey = null,Object? iconKey = null,Object? createdAt = null,Object? sortOrder = null,Object? description = freezed,Object? deadline = freezed,Object? archivedAt = freezed,}) {
  return _then(Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as ProjectColorKey,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as ProjectIconKey,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  ProjectColorKey colorKey,  ProjectIconKey iconKey,  DateTime createdAt,  int sortOrder,  String? description,  DateTime? deadline,  DateTime? archivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.colorKey,_that.iconKey,_that.createdAt,_that.sortOrder,_that.description,_that.deadline,_that.archivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  ProjectColorKey colorKey,  ProjectIconKey iconKey,  DateTime createdAt,  int sortOrder,  String? description,  DateTime? deadline,  DateTime? archivedAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.name,_that.colorKey,_that.iconKey,_that.createdAt,_that.sortOrder,_that.description,_that.deadline,_that.archivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  ProjectColorKey colorKey,  ProjectIconKey iconKey,  DateTime createdAt,  int sortOrder,  String? description,  DateTime? deadline,  DateTime? archivedAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.colorKey,_that.iconKey,_that.createdAt,_that.sortOrder,_that.description,_that.deadline,_that.archivedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Project extends Project {
  const _Project({required this.id, required this.name, required this.colorKey, required this.iconKey, required this.createdAt, required this.sortOrder, this.description, this.deadline, this.archivedAt}): super._();
  

@override final  int id;
@override final  String name;
@override final  ProjectColorKey colorKey;
@override final  ProjectIconKey iconKey;
@override final  DateTime createdAt;
@override final  int sortOrder;
@override final  String? description;
@override final  DateTime? deadline;
@override final  DateTime? archivedAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.description, description) || other.description == description)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,colorKey,iconKey,createdAt,sortOrder,description,deadline,archivedAt);
}

@override
String toString() {
    return 'Project(id: $id, name: $name, colorKey: $colorKey, iconKey: $iconKey, createdAt: $createdAt, sortOrder: $sortOrder, description: $description, deadline: $deadline, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, ProjectColorKey colorKey, ProjectIconKey iconKey, DateTime createdAt, int sortOrder, String? description, DateTime? deadline, DateTime? archivedAt
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? colorKey = null,Object? iconKey = null,Object? createdAt = null,Object? sortOrder = null,Object? description = freezed,Object? deadline = freezed,Object? archivedAt = freezed,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as ProjectColorKey,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as ProjectIconKey,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
