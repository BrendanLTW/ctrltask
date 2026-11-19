import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask.freezed.dart';

/// A subtask (PRD §8). Title limit as a task's.
@freezed
abstract class Subtask with _$Subtask {
  const factory({
    required int id,
    required int taskId,
    required String title,
    required int sortOrder,
    @Default(false) bool done,
  }) = _Subtask;
}
