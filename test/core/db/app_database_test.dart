import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final now = DateTime.utc(2026, 11, 17, 1, 41);

  Future<int> addProject({String name = 'Q4 report', DateTime? archivedAt}) =>
      db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              name: name,
              colorKey: 'orange',
              iconKey: 'chart',
              createdAt: now,
              sortOrder: 0,
              archivedAt: Value(archivedAt),
            ),
          );

  Future<int> addTask({
    String title = 'Finish Q4 revenue slides',
    int? projectId,
    DateTime? dueDate,
    int? dueMinute,
    String status = 'open',
    String boardColumn = 'todo',
    String priority = 'urgent',
  }) => db
      .into(db.tasks)
      .insert(
        TasksCompanion.insert(
          title: title,
          priority: priority,
          status: status,
          boardColumn: boardColumn,
          createdAt: now,
          updatedAt: now,
          sortOrder: 0,
          projectId: Value(projectId),
          dueDate: Value(dueDate),
          dueMinute: Value(dueMinute),
        ),
      );

  Future<int> addTag(String name) =>
      db.into(db.tags).insert(TagsCompanion.insert(name: name));

  final rejected = throwsA(
    anyOf(isA<SqliteException>(), isA<InvalidDataException>()),
  );

  test('schema v1 has the nine tables', () async {
    expect(db.schemaVersion, 1);
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .map((r) => r.read<String>('name'))
        .get();
    expect(
      tables,
      unorderedEquals([
        'projects',
        'repeat_rules',
        'tasks',
        'subtasks',
        'tags',
        'task_tags',
        'links',
        'focus_sessions',
        'preferences',
      ]),
    );
  });

  test('foreign keys are on', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.single, 1);
  });

  group('tasks', () {
    test('a due date and a UTC timestamp come back unchanged', () async {
      final id = await addTask(
        dueDate: storedDate(DateTime(2026, 11, 17)),
        dueMinute: 600,
      );
      final row = await (db.select(
        db.tasks,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(localDate(row.dueDate!), DateTime(2026, 11, 17));
      expect(row.dueMinute, 600);
      expect(row.createdAt, now);
      expect(row.createdAt.isUtc, isTrue);
      expect(row.reminder, 'none');
    });

    test('a time needs a date', () async {
      expect(() => addTask(dueMinute: 600), rejected);
    });

    test('the minute is 0–1439', () async {
      final date = storedDate(DateTime(2026, 11, 17));
      expect(() => addTask(dueDate: date, dueMinute: 1440), rejected);
      expect(() => addTask(dueDate: date, dueMinute: -1), rejected);
      await addTask(dueDate: date, dueMinute: 1439);
    });

    test('the title is 1–120 characters', () async {
      expect(() => addTask(title: ''), rejected);
      expect(() => addTask(title: 'x' * 121), rejected);
      await addTask(title: 'x' * 120);
    });

    test('length limits hold for raw SQL too', () async {
      // A backup restore (v1.1) may write rows without Drift's checks.
      Future<void> raw(String title) => db.customStatement(
        'INSERT INTO tasks (title, priority, status, board_column, '
        "created_at, updated_at, sort_order) VALUES (?, 'low', 'open', "
        "'todo', '2026-11-17T00:00:00.000Z', '2026-11-17T00:00:00.000Z', 0)",
        [title],
      );
      expect(() => raw(''), throwsA(isA<SqliteException>()));
      expect(() => raw('x' * 121), throwsA(isA<SqliteException>()));
      await raw('x' * 120);
    });

    test('enums only take their PRD values', () async {
      expect(() => addTask(priority: 'critical'), rejected);
      expect(() => addTask(status: 'archived'), rejected);
      expect(() => addTask(boardColumn: 'backlog'), rejected);
    });

    test('the board column is done exactly when the task is', () async {
      expect(() => addTask(status: 'done'), rejected);
      expect(() => addTask(boardColumn: 'done'), rejected);
      await addTask(status: 'done', boardColumn: 'done');
      await addTask(boardColumn: 'doing');
    });
  });

  group('deleting a task', () {
    test('removes its subtasks, tag links and links', () async {
      final task = await addTask();
      final tag = await addTag('work');
      await db
          .into(db.subtasks)
          .insert(
            SubtasksCompanion.insert(
              taskId: task,
              title: 'Revenue chart',
              sortOrder: 0,
            ),
          );
      await db
          .into(db.taskTags)
          .insert(TaskTagsCompanion.insert(taskId: task, tagId: tag));
      await db
          .into(db.links)
          .insert(
            LinksCompanion.insert(
              taskId: task,
              title: 'Deck',
              url: 'https://example.com/deck',
            ),
          );

      await (db.delete(db.tasks)..where((t) => t.id.equals(task))).go();

      expect(await db.select(db.subtasks).get(), isEmpty);
      expect(await db.select(db.taskTags).get(), isEmpty);
      expect(await db.select(db.links).get(), isEmpty);
      expect(await db.select(db.tags).get(), hasLength(1));
    });

    test('keeps its focus sessions without a task', () async {
      final task = await addTask();
      await db
          .into(db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              taskId: Value(task),
              kind: 'focus',
              plannedSec: 1500,
              startedAt: now,
              elapsedSec: 1500,
            ),
          );

      await (db.delete(db.tasks)..where((t) => t.id.equals(task))).go();

      final session = await db.select(db.focusSessions).getSingle();
      expect(session.taskId, isNull);
      expect(session.elapsedSec, 1500);
    });
  });

  test("deleting a project clears its tasks' project", () async {
    final project = await addProject();
    final task = await addTask(projectId: project);

    await (db.delete(db.projects)..where((p) => p.id.equals(project))).go();

    final row = await (db.select(
      db.tasks,
    )..where((t) => t.id.equals(task))).getSingle();
    expect(row.projectId, isNull);
  });

  test('deleting a tag removes it from tasks', () async {
    final task = await addTask();
    final tag = await addTag('work');
    await db
        .into(db.taskTags)
        .insert(TaskTagsCompanion.insert(taskId: task, tagId: tag));

    await (db.delete(db.tags)..where((t) => t.id.equals(tag))).go();

    expect(await db.select(db.taskTags).get(), isEmpty);
  });

  group('projects', () {
    test('names are unique among active projects, ignoring case', () async {
      await addProject(name: 'Freelance');
      expect(() => addProject(name: 'freelance'), rejected);
    });

    test('an archived project can share a name', () async {
      await addProject(name: 'Freelance', archivedAt: now);
      await addProject(name: 'Freelance');
      expect(() => addProject(name: 'Freelance'), rejected);
    });

    test('colour and icon keys are checked', () async {
      expect(
        () => db
            .into(db.projects)
            .insert(
              ProjectsCompanion.insert(
                name: 'X',
                colorKey: 'teal',
                iconKey: 'chart',
                createdAt: now,
                sortOrder: 0,
              ),
            ),
        rejected,
      );
      expect(
        () => db
            .into(db.projects)
            .insert(
              ProjectsCompanion.insert(
                name: 'X',
                colorKey: 'blue',
                iconKey: 'rocket',
                createdAt: now,
                sortOrder: 0,
              ),
            ),
        rejected,
      );
    });

    test('the name is 1–40 characters', () async {
      expect(() => addProject(name: ''), rejected);
      expect(() => addProject(name: 'x' * 41), rejected);
    });
  });

  group('tags', () {
    test('are lowercase, without #, 1–24 characters and unique', () async {
      await addTag('work');
      expect(() => addTag('work'), rejected);
      expect(() => addTag('Work'), rejected);
      expect(() => addTag('#work'), rejected);
      expect(() => addTag(''), rejected);
      expect(() => addTag('x' * 25), rejected);
      await addTag('x' * 24);
    });
  });

  test('links must be http or https', () async {
    final task = await addTask();
    Future<int> link(String url) => db
        .into(db.links)
        .insert(LinksCompanion.insert(taskId: task, title: 'L', url: url));
    expect(() => link('ftp://example.com'), rejected);
    expect(() => link('javascript:alert(1)'), rejected);
    expect(() => link('https://'), rejected);
    await link('http://example.com');
    await link('https://example.com');
  });

  group('repeat rules', () {
    Future<int> rule(RepeatRulesCompanion row) =>
        db.into(db.repeatRules).insert(row);

    test('weekly needs a day, monthly a day of the month', () async {
      expect(() => rule(RepeatRulesCompanion.insert(kind: 'weekly')), rejected);
      await rule(
        RepeatRulesCompanion.insert(kind: 'weekly', weekdays: const Value(9)),
      );
      expect(
        () => rule(RepeatRulesCompanion.insert(kind: 'monthly')),
        rejected,
      );
    });

    test('custom needs an interval and unit, months a day too', () async {
      expect(
        () => rule(
          RepeatRulesCompanion.insert(kind: 'custom', interval: const Value(2)),
        ),
        rejected,
      );
      expect(
        () => rule(
          RepeatRulesCompanion.insert(
            kind: 'custom',
            interval: const Value(2),
            unit: const Value('month'),
          ),
        ),
        rejected,
      );
      await rule(
        RepeatRulesCompanion.insert(
          kind: 'custom',
          interval: const Value(2),
          unit: const Value('month'),
          dayOfMonth: const Value(31),
        ),
      );
    });

    test('the interval is 1–12', () async {
      expect(
        () => rule(
          RepeatRulesCompanion.insert(
            kind: 'custom',
            interval: const Value(13),
            unit: const Value('day'),
          ),
        ),
        rejected,
      );
    });
  });

  test('focus sessions check their kind and lengths', () async {
    Future<int> session({String kind = 'focus', int planned = 1500}) => db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            kind: kind,
            plannedSec: planned,
            startedAt: now,
            elapsedSec: 0,
          ),
        );
    expect(() => session(kind: 'nap'), rejected);
    expect(() => session(planned: 0), rejected);
    await session();
  });
}
