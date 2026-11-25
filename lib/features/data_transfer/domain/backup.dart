import 'dart:convert';

import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup.g.dart';

/// A backup on disk (S42): where it is, when it was made and its size.
typedef BackupFile = ({String path, DateTime at, int bytes});

/// Backups (PRD §6.7, v1.1): every table as JSON, like the full export.
abstract interface class BackupStore {
  /// Writes a backup of everything now, then deletes all but the newest
  /// [keep].
  Future<BackupFile> backUp({required int keep});

  /// The backups in the folder, newest first.
  Future<List<BackupFile>> list();

  /// Checks the whole of [file] first, then replaces everything on the phone
  /// with it in one transaction. Throws [BackupException], leaving the data
  /// as it was.
  Future<void> restore(BackupFile file);
}

/// Overridden in `main.dart` with the Drift one.
@Riverpod(keepAlive: true)
BackupStore backupStore(Ref ref) =>
    throw UnimplementedError('Override backupStoreProvider');

/// Why a file can't be restored.
enum BackupProblem {
  /// Not JSON, cut short, or a table or row that doesn't read.
  damaged,

  /// JSON, but not a ctrlTask backup.
  notBackup,

  /// Made by a newer version of the app.
  newer,

  /// Older than any version this app can upgrade.
  tooOld,
}

class BackupException implements Exception {
  const new(this.problem, [this.detail = '']);

  final BackupProblem problem;
  final String detail;

  @override
  String toString() => 'BackupException(${problem.name}: $detail)';
}

/// Turns one schema version's tables into the next one's. Keyed by the
/// version it upgrades from; add one with every schema bump.
typedef SchemaUpgrade = Map<String, TableRows> Function(Map<String, TableRows>);

const _prefix = 'ctrltask-backup-';
const _suffix = '.json';
final _name = RegExp(
  r'^ctrltask-backup-(\d{4})-(\d\d)-(\d\d)-(\d\d)(\d\d)\.json$',
);

String _two(int n) => '$n'.padLeft(2, '0');

/// `ctrltask-backup-2026-11-17-0214.json`, in local time (PRD §6.7).
String backupFileName(DateTime at) =>
    '$_prefix${at.year}-${_two(at.month)}-${_two(at.day)}-'
    '${_two(at.hour)}${_two(at.minute)}$_suffix';

/// When a backup named [name] was made, or null if it isn't one.
DateTime? backupTime(String name) {
  final m = _name.firstMatch(name);
  if (m == null) return null;
  final [y, mo, d, h, mi] = [for (var i = 1; i <= 5; i++) int.parse(m[i]!)];
  return DateTime(y, mo, d, h, mi);
}

/// Of the backup [names], the ones to delete to keep the newest [keep].
/// Other files are left alone.
List<String> backupsToDelete(Iterable<String> names, {required int keep}) {
  final backups = [
    for (final n in names)
      if (backupTime(n) != null) n,
  ]..sort((a, b) => b.compareTo(a));
  return backups.skip(keep).toList();
}

/// Reads a backup's tables, checking the whole file before anything is
/// touched: valid JSON with a `schemaVersion` this app can read and every
/// one of [tables] as a list of rows. A file from an older version is
/// brought up to [schemaVersion] through [upgrades]; rows are checked
/// against the database when restored.
Map<String, TableRows> parseBackup(
  String text, {
  required int schemaVersion,
  required Set<String> tables,
  Map<int, SchemaUpgrade> upgrades = const {},
}) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException catch (e) {
    throw BackupException(BackupProblem.damaged, e.message);
  }
  if (json case {
    'schemaVersion': final int version,
    'tables': final Map<String, Object?> raw,
  }) {
    if (version > schemaVersion) {
      throw BackupException(BackupProblem.newer, 'version $version');
    }
    var data = <String, TableRows>{};
    for (final MapEntry(key: name, value: rows) in raw.entries) {
      if (rows is! List || rows.any((r) => r is! Map<String, Object?>)) {
        throw BackupException(BackupProblem.damaged, 'table $name');
      }
      data[name] = rows.cast<Map<String, Object?>>();
    }
    for (var v = version; v < schemaVersion; v++) {
      final upgrade = upgrades[v];
      if (upgrade == null) {
        throw BackupException(BackupProblem.tooOld, 'version $version');
      }
      data = upgrade(data);
    }
    final missing = tables.difference(data.keys.toSet());
    final unknown = data.keys.toSet().difference(tables);
    if (missing.isNotEmpty || unknown.isNotEmpty) {
      throw BackupException(
        BackupProblem.damaged,
        'missing $missing, unknown $unknown',
      );
    }
    return data;
  }
  throw const BackupException(BackupProblem.notBackup);
}
