import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/demo_seed.dart';
import 'package:ctrltask/features/focus/data/focus_session_mapper.dart';
import 'package:ctrltask/features/insights/domain/insight_calculations.dart';
import 'package:ctrltask/features/projects/data/drift_project_repository.dart';
import 'package:ctrltask/features/projects/domain/project_calculations.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrltask/features/tags/data/drift_tag_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftTaskRepository tasks;
  final today = DateTime(2026, 11, 17);

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedDemo(db);
    tasks = DriftTaskRepository(db, () => demoNow);
  });
  tearDownAll(() => db.close());

  Future<List<Task>> everyTask() async => [
    for (final row in await db.select(db.tasks).get())
      (await tasks.watchDetails(row.id).first)!.task,
  ];

  test('Alex has finished onboarding', () async {
    final prefs = await DriftPreferencesRepository(db).read();
    expect(prefs.userName, 'Alex');
    expect(prefs.onboardingComplete, isTrue);
  });

  test("Home: today's list is 2 of 6 done, in the canvas order", () async {
    final list = orderToday(await tasks.watchToday(today).first);
    expect(
      [for (final t in list) t.title],
      [
        'Review homepage wireframes',
        'Call contractor about bathroom tiles',
        'Finish Q4 revenue slides',
        'Read Flutter state management chapter',
        'Morning run, 5 km',
        'Pay TNB electricity bill',
      ],
    );
    expect(todayProgress(list), (done: 2, total: 6));
  });

  test('Home: one overdue task, the Lumen Studio invoice', () async {
    final overdue = overdueTasks(await tasks.watchAll().first, demoNow);
    expect(
      [for (final t in overdue) t.title],
      ['Send invoice to Lumen Studio'],
    );
  });

  test('Home: 12-day streak, 18 done this week, 1h 15m focused', () async {
    final all = await everyTask();
    expect(streak(all, today), 12);
    expect(doneThisWeek(all, today, WeekStart.mon), 18);
    final sessions = [
      for (final row in await db.select(db.focusSessions).get()) row.toEntity(),
    ];
    final focused = focusPerDay(sessions, (start: today, end: today));
    expect(focused.single.seconds, 75 * 60);
  });

  test('Settings: 342 tasks done', () async {
    final all = await everyTask();
    expect(all.where((t) => t.status == TaskStatus.done), hasLength(342));
  });

  test('Projects: 8 active with the canvas progress, 3 archived', () async {
    final projects = DriftProjectRepository(db, () => demoNow);
    final active = await projects.watchActive().first;
    final progress = {
      for (final p in active)
        p.name: projectProgress(await tasks.watchByProject(p.id).first),
    };
    expect(progress, {
      'Website redesign': (done: 5, total: 8),
      'Q4 report': (done: 4, total: 7),
      'Home renovation': (done: 9, total: 15),
      'Learn Flutter': (done: 6, total: 12),
      'Japan trip': (done: 3, total: 10),
      'Freelance': (done: 4, total: 6),
      'Personal': progress['Personal'],
      'Health': progress['Health'],
    });
    final website = active.firstWhere((p) => p.name == 'Website redesign');
    expect(daysLeft(website.deadline!, today), 13);

    final archived = await projects.watchArchived().first;
    expect(
      [for (final p in archived) p.name],
      ['Portfolio site v1', 'Wedding gifts', 'Moving house'],
    );
  });

  test('Tags: 12, led by the S46 counts', () async {
    final usage = await DriftTagRepository(db).watch().first;
    expect(usage, hasLength(12));
    expect(
      [for (final u in usage.take(5)) (u.tag.name, u.taskCount)],
      [
        ('design', 14),
        ('errands', 9),
        ('admin', 7),
        ('review', 6),
        ('calls', 5),
      ],
    );
  });

  test('Task detail: wireframes has 2 of 4 subtasks and a link', () async {
    final row = await (db.select(
      db.tasks,
    )..where((t) => t.title.equals('Review homepage wireframes'))).getSingle();
    final details = (await tasks.watchDetails(row.id).first)!;
    expect(
      [for (final s in details.subtasks) s.done],
      [true, true, false, false],
    );
    expect(details.links, hasLength(1));
    expect([for (final t in details.tags) t.name], ['design', 'review']);
  });

  test('Insights: enough history and Thursday is the power day', () async {
    final all = await everyTask();
    expect(hasEnoughHistory(all, const [], today), isTrue);
    expect(powerDay(all, today, WeekStart.mon)?.weekday, DateTime.thursday);
  });
}
