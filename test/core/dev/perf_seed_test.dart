import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/perf_seed.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 17);

  Future<Map<String, int>> counts(AppDatabase db) async => {
    for (final t in db.allTables)
      t.actualTableName: await db
          .customSelect('SELECT COUNT(*) AS n FROM ${t.actualTableName}')
          .getSingle()
          .then((r) => r.read<int>('n')),
  };

  test('writes the PLAN 4.3 data set within the schema', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final watch = Stopwatch()..start();
    await seedPerf(db, today: today);
    watch.stop();

    final n = await counts(db);
    expect(n['tasks'], PerfSize.tasks);
    expect(n['projects'], PerfSize.projects);
    expect(n['focus_sessions'], (PerfSize.sessionDays + 1) * 3);
    expect(n['subtasks'], greaterThan(0));
    expect(n['task_tags'], greaterThan(0));
    expect(n['repeat_rules'], 3);

    final done = await (db.select(
      db.tasks,
    )..where((t) => t.status.equals('done'))).get();
    expect(done.length / PerfSize.tasks, inInclusiveRange(0.5, 0.75));
    // One batch keeps the first launch short.
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('is the same every time', () async {
    Future<List<String>> titles() async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await seedPerf(db, today: today);
      return [for (final t in await db.select(db.tasks).get()) t.title];
    }

    expect(await titles(), await titles());
  });
}
