import 'dart:convert';
import 'dart:io';

import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/demo_seed.dart';
import 'package:ctrltask/features/data_transfer/data/drift_backup_store.dart';
import 'package:ctrltask/features/data_transfer/data/drift_data_eraser.dart';
import 'package:ctrltask/features/data_transfer/data/drift_export_source.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late Directory folder;
  late DateTime now;
  late DriftBackupStore store;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedDemo(db);
    folder = await Directory.systemTemp.createTemp('ctrltask-backups');
    now = DateTime(2026, 11, 17, 2, 14);
    store = DriftBackupStore(db, () async => folder, () => now);
  });
  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  Future<Map<String, Object?>> tables() async =>
      (await DriftExportSource(db).read()).tables;

  test('back up, erase, restore: every table comes back', () async {
    final before = await tables();
    final backup = await store.backUp(keep: 7);
    expect(backup.path, endsWith('ctrltask-backup-2026-11-17-0214.json'));
    expect(backup.at, now);
    expect(backup.bytes, greaterThan(0));

    await DriftDataEraser(db).eraseAll();
    await store.restore(backup);
    expect(await tables(), before);
  });

  test('written aside then renamed: no temp file is left', () async {
    await store.backUp(keep: 7);
    final names = [for (final f in folder.listSync()) f.uri.pathSegments.last];
    expect(names, ['ctrltask-backup-2026-11-17-0214.json']);
  });

  test('keeps the newest N, newest first', () async {
    for (var day = 10; day <= 13; day++) {
      now = DateTime(2026, 11, day, 2);
      await store.backUp(keep: 3);
    }
    expect([for (final b in await store.list()) b.at.day], [13, 12, 11]);
  });

  test('a damaged file is refused and changes nothing', () async {
    final before = await tables();
    final backup = await store.backUp(keep: 7);
    final text = await File(backup.path).readAsString();
    await File(backup.path).writeAsString(text.substring(0, text.length - 40));
    await expectLater(
      store.restore(backup),
      throwsA(
        isA<BackupException>().having(
          (e) => e.problem,
          'problem',
          BackupProblem.damaged,
        ),
      ),
    );
    expect(await tables(), before);
  });

  test('a row that breaks a reference undoes the whole restore', () async {
    final before = await tables();
    final backup = await store.backUp(keep: 7);
    final json = jsonDecode(
      await File(backup.path).readAsString(),
    ) as Map<String, Object?>;
    final data = json['tables']! as Map<String, Object?>;
    // A subtask of a task that isn't in the file.
    (data['subtasks']! as List).add({
      'id': 9999,
      'taskId': 424242,
      'title': 'Orphan',
      'done': false,
      'sortOrder': 0,
    });
    await File(backup.path).writeAsString(jsonEncode(json));
    await expectLater(store.restore(backup), throwsA(isA<BackupException>()));
    expect(await tables(), before);
  });
}
