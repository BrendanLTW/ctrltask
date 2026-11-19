import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:drift/drift.dart';

extension FocusSessionRowMapper on FocusSessionRow {
  FocusSession toEntity() => FocusSession(
    id: id,
    taskId: taskId,
    kind: FocusKind.values.byName(kind),
    plannedSec: plannedSec,
    startedAt: startedAt,
    endedAt: endedAt,
    elapsedSec: elapsedSec,
    completed: completed,
  );
}

extension FocusSessionMapper on FocusSession {
  /// The row to update. For a new session, leave out the id.
  FocusSessionsCompanion toCompanion() => FocusSessionsCompanion(
    id: Value(id),
    taskId: Value(taskId),
    kind: Value(kind.name),
    plannedSec: Value(plannedSec),
    startedAt: Value(startedAt),
    endedAt: Value(endedAt),
    elapsedSec: Value(elapsedSec),
    completed: Value(completed),
  );
}
