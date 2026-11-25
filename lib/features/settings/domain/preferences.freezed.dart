// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Preferences {

 String get userName; AppTheme get theme; WeekStart get weekStart; TaskPriority get defaultPriority; bool get onboardingComplete; int get focusMin; int get shortMin; int get longMin; int get sessionsPerRound; bool get autoStartBreaks; bool get autoStartNext; bool get silenceWhileFocusing; bool get remindersOn; bool get dailyPlanOn; int get dailyPlanMinute; bool get overdueOn; bool get focusEndOn; bool get weeklyReviewOn; ReminderOffset get defaultReminder; int get quietStartMinute; int get quietEndMinute;/// Whether ctrlTask has asked the phone for permission (S05, S39); the
/// OS can't tell "never asked" from "denied" on iOS.
 bool get notificationsAsked; bool get autoBackup; int get backupKeep;
/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesCopyWith<Preferences> get copyWith => _$PreferencesCopyWithImpl<Preferences>(this as Preferences, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Preferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preferences&&(identical(other.userName, _this.userName) || other.userName == _this.userName)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.weekStart, _this.weekStart) || other.weekStart == _this.weekStart)&&(identical(other.defaultPriority, _this.defaultPriority) || other.defaultPriority == _this.defaultPriority)&&(identical(other.onboardingComplete, _this.onboardingComplete) || other.onboardingComplete == _this.onboardingComplete)&&(identical(other.focusMin, _this.focusMin) || other.focusMin == _this.focusMin)&&(identical(other.shortMin, _this.shortMin) || other.shortMin == _this.shortMin)&&(identical(other.longMin, _this.longMin) || other.longMin == _this.longMin)&&(identical(other.sessionsPerRound, _this.sessionsPerRound) || other.sessionsPerRound == _this.sessionsPerRound)&&(identical(other.autoStartBreaks, _this.autoStartBreaks) || other.autoStartBreaks == _this.autoStartBreaks)&&(identical(other.autoStartNext, _this.autoStartNext) || other.autoStartNext == _this.autoStartNext)&&(identical(other.silenceWhileFocusing, _this.silenceWhileFocusing) || other.silenceWhileFocusing == _this.silenceWhileFocusing)&&(identical(other.remindersOn, _this.remindersOn) || other.remindersOn == _this.remindersOn)&&(identical(other.dailyPlanOn, _this.dailyPlanOn) || other.dailyPlanOn == _this.dailyPlanOn)&&(identical(other.dailyPlanMinute, _this.dailyPlanMinute) || other.dailyPlanMinute == _this.dailyPlanMinute)&&(identical(other.overdueOn, _this.overdueOn) || other.overdueOn == _this.overdueOn)&&(identical(other.focusEndOn, _this.focusEndOn) || other.focusEndOn == _this.focusEndOn)&&(identical(other.weeklyReviewOn, _this.weeklyReviewOn) || other.weeklyReviewOn == _this.weeklyReviewOn)&&(identical(other.defaultReminder, _this.defaultReminder) || other.defaultReminder == _this.defaultReminder)&&(identical(other.quietStartMinute, _this.quietStartMinute) || other.quietStartMinute == _this.quietStartMinute)&&(identical(other.quietEndMinute, _this.quietEndMinute) || other.quietEndMinute == _this.quietEndMinute)&&(identical(other.notificationsAsked, _this.notificationsAsked) || other.notificationsAsked == _this.notificationsAsked)&&(identical(other.autoBackup, _this.autoBackup) || other.autoBackup == _this.autoBackup)&&(identical(other.backupKeep, _this.backupKeep) || other.backupKeep == _this.backupKeep));
}


@override
int get hashCode {
  final _this = this as Preferences;
  return Object.hashAll([runtimeType,_this.userName,_this.theme,_this.weekStart,_this.defaultPriority,_this.onboardingComplete,_this.focusMin,_this.shortMin,_this.longMin,_this.sessionsPerRound,_this.autoStartBreaks,_this.autoStartNext,_this.silenceWhileFocusing,_this.remindersOn,_this.dailyPlanOn,_this.dailyPlanMinute,_this.overdueOn,_this.focusEndOn,_this.weeklyReviewOn,_this.defaultReminder,_this.quietStartMinute,_this.quietEndMinute,_this.notificationsAsked,_this.autoBackup,_this.backupKeep]);
}

@override
String toString() {
  final _this = this as Preferences;
  return 'Preferences(userName: ${_this.userName}, theme: ${_this.theme}, weekStart: ${_this.weekStart}, defaultPriority: ${_this.defaultPriority}, onboardingComplete: ${_this.onboardingComplete}, focusMin: ${_this.focusMin}, shortMin: ${_this.shortMin}, longMin: ${_this.longMin}, sessionsPerRound: ${_this.sessionsPerRound}, autoStartBreaks: ${_this.autoStartBreaks}, autoStartNext: ${_this.autoStartNext}, silenceWhileFocusing: ${_this.silenceWhileFocusing}, remindersOn: ${_this.remindersOn}, dailyPlanOn: ${_this.dailyPlanOn}, dailyPlanMinute: ${_this.dailyPlanMinute}, overdueOn: ${_this.overdueOn}, focusEndOn: ${_this.focusEndOn}, weeklyReviewOn: ${_this.weeklyReviewOn}, defaultReminder: ${_this.defaultReminder}, quietStartMinute: ${_this.quietStartMinute}, quietEndMinute: ${_this.quietEndMinute}, notificationsAsked: ${_this.notificationsAsked}, autoBackup: ${_this.autoBackup}, backupKeep: ${_this.backupKeep})';
}


}

/// @nodoc
abstract mixin class $PreferencesCopyWith<$Res>  {
  factory $PreferencesCopyWith(Preferences value, $Res Function(Preferences) _then) = _$PreferencesCopyWithImpl;
@useResult
$Res call({
 String userName, AppTheme theme, WeekStart weekStart, TaskPriority defaultPriority, bool onboardingComplete, int focusMin, int shortMin, int longMin, int sessionsPerRound, bool autoStartBreaks, bool autoStartNext, bool silenceWhileFocusing, bool remindersOn, bool dailyPlanOn, int dailyPlanMinute, bool overdueOn, bool focusEndOn, bool weeklyReviewOn, ReminderOffset defaultReminder, int quietStartMinute, int quietEndMinute, bool notificationsAsked, bool autoBackup, int backupKeep
});




}
/// @nodoc
class _$PreferencesCopyWithImpl<$Res>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._self, this._then);

  final Preferences _self;
  final $Res Function(Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? theme = null,Object? weekStart = null,Object? defaultPriority = null,Object? onboardingComplete = null,Object? focusMin = null,Object? shortMin = null,Object? longMin = null,Object? sessionsPerRound = null,Object? autoStartBreaks = null,Object? autoStartNext = null,Object? silenceWhileFocusing = null,Object? remindersOn = null,Object? dailyPlanOn = null,Object? dailyPlanMinute = null,Object? overdueOn = null,Object? focusEndOn = null,Object? weeklyReviewOn = null,Object? defaultReminder = null,Object? quietStartMinute = null,Object? quietEndMinute = null,Object? notificationsAsked = null,Object? autoBackup = null,Object? backupKeep = null,}) {
  return _then(Preferences(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppTheme,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as WeekStart,defaultPriority: null == defaultPriority ? _self.defaultPriority : defaultPriority // ignore: cast_nullable_to_non_nullable
as TaskPriority,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,focusMin: null == focusMin ? _self.focusMin : focusMin // ignore: cast_nullable_to_non_nullable
as int,shortMin: null == shortMin ? _self.shortMin : shortMin // ignore: cast_nullable_to_non_nullable
as int,longMin: null == longMin ? _self.longMin : longMin // ignore: cast_nullable_to_non_nullable
as int,sessionsPerRound: null == sessionsPerRound ? _self.sessionsPerRound : sessionsPerRound // ignore: cast_nullable_to_non_nullable
as int,autoStartBreaks: null == autoStartBreaks ? _self.autoStartBreaks : autoStartBreaks // ignore: cast_nullable_to_non_nullable
as bool,autoStartNext: null == autoStartNext ? _self.autoStartNext : autoStartNext // ignore: cast_nullable_to_non_nullable
as bool,silenceWhileFocusing: null == silenceWhileFocusing ? _self.silenceWhileFocusing : silenceWhileFocusing // ignore: cast_nullable_to_non_nullable
as bool,remindersOn: null == remindersOn ? _self.remindersOn : remindersOn // ignore: cast_nullable_to_non_nullable
as bool,dailyPlanOn: null == dailyPlanOn ? _self.dailyPlanOn : dailyPlanOn // ignore: cast_nullable_to_non_nullable
as bool,dailyPlanMinute: null == dailyPlanMinute ? _self.dailyPlanMinute : dailyPlanMinute // ignore: cast_nullable_to_non_nullable
as int,overdueOn: null == overdueOn ? _self.overdueOn : overdueOn // ignore: cast_nullable_to_non_nullable
as bool,focusEndOn: null == focusEndOn ? _self.focusEndOn : focusEndOn // ignore: cast_nullable_to_non_nullable
as bool,weeklyReviewOn: null == weeklyReviewOn ? _self.weeklyReviewOn : weeklyReviewOn // ignore: cast_nullable_to_non_nullable
as bool,defaultReminder: null == defaultReminder ? _self.defaultReminder : defaultReminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset,quietStartMinute: null == quietStartMinute ? _self.quietStartMinute : quietStartMinute // ignore: cast_nullable_to_non_nullable
as int,quietEndMinute: null == quietEndMinute ? _self.quietEndMinute : quietEndMinute // ignore: cast_nullable_to_non_nullable
as int,notificationsAsked: null == notificationsAsked ? _self.notificationsAsked : notificationsAsked // ignore: cast_nullable_to_non_nullable
as bool,autoBackup: null == autoBackup ? _self.autoBackup : autoBackup // ignore: cast_nullable_to_non_nullable
as bool,backupKeep: null == backupKeep ? _self.backupKeep : backupKeep // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Preferences].
extension PreferencesPatterns on Preferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preferences value)  $default,){
final _that = this;
switch (_that) {
case _Preferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preferences value)?  $default,){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  AppTheme theme,  WeekStart weekStart,  TaskPriority defaultPriority,  bool onboardingComplete,  int focusMin,  int shortMin,  int longMin,  int sessionsPerRound,  bool autoStartBreaks,  bool autoStartNext,  bool silenceWhileFocusing,  bool remindersOn,  bool dailyPlanOn,  int dailyPlanMinute,  bool overdueOn,  bool focusEndOn,  bool weeklyReviewOn,  ReminderOffset defaultReminder,  int quietStartMinute,  int quietEndMinute,  bool notificationsAsked,  bool autoBackup,  int backupKeep)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.userName,_that.theme,_that.weekStart,_that.defaultPriority,_that.onboardingComplete,_that.focusMin,_that.shortMin,_that.longMin,_that.sessionsPerRound,_that.autoStartBreaks,_that.autoStartNext,_that.silenceWhileFocusing,_that.remindersOn,_that.dailyPlanOn,_that.dailyPlanMinute,_that.overdueOn,_that.focusEndOn,_that.weeklyReviewOn,_that.defaultReminder,_that.quietStartMinute,_that.quietEndMinute,_that.notificationsAsked,_that.autoBackup,_that.backupKeep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  AppTheme theme,  WeekStart weekStart,  TaskPriority defaultPriority,  bool onboardingComplete,  int focusMin,  int shortMin,  int longMin,  int sessionsPerRound,  bool autoStartBreaks,  bool autoStartNext,  bool silenceWhileFocusing,  bool remindersOn,  bool dailyPlanOn,  int dailyPlanMinute,  bool overdueOn,  bool focusEndOn,  bool weeklyReviewOn,  ReminderOffset defaultReminder,  int quietStartMinute,  int quietEndMinute,  bool notificationsAsked,  bool autoBackup,  int backupKeep)  $default,) {final _that = this;
switch (_that) {
case _Preferences():
return $default(_that.userName,_that.theme,_that.weekStart,_that.defaultPriority,_that.onboardingComplete,_that.focusMin,_that.shortMin,_that.longMin,_that.sessionsPerRound,_that.autoStartBreaks,_that.autoStartNext,_that.silenceWhileFocusing,_that.remindersOn,_that.dailyPlanOn,_that.dailyPlanMinute,_that.overdueOn,_that.focusEndOn,_that.weeklyReviewOn,_that.defaultReminder,_that.quietStartMinute,_that.quietEndMinute,_that.notificationsAsked,_that.autoBackup,_that.backupKeep);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  AppTheme theme,  WeekStart weekStart,  TaskPriority defaultPriority,  bool onboardingComplete,  int focusMin,  int shortMin,  int longMin,  int sessionsPerRound,  bool autoStartBreaks,  bool autoStartNext,  bool silenceWhileFocusing,  bool remindersOn,  bool dailyPlanOn,  int dailyPlanMinute,  bool overdueOn,  bool focusEndOn,  bool weeklyReviewOn,  ReminderOffset defaultReminder,  int quietStartMinute,  int quietEndMinute,  bool notificationsAsked,  bool autoBackup,  int backupKeep)?  $default,) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.userName,_that.theme,_that.weekStart,_that.defaultPriority,_that.onboardingComplete,_that.focusMin,_that.shortMin,_that.longMin,_that.sessionsPerRound,_that.autoStartBreaks,_that.autoStartNext,_that.silenceWhileFocusing,_that.remindersOn,_that.dailyPlanOn,_that.dailyPlanMinute,_that.overdueOn,_that.focusEndOn,_that.weeklyReviewOn,_that.defaultReminder,_that.quietStartMinute,_that.quietEndMinute,_that.notificationsAsked,_that.autoBackup,_that.backupKeep);case _:
  return null;

}
}

}

/// @nodoc


class _Preferences implements Preferences {
  const _Preferences({this.userName = '', this.theme = AppTheme.system, this.weekStart = WeekStart.mon, this.defaultPriority = TaskPriority.medium, this.onboardingComplete = false, this.focusMin = 25, this.shortMin = 5, this.longMin = 15, this.sessionsPerRound = 4, this.autoStartBreaks = true, this.autoStartNext = false, this.silenceWhileFocusing = true, this.remindersOn = true, this.dailyPlanOn = true, this.dailyPlanMinute = 8 * 60, this.overdueOn = false, this.focusEndOn = true, this.weeklyReviewOn = true, this.defaultReminder = ReminderOffset.min30, this.quietStartMinute = 23 * 60, this.quietEndMinute = 7 * 60, this.notificationsAsked = false, this.autoBackup = true, this.backupKeep = 7});
  

@override@JsonKey() final  String userName;
@override@JsonKey() final  AppTheme theme;
@override@JsonKey() final  WeekStart weekStart;
@override@JsonKey() final  TaskPriority defaultPriority;
@override@JsonKey() final  bool onboardingComplete;
@override@JsonKey() final  int focusMin;
@override@JsonKey() final  int shortMin;
@override@JsonKey() final  int longMin;
@override@JsonKey() final  int sessionsPerRound;
@override@JsonKey() final  bool autoStartBreaks;
@override@JsonKey() final  bool autoStartNext;
@override@JsonKey() final  bool silenceWhileFocusing;
@override@JsonKey() final  bool remindersOn;
@override@JsonKey() final  bool dailyPlanOn;
@override@JsonKey() final  int dailyPlanMinute;
@override@JsonKey() final  bool overdueOn;
@override@JsonKey() final  bool focusEndOn;
@override@JsonKey() final  bool weeklyReviewOn;
@override@JsonKey() final  ReminderOffset defaultReminder;
@override@JsonKey() final  int quietStartMinute;
@override@JsonKey() final  int quietEndMinute;
/// Whether ctrlTask has asked the phone for permission (S05, S39); the
/// OS can't tell "never asked" from "denied" on iOS.
@override@JsonKey() final  bool notificationsAsked;
@override@JsonKey() final  bool autoBackup;
@override@JsonKey() final  int backupKeep;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesCopyWith<_Preferences> get copyWith => __$PreferencesCopyWithImpl<_Preferences>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preferences&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&(identical(other.defaultPriority, defaultPriority) || other.defaultPriority == defaultPriority)&&(identical(other.onboardingComplete, onboardingComplete) || other.onboardingComplete == onboardingComplete)&&(identical(other.focusMin, focusMin) || other.focusMin == focusMin)&&(identical(other.shortMin, shortMin) || other.shortMin == shortMin)&&(identical(other.longMin, longMin) || other.longMin == longMin)&&(identical(other.sessionsPerRound, sessionsPerRound) || other.sessionsPerRound == sessionsPerRound)&&(identical(other.autoStartBreaks, autoStartBreaks) || other.autoStartBreaks == autoStartBreaks)&&(identical(other.autoStartNext, autoStartNext) || other.autoStartNext == autoStartNext)&&(identical(other.silenceWhileFocusing, silenceWhileFocusing) || other.silenceWhileFocusing == silenceWhileFocusing)&&(identical(other.remindersOn, remindersOn) || other.remindersOn == remindersOn)&&(identical(other.dailyPlanOn, dailyPlanOn) || other.dailyPlanOn == dailyPlanOn)&&(identical(other.dailyPlanMinute, dailyPlanMinute) || other.dailyPlanMinute == dailyPlanMinute)&&(identical(other.overdueOn, overdueOn) || other.overdueOn == overdueOn)&&(identical(other.focusEndOn, focusEndOn) || other.focusEndOn == focusEndOn)&&(identical(other.weeklyReviewOn, weeklyReviewOn) || other.weeklyReviewOn == weeklyReviewOn)&&(identical(other.defaultReminder, defaultReminder) || other.defaultReminder == defaultReminder)&&(identical(other.quietStartMinute, quietStartMinute) || other.quietStartMinute == quietStartMinute)&&(identical(other.quietEndMinute, quietEndMinute) || other.quietEndMinute == quietEndMinute)&&(identical(other.notificationsAsked, notificationsAsked) || other.notificationsAsked == notificationsAsked)&&(identical(other.autoBackup, autoBackup) || other.autoBackup == autoBackup)&&(identical(other.backupKeep, backupKeep) || other.backupKeep == backupKeep));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,userName,theme,weekStart,defaultPriority,onboardingComplete,focusMin,shortMin,longMin,sessionsPerRound,autoStartBreaks,autoStartNext,silenceWhileFocusing,remindersOn,dailyPlanOn,dailyPlanMinute,overdueOn,focusEndOn,weeklyReviewOn,defaultReminder,quietStartMinute,quietEndMinute,notificationsAsked,autoBackup,backupKeep]);
}

@override
String toString() {
    return 'Preferences(userName: $userName, theme: $theme, weekStart: $weekStart, defaultPriority: $defaultPriority, onboardingComplete: $onboardingComplete, focusMin: $focusMin, shortMin: $shortMin, longMin: $longMin, sessionsPerRound: $sessionsPerRound, autoStartBreaks: $autoStartBreaks, autoStartNext: $autoStartNext, silenceWhileFocusing: $silenceWhileFocusing, remindersOn: $remindersOn, dailyPlanOn: $dailyPlanOn, dailyPlanMinute: $dailyPlanMinute, overdueOn: $overdueOn, focusEndOn: $focusEndOn, weeklyReviewOn: $weeklyReviewOn, defaultReminder: $defaultReminder, quietStartMinute: $quietStartMinute, quietEndMinute: $quietEndMinute, notificationsAsked: $notificationsAsked, autoBackup: $autoBackup, backupKeep: $backupKeep)';
}


}

/// @nodoc
abstract mixin class _$PreferencesCopyWith<$Res> implements $PreferencesCopyWith<$Res> {
  factory _$PreferencesCopyWith(_Preferences value, $Res Function(_Preferences) _then) = __$PreferencesCopyWithImpl;
@override @useResult
$Res call({
 String userName, AppTheme theme, WeekStart weekStart, TaskPriority defaultPriority, bool onboardingComplete, int focusMin, int shortMin, int longMin, int sessionsPerRound, bool autoStartBreaks, bool autoStartNext, bool silenceWhileFocusing, bool remindersOn, bool dailyPlanOn, int dailyPlanMinute, bool overdueOn, bool focusEndOn, bool weeklyReviewOn, ReminderOffset defaultReminder, int quietStartMinute, int quietEndMinute, bool notificationsAsked, bool autoBackup, int backupKeep
});




}
/// @nodoc
class __$PreferencesCopyWithImpl<$Res>
    implements _$PreferencesCopyWith<$Res> {
  __$PreferencesCopyWithImpl(this._self, this._then);

  final _Preferences _self;
  final $Res Function(_Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? theme = null,Object? weekStart = null,Object? defaultPriority = null,Object? onboardingComplete = null,Object? focusMin = null,Object? shortMin = null,Object? longMin = null,Object? sessionsPerRound = null,Object? autoStartBreaks = null,Object? autoStartNext = null,Object? silenceWhileFocusing = null,Object? remindersOn = null,Object? dailyPlanOn = null,Object? dailyPlanMinute = null,Object? overdueOn = null,Object? focusEndOn = null,Object? weeklyReviewOn = null,Object? defaultReminder = null,Object? quietStartMinute = null,Object? quietEndMinute = null,Object? notificationsAsked = null,Object? autoBackup = null,Object? backupKeep = null,}) {
  return _then(_Preferences(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppTheme,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as WeekStart,defaultPriority: null == defaultPriority ? _self.defaultPriority : defaultPriority // ignore: cast_nullable_to_non_nullable
as TaskPriority,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,focusMin: null == focusMin ? _self.focusMin : focusMin // ignore: cast_nullable_to_non_nullable
as int,shortMin: null == shortMin ? _self.shortMin : shortMin // ignore: cast_nullable_to_non_nullable
as int,longMin: null == longMin ? _self.longMin : longMin // ignore: cast_nullable_to_non_nullable
as int,sessionsPerRound: null == sessionsPerRound ? _self.sessionsPerRound : sessionsPerRound // ignore: cast_nullable_to_non_nullable
as int,autoStartBreaks: null == autoStartBreaks ? _self.autoStartBreaks : autoStartBreaks // ignore: cast_nullable_to_non_nullable
as bool,autoStartNext: null == autoStartNext ? _self.autoStartNext : autoStartNext // ignore: cast_nullable_to_non_nullable
as bool,silenceWhileFocusing: null == silenceWhileFocusing ? _self.silenceWhileFocusing : silenceWhileFocusing // ignore: cast_nullable_to_non_nullable
as bool,remindersOn: null == remindersOn ? _self.remindersOn : remindersOn // ignore: cast_nullable_to_non_nullable
as bool,dailyPlanOn: null == dailyPlanOn ? _self.dailyPlanOn : dailyPlanOn // ignore: cast_nullable_to_non_nullable
as bool,dailyPlanMinute: null == dailyPlanMinute ? _self.dailyPlanMinute : dailyPlanMinute // ignore: cast_nullable_to_non_nullable
as int,overdueOn: null == overdueOn ? _self.overdueOn : overdueOn // ignore: cast_nullable_to_non_nullable
as bool,focusEndOn: null == focusEndOn ? _self.focusEndOn : focusEndOn // ignore: cast_nullable_to_non_nullable
as bool,weeklyReviewOn: null == weeklyReviewOn ? _self.weeklyReviewOn : weeklyReviewOn // ignore: cast_nullable_to_non_nullable
as bool,defaultReminder: null == defaultReminder ? _self.defaultReminder : defaultReminder // ignore: cast_nullable_to_non_nullable
as ReminderOffset,quietStartMinute: null == quietStartMinute ? _self.quietStartMinute : quietStartMinute // ignore: cast_nullable_to_non_nullable
as int,quietEndMinute: null == quietEndMinute ? _self.quietEndMinute : quietEndMinute // ignore: cast_nullable_to_non_nullable
as int,notificationsAsked: null == notificationsAsked ? _self.notificationsAsked : notificationsAsked // ignore: cast_nullable_to_non_nullable
as bool,autoBackup: null == autoBackup ? _self.autoBackup : autoBackup // ignore: cast_nullable_to_non_nullable
as bool,backupKeep: null == backupKeep ? _self.backupKeep : backupKeep // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
