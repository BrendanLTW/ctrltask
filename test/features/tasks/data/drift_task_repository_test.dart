import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftTaskRepository repo;
  // Tue 17 Nov 2026, 9:41 AM local: the canvas's "now". Tests move it.
  late DateTime now;

  final today = DateTime(2026, 11, 17);
  final tomorrow = DateTime(2026, 11, 18);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 17, 9, 41);
    repo = DriftTaskRepository(db, () => now);
  });
  tearDown(() => db.close());

  Future<int> addProject(String name, {bool archived = false}) => db
      .into(db.projects)
      .insert(
        ProjectsCompanion.insert(
          name: name,
          colorKey: 'blue',
          iconKey: 'globe',
          createdAt: DateTime.utc(2026),
          sortOrder: 0,
          archivedAt: Value(archived ? DateTime.utc(2026, 11) : null),
        ),
      );

  Future<int> addTag(String name) =>
      db.into(db.tags).insert(TagsCompanion.insert(name: name));

  Future<List<String>> titles(Stream<List<Task>> stream) async => [
    for (final t in await stream.first) t.title,
  ];

  group('add', () {
    test('saves the task and everything attached, trimmed', () async {
      final project = await addProject('Website redesign');
      final tag = await addTag('design');

      final task = await repo.add(
        TaskDraft(
          title: '  Review homepage wireframes ',
          description: 'Hero and pricing.',
          dueDate: today,
          dueMinute: 600,
          priority: TaskPriority.high,
          projectId: project,
          reminder: ReminderOffset.min30,
          tagIds: {tag},
          subtasks: [' Hero ', 'Pricing'],
          links: [(title: 'Figma', url: 'https://figma.com/f/1')],
        ),
      );

      expect(task.title, 'Review homepage wireframes');
      expect(task.status, TaskStatus.open);
      expect(task.boardColumn, BoardColumn.todo);
      expect(task.createdAt, now.toUtc());
      expect(task.createdAt.isUtc, isTrue);
      expect(task.dueDate, today);

      final details = (await repo.watchDetails(task.id).first)!;
      expect([for (final s in details.subtasks) s.title], ['Hero', 'Pricing']);
      expect([for (final s in details.subtasks) s.done], [false, false]);
      expect([for (final t in details.tags) t.name], ['design']);
      expect(details.links.single.url, 'https://figma.com/f/1');
      expect(details.repeat, isNull);
    });

    test('puts each new task last', () async {
      final a = await repo.add(const TaskDraft(title: 'A'));
      final b = await repo.add(const TaskDraft(title: 'B'));
      expect(b.sortOrder, a.sortOrder + 1);
    });

    test('a repeating task without a date is due today', () async {
      final task = await repo.add(
        const TaskDraft(title: 'Water plants', repeat: RepeatRule.daily()),
      );
      expect(task.dueDate, today);
      expect(
        (await repo.watchDetails(task.id).first)!.repeat,
        const RepeatRule.daily(),
      );
    });

    test('rejects drafts that break PRD §8 rules and writes nothing', () async {
      final bad = <TaskDraft>[
        const TaskDraft(title: '   '),
        TaskDraft(title: 'x' * 121),
        TaskDraft(title: 'T', description: 'x' * 1001),
        const TaskDraft(title: 'T', dueMinute: 600),
        TaskDraft(title: 'T', dueDate: today, dueMinute: 1440),
        TaskDraft(title: 'T', subtasks: List.filled(51, 'step')),
        const TaskDraft(title: 'T', subtasks: [' ']),
        const TaskDraft(title: 'T', links: [(title: 'x', url: 'ftp://a.b')]),
        const TaskDraft(
          title: 'T',
          links: [(title: 'x', url: 'javascript:alert(1)')],
        ),
        const TaskDraft(title: 'T', links: [(title: 'x', url: 'https://')]),
      ];
      for (final draft in bad) {
        expect(
          () => repo.add(draft),
          throwsA(isA<ArgumentError>()),
          reason: '$draft',
        );
      }
      expect(await db.select(db.tasks).get(), isEmpty);
    });

    test('accepts the limits exactly', () async {
      await repo.add(
        TaskDraft(
          title: 'x' * 120,
          description: 'x' * 1000,
          dueDate: today,
          dueMinute: 1439,
          subtasks: List.filled(50, 'step'),
        ),
      );
    });
  });

  group('watches', () {
    test('today: open tasks due today and tasks completed today', () async {
      await repo.add(TaskDraft(title: 'Due today', dueDate: today));
      await repo.add(TaskDraft(title: 'Due tomorrow', dueDate: tomorrow));
      await repo.add(const TaskDraft(title: 'No date'));
      final early = await repo.add(const TaskDraft(title: 'Done at 00:00'));
      final late = await repo.add(const TaskDraft(title: 'Done at 23:59'));
      final before = await repo.add(const TaskDraft(title: 'Done yesterday'));
      final dueDone = await repo.add(
        TaskDraft(title: 'Due today, done yesterday', dueDate: today),
      );

      now = DateTime(2026, 11, 16, 23, 59, 59);
      await repo.complete(before.id);
      await repo.complete(dueDone.id);
      now = DateTime(2026, 11, 17);
      await repo.complete(early.id);
      now = DateTime(2026, 11, 17, 23, 59, 59);
      await repo.complete(late.id);

      expect(await titles(repo.watchToday(today)), [
        'Due today',
        'Done at 00:00',
        'Done at 23:59',
      ]);
    });

    test('all: open only, unless done is asked for', () async {
      await repo.add(const TaskDraft(title: 'Open'));
      final done = await repo.add(const TaskDraft(title: 'Done'));
      await repo.complete(done.id);

      expect(await titles(repo.watchAll()), ['Open']);
      expect(await titles(repo.watchAll(includeDone: true)), ['Open', 'Done']);
    });

    test('tasks in archived projects are hidden everywhere', () async {
      final archived = await addProject('Old', archived: true);
      await repo.add(
        TaskDraft(title: 'Hidden', projectId: archived, dueDate: today),
      );
      await repo.add(TaskDraft(title: 'Shown', dueDate: today));

      expect(await titles(repo.watchAll()), ['Shown']);
      expect(await titles(repo.watchToday(today)), ['Shown']);
      expect(await titles(repo.watchDueBetween(today, today)), ['Shown']);
      expect(await titles(repo.watchByProject(archived)), isEmpty);
      expect(await titles(repo.search('hidden')), isEmpty);
    });

    test('by project, and Inbox for null', () async {
      final project = await addProject('Q4 report');
      await repo.add(TaskDraft(title: 'In project', projectId: project));
      await repo.add(const TaskDraft(title: 'In inbox'));

      expect(await titles(repo.watchByProject(project)), ['In project']);
      expect(await titles(repo.watchByProject(null)), ['In inbox']);
    });

    test('due between two dates, inclusive', () async {
      for (final day in [16, 17, 20, 22, 23]) {
        await repo.add(
          TaskDraft(title: '$day', dueDate: DateTime(2026, 11, day)),
        );
      }
      await repo.add(const TaskDraft(title: 'No date'));

      expect(
        await titles(
          repo.watchDueBetween(DateTime(2026, 11, 17), DateTime(2026, 11, 22)),
        ),
        ['17', '20', '22'],
      );
    });

    test('update live as tasks change', () async {
      final stream = repo.watchAll().map((l) => [for (final t in l) t.title]);
      final expectation = expectLater(
        stream,
        emitsInOrder([
          <String>[],
          ['A'],
          ['A', 'B'],
          ['B'],
        ]),
      );
      await pumpEventQueue();
      final a = await repo.add(const TaskDraft(title: 'A'));
      await pumpEventQueue();
      await repo.add(const TaskDraft(title: 'B'));
      await pumpEventQueue();
      await repo.complete(a.id);
      await expectation;
    });
  });

  group('search', () {
    setUp(() async {
      final project = await addProject('Japan trip');
      final tag = await addTag('errands');
      await repo.add(
        TaskDraft(
          title: 'Book ryokan',
          description: 'Kyoto, two nights',
          projectId: project,
        ),
      );
      await repo.add(
        TaskDraft(
          title: 'Weekly shop',
          tagIds: {tag},
          subtasks: const ['Buy MILK'],
        ),
      );
      await repo.add(const TaskDraft(title: 'Discount 50% off'));
      await repo.add(const TaskDraft(title: 'Discount 50 off'));
    });

    test('matches title, description, subtasks, tags and project', () async {
      expect(await titles(repo.search('RYOKAN')), ['Book ryokan']);
      expect(await titles(repo.search('kyoto')), ['Book ryokan']);
      expect(await titles(repo.search('japan')), ['Book ryokan']);
      expect(await titles(repo.search('milk')), ['Weekly shop']);
      expect(await titles(repo.search('errand')), ['Weekly shop']);
    });

    test('treats % and _ as plain characters', () async {
      expect(await titles(repo.search('50%')), ['Discount 50% off']);
      expect(await titles(repo.search('_')), isEmpty);
    });

    test('#word matches only tags starting with it', () async {
      await repo.add(const TaskDraft(title: 'Errands list'));
      expect(await titles(repo.search('#ERR')), ['Weekly shop']);
      expect(await titles(repo.search('#rands')), isEmpty);
      expect(await titles(repo.search('#')), isEmpty);
    });

    test('a blank query finds nothing', () async {
      expect(await titles(repo.search('  ')), isEmpty);
    });

    test('includes done tasks', () async {
      final done = await repo.add(const TaskDraft(title: 'Ryokan deposit'));
      await repo.complete(done.id);
      expect(await titles(repo.search('ryokan')), [
        'Book ryokan',
        'Ryokan deposit',
      ]);
    });
  });

  group('update', () {
    test('saves fields and replaces subtasks, tags and links', () async {
      final design = await addTag('design');
      final work = await addTag('work');
      final task = await repo.add(
        TaskDraft(
          title: 'Wireframes',
          tagIds: {design},
          subtasks: const ['Keep', 'Rename', 'Drop'],
          links: const [
            (title: 'Keep', url: 'https://a.com'),
            (title: 'Drop', url: 'https://b.com'),
          ],
        ),
      );
      final before = (await repo.watchDetails(task.id).first)!;
      now = DateTime(2026, 11, 17, 11);

      await repo.update(
        before.copyWith(
          task: before.task.copyWith(
            title: ' Review wireframes ',
            priority: TaskPriority.urgent,
            dueDate: tomorrow,
            dueMinute: 540,
          ),
          subtasks: [
            before.subtasks[1].copyWith(title: 'Renamed', done: true),
            before.subtasks[0],
            const Subtask(id: 0, taskId: 0, title: 'New', sortOrder: 0),
          ],
          tags: [Tag(id: work, name: 'work')],
          links: [
            before.links[0],
            const TaskLink(
              id: 0,
              taskId: 0,
              title: 'New',
              url: 'https://c.com',
            ),
          ],
        ),
      );

      final after = (await repo.watchDetails(task.id).first)!;
      expect(after.task.title, 'Review wireframes');
      expect(after.task.priority, TaskPriority.urgent);
      expect((after.task.dueDate, after.task.dueMinute), (tomorrow, 540));
      expect(after.task.updatedAt, now.toUtc());
      expect(after.task.createdAt, before.task.createdAt);
      expect(
        [for (final s in after.subtasks) (s.title, s.done)],
        [('Renamed', true), ('Keep', false), ('New', false)],
      );
      expect(after.subtasks[0].id, before.subtasks[1].id);
      expect([for (final t in after.tags) t.name], ['work']);
      expect(
        [for (final l in after.links) l.url],
        ['https://a.com', 'https://c.com'],
      );
    });

    test('adds, changes and removes the repeat rule', () async {
      final task = await repo.add(TaskDraft(title: 'Gym', dueDate: today));
      var details = (await repo.watchDetails(task.id).first)!;

      await repo.update(details.copyWith(repeat: const RepeatRule.daily()));
      details = (await repo.watchDetails(task.id).first)!;
      expect(details.repeat, const RepeatRule.daily());

      final weekly = RepeatRule.weekly({DateTime.monday, DateTime.thursday});
      await repo.update(details.copyWith(repeat: weekly));
      details = (await repo.watchDetails(task.id).first)!;
      expect(details.repeat, weekly);
      expect(await db.select(db.repeatRules).get(), hasLength(1));

      await repo.update(details.copyWith(repeat: null));
      details = (await repo.watchDetails(task.id).first)!;
      expect(details.repeat, isNull);
      expect(await db.select(db.repeatRules).get(), isEmpty);
    });

    test('validates like add', () async {
      final task = await repo.add(const TaskDraft(title: 'T'));
      final details = (await repo.watchDetails(task.id).first)!;
      expect(
        () => repo.update(
          details.copyWith(task: details.task.copyWith(title: '')),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('complete', () {
    test('marks the task done now, in the done column', () async {
      final task = await repo.add(TaskDraft(title: 'Pay bill', dueDate: today));

      final result = await repo.complete(task.id);

      final after = (await repo.watchDetails(task.id).first)!.task;
      expect(after.status, TaskStatus.done);
      expect(after.boardColumn, BoardColumn.done);
      expect(after.completedAt, now.toUtc());
      expect(result.nextId, isNull);
      expect(result.before.task, task);
    });

    test('a done task cannot be completed again', () async {
      final task = await repo.add(const TaskDraft(title: 'T'));
      await repo.complete(task.id);
      expect(() => repo.complete(task.id), throwsStateError);
    });

    test(
      'a repeating task gets its next occurrence from the due date',
      () async {
        final project = await addProject('Health');
        final tag = await addTag('fitness');
        final rule = RepeatRule.weekly({DateTime.monday, DateTime.thursday});
        // Due yesterday, completed today: the next date follows the due date.
        final task = await repo.add(
          TaskDraft(
            title: 'Gym',
            description: 'Legs',
            dueDate: DateTime(2026, 11, 16),
            dueMinute: 420,
            priority: TaskPriority.high,
            projectId: project,
            reminder: ReminderOffset.min10,
            repeat: rule,
            tagIds: {tag},
            subtasks: const ['Warm up'],
            links: const [(title: 'Plan', url: 'https://plan.com')],
          ),
        );
        final original = (await repo.watchDetails(task.id).first)!;
        await repo.update(
          original.copyWith(
            subtasks: [original.subtasks.single.copyWith(done: true)],
          ),
        );

        final result = await repo.complete(task.id);

        final next = (await repo.watchDetails(result.nextId!).first)!;
        expect(next.task.dueDate, DateTime(2026, 11, 19));
        expect(next.task.dueMinute, 420);
        expect(next.task.title, 'Gym');
        expect(next.task.description, 'Legs');
        expect(next.task.priority, TaskPriority.high);
        expect(next.task.projectId, project);
        expect(next.task.reminder, ReminderOffset.min10);
        expect(next.task.status, TaskStatus.open);
        expect(next.task.boardColumn, BoardColumn.todo);
        expect(next.repeat, rule);
        expect([for (final t in next.tags) t.name], ['fitness']);
        expect(
          [for (final s in next.subtasks) (s.title, s.done)],
          [('Warm up', false)],
        );
        expect(next.links, isEmpty);

        final done = (await repo.watchDetails(task.id).first)!;
        expect(done.task.status, TaskStatus.done);
        expect(done.repeat, isNull, reason: 'the rule moved to the next one');
      },
    );

    test('no next occurrence after the end date; the rule stays', () async {
      final task = await repo.add(
        TaskDraft(
          title: 'Course',
          dueDate: today,
          repeat: RepeatRule.daily(endsOn: today),
        ),
      );

      final result = await repo.complete(task.id);

      expect(result.nextId, isNull);
      expect(await titles(repo.watchAll()), isEmpty);
      final done = (await repo.watchDetails(task.id).first)!;
      expect(done.repeat, RepeatRule.daily(endsOn: today));
    });

    test('undo puts the task back exactly and removes the next one', () async {
      final tag = await addTag('home');
      final task = await repo.add(
        TaskDraft(
          title: 'Water plants',
          dueDate: today,
          repeat: const RepeatRule.daily(),
          tagIds: {tag},
          subtasks: const ['Balcony'],
        ),
      );
      final before = (await repo.watchDetails(task.id).first)!;
      final result = await repo.complete(task.id);
      now = DateTime(2026, 11, 17, 9, 45);

      await repo.undoComplete(result);

      expect(await repo.watchDetails(task.id).first, before);
      expect(await repo.watchDetails(result.nextId!).first, isNull);
      expect(await titles(repo.watchAll()), ['Water plants']);
      expect(await db.select(db.repeatRules).get(), hasLength(1));
    });
  });

  test('subtask progress counts ticked out of all, per task', () async {
    final a = await repo.add(
      const TaskDraft(title: 'A', subtasks: ['1', '2', '3', '4']),
    );
    await repo.add(const TaskDraft(title: 'No subtasks'));
    final details = (await repo.watchDetails(a.id).first)!;
    await repo.update(
      details.copyWith(
        subtasks: [
          for (final (i, s) in details.subtasks.indexed)
            s.copyWith(done: i < 2),
        ],
      ),
    );

    expect(await repo.watchSubtaskProgress().first, {
      a.id: (done: 2, total: 4),
    });
  });

  test('Insights sees every task, archived projects included', () async {
    final old = await addProject('Old', archived: true);
    await repo.add(TaskDraft(title: 'Archived', projectId: old));
    final done = await repo.add(const TaskDraft(title: 'Done'));
    await repo.complete(done.id);
    expect(await titles(repo.watchForInsights()), ['Archived', 'Done']);
  });

  test('counts every task per project, archived ones included', () async {
    final live = await addProject('Live');
    final old = await addProject('Old', archived: true);
    await repo.add(TaskDraft(title: 'A', projectId: live));
    final done = await repo.add(TaskDraft(title: 'B', projectId: live));
    await repo.complete(done.id);
    await repo.add(TaskDraft(title: 'C', projectId: old));
    await repo.add(const TaskDraft(title: 'Inbox'));

    expect(await repo.watchTaskCounts().first, {live: 2, old: 1});
  });

  test('uncomplete reopens a done task', () async {
    final task = await repo.add(const TaskDraft(title: 'T'));
    await repo.complete(task.id);
    now = DateTime(2026, 11, 17, 12);

    await repo.uncomplete(task.id);

    final after = (await repo.watchDetails(task.id).first)!.task;
    expect(after.status, TaskStatus.open);
    expect(after.boardColumn, BoardColumn.todo);
    expect(after.completedAt, isNull);
    expect(after.updatedAt, now.toUtc());
  });

  test('tag names per task, A to Z', () async {
    final work = await addTag('work');
    final calls = await addTag('calls');
    final task = await repo.add(TaskDraft(title: 'T', tagIds: {work, calls}));
    await repo.add(const TaskDraft(title: 'Untagged'));
    expect(await repo.watchTagNames().first, {
      task.id: ['calls', 'work'],
    });
  });

  group('board columns (S20)', () {
    Future<Task> read(int id) async =>
        (await repo.watchDetails(id).first)!.task;

    test('a new task can start In progress, never Done', () async {
      final task = await repo.add(
        const TaskDraft(title: 'T', column: BoardColumn.doing),
      );
      expect(task.boardColumn, BoardColumn.doing);
      expect(
        () => repo.add(const TaskDraft(title: 'T', column: BoardColumn.done)),
        throwsArgumentError,
      );
    });

    test('moving goes to the end of the column', () async {
      final a = await repo.add(const TaskDraft(title: 'A'));
      final b = await repo.add(const TaskDraft(title: 'B'));
      await repo.moveToColumn(a.id, BoardColumn.doing);
      final moved = await read(a.id);
      expect(moved.boardColumn, BoardColumn.doing);
      expect(moved.status, TaskStatus.open);
      expect(moved.sortOrder, greaterThan((await read(b.id)).sortOrder));
    });

    test('a done task only leaves Done by reopening', () async {
      final task = await repo.add(const TaskDraft(title: 'T'));
      await repo.complete(task.id);
      await repo.moveToColumn(task.id, BoardColumn.doing);
      expect((await read(task.id)).boardColumn, BoardColumn.done);

      await repo.uncomplete(task.id, into: BoardColumn.doing);
      final after = await read(task.id);
      expect(after.status, TaskStatus.open);
      expect(after.boardColumn, BoardColumn.doing);
    });
  });

  group('delete and restore', () {
    test('delete removes everything attached and returns it', () async {
      final tag = await addTag('work');
      final task = await repo.add(
        TaskDraft(
          title: 'Slides',
          dueDate: today,
          repeat: const RepeatRule.weekdays(),
          tagIds: {tag},
          subtasks: const ['Chart'],
          links: const [(title: 'Deck', url: 'https://deck.com')],
        ),
      );
      final before = (await repo.watchDetails(task.id).first)!;

      final deleted = await repo.delete(task.id);

      expect(deleted, before);
      expect(await repo.watchDetails(task.id).first, isNull);
      expect(await db.select(db.subtasks).get(), isEmpty);
      expect(await db.select(db.taskTags).get(), isEmpty);
      expect(await db.select(db.links).get(), isEmpty);
      expect(await db.select(db.repeatRules).get(), isEmpty);
      expect(await db.select(db.tags).get(), hasLength(1));
    });

    test('restore puts it back with the same ids', () async {
      final tag = await addTag('work');
      final task = await repo.add(
        TaskDraft(
          title: 'Slides',
          dueDate: today,
          repeat: const RepeatRule.monthly(31),
          tagIds: {tag},
          subtasks: const ['Chart', 'Notes'],
          links: const [(title: 'Deck', url: 'https://deck.com')],
        ),
      );
      final deleted = await repo.delete(task.id);

      await repo.restore(deleted);

      expect(await repo.watchDetails(task.id).first, deleted);
    });

    test('restore leaves off tags deleted in the meantime', () async {
      final keep = await addTag('keep');
      final gone = await addTag('gone');
      final task = await repo.add(TaskDraft(title: 'T', tagIds: {keep, gone}));
      final deleted = await repo.delete(task.id);
      await (db.delete(db.tags)..where((t) => t.id.equals(gone))).go();

      await repo.restore(deleted);

      final back = (await repo.watchDetails(task.id).first)!;
      expect([for (final t in back.tags) t.name], ['keep']);
    });
  });
}
