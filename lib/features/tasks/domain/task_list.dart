import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';

/// S19's filter chips (PRD §5.6).
enum TaskFilter { all, today, upcoming, high, done }

/// Whether [task] was completed on the local day [today].
bool doneOn(Task task, DateTime today) {
  final at = task.completedAt?.toLocal();
  return task.status == TaskStatus.done &&
      at != null &&
      at.year == today.year &&
      at.month == today.month &&
      at.day == today.day;
}

/// The tasks a chip shows, from every task outside archived projects:
/// - All: open tasks, and those done today (struck through in Today).
/// - Today: open tasks due today, and those done today.
/// - Upcoming: open tasks due after today.
/// - High priority: open Urgent and High tasks.
/// - Done: every done task, most recent first.
List<Task> tasksFor(
  TaskFilter filter,
  Iterable<Task> tasks, {
  required DateTime today,
}) {
  bool open(Task t) => t.status == TaskStatus.open;
  bool dueToday(Task t) => t.dueDate == today;
  bool afterToday(Task t) => t.dueDate?.isAfter(today) ?? false;
  return switch (filter) {
    TaskFilter.all => [
      for (final t in tasks)
        if (open(t) || doneOn(t, today)) t,
    ],
    TaskFilter.today => [
      for (final t in tasks)
        if ((open(t) && dueToday(t)) || doneOn(t, today)) t,
    ],
    TaskFilter.upcoming => [
      for (final t in tasks)
        if (open(t) && afterToday(t)) t,
    ],
    TaskFilter.high => [
      for (final t in tasks)
        if (open(t) &&
            (t.priority == TaskPriority.urgent ||
                t.priority == TaskPriority.high))
          t,
    ],
    TaskFilter.done => [
      for (final t in tasks)
        if (!open(t)) t,
    ]..sort((a, b) => b.completedAt!.compareTo(a.completedAt!)),
  };
}

/// How many tasks each chip shows.
Map<TaskFilter, int> filterCounts(
  Iterable<Task> tasks, {
  required DateTime today,
}) => {
  for (final f in TaskFilter.values) f: tasksFor(f, tasks, today: today).length,
};

/// [tasks] in S19's sections, in section order, leaving out empty ones.
/// Done-today tasks go in Today. Within a section tasks run by date, then
/// as Today orders them: open first, by priority, then time.
List<(TaskSection, List<Task>)> sectionTasks(
  Iterable<Task> tasks, {
  required DateTime today,
  required WeekStart weekStart,
}) {
  final bySection = <TaskSection, List<Task>>{};
  for (final t in tasks) {
    final section = t.status == TaskStatus.done
        ? TaskSection.today
        : sectionFor(dueDate: t.dueDate, today: today, weekStart: weekStart);
    (bySection[section] ??= []).add(t);
  }
  return [
    for (final section in TaskSection.values)
      if (bySection[section] case final list?) (section, _byDate(list)),
  ];
}

List<Task> _byDate(List<Task> tasks) {
  final days = <DateTime?, List<Task>>{};
  for (final t in tasks) {
    (days[t.status == TaskStatus.done ? null : t.dueDate] ??= []).add(t);
  }
  final keys = days.keys.whereType<DateTime>().toList()..sort();
  return [
    for (final day in keys) ...orderToday(days[day]!),
    if (days[null] case final rest?) ...orderToday(rest),
  ];
}
