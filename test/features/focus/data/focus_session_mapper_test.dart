import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/focus/data/focus_session_mapper.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final session = FocusSession(
    id: 0,
    kind: FocusKind.focus,
    plannedSec: 1500,
    startedAt: DateTime.utc(2026, 11, 17, 2),
    endedAt: DateTime.utc(2026, 11, 17, 2, 25),
    elapsedSec: 1500,
    completed: true,
  );

  test('every kind survives a round trip', () async {
    for (final kind in FocusKind.values) {
      final s = session.copyWith(kind: kind);
      final row = await db
          .into(db.focusSessions)
          .insertReturning(s.toCompanion().copyWith(id: const Value.absent()));
      expect(row.toEntity(), s.copyWith(id: row.id));
    }
  });

  test('a session counts from one minute (PRD §6.6)', () {
    expect(session.copyWith(elapsedSec: 59).counts, isFalse);
    expect(session.copyWith(elapsedSec: 60).counts, isTrue);
  });
}
