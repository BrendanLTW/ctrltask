import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:ctrltask/core/repeat/next_occurrence.dart';
import 'package:ctrltask/features/tags/data/tag_mapper.dart';
import 'package:ctrltask/features/tasks/data/repeat_rule_mapper.dart';
import 'package:ctrltask/features/tasks/data/subtask_mapper.dart';
import 'package:ctrltask/features/tasks/data/task_link_mapper.dart';
import 'package:ctrltask/features/tasks/data/task_mapper.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:drift/drift.dart';

class DriftTaskRepository implements TaskRepository {
  new(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  DateTime get _nowUtc => _clock().toUtc();

  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  // Watches -----------------------------------------------------------------

  /// Tasks matching [where], leaving out those in archived projects.
  Stream<List<Task>> _watch(Expression<bool> Function($TasksTable t) where) {
    final t = _db.tasks;
    final query =
        _db.select(t).join([
            leftOuterJoin(_db.projects, _db.projects.id.equalsExp(t.projectId)),
          ])
          ..where(_db.projects.archivedAt.isNull() & where(t))
          ..orderBy([OrderingTerm.asc(t.sortOrder), OrderingTerm.asc(t.id)]);
    return query.watch().map(
      (rows) => [for (final row in rows) row.readTable(t).toEntity()],
    );
  }

  @override
  Stream<List<Task>> watchToday(DateTime today) {
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(today.year, today.month, today.day + 1);
    return _watch(
      (t) =>
          (t.status.equals('open') & t.dueDate.equals(storedDate(start))) |
          (t.status.equals('done') &
              t.completedAt.isBiggerOrEqualValue(start.toUtc()) &
              t.completedAt.isSmallerThanValue(end.toUtc())),
    );
  }

  @override
  Stream<List<Task>> watchAll({bool includeDone = false}) => _watch(
    (t) => includeDone ? const Constant(true) : t.status.equals('open'),
  );

  @override
  Stream<List<Task>> watchByProject(int? projectId) => _watch(
    (t) => projectId == null
        ? t.projectId.isNull()
        : t.projectId.equals(projectId),
  );

  @override
  Stream<List<Task>> watchDueBetween(DateTime from, DateTime to) => _watch(
    (t) => t.dueDate.isBetweenValues(storedDate(from), storedDate(to)),
  );

  @override
  Stream<List<Task>> search(String query) {
    final text = query.trim();
    if (text.isEmpty) return Stream.value(const []);
    // "#design": only tasks with a tag that starts with the word (S24).
    if (text.startsWith('#')) return _searchTag(text.substring(1).trim());
    // Match % and _ literally.
    final escaped = text.replaceAllMapped(
      RegExp(r'[\\%_]'),
      (m) => '\\${m[0]}',
    );
    const like = r"LIKE ?1 ESCAPE '\'";
    return _db
        .customSelect(
          'SELECT t.* FROM tasks t '
          'LEFT JOIN projects p ON p.id = t.project_id '
          'WHERE p.archived_at IS NULL '
          'AND (t.title $like OR t.description $like OR p.name $like '
          'OR EXISTS (SELECT 1 FROM subtasks s '
          'WHERE s.task_id = t.id AND s.title $like) '
          'OR EXISTS (SELECT 1 FROM task_tags tt '
          'JOIN tags g ON g.id = tt.tag_id '
          'WHERE tt.task_id = t.id AND g.name $like)) '
          'ORDER BY t.sort_order, t.id',
          variables: [Variable.withString('%$escaped%')],
          readsFrom: {
            _db.tasks,
            _db.projects,
            _db.subtasks,
            _db.taskTags,
            _db.tags,
          },
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows) _db.tasks.map(row.data).toEntity(),
          ],
        );
  }

  Stream<List<Task>> _searchTag(String name) {
    if (name.isEmpty) return Stream.value(const []);
    final escaped = name.toLowerCase().replaceAllMapped(
      RegExp(r'[\\%_]'),
      (m) => '\\${m[0]}',
    );
    return _db
        .customSelect(
          'SELECT t.* FROM tasks t '
          'LEFT JOIN projects p ON p.id = t.project_id '
          'WHERE p.archived_at IS NULL AND EXISTS (SELECT 1 FROM task_tags tt '
          'JOIN tags g ON g.id = tt.tag_id WHERE tt.task_id = t.id '
          r"AND g.name LIKE ?1 ESCAPE '\') "
          'ORDER BY t.sort_order, t.id',
          variables: [Variable.withString('$escaped%')],
          readsFrom: {_db.tasks, _db.projects, _db.taskTags, _db.tags},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows) _db.tasks.map(row.data).toEntity(),
          ],
        );
  }

  @override
  Stream<Map<int, int>> watchTaskCounts() => _db
      .customSelect(
        'SELECT project_id, COUNT(*) AS n FROM tasks '
        'WHERE project_id IS NOT NULL GROUP BY project_id',
        readsFrom: {_db.tasks},
      )
      .watch()
      .map(
        (rows) => {
          for (final r in rows) r.read<int>('project_id'): r.read<int>('n'),
        },
      );

  @override
  Stream<Map<int, Progress>> watchSubtaskProgress() => _db
      .customSelect(
        'SELECT task_id, SUM(done) AS done, COUNT(*) AS total '
        'FROM subtasks GROUP BY task_id',
        readsFrom: {_db.subtasks},
      )
      .watch()
      .map(
        (rows) => {
          for (final r in rows)
            r.read<int>('task_id'): (
              done: r.read<int>('done'),
              total: r.read<int>('total'),
            ),
        },
      );

  @override
  Stream<TaskDetails?> watchDetails(int id) => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          _db.tasks,
          _db.repeatRules,
          _db.subtasks,
          _db.taskTags,
          _db.tags,
          _db.links,
        },
      )
      .watch()
      .asyncMap((_) => _details(id));

  Future<TaskDetails?> _details(int id) async {
    final row = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final ruleId = row.repeatRuleId;
    final rule = ruleId == null
        ? null
        : await (_db.select(
            _db.repeatRules,
          )..where((r) => r.id.equals(ruleId))).getSingle();
    final subtasks =
        await (_db.select(_db.subtasks)
              ..where((s) => s.taskId.equals(id))
              ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
            .get();
    final tags =
        await (_db.select(_db.tags).join([
                innerJoin(
                  _db.taskTags,
                  _db.taskTags.tagId.equalsExp(_db.tags.id),
                ),
              ])
              ..where(_db.taskTags.taskId.equals(id))
              ..orderBy([OrderingTerm.asc(_db.tags.name)]))
            .map((r) => r.readTable(_db.tags).toEntity())
            .get();
    final links =
        await (_db.select(_db.links)
              ..where((l) => l.taskId.equals(id))
              ..orderBy([(l) => OrderingTerm.asc(l.id)]))
            .get();
    return TaskDetails(
      task: row.toEntity(),
      repeat: rule?.toEntity(),
      subtasks: [for (final s in subtasks) s.toEntity()],
      tags: tags,
      links: [for (final l in links) l.toEntity()],
    );
  }

  // Writes ------------------------------------------------------------------

  @override
  Future<Task> add(TaskDraft draft) {
    _validate(
      title: draft.title,
      description: draft.description,
      dueDate: draft.dueDate,
      dueMinute: draft.dueMinute,
      subtaskTitles: draft.subtasks,
      urls: [for (final l in draft.links) l.url],
    );
    return _db.transaction(() async {
      final ruleId = draft.repeat == null
          ? null
          : await _db.into(_db.repeatRules).insert(draft.repeat!.toCompanion());
      final now = _nowUtc;
      final row = await _db
          .into(_db.tasks)
          .insertReturning(
            TasksCompanion.insert(
              title: draft.title.trim(),
              description: Value(draft.description),
              dueDate: Value(
                _storedOrNull(
                  draft.dueDate ?? (ruleId == null ? null : _today),
                ),
              ),
              dueMinute: Value(draft.dueMinute),
              priority: draft.priority.name,
              projectId: Value(draft.projectId),
              status: TaskStatus.open.name,
              boardColumn: BoardColumn.todo.name,
              createdAt: now,
              updatedAt: now,
              sortOrder: await _nextSortOrder(),
              repeatRuleId: Value(ruleId),
              reminder: Value(draft.reminder.name),
            ),
          );
      for (final (i, title) in draft.subtasks.indexed) {
        await _db
            .into(_db.subtasks)
            .insert(
              SubtasksCompanion.insert(
                taskId: row.id,
                title: title.trim(),
                sortOrder: i,
              ),
            );
      }
      await _setTags(row.id, draft.tagIds);
      for (final link in draft.links) {
        await _db
            .into(_db.links)
            .insert(
              LinksCompanion.insert(
                taskId: row.id,
                title: link.title.trim(),
                url: link.url.trim(),
              ),
            );
      }
      return row.toEntity();
    });
  }

  @override
  Future<void> update(TaskDetails details) {
    final task = details.task;
    _validate(
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueMinute: task.dueMinute,
      subtaskTitles: [for (final s in details.subtasks) s.title],
      urls: [for (final l in details.links) l.url],
    );
    return _db.transaction(() async {
      final current = await (_db.select(
        _db.tasks,
      )..where((t) => t.id.equals(task.id))).getSingle();
      final oldRuleId = current.repeatRuleId;
      int? ruleId;
      if (details.repeat case final repeat?) {
        final row = repeat.toCompanion();
        if (oldRuleId == null) {
          ruleId = await _db.into(_db.repeatRules).insert(row);
        } else {
          ruleId = oldRuleId;
          await _db
              .update(_db.repeatRules)
              .replace(row.copyWith(id: Value(oldRuleId)));
        }
      }
      await _db
          .update(_db.tasks)
          .replace(
            task
                .copyWith(
                  title: task.title.trim(),
                  dueDate: task.dueDate ?? (ruleId == null ? null : _today),
                  repeatRuleId: ruleId,
                  updatedAt: _nowUtc,
                )
                .toCompanion(),
          );
      if (ruleId == null && oldRuleId != null) {
        await _dropRuleIfUnused(oldRuleId);
      }

      final keptSubtasks = {for (final s in details.subtasks) s.id}..remove(0);
      await (_db.delete(_db.subtasks)..where(
            (s) => s.taskId.equals(task.id) & s.id.isNotIn(keptSubtasks),
          ))
          .go();
      for (final (i, s) in details.subtasks.indexed) {
        final row = s.copyWith(
          taskId: task.id,
          title: s.title.trim(),
          sortOrder: i,
        );
        if (s.id == 0) {
          await _db
              .into(_db.subtasks)
              .insert(row.toCompanion().copyWith(id: const Value.absent()));
        } else {
          await (_db.update(_db.subtasks)
                ..where((r) => r.id.equals(s.id) & r.taskId.equals(task.id)))
              .write(row.toCompanion());
        }
      }

      await (_db.delete(
        _db.taskTags,
      )..where((t) => t.taskId.equals(task.id))).go();
      await _setTags(task.id, {for (final t in details.tags) t.id});

      final keptLinks = {for (final l in details.links) l.id}..remove(0);
      await (_db.delete(
        _db.links,
      )..where((l) => l.taskId.equals(task.id) & l.id.isNotIn(keptLinks))).go();
      for (final l in details.links) {
        final row = l.copyWith(
          taskId: task.id,
          title: l.title.trim(),
          url: l.url.trim(),
        );
        if (l.id == 0) {
          await _db
              .into(_db.links)
              .insert(row.toCompanion().copyWith(id: const Value.absent()));
        } else {
          await (_db.update(_db.links)
                ..where((r) => r.id.equals(l.id) & r.taskId.equals(task.id)))
              .write(row.toCompanion());
        }
      }
    });
  }

  @override
  Future<Completion> complete(int id) => _db.transaction(() async {
    final before = await _details(id);
    if (before == null) throw StateError('no task $id');
    final task = before.task;
    if (task.status == TaskStatus.done) throw StateError('task $id is done');
    final now = _nowUtc;

    int? nextId;
    final rule = before.repeat;
    final dueDate = task.dueDate;
    if (rule != null && dueDate != null) {
      final nextDate = nextOccurrence(rule, dueDate);
      if (nextDate != null) {
        // PRD §6.4: title, description, priority, project, tags, reminder
        // and subtasks (unticked) carry over; the rule moves with it.
        nextId = await _db
            .into(_db.tasks)
            .insert(
              task
                  .copyWith(
                    dueDate: nextDate,
                    createdAt: now,
                    updatedAt: now,
                    sortOrder: await _nextSortOrder(),
                  )
                  .toCompanion()
                  .copyWith(id: const Value.absent()),
            );
        for (final s in before.subtasks) {
          await _db
              .into(_db.subtasks)
              .insert(
                SubtasksCompanion.insert(
                  taskId: nextId,
                  title: s.title,
                  sortOrder: s.sortOrder,
                ),
              );
        }
        await _setTags(nextId, {for (final t in before.tags) t.id});
      }
    }

    await _db
        .update(_db.tasks)
        .replace(
          task
              .copyWith(
                status: TaskStatus.done,
                boardColumn: BoardColumn.done,
                completedAt: now,
                updatedAt: now,
                repeatRuleId: nextId == null ? task.repeatRuleId : null,
              )
              .toCompanion(),
        );
    return (before: before, nextId: nextId);
  });

  @override
  Future<void> undoComplete(Completion completion) => _db.transaction(() async {
    if (completion.nextId case final nextId?) {
      await (_db.delete(_db.tasks)..where((t) => t.id.equals(nextId))).go();
    }
    await _db.update(_db.tasks).replace(completion.before.task.toCompanion());
  });

  @override
  Future<void> uncomplete(int id) =>
      (_db.update(
        _db.tasks,
      )..where((t) => t.id.equals(id) & t.status.equals('done'))).write(
        TasksCompanion(
          status: Value(TaskStatus.open.name),
          boardColumn: Value(BoardColumn.todo.name),
          completedAt: const Value(null),
          updatedAt: Value(_nowUtc),
        ),
      );

  @override
  Future<TaskDetails> delete(int id) => _db.transaction(() async {
    final before = await _details(id);
    if (before == null) throw StateError('no task $id');
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    if (before.task.repeatRuleId case final ruleId?) {
      await _dropRuleIfUnused(ruleId);
    }
    return before;
  });

  @override
  Future<void> restore(TaskDetails details) => _db.transaction(() async {
    final task = details.task;
    if ((details.repeat, task.repeatRuleId) case (final rule?, final ruleId?)) {
      await _db
          .into(_db.repeatRules)
          .insertOnConflictUpdate(
            rule.toCompanion().copyWith(id: Value(ruleId)),
          );
    }
    await _db.into(_db.tasks).insert(task.toCompanion());
    for (final s in details.subtasks) {
      await _db.into(_db.subtasks).insert(s.toCompanion());
    }
    await _setTags(task.id, {for (final t in details.tags) t.id});
    for (final l in details.links) {
      await _db.into(_db.links).insert(l.toCompanion());
    }
  });

  // Helpers -----------------------------------------------------------------

  /// Links [tagIds] that still exist to the task.
  Future<void> _setTags(int taskId, Set<int> tagIds) async {
    if (tagIds.isEmpty) return;
    final existing = await (_db.select(
      _db.tags,
    )..where((t) => t.id.isIn(tagIds))).map((t) => t.id).get();
    for (final tagId in existing) {
      await _db
          .into(_db.taskTags)
          .insert(TaskTagsCompanion.insert(taskId: taskId, tagId: tagId));
    }
  }

  Future<void> _dropRuleIfUnused(int ruleId) async {
    final used = await (_db.select(
      _db.tasks,
    )..where((t) => t.repeatRuleId.equals(ruleId))).get();
    if (used.isEmpty) {
      await (_db.delete(
        _db.repeatRules,
      )..where((r) => r.id.equals(ruleId))).go();
    }
  }

  Future<int> _nextSortOrder() async {
    final max = _db.tasks.sortOrder.max();
    final last = await (_db.selectOnly(
      _db.tasks,
    )..addColumns([max])).map((r) => r.read(max)).getSingle();
    return (last ?? -1) + 1;
  }

  static DateTime? _storedOrNull(DateTime? date) =>
      date == null ? null : storedDate(date);

  /// PRD §8 field rules, checked before anything is written.
  static void _validate({
    required String title,
    required String? description,
    required DateTime? dueDate,
    required int? dueMinute,
    required List<String> subtaskTitles,
    required List<String> urls,
  }) {
    _checkTitle(title, 'title');
    if (description != null && description.length > maxTaskDescriptionLength) {
      throw ArgumentError.value(
        description.length,
        'description',
        'longer than $maxTaskDescriptionLength characters',
      );
    }
    if (dueMinute != null) {
      if (dueDate == null) {
        throw ArgumentError.value(dueMinute, 'dueMinute', 'needs a due date');
      }
      if (dueMinute < 0 || dueMinute > 1439) {
        throw RangeError.range(dueMinute, 0, 1439, 'dueMinute');
      }
    }
    if (subtaskTitles.length > maxSubtasksPerTask) {
      throw ArgumentError.value(
        subtaskTitles.length,
        'subtasks',
        'more than $maxSubtasksPerTask',
      );
    }
    for (final s in subtaskTitles) {
      _checkTitle(s, 'subtask');
    }
    for (final url in urls) {
      if (!isWebLink(url)) {
        throw ArgumentError.value(url, 'url', 'not an http or https link');
      }
    }
  }

  static void _checkTitle(String title, String name) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(title, name, 'is blank');
    if (trimmed.length > maxTaskTitleLength) {
      throw ArgumentError.value(
        title.length,
        name,
        'longer than $maxTaskTitleLength characters',
      );
    }
  }
}
