import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/projects/data/project_mapper.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final project = Project(
    id: 0,
    name: 'Website redesign',
    description: 'New marketing site for Q1.',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    deadline: DateTime(2026, 11, 30),
    createdAt: DateTime.utc(2026, 10),
    sortOrder: 0,
  );

  Future<Project> roundTrip(Project p) async {
    final row = await db
        .into(db.projects)
        .insertReturning(p.toCompanion().copyWith(id: const Value.absent()));
    return row.toEntity();
  }

  test('every field survives a round trip', () async {
    final back = await roundTrip(project);
    expect(back, project.copyWith(id: back.id));
    expect(back.archived, isFalse);
  });

  test('an archived project survives and reads as archived', () async {
    final archived = project.copyWith(
      archivedAt: DateTime.utc(2026, 11, 2),
      deadline: null,
      description: null,
    );
    final back = await roundTrip(archived);
    expect(back, archived.copyWith(id: back.id));
    expect(back.archived, isTrue);
  });

  test('every colour and icon key passes the SQL checks', () async {
    for (final (i, color) in ProjectColorKey.values.indexed) {
      final back = await roundTrip(
        project.copyWith(name: 'c$i', colorKey: color),
      );
      expect(back.colorKey, color);
    }
    for (final (i, icon) in ProjectIconKey.values.indexed) {
      final back = await roundTrip(
        project.copyWith(name: 'i$i', iconKey: icon),
      );
      expect(back.iconKey, icon);
    }
  });
}
