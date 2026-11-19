import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_details.freezed.dart';

/// A task with everything attached to it (S11, S12), and the snapshot that
/// Undo puts back. New subtasks and links have id 0.
@freezed
abstract class TaskDetails with _$TaskDetails {
  const factory({
    required Task task,
    RepeatRule? repeat,
    @Default(<Subtask>[]) List<Subtask> subtasks,
    @Default(<Tag>[]) List<Tag> tags,
    @Default(<TaskLink>[]) List<TaskLink> links,
  }) = _TaskDetails;
}
