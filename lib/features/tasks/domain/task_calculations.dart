import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';

/// Today's list in display order (PRD §8): done last, then by time with
/// untimed after timed, then priority, then `sortOrder`.
List<Task> orderToday(Iterable<Task> tasks) => [...tasks]
  ..sort((a, b) {
    final done = _isDone(a).compareTo(_isDone(b));
    if (done != 0) return done;
    final (am, bm) = (a.dueMinute, b.dueMinute);
    if (am != bm) {
      if (am == null) return 1;
      if (bm == null) return -1;
      return am.compareTo(bm);
    }
    final priority = a.priority.index.compareTo(b.priority.index);
    return priority != 0 ? priority : a.sortOrder.compareTo(b.sortOrder);
  });

/// Completed out of today's list (PRD §8).
Progress todayProgress(Iterable<Task> todayList) => (
  done: todayList.where((t) => t.status == TaskStatus.done).length,
  total: todayList.length,
);

/// Open tasks overdue at [now], most urgent first: by priority, then the
/// oldest due date and time. The first is the Home banner's task (S07).
List<Task> overdueTasks(Iterable<Task> tasks, DateTime now) =>
    [
      for (final t in tasks)
        if (t.status == TaskStatus.open &&
            isOverdue(dueDate: t.dueDate, dueMinute: t.dueMinute, now: now))
          t,
    ]..sort((a, b) {
      final priority = a.priority.index.compareTo(b.priority.index);
      if (priority != 0) return priority;
      final date = a.dueDate!.compareTo(b.dueDate!);
      if (date != 0) return date;
      final time = (a.dueMinute ?? 0).compareTo(b.dueMinute ?? 0);
      return time != 0 ? time : a.sortOrder.compareTo(b.sortOrder);
    });

/// Consecutive local days with at least one completion, ending [today] or
/// yesterday (PRD §8). Derived from `completedAt`, so Undo needs nothing.
int streak(Iterable<Task> tasks, DateTime today) {
  final days = {for (final d in _completionDays(tasks)) d};
  var day = DateTime(today.year, today.month, today.day);
  if (!days.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
  var count = 0;
  while (days.contains(day)) {
    count++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return count;
}

/// Tasks completed in the week containing [today] (PRD §8).
int doneThisWeek(Iterable<Task> tasks, DateTime today, WeekStart weekStart) {
  final week = weekOf(today, weekStart);
  return _completionDays(tasks)
      .where((d) => !d.isBefore(week.start) && !d.isAfter(week.end))
      .length;
}

int _isDone(Task t) => t.status == TaskStatus.done ? 1 : 0;

/// The local day of each done task's completion.
Iterable<DateTime> _completionDays(Iterable<Task> tasks) sync* {
  for (final t in tasks) {
    final at = t.completedAt;
    if (t.status != TaskStatus.done || at == null) continue;
    final local = at.toLocal();
    yield DateTime(local.year, local.month, local.day);
  }
}
