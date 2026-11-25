import 'dart:convert';

import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/demo_seed.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/data_transfer/data/drift_backup_store.dart';
import 'package:ctrltask/features/data_transfer/data/drift_export_source.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads an export into [db], row by row as a restore does.
Future<void> load(AppDatabase db, String json) async {
  final tables =
      (jsonDecode(json) as Map<String, Object?>)['tables']!
          as Map<String, Object?>;
  final byName = {for (final t in db.allTables) t.actualTableName: t};
  await db.batch((b) {
    for (final MapEntry(key: name, value: rows) in tables.entries) {
      for (final row in (rows! as List).cast<Map<String, Object?>>()) {
        b.insert(byName[name]!, rowFromJson(name, row));
      }
    }
  });
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedDemo(db);
    // The seed has no repeating task.
    await DriftTaskRepository(db, () => demoNow).add(
      TaskDraft(
        title: 'Water plants',
        dueDate: DateTime(2026, 11, 17),
        repeat: RepeatRule.weekly({DateTime.monday}),
      ),
    );
  });
  tearDown(() => db.close());

  const everything = (
    from: null,
    to: null,
    completed: true,
    archived: true,
    focus: true,
  );

  test('reads every table, parents first', () async {
    final s = await DriftExportSource(db).read();
    expect(s.tables.keys, [
      'projects',
      'repeat_rules',
      'tasks',
      'subtasks',
      'tags',
      'task_tags',
      'links',
      'focus_sessions',
      'preferences',
    ]);
    expect(s.tables['tasks'], hasLength(s.tasks.length));
    expect(s.tasks.where((t) => t.tags.isNotEmpty), isNotEmpty);
    expect(s.tasks.where((t) => t.repeat != null), isNotEmpty);
    expect(s.tasks.where((t) => t.project != null), isNotEmpty);
  });

  test('JSON round trip: everything restores exactly', () async {
    final s = await DriftExportSource(db).read();
    final json = exportJson(
      s,
      selectForExport(s, everything),
      exportedAt: DateTime.utc(2026, 11, 17),
    );
    expect(jsonDecode(json), containsPair('schemaVersion', db.schemaVersion));

    final copy = AppDatabase(NativeDatabase.memory());
    addTearDown(copy.close);
    await load(copy, json);
    final again = await DriftExportSource(copy).read();
    for (final name in s.tables.keys) {
      expect(again.tables[name], s.tables[name], reason: name);
      expect(s.tables[name], isNotEmpty, reason: name);
    }
  });

  test('a partial JSON export still loads', () async {
    final s = await DriftExportSource(db).read();
    final json = exportJson(
      s,
      selectForExport(s, (
        from: DateTime(2026, 11, 17),
        to: DateTime(2026, 11, 17),
        completed: false,
        archived: false,
        focus: true,
      )),
      exportedAt: DateTime.utc(2026, 11, 17),
    );
    final copy = AppDatabase(NativeDatabase.memory());
    addTearDown(copy.close);
    await expectLater(load(copy, json), completes);
  });
}
