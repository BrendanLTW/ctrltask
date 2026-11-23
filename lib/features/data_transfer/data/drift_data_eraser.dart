import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/data_transfer/domain/data_eraser.dart';

/// [DataEraser] on Drift, in one transaction.
class DriftDataEraser implements DataEraser {
  const new(this._db);

  final AppDatabase _db;

  @override
  Future<void> eraseAll() => _db.transaction(() async {
    // Children first, so no reference breaks along the way; preferences
    // hold the name, settings, the focus timer and recent searches.
    for (final table in _db.allTables.toList().reversed) {
      await _db.delete(table).go();
    }
  });
}
