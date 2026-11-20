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

/// S23's Sort by.
enum TaskSort { dueDate, priority, project, added }

/// S23's choices. Empty sets mean every priority or project.
typedef ListOptions = ({
  TaskSort sort,
  Set<TaskPriority> priorities,
  Set<int> projectIds,
  bool showCompleted,
});

const ListOptions defaultListOptions = (
  sort: TaskSort.dueDate,
  priorities: <TaskPriority>{},
  projectIds: <int>{},
  showCompleted: false,
);

/// Whether anything differs from the defaults: S19's filter dot.
bool optionsChanged(ListOptions o) =>
    o.sort != TaskSort.dueDate ||
    o.priorities.isNotEmpty ||
    o.projectIds.isNotEmpty ||
    o.showCompleted;

/// [tasks] narrowed by S23's priority and project chips.
List<Task> applyListFilters(Iterable<Task> tasks, ListOptions o) => [
  for (final t in tasks)
    if ((o.priorities.isEmpty || o.priorities.contains(t.priority)) &&
        (o.projectIds.isEmpty || o.projectIds.contains(t.projectId)))
      t,
];

/// What S19 lists for [filter] with [options]: the chip's tasks, and with
/// Show completed the done ones it leaves out, for a Completed section.
({List<Task> shown, List<Task> completed}) listFor(
  TaskFilter filter,
  Iterable<Task> tasks,
  ListOptions options, {
  required DateTime today,
}) {
  final filtered = applyListFilters(tasks, options);
  final shown = tasksFor(filter, filtered, today: today);
  final completed = !options.showCompleted || filter == TaskFilter.done
      ? <Task>[]
      : (tasksFor(TaskFilter.done, filtered, today: today)
          ..removeWhere(shown.contains));
  return (shown: shown, completed: completed);
}

int _byDue(Task a, Task b) {
  final da = a.dueDate;
  final db = b.dueDate;
  if (da != db) {
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }
  return (a.dueMinute ?? 24 * 60).compareTo(b.dueMinute ?? 24 * 60);
}

/// Sort by Priority: Urgent to Low, each by due date.
List<(TaskPriority, List<Task>)> byPriority(Iterable<Task> tasks) => [
  for (final p in TaskPriority.values)
    if ([
          for (final t in tasks)
            if (t.priority == p) t,
        ]..sort(_byDue)
        case final group when group.isNotEmpty)
      (p, group),
];

/// Sort by Project: in [projectOrder], then Inbox (null), each by due date.
List<(int?, List<Task>)> byProject(
  Iterable<Task> tasks, {
  required List<int> projectOrder,
}) => [
  for (final id in [...projectOrder, null])
    if ([
          for (final t in tasks)
            if (t.projectId == id) t,
        ]..sort(_byDue)
        case final group when group.isNotEmpty)
      (id, group),
];

/// Sort by Date added: newest first.
List<Task> byAdded(Iterable<Task> tasks) =>
    [...tasks]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
