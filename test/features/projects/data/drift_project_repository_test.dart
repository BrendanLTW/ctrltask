import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/projects/data/drift_project_repository.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftProjectRepository repo;
  late DriftTaskRepository tasks;
  final now = DateTime(2026, 11, 17, 9, 41);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftProjectRepository(db, () => now);
    tasks = DriftTaskRepository(db, () => now);
  });
  tearDown(() => db.close());

  Future<Project> add(String name, {String? description}) => repo.add(
    name: name,
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    description: description,
  );

  Future<List<String>> names(Stream<List<Project>> stream) async => [
    for (final p in await stream.first) p.name,
  ];

  group('add and update', () {
    test('trims, puts the project last and stamps it', () async {
      final a = await add('  Website redesign ', description: '  ');
      final b = await repo.add(
        name: 'Japan trip',
        colorKey: ProjectColorKey.pink,
        iconKey: ProjectIconKey.plane,
        description: ' Two weeks ',
        deadline: DateTime(2027, 4),
      );

      expect(a.name, 'Website redesign');
      expect(a.description, isNull);
      expect(a.createdAt, now.toUtc());
      expect(b.sortOrder, a.sortOrder + 1);
      expect(b.description, 'Two weeks');
      expect(b.deadline, DateTime(2027, 4));
      expect(await names(repo.watchActive()), [
        'Website redesign',
        'Japan trip',
      ]);
    });

    test('rejects blank or long names and long descriptions', () async {
      expect(() => add(' '), throwsArgumentError);
      expect(() => add('x' * 41), throwsArgumentError);
      expect(() => add('Ok', description: 'x' * 301), throwsArgumentError);
      await add('x' * 40, description: 'x' * 300);
    });

    test('names are unique among active projects, ignoring case', () async {
      await add('Freelance');
      expect(
        () => add(' freelance '),
        throwsA(isA<DuplicateProjectNameException>()),
      );
    });

    test('update saves fields and checks the name against others', () async {
      final a = await add('Q4 report');
      await add('Freelance');

      await repo.update(
        a.copyWith(name: ' Q4 board report ', colorKey: ProjectColorKey.red),
      );
      expect((await repo.watchActive().first).first.name, 'Q4 board report');

      // Keeping its own name is fine; taking another's isn't.
      await repo.update(a.copyWith(name: 'Q4 board report'));
      expect(
        () => repo.update(a.copyWith(name: 'FREELANCE')),
        throwsA(isA<DuplicateProjectNameException>()),
      );
    });
  });

  group('archive and restore', () {
    test('moves between active and archived, live', () async {
      final p = await add('Home renovation');
      final active = repo.watchActive().map((l) => [for (final x in l) x.name]);
      final expectation = expectLater(
        active,
        emitsInOrder([
          ['Home renovation'],
          <String>[],
          ['Home renovation'],
        ]),
      );
      await pumpEventQueue();

      await repo.archive(p.id);
      await pumpEventQueue();
      final archived = (await repo.watchArchived().first).single;
      expect(archived.archivedAt, now.toUtc());

      await repo.restore(p.id);
      await expectation;
      final back = (await repo.watchActive().first).single;
      expect(back, p);
    });

    test('an archived name is free; restoring it then clashes', () async {
      final old = await add('Freelance');
      await repo.archive(old.id);
      await add('Freelance');

      expect(
        () => repo.restore(old.id),
        throwsA(isA<DuplicateProjectNameException>()),
      );
    });

    test(
      'archiving hides the project tasks; restoring brings them back',
      () async {
        final p = await add('Learn Flutter');
        await tasks.add(TaskDraft(title: 'Read chapter', projectId: p.id));
        final before = await tasks.watchAll().first;
        final project = (await repo.watchActive().first).single;

        await repo.archive(p.id);
        expect(await tasks.watchAll().first, isEmpty);

        await repo.restore(p.id);
        // Exactly as they were (PRD §5.7).
        expect(await tasks.watchAll().first, before);
        expect((await repo.watchActive().first).single, project);
      },
    );
  });

  group('delete', () {
    Future<(int, int)> projectWithTask() async {
      final p = await add('Q4 report');
      final t = await tasks.add(
        TaskDraft(
          title: 'Slides',
          projectId: p.id,
          dueDate: DateTime(2026, 11, 17),
          repeat: const RepeatRule.daily(),
          subtasks: const ['Chart'],
        ),
      );
      await db
          .into(db.focusSessions)
          .insert(
            FocusSessionsCompanion.insert(
              taskId: Value(t.id),
              kind: 'focus',
              plannedSec: 1500,
              startedAt: now.toUtc(),
              elapsedSec: 1500,
            ),
          );
      return (p.id, t.id);
    }

    test('moves its tasks to Inbox by default', () async {
      final (project, task) = await projectWithTask();

      await repo.delete(project, deleteTasks: false);

      expect(await repo.watchActive().first, isEmpty);
      final moved = (await tasks.watchDetails(task).first)!;
      expect(moved.task.projectId, isNull);
      expect(moved.subtasks, hasLength(1));
      expect(moved.repeat, const RepeatRule.daily());
    });

    test('or deletes them with everything attached', () async {
      final (project, _) = await projectWithTask();

      await repo.delete(project, deleteTasks: true);

      expect(await db.select(db.tasks).get(), isEmpty);
      expect(await db.select(db.subtasks).get(), isEmpty);
      expect(await db.select(db.repeatRules).get(), isEmpty);
      final session = await db.select(db.focusSessions).getSingle();
      expect(session.taskId, isNull, reason: 'focus history is kept');
    });
  });
}
