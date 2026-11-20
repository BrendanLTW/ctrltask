import 'dart:convert';

import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tasks/domain/recent_searches_repository.dart';

/// Recent searches as a JSON list under one key of the preferences table.
class DriftRecentSearchesRepository implements RecentSearchesRepository {
  new(this._db);

  final AppDatabase _db;

  static const _key = 'search.recent';

  @override
  Stream<List<String>> watch() =>
      (_db.select(_db.preferences)..where((p) => p.key.equals(_key)))
          .watchSingleOrNull()
          .map((row) => _decode(row?.value));

  @override
  Future<void> add(String query) => _db.transaction(() async {
    final text = query.trim();
    if (text.isEmpty) return;
    final row = await (_db.select(
      _db.preferences,
    )..where((p) => p.key.equals(_key))).getSingleOrNull();
    final list = [
      text,
      for (final q in _decode(row?.value))
        if (q.toLowerCase() != text.toLowerCase()) q,
    ].take(RecentSearchesRepository.keep).toList();
    await _db
        .into(_db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion.insert(key: _key, value: jsonEncode(list)),
        );
  });

  @override
  Future<void> clear() =>
      (_db.delete(_db.preferences)..where((p) => p.key.equals(_key))).go();

  /// A missing or broken value reads as none.
  static List<String> _decode(String? value) {
    try {
      final decoded = jsonDecode(value ?? '[]');
      return [
        if (decoded is List)
          for (final q in decoded)
            if (q is String) q,
      ];
    } on FormatException {
      return const [];
    }
  }
}
