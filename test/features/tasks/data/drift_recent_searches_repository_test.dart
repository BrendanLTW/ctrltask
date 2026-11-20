import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tasks/data/drift_recent_searches_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftRecentSearchesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftRecentSearchesRepository(db);
  });
  tearDown(() => db.close());

  test('newest first, no repeats, six at most', () async {
    expect(await repo.watch().first, isEmpty);
    for (final q in ['a1', 'b2', 'c3', 'd4', 'e5', 'f6', 'g7', ' B2 ', '']) {
      await repo.add(q);
    }
    expect(await repo.watch().first, ['B2', 'g7', 'f6', 'e5', 'd4', 'c3']);
  });

  test('clear empties it', () async {
    await repo.add('flights');
    await repo.clear();
    expect(await repo.watch().first, isEmpty);
  });

  test('a broken value reads as empty', () async {
    await db
        .into(db.preferences)
        .insert(PreferencesCompanion.insert(key: 'search.recent', value: '{'));
    expect(await repo.watch().first, isEmpty);
  });
}
