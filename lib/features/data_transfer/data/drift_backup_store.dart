import 'dart:io';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/data_transfer/data/drift_export_source.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:drift/drift.dart';

/// A backup row as the table it belongs to stores it; throws on a value of
/// the wrong type.
Insertable<Object?> rowFromJson(String table, Map<String, Object?> row) =>
    switch (table) {
      'projects' => ProjectRow.fromJson(row),
      'repeat_rules' => RepeatRuleRow.fromJson(row),
      'tasks' => TaskRow.fromJson(row),
      'subtasks' => SubtaskRow.fromJson(row),
      'tags' => TagRow.fromJson(row),
      'task_tags' => TaskTagRow.fromJson(row),
      'links' => LinkRow.fromJson(row),
      'focus_sessions' => FocusSessionRow.fromJson(row),
      'preferences' => Preference.fromJson(row),
      _ => throw ArgumentError.value(table, 'table'),
    } as Insertable<Object?>;

/// [BackupStore] on Drift and files in a folder.
class DriftBackupStore implements BackupStore {
  new(this._db, this._folder, this._clock, {this.upgrades = const {}});

  final AppDatabase _db;

  /// Where backups go; 5.3 lets the user choose.
  final Future<Directory> Function() _folder;
  final Clock _clock;

  /// Older schema versions this app can read (see [SchemaUpgrade]).
  final Map<int, SchemaUpgrade> upgrades;

  static String _inFolder(Directory folder, String name) =>
      '${folder.path}${Platform.pathSeparator}$name';

  static String _name(String path) => path.split(Platform.pathSeparator).last;

  @override
  Future<BackupFile> backUp({required int keep}) async {
    final now = _clock();
    final snapshot = await DriftExportSource(_db).read();
    final json = exportJson(
      snapshot,
      selectForExport(snapshot, (
        from: null,
        to: null,
        completed: true,
        archived: true,
        focus: true,
      )),
      exportedAt: now,
    );
    final folder = await _folder();
    await folder.create(recursive: true);
    final file = File(_inFolder(folder, backupFileName(now)));
    // Written aside, then renamed into place: a crash or a full disk never
    // leaves a half backup under a backup's name.
    final temp = File('${file.path}.tmp');
    try {
      await temp.writeAsString(json, flush: true);
      await temp.rename(file.path);
    } catch (_) {
      if (temp.existsSync()) await temp.delete();
      rethrow;
    }
    final names = [
      await for (final f in folder.list())
        if (f is File) _name(f.path),
    ];
    for (final old in backupsToDelete(names, keep: keep)) {
      await File(_inFolder(folder, old)).delete();
    }
    return (
      path: file.path,
      at: backupTime(_name(file.path))!,
      bytes: await file.length(),
    );
  }

  @override
  Future<List<BackupFile>> list() async {
    final folder = await _folder();
    if (!folder.existsSync()) return const [];
    final backups = <BackupFile>[
      await for (final f in folder.list())
        if (f is File)
          if (backupTime(_name(f.path)) case final at?)
            (path: f.path, at: at, bytes: await f.length()),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return backups;
  }

  @override
  Future<void> restore(BackupFile file) async {
    final tables = parseBackup(
      await File(file.path).readAsString(),
      schemaVersion: _db.schemaVersion,
      tables: {for (final t in _db.allTables) t.actualTableName},
      upgrades: upgrades,
    );
    // Every row is read before anything is touched.
    final rows = <(TableInfo<Table, Object?>, Insertable<Object?>)>[];
    for (final table in _db.allTables) {
      for (final row in tables[table.actualTableName]!) {
        try {
          rows.add((table, rowFromJson(table.actualTableName, row)));
        } on Object catch (e) {
          throw BackupException(
            BackupProblem.damaged,
            '${table.actualTableName}: $e',
          );
        }
      }
    }
    // One transaction: a row that can't go in (a broken reference) undoes
    // the lot, and the phone keeps what it had.
    try {
      await _db.transaction(() async {
        for (final table in _db.allTables.toList().reversed) {
          await _db.delete(table).go();
        }
        await _db.batch((b) {
          for (final (table, row) in rows) {
            b.insert(table, row);
          }
        });
      });
    } on Exception catch (e) {
      throw BackupException(BackupProblem.damaged, '$e');
    }
  }
}
