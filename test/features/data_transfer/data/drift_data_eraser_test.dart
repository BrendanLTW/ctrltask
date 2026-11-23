import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/demo_seed.dart';
import 'package:ctrltask/features/data_transfer/data/drift_data_eraser.dart';
import 'package:ctrltask/features/data_transfer/data/drift_export_source.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedDemo(db);
  });
  tearDown(() => db.close());

  test('empties every table, and settings read as a fresh install', () async {
    final before = await DriftExportSource(db).read();
    for (final name in ['projects', 'tasks', 'focus_sessions', 'preferences']) {
      expect(before.tables[name], isNotEmpty, reason: name);
    }

    await DriftDataEraser(db).eraseAll();

    final after = await DriftExportSource(db).read();
    for (final MapEntry(key: name, value: rows) in after.tables.entries) {
      expect(rows, isEmpty, reason: name);
    }
    expect(await DriftPreferencesRepository(db).read(), const Preferences());
  });

  test('the app can start over after erasing', () async {
    await DriftDataEraser(db).eraseAll();
    await expectLater(seedDemo(db), completes);
  });
}
