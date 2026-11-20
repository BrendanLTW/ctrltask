import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/data/drift_focus_timer_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftFocusTimerRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftFocusTimerRepository(db);
  });
  tearDown(() => db.close());

  test('nothing saved reads as null', () async {
    expect(await repo.watch().first, isNull);
  });

  test('every field survives a round trip', () async {
    final timer = FocusTimer(
      kind: FocusKind.short,
      phase: TimerPhase.running,
      plannedSec: 300,
      taskId: 4,
      startedAt: DateTime.utc(2026, 11, 17, 1, 41),
      runningSince: DateTime.utc(2026, 11, 17, 1, 50),
      bankedSec: 120,
    );
    await repo.save(timer);
    expect(await repo.watch().first, timer);

    // Clearing a field removes its key.
    await repo.save(timer.reset());
    expect(await repo.watch().first, timer.reset());
  });

  test('a broken saved timer falls back to idle', () async {
    await db
        .into(db.preferences)
        .insert(
          PreferencesCompanion.insert(
            key: 'focus.timer.phase',
            value: 'running',
          ),
        );
    expect((await repo.watch().first)!.phase, TimerPhase.idle);
  });

  test("leaves the settings' own keys alone", () async {
    final prefs = DriftPreferencesRepository(db);
    await prefs.update((p) => p.copyWith(userName: 'Alex'));
    await repo.save(const FocusTimer(taskId: 1));
    expect((await prefs.read()).userName, 'Alex');
  });
}
