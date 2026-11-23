import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/notifications/domain/notification_plan.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tue 17 Nov 2026, 9:41 AM.
  final now = DateTime(2026, 11, 17, 9, 41);
  var id = 1;

  Task task(
    String title, {
    DateTime? due,
    int? minute,
    ReminderOffset reminder = ReminderOffset.none,
    bool done = false,
  }) => Task(
    id: id++,
    title: title,
    priority: TaskPriority.medium,
    status: done ? TaskStatus.done : TaskStatus.open,
    boardColumn: BoardColumn.todo,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    sortOrder: 0,
    dueDate: due,
    dueMinute: minute,
    reminder: reminder,
  );

  /// Only task reminders on, unless a test turns more on.
  const remindersOnly = Preferences(
    dailyPlanOn: false,
    weeklyReviewOn: false,
    focusEndOn: false,
    quietStartMinute: 0,
    quietEndMinute: 0,
  );

  List<PlannedNotification> plan(
    List<Task> tasks, {
    Preferences prefs = remindersOnly,
    FocusTimer timer = const FocusTimer(),
  }) =>
      planNotifications(openTasks: tasks, prefs: prefs, timer: timer, now: now);

  group('reminderTime', () {
    final thu = DateTime(2026, 11, 19);
    for (final (offset, minute, expected) in [
      (ReminderOffset.atTime, 900, DateTime(2026, 11, 19, 15)),
      (ReminderOffset.min10, 900, DateTime(2026, 11, 19, 14, 50)),
      (ReminderOffset.min30, 900, DateTime(2026, 11, 19, 14, 30)),
      (ReminderOffset.hour1, 900, DateTime(2026, 11, 19, 14)),
      (ReminderOffset.morningOf, 900, DateTime(2026, 11, 19, 9)),
      (ReminderOffset.dayBefore, 900, DateTime(2026, 11, 18, 15)),
      // Without a time: Morning of and Day before at 9 AM; the rest none.
      (ReminderOffset.morningOf, null, DateTime(2026, 11, 19, 9)),
      (ReminderOffset.dayBefore, null, DateTime(2026, 11, 18, 9)),
      (ReminderOffset.min30, null, null),
      (ReminderOffset.none, 900, null),
    ]) {
      test('${offset.name} with ${minute ?? 'no'} time', () {
        expect(
          reminderTime(task('T', due: thu, minute: minute, reminder: offset)),
          expected,
        );
      });
    }

    test('10 minutes before midnight crosses into the day before', () {
      expect(
        reminderTime(
          task('T', due: thu, minute: 5, reminder: ReminderOffset.min10),
        ),
        DateTime(2026, 11, 18, 23, 55),
      );
    });
  });

  group('quiet hours', () {
    test('across midnight: late and early times move to the end', () {
      for (final (at, expected) in [
        (DateTime(2026, 11, 17, 23, 30), DateTime(2026, 11, 18, 7)),
        (DateTime(2026, 11, 18, 6, 59), DateTime(2026, 11, 18, 7)),
        (DateTime(2026, 11, 18, 7), DateTime(2026, 11, 18, 7)),
        (DateTime(2026, 11, 17, 22, 59), DateTime(2026, 11, 17, 22, 59)),
      ]) {
        expect(outsideQuietHours(at, start: 23 * 60, end: 7 * 60), expected);
      }
    });

    test('within a day, and none when the ends match', () {
      final at = DateTime(2026, 11, 17, 13);
      expect(
        outsideQuietHours(at, start: 12 * 60, end: 14 * 60),
        DateTime(2026, 11, 17, 14),
      );
      expect(outsideQuietHours(at, start: 600, end: 600), at);
    });
  });

  group('planNotifications', () {
    test('task reminders: open, in the future, within 14 days', () {
      final soon = task(
        'Slides',
        due: DateTime(2026, 11, 17),
        minute: 17 * 60,
        reminder: ReminderOffset.min30,
      );
      final past = task(
        'Standup',
        due: DateTime(2026, 11, 17),
        minute: 9 * 60,
        reminder: ReminderOffset.atTime,
      );
      final far = task(
        'Taxes',
        due: DateTime(2026, 12, 20),
        reminder: ReminderOffset.morningOf,
      );
      final done = task(
        'Done',
        due: DateTime(2026, 11, 18),
        reminder: ReminderOffset.morningOf,
        done: true,
      );
      final planned = plan([soon, past, far, done]);
      expect([for (final n in planned) n.task!.title], ['Slides']);
      expect(planned.single.at, DateTime(2026, 11, 17, 16, 30));
    });

    test('reminders off: none', () {
      final t = task(
        'Slides',
        due: DateTime(2026, 11, 18),
        reminder: ReminderOffset.morningOf,
      );
      expect(
        plan([t], prefs: remindersOnly.copyWith(remindersOn: false)),
        isEmpty,
      );
    });

    test('quiet hours delay reminders and nudges, not the focus end', () {
      final t = task(
        'Early',
        due: DateTime(2026, 11, 18),
        minute: 6 * 60,
        reminder: ReminderOffset.atTime,
      );
      final planned = plan(
        [t],
        prefs: remindersOnly.copyWith(
          quietStartMinute: 23 * 60,
          quietEndMinute: 7 * 60,
        ),
      );
      expect(planned.single.at, DateTime(2026, 11, 18, 7));
    });

    test('the daily plan: each day with something due, with a count', () {
      final planned = plan(
        [
          task('Slides', due: DateTime(2026, 11, 18)),
          task('Copy', due: DateTime(2026, 11, 18)),
          task('Gym', due: DateTime(2026, 11, 20)),
        ],
        prefs: remindersOnly.copyWith(dailyPlanOn: true, dailyPlanMinute: 480),
      );
      expect(
        [for (final n in planned) (n.kind, n.at, n.count)],
        [
          (NotificationKind.dailyPlan, DateTime(2026, 11, 18, 8), 2),
          (NotificationKind.dailyPlan, DateTime(2026, 11, 20, 8), 1),
        ],
      );
      expect(planned.first.firstTitle, isNotNull);
    });

    test("today's plan isn't sent once its time has passed", () {
      final planned = plan(
        [task('Slides', due: DateTime(2026, 11, 17))],
        prefs: remindersOnly.copyWith(dailyPlanOn: true, dailyPlanMinute: 480),
      );
      expect(planned, isEmpty);
    });

    test('the overdue nudge at 6 PM while something is overdue', () {
      final planned = plan([
        task('Invoice', due: DateTime(2026, 11, 16)),
      ], prefs: remindersOnly.copyWith(overdueOn: true));
      expect(planned.first.kind, NotificationKind.overdue);
      expect(planned.first.at, DateTime(2026, 11, 17, 18));
      expect(planned.first.count, 1);
      // Every evening until it's done, within the 14 days.
      expect(planned, hasLength(14));
    });

    test('the weekly review on Sundays at 8 PM', () {
      final planned = plan(
        const [],
        prefs: remindersOnly.copyWith(weeklyReviewOn: true),
      );
      expect(
        [for (final n in planned) n.at],
        [DateTime(2026, 11, 22, 20), DateTime(2026, 11, 29, 20)],
      );
    });

    test('the focus end when a session is running', () {
      final timer = const FocusTimer().start(now.toUtc());
      final planned = plan(
        const [],
        prefs: remindersOnly.copyWith(focusEndOn: true),
        timer: timer,
      );
      expect(planned.single.kind, NotificationKind.focusEnd);
      expect(planned.single.at, now.add(const Duration(minutes: 25)));
      expect(planned.single.isBreak, isFalse);

      final paused = timer.pause(now.toUtc());
      expect(
        plan(
          const [],
          prefs: remindersOnly.copyWith(focusEndOn: true),
          timer: paused,
        ),
        isEmpty,
      );
    });

    test('silence while focusing holds reminders until the session ends', () {
      final timer = const FocusTimer().start(now.toUtc());
      final t = task(
        'Call',
        due: DateTime(2026, 11, 17),
        minute: 10 * 60,
        reminder: ReminderOffset.atTime,
      );
      final held = plan([t], timer: timer);
      expect(held.single.at, now.add(const Duration(minutes: 25)));

      final loud = plan(
        [t],
        timer: timer,
        prefs: remindersOnly.copyWith(silenceWhileFocusing: false),
      );
      expect(loud.single.at, DateTime(2026, 11, 17, 10));

      // A break doesn't hold them.
      final onBreak = const FocusTimer(
        kind: FocusKind.short,
        plannedSec: 300,
      ).start(now.toUtc());
      expect(plan([t], timer: onBreak).single.at, DateTime(2026, 11, 17, 10));
    });

    test('at most the cap, earliest first', () {
      final tasks = [
        for (var i = 1; i <= 13; i++)
          for (var h = 10; h < 16; h++)
            task(
              'T$i-$h',
              due: DateTime(2026, 11, 17 + i),
              minute: h * 60,
              reminder: ReminderOffset.atTime,
            ),
      ];
      final planned = plan(tasks);
      expect(planned, hasLength(60));
      expect(planned.first.at, DateTime(2026, 11, 18, 10));
      expect([
        for (final n in planned) n.at,
      ], [...planned.map((n) => n.at)]..sort());
    });
  });
}
