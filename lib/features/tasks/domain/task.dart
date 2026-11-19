import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

/// Field limits from PRD §8.
const maxTaskTitleLength = 120;
const maxTaskDescriptionLength = 1000;
const maxSubtasksPerTask = 50;

enum TaskStatus { open, done }

/// The Kanban column (S20, v1.1). `done` exactly when the task is.
enum BoardColumn { todo, doing, done }

/// When a task's reminder fires, relative to its due date and time (S16).
enum ReminderOffset { none, atTime, min10, min30, hour1, morningOf, dayBefore }

/// A task (PRD §8). [dueDate] is a local date at midnight and [dueMinute]
/// minutes after it; timestamps are UTC.
@freezed
abstract class Task with _$Task {
  const factory({
    required int id,
    required String title,
    required TaskPriority priority,
    required TaskStatus status,
    required BoardColumn boardColumn,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int sortOrder,
    String? description,
    DateTime? dueDate,
    int? dueMinute,
    int? projectId,
    DateTime? completedAt,
    int? repeatRuleId,
    @Default(ReminderOffset.none) ReminderOffset reminder,
  }) = _Task;
}
