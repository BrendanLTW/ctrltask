import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftPreferencesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftPreferencesRepository(db);
  });
  tearDown(() => db.close());

  test('an empty table reads as the defaults', () async {
    expect(await repo.read(), const Preferences());
  });

  test('updates are saved and watched live', () async {
    final names = repo.watch().map((p) => p.userName);
    final expectation = expectLater(names, emitsInOrder(['', 'Alex']));
    await pumpEventQueue();

    await repo.update((p) => p.copyWith(userName: 'Alex'));

    await expectation;
    expect((await repo.read()).userName, 'Alex');
  });

  test('updates in a row build on each other', () async {
    await Future.wait([
      repo.update((p) => p.copyWith(theme: AppTheme.dark)),
      repo.update((p) => p.copyWith(weekStart: WeekStart.sun)),
    ]);

    final prefs = await repo.read();
    expect(prefs.theme, AppTheme.dark);
    expect(prefs.weekStart, WeekStart.sun);
  });

  test('keys it does not know are left alone', () async {
    await db
        .into(db.preferences)
        .insert(PreferencesCompanion.insert(key: 'autoBackup', value: 'true'));

    await repo.update((p) => p.copyWith(userName: 'Alex'));

    final rows = await db.select(db.preferences).get();
    expect(rows.firstWhere((r) => r.key == 'autoBackup').value, 'true');
  });
}
