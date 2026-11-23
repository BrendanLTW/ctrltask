import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:ctrltask/features/focus/data/focus_session_mapper.dart';
import 'package:ctrltask/features/projects/data/project_mapper.dart';
import 'package:ctrltask/features/tasks/data/repeat_rule_mapper.dart';
import 'package:ctrltask/features/tasks/data/task_mapper.dart';
import 'package:drift/drift.dart';

/// [ExportSource] on Drift: every table in one transaction, so the export
/// is consistent.
class DriftExportSource implements ExportSource {
  const new(this._db);

  final AppDatabase _db;

  @override
  Future<ExportSnapshot> read() => _db.transaction(() async {
    final tables = <String, TableRows>{
      // Declared parents first, so a restore never breaks a reference.
      for (final table in _db.allTables)
        table.actualTableName: [
          for (final row in (await _db.select(table).get()).cast<DataClass>())
            row.toJson(),
        ],
    };
    final projects = [
      for (final p in await _db.select(_db.projects).get()) p.toEntity(),
    ];
    final rules = {
      for (final r in await _db.select(_db.repeatRules).get())
        r.id: r.toEntity(),
    };
    final tagNames = {
      for (final t in await _db.select(_db.tags).get()) t.id: t.name,
    };
    final tagsOf = <int, List<String>>{};
    for (final tt in await _db.select(_db.taskTags).get()) {
      (tagsOf[tt.taskId] ??= []).add(tagNames[tt.tagId]!);
    }
    final byId = {for (final p in projects) p.id: p};
    final tasks = await (_db.select(
      _db.tasks,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return ExportSnapshot(
      schemaVersion: _db.schemaVersion,
      tables: tables,
      projects: projects,
      tasks: [
        for (final row in tasks)
          (
            task: row.toEntity(),
            project: byId[row.projectId],
            tags: tagsOf[row.id] ?? const [],
            repeat: rules[row.repeatRuleId],
          ),
      ],
      sessions: [
        for (final s in await _db.select(_db.focusSessions).get()) s.toEntity(),
      ],
    );
  });
}
