import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tags/data/tag_mapper.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a tag survives a round trip', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    const tag = Tag(id: 0, name: 'design');

    final row = await db
        .into(db.tags)
        .insertReturning(tag.toCompanion().copyWith(id: const Value.absent()));

    expect(row.toEntity(), tag.copyWith(id: row.id));
  });
}
