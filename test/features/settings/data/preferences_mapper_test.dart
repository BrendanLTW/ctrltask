import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/settings/data/preferences_mapper.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nothing stored reads as the PRD and design defaults', () {
    final prefs = preferencesFromValues({});
    expect(prefs, const Preferences());
    expect(prefs.theme, AppTheme.system);
    expect(prefs.weekStart, WeekStart.mon);
    expect(prefs.defaultPriority, TaskPriority.medium);
    expect(
      (prefs.focusMin, prefs.shortMin, prefs.longMin, prefs.sessionsPerRound),
      (25, 5, 15, 4),
    );
    expect(prefs.dailyPlanMinute, 480);
    expect(prefs.defaultReminder, ReminderOffset.min30);
    expect((prefs.quietStartMinute, prefs.quietEndMinute), (1380, 420));
  });

  test('every key survives a round trip', () {
    const prefs = Preferences(
      userName: 'Alex',
      theme: AppTheme.dark,
      weekStart: WeekStart.sat,
      defaultPriority: TaskPriority.urgent,
      onboardingComplete: true,
      focusMin: 90,
      shortMin: 1,
      longMin: 45,
      sessionsPerRound: 8,
      autoStartBreaks: false,
      autoStartNext: true,
      silenceWhileFocusing: false,
      remindersOn: false,
      dailyPlanOn: false,
      dailyPlanMinute: 9 * 60 + 30,
      overdueOn: true,
      focusEndOn: false,
      weeklyReviewOn: false,
      defaultReminder: ReminderOffset.dayBefore,
      quietStartMinute: 0,
      quietEndMinute: 1439,
    );
    final values = preferencesToValues(prefs);
    expect(values.keys, hasLength(21));
    expect(preferencesFromValues(values), prefs);
  });

  test('bad or out-of-range values fall back to their defaults', () {
    const d = Preferences();
    final prefs = preferencesFromValues({
      PreferenceKeys.theme: 'sepia',
      PreferenceKeys.weekStart: 'tue',
      PreferenceKeys.defaultPriority: '',
      PreferenceKeys.onboardingComplete: 'yes',
      PreferenceKeys.focusMin: '27', // off the 5-minute step
      PreferenceKeys.shortMin: '16',
      PreferenceKeys.longMin: '5',
      PreferenceKeys.sessionsPerRound: '1',
      PreferenceKeys.dailyPlanMinute: '1440',
      PreferenceKeys.quietStartMinute: '-1',
      PreferenceKeys.quietEndMinute: 'seven',
      PreferenceKeys.defaultReminder: 'min45',
    });
    expect(prefs, d);
  });
}
