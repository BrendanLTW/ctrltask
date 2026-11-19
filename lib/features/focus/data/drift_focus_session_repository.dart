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
}
