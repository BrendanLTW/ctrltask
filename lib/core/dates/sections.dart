import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';

/// The Tasks list sections (PRD §6.2), in display order.
enum TaskSection { overdue, today, tomorrow, thisWeek, later, noDate }

/// The section for a task due on [dueDate]. Dates only: a task due today
/// whose time has passed stays in Today and is marked with [isOverdue].
TaskSection sectionFor({
  required DateTime? dueDate,
  required DateTime today,
  required WeekStart weekStart,
}) {
  if (dueDate == null) return TaskSection.noDate;
  final days = DateLabels.daysBetween(today, dueDate);
  if (days < 0) return TaskSection.overdue;
  if (days == 0) return TaskSection.today;
  if (days == 1) return TaskSection.tomorrow;
  final weekEnd = weekOf(today, weekStart).end;
  return DateLabels.daysBetween(dueDate, weekEnd) >= 0
      ? TaskSection.thisWeek
      : TaskSection.later;
}

/// Whether an open task is overdue at [now] (PRD §8): due before today, or
/// due today at a minute that has already passed.
bool isOverdue({
  required DateTime? dueDate,
  required int? dueMinute,
  required DateTime now,
}) {
  if (dueDate == null) return false;
  final days = DateLabels.daysBetween(now, dueDate);
  if (days != 0) return days < 0;
  return dueMinute != null && now.hour * 60 + now.minute > dueMinute;
}
