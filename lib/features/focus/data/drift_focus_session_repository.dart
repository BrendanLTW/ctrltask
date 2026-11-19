import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/data/focus_session_mapper.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:drift/drift.dart';

class DriftFocusSessionRepository implements FocusSessionRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<FocusSession>> watchStartedBetween(DateTime from, DateTime to) {
    // Local midnights, compared in UTC as stored.
    final start = DateTime(from.year, from.month, from.day).toUtc();
    final end = DateTime(to.year, to.month, to.day + 1).toUtc();
    final query = _db.select(_db.focusSessions)
      ..where(
        (s) =>
            s.startedAt.isBiggerOrEqualValue(start) &
            s.startedAt.isSmallerThanValue(end),
      )
      ..orderBy([(s) => OrderingTerm.asc(s.startedAt)]);
    return query.watch().map((rows) => [for (final r in rows) r.toEntity()]);
  }

  @override
  Stream<int> watchFocusedSeconds(int projectId) => _db
      .customSelect(
        'SELECT COALESCE(SUM(s.elapsed_sec), 0) AS n FROM focus_sessions s '
        'JOIN tasks t ON t.id = s.task_id '
        "WHERE t.project_id = ?1 AND s.kind = 'focus' "
        'AND s.elapsed_sec >= 60',
        variables: [Variable.withInt(projectId)],
        readsFrom: {_db.focusSessions, _db.tasks},
      )
      .watchSingle()
      .map((row) => row.read<int>('n'));
}
