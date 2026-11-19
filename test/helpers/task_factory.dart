import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';

/// A task for domain tests; only what the test sets matters.
Task task(
  String title, {
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  int? dueMinute,
  DateTime? completedAt,
  int sortOrder = 0,
}) => Task(
  id: title.hashCode,
  title: title,
  priority: priority,
  status: completedAt == null ? TaskStatus.open : TaskStatus.done,
  boardColumn: completedAt == null ? BoardColumn.todo : BoardColumn.done,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
  sortOrder: sortOrder,
  dueDate: dueDate,
  dueMinute: dueMinute,
  completedAt: completedAt,
);
