import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';

enum NotificationKind { reminder, dailyPlan, overdue, weeklyReview, focusEnd }

/// A notification to schedule (PRD §6.5). `at` is local time. The words
/// come from the ARB copy when it's scheduled.
typedef PlannedNotification = ({
  NotificationKind kind,
  DateTime at,

  /// The task a reminder is for.
  Task? task,

  /// Tasks due (daily plan) or overdue (nudge) that day.
  int count,

  /// The daily plan's first task.
  String? firstTitle,

  /// A focus end that finishes a break.
  bool isBreak,
});

/// The overdue nudge's time (S39: 6:00 PM).
const int overdueNudgeMinute = 18 * 60;

/// The weekly review: Sunday at 8:00 PM (S39).
const int weeklyReviewMinute = 20 * 60;

/// Morning of, and Day before without a due time (§6.5): 9:00 AM.
const int morningMinute = 9 * 60;

/// [minute] after [day]'s midnight; negative goes into the day before.
DateTime _at(DateTime day, int minute) =>
    DateTime(day.year, day.month, day.day, 0, minute);

/// When [task]'s reminder fires, before quiet hours; null without one.
DateTime? reminderTime(Task task) =>
    reminderAt(task.reminder, dueDate: task.dueDate, dueMinute: task.dueMinute);

/// When [offset] fires for a due date and time (§6.5), or null if it
/// can't: no reminder, no date, or a timed offset without a time.
DateTime? reminderAt(
  ReminderOffset offset, {
  required DateTime? dueDate,
  required int? dueMinute,
}) {
  final due = dueDate;
  if (due == null) return null;
  DateTime? before(int minutes) =>
      dueMinute == null ? null : _at(due, dueMinute - minutes);
  return switch (offset) {
    ReminderOffset.none => null,
    ReminderOffset.atTime => before(0),
    ReminderOffset.min10 => before(10),
    ReminderOffset.min30 => before(30),
    ReminderOffset.hour1 => before(60),
    ReminderOffset.morningOf => _at(due, morningMinute),
    ReminderOffset.dayBefore => _at(
      DateTime(due.year, due.month, due.day - 1),
      dueMinute ?? morningMinute,
    ),
  };
}

/// The reminder a new task starts with: the Default task reminder (S39)
/// when it can fire for this due date and time, else none.
ReminderOffset defaultReminderFor(
  ReminderOffset preferred, {
  required DateTime? dueDate,
  required int? dueMinute,
}) => reminderAt(preferred, dueDate: dueDate, dueMinute: dueMinute) == null
    ? ReminderOffset.none
    : preferred;

/// [at], or the end of quiet hours if it falls inside them. Quiet hours
/// may cross midnight (11 PM – 7 AM); equal ends mean none.
DateTime outsideQuietHours(
  DateTime at, {
  required int start,
  required int end,
}) {
  if (start == end) return at;
  final minute = at.hour * 60 + at.minute;
  final day = DateTime(at.year, at.month, at.day);
  if (start < end) {
    return minute >= start && minute < end ? _at(day, end) : at;
  }
  if (minute >= start) {
    return _at(DateTime(day.year, day.month, day.day + 1), end);
  }
  if (minute < end) return _at(day, end);
  return at;
}

/// Every notification due in the next [horizon] from [now], earliest
/// first, at most [cap] (iOS keeps 64 pending). [openTasks] leaves out
/// archived projects; done tasks have no reminders.
List<PlannedNotification> planNotifications({
  required Iterable<Task> openTasks,
  required Preferences prefs,
  required FocusTimer timer,
  required DateTime now,
  Duration horizon = const Duration(days: 14),
  int cap = 60,
}) {
  // Nothing until the app is set up: a fresh install, or just erased.
  if (!prefs.onboardingComplete) return const [];
  final open = [
    for (final t in openTasks)
      if (t.status == TaskStatus.open) t,
  ];
  final until = now.add(horizon);
  final today = DateTime(now.year, now.month, now.day);
  final days = [
    for (var i = 0; i <= horizon.inDays; i++)
      DateTime(today.year, today.month, today.day + i),
  ];
  final out = <PlannedNotification>[];
  PlannedNotification note(
    NotificationKind kind,
    DateTime at, {
    Task? task,
    int count = 0,
    String? firstTitle,
    bool isBreak = false,
  }) => (
    kind: kind,
    at: at,
    task: task,
    count: count,
    firstTitle: firstTitle,
    isBreak: isBreak,
  );

  // When a running focus session or break ends.
  final focusEnd = timer.phase == TimerPhase.running
      ? now.add(Duration(seconds: timer.remainingSec(now.toUtc())))
      : null;
  if (focusEnd != null && prefs.focusEndOn) {
    out.add(
      note(
        NotificationKind.focusEnd,
        focusEnd,
        isBreak: timer.kind != FocusKind.focus,
      ),
    );
  }

  if (prefs.remindersOn) {
    for (final task in open) {
      var at = reminderTime(task);
      if (at == null) continue;
      // Held while focusing, until the session ends (S31).
      if (prefs.silenceWhileFocusing &&
          focusEnd != null &&
          timer.kind == FocusKind.focus &&
          at.isBefore(focusEnd)) {
        at = focusEnd;
      }
      out.add(note(NotificationKind.reminder, at, task: task));
    }
  }

  for (final day in days) {
    if (prefs.dailyPlanOn) {
      final due = orderToday(open.where((t) => t.dueDate == day));
      if (due.isNotEmpty) {
        out.add(
          note(
            NotificationKind.dailyPlan,
            _at(day, prefs.dailyPlanMinute),
            count: due.length,
            firstTitle: due.first.title,
          ),
        );
      }
    }
    if (prefs.overdueOn) {
      // Still open by then, it's overdue that evening.
      final late = open.where((t) => t.dueDate?.isBefore(day) ?? false);
      if (late.isNotEmpty) {
        out.add(
          note(
            NotificationKind.overdue,
            _at(day, overdueNudgeMinute),
            count: late.length,
          ),
        );
      }
    }
    if (prefs.weeklyReviewOn && day.weekday == DateTime.sunday) {
      out.add(
        note(NotificationKind.weeklyReview, _at(day, weeklyReviewMinute)),
      );
    }
  }

  final planned =
      [
          for (final n in out)
            if (n.kind == NotificationKind.focusEnd)
              n
            else
              note(
                n.kind,
                outsideQuietHours(
                  n.at,
                  start: prefs.quietStartMinute,
                  end: prefs.quietEndMinute,
                ),
                task: n.task,
                count: n.count,
                firstTitle: n.firstTitle,
              ),
        ].where((n) => n.at.isAfter(now) && !n.at.isAfter(until)).toList()
        ..sort((a, b) => a.at.compareTo(b.at));
  return planned.take(cap).toList();
}
