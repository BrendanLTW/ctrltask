import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';

/// The Theme setting (S36). Flutter's `ThemeMode` isn't pure Dart.
enum AppTheme { light, dark, system }

/// The user's settings (PRD §8 Preferences), with first-launch defaults.
/// Toggle defaults follow the S31 and S39 designs.
@freezed
abstract class Preferences with _$Preferences {
  const factory({
    @Default('') String userName,
    @Default(AppTheme.system) AppTheme theme,
    @Default(WeekStart.mon) WeekStart weekStart,
    @Default(TaskPriority.medium) TaskPriority defaultPriority,
    @Default(false) bool onboardingComplete,

    // Focus timer (S31). Lengths in minutes.
    @Default(25) int focusMin,
    @Default(5) int shortMin,
    @Default(15) int longMin,
    @Default(4) int sessionsPerRound,
    @Default(true) bool autoStartBreaks,
    @Default(false) bool autoStartNext,
    @Default(true) bool silenceWhileFocusing,

    // Notifications (S39). Times are minutes after local midnight.
    @Default(true) bool remindersOn,
    @Default(true) bool dailyPlanOn,
    @Default(8 * 60) int dailyPlanMinute,
    @Default(false) bool overdueOn,
    @Default(true) bool focusEndOn,
    @Default(true) bool weeklyReviewOn,
    @Default(ReminderOffset.min30) ReminderOffset defaultReminder,
    @Default(23 * 60) int quietStartMinute,
    @Default(7 * 60) int quietEndMinute,

    /// Whether ctrlTask has asked the phone for permission (S05, S39); the
    /// OS can't tell "never asked" from "denied" on iOS.
    @Default(false) bool notificationsAsked,
  }) = _Preferences;
}
