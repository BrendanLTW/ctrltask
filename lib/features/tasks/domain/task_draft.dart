import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_draft.freezed.dart';

/// A new task's fields (S10, S11). Only the title is required.
@freezed
abstract class TaskDraft with _$TaskDraft {
  const factory({
    required String title,
    String? description,
    DateTime? dueDate,
    int? dueMinute,
    @Default(TaskPriority.medium) TaskPriority priority,
    int? projectId,
    @Default(ReminderOffset.none) ReminderOffset reminder,
    RepeatRule? repeat,
    @Default(<int>{}) Set<int> tagIds,
    @Default(<String>[]) List<String> subtasks,
    @Default(<({String title, String url})>[])
    List<({String title, String url})> links,
  }) = _TaskDraft;
}
