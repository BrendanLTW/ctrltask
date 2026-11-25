import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';

/// Keys in the Preferences table (PRD §8).
abstract final class PreferenceKeys {
  static const userName = 'userName';
  static const theme = 'theme';
  static const weekStart = 'weekStart';
  static const defaultPriority = 'defaultPriority';
  static const onboardingComplete = 'onboardingComplete';
  static const focusMin = 'focusMin';
  static const shortMin = 'shortMin';
  static const longMin = 'longMin';
  static const sessionsPerRound = 'sessionsPerRound';
  static const autoStartBreaks = 'autoStartBreaks';
  static const autoStartNext = 'autoStartNext';
  static const silenceWhileFocusing = 'silenceWhileFocusing';
  static const remindersOn = 'remindersOn';
  static const dailyPlanOn = 'dailyPlanOn';
  static const dailyPlanMinute = 'dailyPlanMinute';
  static const overdueOn = 'overdueOn';
  static const focusEndOn = 'focusEndOn';
  static const weeklyReviewOn = 'weeklyReviewOn';
  static const defaultReminder = 'defaultReminder';
  static const quietStartMinute = 'quietStartMinute';
  static const quietEndMinute = 'quietEndMinute';
  static const notificationsAsked = 'notificationsAsked';
  static const autoBackup = 'autoBackup';
  static const backupKeep = 'backupKeep';
}

/// Builds [Preferences] from the table's key-value pairs. A missing,
/// unreadable or out-of-range value falls back to its default, so a bad
/// row never stops the app from starting.
Preferences preferencesFromValues(Map<String, String> values) {
  const d = Preferences();
  bool? flag(String key) => bool.tryParse(values[key] ?? '');
  T byName<T extends Enum>(List<T> all, String key, T fallback) =>
      all.asNameMap()[values[key]] ?? fallback;
  // An integer in min–max on the given step (S31 steppers), else fallback.
  int number(String key, int fallback, int min, int max, [int step = 1]) =>
      switch (int.tryParse(values[key] ?? '')) {
        final n? when n >= min && n <= max && (n - min) % step == 0 => n,
        _ => fallback,
      };
  int minute(String key, int fallback) => number(key, fallback, 0, 1439);

  return Preferences(
    userName: values[PreferenceKeys.userName] ?? d.userName,
    theme: byName(AppTheme.values, PreferenceKeys.theme, d.theme),
    weekStart: byName(WeekStart.values, PreferenceKeys.weekStart, d.weekStart),
    defaultPriority: byName(
      TaskPriority.values,
      PreferenceKeys.defaultPriority,
      d.defaultPriority,
    ),
    onboardingComplete:
        flag(PreferenceKeys.onboardingComplete) ?? d.onboardingComplete,
    focusMin: number(PreferenceKeys.focusMin, d.focusMin, 10, 90, 5),
    shortMin: number(PreferenceKeys.shortMin, d.shortMin, 1, 15),
    longMin: number(PreferenceKeys.longMin, d.longMin, 10, 45, 5),
    sessionsPerRound: number(
      PreferenceKeys.sessionsPerRound,
      d.sessionsPerRound,
      2,
      8,
    ),
    autoStartBreaks: flag(PreferenceKeys.autoStartBreaks) ?? d.autoStartBreaks,
    autoStartNext: flag(PreferenceKeys.autoStartNext) ?? d.autoStartNext,
    silenceWhileFocusing:
        flag(PreferenceKeys.silenceWhileFocusing) ?? d.silenceWhileFocusing,
    remindersOn: flag(PreferenceKeys.remindersOn) ?? d.remindersOn,
    dailyPlanOn: flag(PreferenceKeys.dailyPlanOn) ?? d.dailyPlanOn,
    dailyPlanMinute: minute(PreferenceKeys.dailyPlanMinute, d.dailyPlanMinute),
    overdueOn: flag(PreferenceKeys.overdueOn) ?? d.overdueOn,
    focusEndOn: flag(PreferenceKeys.focusEndOn) ?? d.focusEndOn,
    weeklyReviewOn: flag(PreferenceKeys.weeklyReviewOn) ?? d.weeklyReviewOn,
    defaultReminder: byName(
      ReminderOffset.values,
      PreferenceKeys.defaultReminder,
      d.defaultReminder,
    ),
    quietStartMinute: minute(
      PreferenceKeys.quietStartMinute,
      d.quietStartMinute,
    ),
    quietEndMinute: minute(PreferenceKeys.quietEndMinute, d.quietEndMinute),
    notificationsAsked:
        flag(PreferenceKeys.notificationsAsked) ?? d.notificationsAsked,
    autoBackup: flag(PreferenceKeys.autoBackup) ?? d.autoBackup,
    backupKeep: switch (int.tryParse(values[PreferenceKeys.backupKeep] ?? '')) {
      final n? when backupKeepChoices.contains(n) => n,
      _ => d.backupKeep,
    },
  );
}

/// The table's key-value pairs for [prefs].
Map<String, String> preferencesToValues(Preferences prefs) => {
  PreferenceKeys.userName: prefs.userName,
  PreferenceKeys.theme: prefs.theme.name,
  PreferenceKeys.weekStart: prefs.weekStart.name,
  PreferenceKeys.defaultPriority: prefs.defaultPriority.name,
  PreferenceKeys.onboardingComplete: '${prefs.onboardingComplete}',
  PreferenceKeys.focusMin: '${prefs.focusMin}',
  PreferenceKeys.shortMin: '${prefs.shortMin}',
  PreferenceKeys.longMin: '${prefs.longMin}',
  PreferenceKeys.sessionsPerRound: '${prefs.sessionsPerRound}',
  PreferenceKeys.autoStartBreaks: '${prefs.autoStartBreaks}',
  PreferenceKeys.autoStartNext: '${prefs.autoStartNext}',
  PreferenceKeys.silenceWhileFocusing: '${prefs.silenceWhileFocusing}',
  PreferenceKeys.remindersOn: '${prefs.remindersOn}',
  PreferenceKeys.dailyPlanOn: '${prefs.dailyPlanOn}',
  PreferenceKeys.dailyPlanMinute: '${prefs.dailyPlanMinute}',
  PreferenceKeys.overdueOn: '${prefs.overdueOn}',
  PreferenceKeys.focusEndOn: '${prefs.focusEndOn}',
  PreferenceKeys.weeklyReviewOn: '${prefs.weeklyReviewOn}',
  PreferenceKeys.defaultReminder: prefs.defaultReminder.name,
  PreferenceKeys.quietStartMinute: '${prefs.quietStartMinute}',
  PreferenceKeys.quietEndMinute: '${prefs.quietEndMinute}',
  PreferenceKeys.notificationsAsked: '${prefs.notificationsAsked}',
  PreferenceKeys.autoBackup: '${prefs.autoBackup}',
  PreferenceKeys.backupKeep: '${prefs.backupKeep}',
};
