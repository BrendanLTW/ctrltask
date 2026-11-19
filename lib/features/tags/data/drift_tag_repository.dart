import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/tags/data/tag_mapper.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:drift/drift.dart';

class DriftTagRepository implements TagRepository {
  new(this._db);

  final AppDatabase _db;

  @override
  Stream<List<TagUsage>> watch() {
    final count = _db.taskTags.taskId.count();
    final query =
        _db.select(_db.tags).join([
            leftOuterJoin(
              _db.taskTags,
              _db.taskTags.tagId.equalsExp(_db.tags.id),
            ),
          ])
          ..addColumns([count])
          ..groupBy([_db.tags.id])
          ..orderBy([
            OrderingTerm.desc(count),
            OrderingTerm.asc(_db.tags.name),
          ]);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          (tag: r.readTable(_db.tags).toEntity(), taskCount: r.read(count)!),
      ],
    );
  }

  @override
  Future<Tag> create(String name) {
    final tag = normaliseTagName(name);
    return _db.transaction(() async {
      if (await _byName(tag) != null) throw DuplicateTagNameException(tag);
      final row = await _db
          .into(_db.tags)
          .insertReturning(TagsCompanion.insert(name: tag));
      return row.toEntity();
    });
  }

  @override
  Future<Tag> rename(int id, String name) {
    final tag = normaliseTagName(name);
    return _db.transaction(() async {
      final existing = await _byName(tag);
      if (existing != null && existing.id != id) {
        await merge(id, existing.id);
        return existing.toEntity();
      }
      await (_db.update(
        _db.tags,
      )..where((t) => t.id.equals(id))).write(TagsCompanion(name: Value(tag)));
      return Tag(id: id, name: tag);
    });
  }

  @override
  Future<void> merge(int fromId, int intoId) => _db.transaction(() async {
    await _db.customStatement(
      'INSERT OR IGNORE INTO task_tags (task_id, tag_id) '
      'SELECT task_id, ? FROM task_tags WHERE tag_id = ?',
      [intoId, fromId],
    );
    await delete(fromId);
  });

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();

  Future<TagRow?> _byName(String name) => (_db.select(
    _db.tags,
  )..where((t) => t.name.equals(name))).getSingleOrNull();
}
