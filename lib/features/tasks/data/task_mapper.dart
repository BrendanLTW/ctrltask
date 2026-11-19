import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:drift/drift.dart';

extension TaskRowMapper on TaskRow {
  Task toEntity() => Task(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate == null ? null : localDate(dueDate!),
    dueMinute: dueMinute,
    priority: TaskPriority.values.byName(priority),
    projectId: projectId,
    status: TaskStatus.values.byName(status),
    completedAt: completedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    boardColumn: BoardColumn.values.byName(boardColumn),
    sortOrder: sortOrder,
    repeatRuleId: repeatRuleId,
    reminder: ReminderOffset.values.byName(reminder),
  );
}

extension TaskMapper on Task {
  /// The row to update. For a new task, leave out the id with
  /// `toCompanion().copyWith(id: const Value.absent())`.
  TasksCompanion toCompanion() => TasksCompanion(
    id: Value(id),
    title: Value(title),
    description: Value(description),
    dueDate: Value(dueDate == null ? null : storedDate(dueDate!)),
    dueMinute: Value(dueMinute),
    priority: Value(priority.name),
    projectId: Value(projectId),
    status: Value(status.name),
    completedAt: Value(completedAt),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    boardColumn: Value(boardColumn.name),
    sortOrder: Value(sortOrder),
    repeatRuleId: Value(repeatRuleId),
    reminder: Value(reminder.name),
  );
}
