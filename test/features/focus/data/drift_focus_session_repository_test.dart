import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/data/drift_focus_session_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
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

  test("adds up focus of a minute or more on the project's tasks", () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 11, 17);
    Future<int> project(String name) => db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            name: name,
            colorKey: 'blue',
            iconKey: 'globe',
            createdAt: now,
            sortOrder: 0,
          ),
        );
    final web = await project('Web');
    final other = await project('Other');
    Future<int> task(int projectId) => db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            title: 'T',
            priority: 'medium',
            status: 'open',
            boardColumn: 'todo',
            createdAt: now,
            updatedAt: now,
            sortOrder: 0,
            projectId: Value(projectId),
          ),
        );
    final a = await task(web);
    final b = await task(other);
    for (final (taskId, kind, sec) in [
      (a, 'focus', 1500),
      (a, 'focus', 59), // too short to count
      (a, 'short', 300), // a break
      (b, 'focus', 900), // another project
      (null, 'focus', 600), // no task
    ]) {
      await db
          .into(db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              kind: kind,
              plannedSec: 1500,
              startedAt: now,
              elapsedSec: sec,
              taskId: Value(taskId),
            ),
          );
    }
    final repo = DriftFocusSessionRepository(db);

    expect(await repo.watchFocusedSeconds(web).first, 1500);
    expect(await repo.watchFocusedSeconds(999).first, 0);
  });
}
