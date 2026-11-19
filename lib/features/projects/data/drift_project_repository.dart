import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:ctrltask/features/projects/data/project_mapper.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:drift/drift.dart';

class DriftProjectRepository implements ProjectRepository {
  new(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Stream<List<Project>> _watch({required bool archived}) {
    final query = _db.select(_db.projects)
      ..where(
        (p) => archived ? p.archivedAt.isNotNull() : p.archivedAt.isNull(),
      )
      ..orderBy([
        (p) => OrderingTerm.asc(p.sortOrder),
        (p) => OrderingTerm.asc(p.name),
      ]);
    return query.watch().map((rows) => [for (final r in rows) r.toEntity()]);
  }

  @override
  Stream<List<Project>> watchActive() => _watch(archived: false);

  @override
  Stream<List<Project>> watchArchived() => _watch(archived: true);

  @override
  Future<Project> add({
    required String name,
    required ProjectColorKey colorKey,
    required ProjectIconKey iconKey,
    String? description,
    DateTime? deadline,
  }) {
    final (trimmedName, trimmedDescription) = _validate(name, description);
    return _db.transaction(() async {
      await _checkNameFree(trimmedName);
      final max = _db.projects.sortOrder.max();
      final last = await (_db.selectOnly(
        _db.projects,
      )..addColumns([max])).map((r) => r.read(max)).getSingle();
      final row = await _db
          .into(_db.projects)
          .insertReturning(
            ProjectsCompanion.insert(
              name: trimmedName,
              description: Value(trimmedDescription),
              colorKey: colorKey.name,
              iconKey: iconKey.name,
              deadline: Value(deadline == null ? null : storedDate(deadline)),
              createdAt: _clock().toUtc(),
              sortOrder: (last ?? -1) + 1,
            ),
          );
      return row.toEntity();
    });
  }

  @override
  Future<void> update(Project project) {
    final (name, description) = _validate(project.name, project.description);
    return _db.transaction(() async {
      if (!project.archived) await _checkNameFree(name, exceptId: project.id);
      await _db
          .update(_db.projects)
          .replace(
            project
                .copyWith(name: name, description: description)
                .toCompanion(),
          );
    });
  }

  @override
  Future<void> archive(int id) =>
      (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
        ProjectsCompanion(archivedAt: Value(_clock().toUtc())),
      );

  @override
  Future<void> restore(int id) => _db.transaction(() async {
    final row = await (_db.select(
      _db.projects,
    )..where((p) => p.id.equals(id))).getSingle();
    await _checkNameFree(row.name, exceptId: id);
    await (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
      const ProjectsCompanion(archivedAt: Value(null)),
    );
  });

  @override
  Future<void> delete(int id, {required bool deleteTasks}) =>
      _db.transaction(() async {
        // Without deleteTasks, the foreign key moves them to Inbox.
        if (deleteTasks) {
          await (_db.delete(
            _db.tasks,
          )..where((t) => t.projectId.equals(id))).go();
          await _db.customStatement(
            'DELETE FROM repeat_rules WHERE id NOT IN '
            '(SELECT repeat_rule_id FROM tasks '
            'WHERE repeat_rule_id IS NOT NULL)',
          );
        }
        await (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();
      });

  Future<void> _checkNameFree(String name, {int? exceptId}) async {
    final clash =
        await (_db.select(_db.projects)..where(
              (p) =>
                  p.archivedAt.isNull() &
                  p.name.lower().equals(name.toLowerCase()) &
                  (exceptId == null
                      ? const Constant(true)
                      : p.id.equals(exceptId).not()),
            ))
            .get();
    if (clash.isNotEmpty) throw DuplicateProjectNameException(name);
  }

  /// PRD §8 and S28 limits; returns the trimmed name and description.
  static (String, String?) _validate(String name, String? description) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'is blank');
    if (trimmed.length > maxProjectNameLength) {
      throw ArgumentError.value(
        name,
        'name',
        'longer than $maxProjectNameLength characters',
      );
    }
    final text = description?.trim();
    if (text != null && text.length > maxProjectDescriptionLength) {
      throw ArgumentError.value(
        text.length,
        'description',
        'longer than $maxProjectDescriptionLength characters',
      );
    }
    return (trimmed, text == null || text.isEmpty ? null : text);
  }
}
