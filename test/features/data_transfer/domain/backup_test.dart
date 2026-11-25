import 'dart:convert';

import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('names', () {
    test('ctrltask-backup-YYYY-MM-DD-HHmm.json, read back', () {
      final at = DateTime(2026, 11, 7, 2, 14);
      expect(backupFileName(at), 'ctrltask-backup-2026-11-07-0214.json');
      expect(backupTime(backupFileName(at)), at);
      expect(backupTime('notes.json'), isNull);
      expect(backupTime('ctrltask-backup-2026-11-07-0214.json.tmp'), isNull);
    });

    test('keeps the newest N and leaves other files alone', () {
      final names = [
        'ctrltask-backup-2026-11-15-0200.json',
        'ctrltask-backup-2026-11-17-0200.json',
        'notes.txt',
        'ctrltask-backup-2026-11-16-0200.json',
        'ctrltask-backup-2025-12-31-2359.json',
      ];
      expect(backupsToDelete(names, keep: 2), [
        'ctrltask-backup-2026-11-15-0200.json',
        'ctrltask-backup-2025-12-31-2359.json',
      ]);
      expect(backupsToDelete(names, keep: 7), isEmpty);
    });
  });

  group('parseBackup', () {
    const tables = {'tasks', 'tags'};
    String file(int version, Map<String, Object?> data) =>
        jsonEncode({'schemaVersion': version, 'tables': data});
    final good = {
      'tasks': [
        {'id': 1},
      ],
      'tags': <Object?>[],
    };

    Matcher fails(BackupProblem problem) => throwsA(
      isA<BackupException>().having((e) => e.problem, 'problem', problem),
    );

    test('reads every table', () {
      final data = parseBackup(file(2, good), schemaVersion: 2, tables: tables);
      expect(data['tasks'], [
        {'id': 1},
      ]);
      expect(data['tags'], isEmpty);
    });

    test('a corrupt or cut-short file is damaged', () {
      final text = file(2, good);
      expect(
        () => parseBackup(
          text.substring(0, text.length ~/ 2),
          schemaVersion: 2,
          tables: tables,
        ),
        fails(BackupProblem.damaged),
      );
      expect(
        () => parseBackup('not json', schemaVersion: 2, tables: tables),
        fails(BackupProblem.damaged),
      );
    });

    test('a missing, unknown or malformed table is damaged', () {
      for (final data in [
        {'tasks': <Object?>[]},
        {...good, 'extra': <Object?>[]},
        {...good, 'tags': 'oops'},
        {
          ...good,
          'tags': [1],
        },
      ]) {
        expect(
          () => parseBackup(file(2, data), schemaVersion: 2, tables: tables),
          fails(BackupProblem.damaged),
          reason: '$data',
        );
      }
    });

    test('other JSON is not a backup', () {
      expect(
        () => parseBackup('{"tasks": []}', schemaVersion: 2, tables: tables),
        fails(BackupProblem.notBackup),
      );
    });

    test('a newer version is refused', () {
      expect(
        () => parseBackup(file(3, good), schemaVersion: 2, tables: tables),
        fails(BackupProblem.newer),
      );
    });

    test('an older version is upgraded step by step, or refused', () {
      // Version 1 called the tags table "labels".
      Map<String, List<Map<String, Object?>>> rename(
        Map<String, List<Map<String, Object?>>> data,
      ) => {
        for (final MapEntry(:key, :value) in data.entries)
          key == 'labels' ? 'tags' : key: value,
      };
      final old = file(1, {
        'tasks': <Object?>[],
        'labels': [
          {'id': 7},
        ],
      });
      expect(
        parseBackup(
          old,
          schemaVersion: 2,
          tables: tables,
          upgrades: {1: rename},
        )['tags'],
        [
          {'id': 7},
        ],
      );
      expect(
        () => parseBackup(old, schemaVersion: 2, tables: tables),
        fails(BackupProblem.tooOld),
      );
    });
  });
}
