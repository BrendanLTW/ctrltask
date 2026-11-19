import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:drift/drift.dart';

extension SubtaskRowMapper on SubtaskRow {
  Subtask toEntity() => Subtask(
    id: id,
    taskId: taskId,
    title: title,
    done: done,
    sortOrder: sortOrder,
  );
}

extension SubtaskMapper on Subtask {
  /// The row to update. For a new subtask, leave out the id.
  SubtasksCompanion toCompanion() => SubtasksCompanion(
    id: Value(id),
    taskId: Value(taskId),
    title: Value(title),
    done: Value(done),
    sortOrder: Value(sortOrder),
  );
}
