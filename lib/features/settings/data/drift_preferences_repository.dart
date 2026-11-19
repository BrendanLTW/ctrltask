import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/settings/data/preferences_mapper.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';

class DriftPreferencesRepository implements PreferencesRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<Preferences> watch() =>
      _db.select(_db.preferences).watch().map(_fromRows);

  @override
  Future<Preferences> read() async =>
      _fromRows(await _db.select(_db.preferences).get());

  @override
  Future<void> update(Preferences Function(Preferences) change) =>
      _db.transaction(() async {
        final values = preferencesToValues(change(await read()));
        // Only our keys are touched; others (v1.1 backup) are left alone.
        for (final MapEntry(:key, :value) in values.entries) {
          await _db
              .into(_db.preferences)
              .insertOnConflictUpdate(
                PreferencesCompanion.insert(key: key, value: value),
              );
        }
      });

  Preferences _fromRows(List<Preference> rows) =>
      preferencesFromValues({for (final row in rows) row.key: row.value});
}
