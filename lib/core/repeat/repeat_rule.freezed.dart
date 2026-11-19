// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repeat_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RepeatRule {

 DateTime? get endsOn;
/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepeatRuleCopyWith<RepeatRule> get copyWith => _$RepeatRuleCopyWithImpl<RepeatRule>(this as RepeatRule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RepeatRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepeatRule&&(identical(other.endsOn, _this.endsOn) || other.endsOn == _this.endsOn));
}


@override
int get hashCode {
  final _this = this as RepeatRule;
  return Object.hash(runtimeType,_this.endsOn);
}

@override
String toString() {
  final _this = this as RepeatRule;
  return 'RepeatRule(endsOn: ${_this.endsOn})';
}


}

/// @nodoc
abstract mixin class $RepeatRuleCopyWith<$Res>  {
  factory $RepeatRuleCopyWith(RepeatRule value, $Res Function(RepeatRule) _then) = _$RepeatRuleCopyWithImpl;
@useResult
$Res call({
 DateTime? endsOn
});




}
/// @nodoc
class _$RepeatRuleCopyWithImpl<$Res>
    implements $RepeatRuleCopyWith<$Res> {
  _$RepeatRuleCopyWithImpl(this._self, this._then);

  final RepeatRule _self;
  final $Res Function(RepeatRule) _then;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? endsOn = freezed,}) {
  return _then(_self.copyWith(
endsOn: freezed == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepeatRule].
extension RepeatRulePatterns on RepeatRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DailyRepeat value)?  daily,TResult Function( WeekdaysRepeat value)?  weekdays,TResult Function( WeeklyRepeat value)?  weekly,TResult Function( MonthlyRepeat value)?  monthly,TResult Function( CustomRepeat value)?  custom,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DailyRepeat() when daily != null:
return daily(_that);case WeekdaysRepeat() when weekdays != null:
return weekdays(_that);case WeeklyRepeat() when weekly != null:
return weekly(_that);case MonthlyRepeat() when monthly != null:
return monthly(_that);case CustomRepeat() when custom != null:
return custom(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DailyRepeat value)  daily,required TResult Function( WeekdaysRepeat value)  weekdays,required TResult Function( WeeklyRepeat value)  weekly,required TResult Function( MonthlyRepeat value)  monthly,required TResult Function( CustomRepeat value)  custom,}){
final _that = this;
switch (_that) {
case DailyRepeat():
return daily(_that);case WeekdaysRepeat():
return weekdays(_that);case WeeklyRepeat():
return weekly(_that);case MonthlyRepeat():
return monthly(_that);case CustomRepeat():
return custom(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DailyRepeat value)?  daily,TResult? Function( WeekdaysRepeat value)?  weekdays,TResult? Function( WeeklyRepeat value)?  weekly,TResult? Function( MonthlyRepeat value)?  monthly,TResult? Function( CustomRepeat value)?  custom,}){
final _that = this;
switch (_that) {
case DailyRepeat() when daily != null:
return daily(_that);case WeekdaysRepeat() when weekdays != null:
return weekdays(_that);case WeeklyRepeat() when weekly != null:
return weekly(_that);case MonthlyRepeat() when monthly != null:
return monthly(_that);case CustomRepeat() when custom != null:
return custom(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime? endsOn)?  daily,TResult Function( DateTime? endsOn)?  weekdays,TResult Function( Set<int> days,  DateTime? endsOn)?  weekly,TResult Function( int dayOfMonth,  DateTime? endsOn)?  monthly,TResult Function( int interval,  RepeatUnit unit,  int? dayOfMonth,  DateTime? endsOn)?  custom,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DailyRepeat() when daily != null:
return daily(_that.endsOn);case WeekdaysRepeat() when weekdays != null:
return weekdays(_that.endsOn);case WeeklyRepeat() when weekly != null:
return weekly(_that.days,_that.endsOn);case MonthlyRepeat() when monthly != null:
return monthly(_that.dayOfMonth,_that.endsOn);case CustomRepeat() when custom != null:
return custom(_that.interval,_that.unit,_that.dayOfMonth,_that.endsOn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime? endsOn)  daily,required TResult Function( DateTime? endsOn)  weekdays,required TResult Function( Set<int> days,  DateTime? endsOn)  weekly,required TResult Function( int dayOfMonth,  DateTime? endsOn)  monthly,required TResult Function( int interval,  RepeatUnit unit,  int? dayOfMonth,  DateTime? endsOn)  custom,}) {final _that = this;
switch (_that) {
case DailyRepeat():
return daily(_that.endsOn);case WeekdaysRepeat():
return weekdays(_that.endsOn);case WeeklyRepeat():
return weekly(_that.days,_that.endsOn);case MonthlyRepeat():
return monthly(_that.dayOfMonth,_that.endsOn);case CustomRepeat():
return custom(_that.interval,_that.unit,_that.dayOfMonth,_that.endsOn);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime? endsOn)?  daily,TResult? Function( DateTime? endsOn)?  weekdays,TResult? Function( Set<int> days,  DateTime? endsOn)?  weekly,TResult? Function( int dayOfMonth,  DateTime? endsOn)?  monthly,TResult? Function( int interval,  RepeatUnit unit,  int? dayOfMonth,  DateTime? endsOn)?  custom,}) {final _that = this;
switch (_that) {
case DailyRepeat() when daily != null:
return daily(_that.endsOn);case WeekdaysRepeat() when weekdays != null:
return weekdays(_that.endsOn);case WeeklyRepeat() when weekly != null:
return weekly(_that.days,_that.endsOn);case MonthlyRepeat() when monthly != null:
return monthly(_that.dayOfMonth,_that.endsOn);case CustomRepeat() when custom != null:
return custom(_that.interval,_that.unit,_that.dayOfMonth,_that.endsOn);case _:
  return null;

}
}

}

/// @nodoc


class DailyRepeat implements RepeatRule {
  const DailyRepeat({this.endsOn});
  

@override final  DateTime? endsOn;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyRepeatCopyWith<DailyRepeat> get copyWith => _$DailyRepeatCopyWithImpl<DailyRepeat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyRepeat&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,endsOn);
}

@override
String toString() {
    return 'RepeatRule.daily(endsOn: $endsOn)';
}


}

/// @nodoc
abstract mixin class $DailyRepeatCopyWith<$Res> implements $RepeatRuleCopyWith<$Res> {
  factory $DailyRepeatCopyWith(DailyRepeat value, $Res Function(DailyRepeat) _then) = _$DailyRepeatCopyWithImpl;
@override @useResult
$Res call({
 DateTime? endsOn
});




}
/// @nodoc
class _$DailyRepeatCopyWithImpl<$Res>
    implements $DailyRepeatCopyWith<$Res> {
  _$DailyRepeatCopyWithImpl(this._self, this._then);

  final DailyRepeat _self;
  final $Res Function(DailyRepeat) _then;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? endsOn = freezed,}) {
  return _then(DailyRepeat(
endsOn: freezed == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class WeekdaysRepeat implements RepeatRule {
  const WeekdaysRepeat({this.endsOn});
  

@override final  DateTime? endsOn;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekdaysRepeatCopyWith<WeekdaysRepeat> get copyWith => _$WeekdaysRepeatCopyWithImpl<WeekdaysRepeat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekdaysRepeat&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,endsOn);
}

@override
String toString() {
    return 'RepeatRule.weekdays(endsOn: $endsOn)';
}


}

/// @nodoc
abstract mixin class $WeekdaysRepeatCopyWith<$Res> implements $RepeatRuleCopyWith<$Res> {
  factory $WeekdaysRepeatCopyWith(WeekdaysRepeat value, $Res Function(WeekdaysRepeat) _then) = _$WeekdaysRepeatCopyWithImpl;
@override @useResult
$Res call({
 DateTime? endsOn
});




}
/// @nodoc
class _$WeekdaysRepeatCopyWithImpl<$Res>
    implements $WeekdaysRepeatCopyWith<$Res> {
  _$WeekdaysRepeatCopyWithImpl(this._self, this._then);

  final WeekdaysRepeat _self;
  final $Res Function(WeekdaysRepeat) _then;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? endsOn = freezed,}) {
  return _then(WeekdaysRepeat(
endsOn: freezed == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class WeeklyRepeat implements RepeatRule {
   WeeklyRepeat( Set<int> days, {this.endsOn}): assert(days.isNotEmpty, 'every week needs at least one day'),assert(days.every((d) => d >= 1 && d <= 7), 'weekday 1–7'),_days = days;
  

 final  Set<int> _days;
 Set<int> get days {
  if (_days is EqualUnmodifiableSetView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_days);
}

@override final  DateTime? endsOn;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeeklyRepeatCopyWith<WeeklyRepeat> get copyWith => _$WeeklyRepeatCopyWithImpl<WeeklyRepeat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WeeklyRepeat&&const DeepCollectionEquality().equals(other.days, _days)&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_days),endsOn);
}

@override
String toString() {
    return 'RepeatRule.weekly(days: $days, endsOn: $endsOn)';
}


}

/// @nodoc
abstract mixin class $WeeklyRepeatCopyWith<$Res> implements $RepeatRuleCopyWith<$Res> {
  factory $WeeklyRepeatCopyWith(WeeklyRepeat value, $Res Function(WeeklyRepeat) _then) = _$WeeklyRepeatCopyWithImpl;
@override @useResult
$Res call({
 Set<int> days, DateTime? endsOn
});




}
/// @nodoc
class _$WeeklyRepeatCopyWithImpl<$Res>
    implements $WeeklyRepeatCopyWith<$Res> {
  _$WeeklyRepeatCopyWithImpl(this._self, this._then);

  final WeeklyRepeat _self;
  final $Res Function(WeeklyRepeat) _then;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? days = null,Object? endsOn = freezed,}) {
  return _then(WeeklyRepeat(
null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as Set<int>,endsOn: freezed == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class MonthlyRepeat implements RepeatRule {
  const MonthlyRepeat(this.dayOfMonth, {this.endsOn}): assert(dayOfMonth >= 1 && dayOfMonth <= 31, 'day 1–31');
  

 final  int dayOfMonth;
@override final  DateTime? endsOn;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyRepeatCopyWith<MonthlyRepeat> get copyWith => _$MonthlyRepeatCopyWithImpl<MonthlyRepeat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyRepeat&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,dayOfMonth,endsOn);
}

@override
String toString() {
    return 'RepeatRule.monthly(dayOfMonth: $dayOfMonth, endsOn: $endsOn)';
}


}

/// @nodoc
abstract mixin class $MonthlyRepeatCopyWith<$Res> implements $RepeatRuleCopyWith<$Res> {
  factory $MonthlyRepeatCopyWith(MonthlyRepeat value, $Res Function(MonthlyRepeat) _then) = _$MonthlyRepeatCopyWithImpl;
@override @useResult
$Res call({
 int dayOfMonth, DateTime? endsOn
});




}
/// @nodoc
class _$MonthlyRepeatCopyWithImpl<$Res>
    implements $MonthlyRepeatCopyWith<$Res> {
  _$MonthlyRepeatCopyWithImpl(this._self, this._then);

  final MonthlyRepeat _self;
  final $Res Function(MonthlyRepeat) _then;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayOfMonth = null,Object? endsOn = freezed,}) {
  return _then(MonthlyRepeat(
null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,endsOn: freezed == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class CustomRepeat implements RepeatRule {
  const CustomRepeat(this.interval, this.unit, {this.dayOfMonth, this.endsOn}): assert(interval >= 1 && interval <= 12, 'interval 1–12'),assert(unit != RepeatUnit.month || (dayOfMonth != null && dayOfMonth >= 1 && dayOfMonth <= 31), 'every N months needs its day 1–31');
  

 final  int interval;
 final  RepeatUnit unit;
 final  int? dayOfMonth;
@override final  DateTime? endsOn;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomRepeatCopyWith<CustomRepeat> get copyWith => _$CustomRepeatCopyWithImpl<CustomRepeat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomRepeat&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,interval,unit,dayOfMonth,endsOn);
}

@override
String toString() {
    return 'RepeatRule.custom(interval: $interval, unit: $unit, dayOfMonth: $dayOfMonth, endsOn: $endsOn)';
}


}

/// @nodoc
abstract mixin class $CustomRepeatCopyWith<$Res> implements $RepeatRuleCopyWith<$Res> {
  factory $CustomRepeatCopyWith(CustomRepeat value, $Res Function(CustomRepeat) _then) = _$CustomRepeatCopyWithImpl;
@override @useResult
$Res call({
 int interval, RepeatUnit unit, int? dayOfMonth, DateTime? endsOn
});




}
/// @nodoc
class _$CustomRepeatCopyWithImpl<$Res>
    implements $CustomRepeatCopyWith<$Res> {
  _$CustomRepeatCopyWithImpl(this._self, this._then);

  final CustomRepeat _self;
  final $Res Function(CustomRepeat) _then;

/// Create a copy of RepeatRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? interval = null,Object? unit = null,Object? dayOfMonth = freezed,Object? endsOn = freezed,}) {
  return _then(CustomRepeat(
null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as RepeatUnit,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,endsOn: freezed == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
