import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/data/drift_focus_session_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('watches sessions started on the given local days', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    for (final start in [
      DateTime(2026, 11, 16, 23, 59),
      DateTime(2026, 11, 17),
      DateTime(2026, 11, 17, 23, 59),
      DateTime(2026, 11, 18),
    ]) {
      await db
          .into(db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              kind: 'focus',
              plannedSec: 1500,
              startedAt: start.toUtc(),
              elapsedSec: 1500,
            ),
          );
    }
    final repo = DriftFocusSessionRepository(db);

    final today = DateTime(2026, 11, 17);
    final sessions = await repo.watchStartedBetween(today, today).first;

    expect(
      [for (final s in sessions) s.startedAt.toLocal()],
      [DateTime(2026, 11, 17), DateTime(2026, 11, 17, 23, 59)],
    );
  });
}
