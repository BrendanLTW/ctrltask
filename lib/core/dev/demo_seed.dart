import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/features/projects/data/drift_project_repository.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrltask/features/tags/data/drift_tag_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:drift/drift.dart';

/// The canvas's "now": Tue 17 Nov 2026, 9:41 AM.
final demoNow = DateTime(2026, 11, 17, 9, 41);

/// Fills an empty [db] with the canvas sample data (CLAUDE.md Testing):
/// Alex's projects, today's tasks, a 12-day streak, 18 done this week,
/// 1h 15m of focus today and 342 tasks done in all. Debug builds only,
/// through `--dart-define=DEMO=true`.
Future<void> seedDemo(AppDatabase db) async {
  var now = DateTime(2026);
  DateTime clock() => now;
  final tasks = DriftTaskRepository(db, clock);
  final projects = DriftProjectRepository(db, clock);
  final tags = DriftTagRepository(db);

  await DriftPreferencesRepository(db)
      .update((p) => p.copyWith(userName: 'Alex', onboardingComplete: true));

  // Tags: the S46 counts, met by the featured tasks and then the history.
  const tagCounts = {
    'design': 14,
    'errands': 9,
    'admin': 7,
    'review': 6,
    'calls': 5,
    'home': 4,
    'health': 3,
    'travel': 3,
    'learning': 3,
    'finance': 2,
    'writing': 2,
    'ideas': 1,
  };
  final tagIds = {
    for (final name in tagCounts.keys) name: (await tags.create(name)).id,
  };
  Set<int> tagged(List<String> names) => {for (final n in names) tagIds[n]!};
  // The history fills what the featured open tasks below don't use.
  final tagsLeft = {
    ...tagCounts,
    'design': tagCounts['design']! - 1,
    'review': tagCounts['review']! - 1,
    'calls': tagCounts['calls']! - 1,
    'admin': tagCounts['admin']! - 1,
  };

  Future<int> project(
    String name,
    ProjectColorKey color,
    ProjectIconKey icon, {
    DateTime? deadline,
  }) async => (await projects.add(
    name: name,
    colorKey: color,
    iconKey: icon,
    deadline: deadline,
  )).id;

  // Archived projects, all tasks done before their finish date (S45).
  for (final (name, color, icon, count, finished) in [
    (
      'Portfolio site v1',
      ProjectColorKey.blue,
      ProjectIconKey.globe,
      31,
      DateTime(2026, 4, 30, 18),
    ),
    (
      'Wedding gifts',
      ProjectColorKey.pink,
      ProjectIconKey.gift,
      9,
      DateTime(2026, 7, 18, 18),
    ),
    (
      'Moving house',
      ProjectColorKey.green,
      ProjectIconKey.box,
      24,
      DateTime(2026, 9, 2, 18),
    ),
  ]) {
    now = finished.subtract(Duration(days: count + 7));
    final id = await project(name, color, icon);
    for (var i = 0; i < count; i++) {
      final done = finished.subtract(Duration(days: count - 1 - i, hours: 4));
      now = done.subtract(const Duration(days: 2));
      final t = await tasks.add(
        TaskDraft(
          title: '$name: step ${i + 1}',
          projectId: id,
          dueDate: DateTime(done.year, done.month, done.day),
        ),
      );
      now = done;
      await tasks.complete(t.id);
    }
    now = finished;
    await projects.archive(id);
  }

  // Active projects (S26, S17), and Personal and Health for Home's rows.
  now = DateTime(2026, 9, 1, 9);
  final website = await project(
    'Website redesign',
    ProjectColorKey.blue,
    ProjectIconKey.globe,
    deadline: DateTime(2026, 11, 30),
  );
  final q4 = await project(
    'Q4 report',
    ProjectColorKey.orange,
    ProjectIconKey.chart,
    deadline: DateTime(2026, 11, 23),
  );
  final renovation = await project(
    'Home renovation',
    ProjectColorKey.green,
    ProjectIconKey.home,
  );
  final flutter = await project(
    'Learn Flutter',
    ProjectColorKey.purple,
    ProjectIconKey.code,
    deadline: DateTime(2026, 12, 31),
  );
  final japan = await project(
    'Japan trip',
    ProjectColorKey.pink,
    ProjectIconKey.plane,
  );
  final freelance = await project(
    'Freelance',
    ProjectColorKey.yellow,
    ProjectIconKey.briefcase,
  );
  final personal = await project(
    'Personal',
    ProjectColorKey.grey,
    ProjectIconKey.bag,
  );
  final health = await project(
    'Health',
    ProjectColorKey.pink,
    ProjectIconKey.heart,
  );

  // History: 276 completions before today. 16 on Mon 16 Nov (18 this week
  // with today's two), every day back to 6 Nov (the streak), none on
  // 5 Nov, then a steady record with busier Thursdays (the power day).
  final completions = <DateTime>[
    for (var i = 0; i < 16; i++) DateTime(2026, 11, 16, 9 + i ~/ 2, 5 + i),
    for (var d = 15; d >= 6; d--)
      for (var i = 0; i < (d == 12 ? 6 : 3); i++)
        DateTime(2026, 11, d, 9 + i, 20),
  ];
  for (var day = DateTime(2026, 11, 4); completions.length < 276;) {
    final perDay = switch (day.weekday) {
      DateTime.thursday => 4,
      DateTime.saturday || DateTime.sunday => 1,
      _ => 2,
    };
    for (var i = 0; i < perDay && completions.length < 276; i++) {
      completions.add(DateTime(day.year, day.month, day.day, 10 + i, 15));
    }
    day = DateTime(day.year, day.month, day.day - 1);
  }

  // The most recent completions go to the active projects' done tasks.
  final projectDone = [
    for (final (id, count) in [
      (website, 5),
      (q4, 4),
      (renovation, 9),
      (flutter, 6),
      (japan, 3),
      (freelance, 4),
    ])
      for (var i = 0; i < count; i++) id,
  ];
  const homes = ['Inbox', 'Personal', 'Health'];
  for (final (i, done) in completions.indexed) {
    final projectId = i < projectDone.length
        ? projectDone[i]
        : [null, personal, health][i % 3];
    final tag = tagsLeft.entries.where((e) => e.value > 0).firstOrNull?.key;
    if (tag != null) tagsLeft[tag] = tagsLeft[tag]! - 1;
    now = done.subtract(const Duration(days: 1));
    final t = await tasks.add(
      TaskDraft(
        title: i < projectDone.length
            ? 'Project task ${i + 1}'
            : '${homes[i % 3]} task ${i + 1}',
        projectId: projectId,
        dueDate: DateTime(done.year, done.month, done.day),
        tagIds: tag == null ? const {} : {tagIds[tag]!},
      ),
    );
    now = done;
    await tasks.complete(t.id);
  }

  // Open tasks: Home's list, the overdue invoice, the week ahead and the
  // rest of each project's open count (S17).
  now = DateTime(2026, 11, 12, 9);
  final today = DateTime(2026, 11, 17);
  DateTime nov(int day) => DateTime(2026, 11, day);

  final slides = await tasks.add(
    TaskDraft(
      title: 'Finish Q4 revenue slides',
      dueDate: today,
      dueMinute: 17 * 60,
      priority: TaskPriority.urgent,
      projectId: q4,
    ),
  );
  final wireframes = await tasks.add(
    TaskDraft(
      title: 'Review homepage wireframes',
      description: 'Check the hero, pricing table and footer before handoff.',
      dueDate: today,
      dueMinute: 10 * 60,
      priority: TaskPriority.high,
      projectId: website,
      tagIds: tagged(['design', 'review']),
      subtasks: const [
        'Hero section',
        'Pricing table',
        'Footer links',
        'Mobile breakpoints',
      ],
      links: const [
        (title: 'Figma file', url: 'https://figma.com/file/website-redesign'),
      ],
    ),
  );
  await tasks.add(
    TaskDraft(
      title: 'Call contractor about bathroom tiles',
      dueDate: today,
      dueMinute: 14 * 60 + 30,
      projectId: renovation,
      tagIds: tagged(['calls']),
    ),
  );
  final chapter = await tasks.add(
    TaskDraft(
      title: 'Read Flutter state management chapter',
      dueDate: today,
      priority: TaskPriority.low,
      projectId: flutter,
      subtasks: const ['Providers', 'Notifiers', 'Code generation'],
    ),
  );
  final bill = await tasks.add(
    TaskDraft(
      title: 'Pay TNB electricity bill',
      dueDate: today,
      dueMinute: 9 * 60,
      projectId: personal,
    ),
  );
  final run = await tasks.add(
    TaskDraft(
      title: 'Morning run, 5 km',
      dueDate: today,
      dueMinute: 7 * 60,
      projectId: health,
    ),
  );
  await tasks.add(
    TaskDraft(
      title: 'Send invoice to Lumen Studio',
      dueDate: nov(16),
      priority: TaskPriority.high,
      projectId: freelance,
      tagIds: tagged(['admin']),
    ),
  );

  for (final (title, projectId, due) in [
    ('Review budget with finance', q4, nov(18)),
    ('Send board pack', q4, nov(23)),
    ('Write hero copy', website, nov(19)),
    ('Set up analytics', website, nov(25)),
    ('Collect tiles from Niro', renovation, nov(18)),
    ('Pick paint colours', renovation, nov(20)),
    ('Book plumber', renovation, null),
    ('Order bathroom fittings', renovation, null),
    ('Measure kitchen cabinets', renovation, null),
    ('Build a sample todo app', flutter, null),
    ('Watch Riverpod talk', flutter, null),
    ('Try go_router redirects', flutter, null),
    ('Write widget tests', flutter, null),
    ('Read Drift docs', flutter, null),
    ('Book flights to Osaka', japan, nov(27)),
    ('Reserve ryokan in Kyoto', japan, DateTime(2026, 12, 4)),
    ('Get a JR Pass', japan, null),
    ('Plan Kyoto day trips', japan, null),
    ('Buy travel adapter', japan, null),
    ('Exchange yen', japan, null),
    ('Pack for the trip', japan, null),
    ('Quote for Nori Studio', freelance, nov(24)),
  ]) {
    await tasks.add(
      TaskDraft(title: title, projectId: projectId, dueDate: due),
    );
  }

  // Today's progress: 2 of 4 wireframe subtasks, 1 of 3 chapter subtasks.
  for (final (id, doneCount) in [(wireframes.id, 2), (chapter.id, 1)]) {
    final details = (await tasks.watchDetails(id).first)!;
    await tasks.update(
      details.copyWith(
        subtasks: [
          for (final (i, s) in details.subtasks.indexed)
            s.copyWith(done: i < doneCount),
        ],
      ),
    );
  }

  // Today's two completions, then 1h 15m of focus before 9:41.
  now = DateTime(2026, 11, 17, 7, 40);
  await tasks.complete(run.id);
  now = DateTime(2026, 11, 17, 9, 5);
  await tasks.complete(bill.id);

  Future<void> focus(DateTime start, {int? taskId}) => db
      .into(db.focusSessions)
      .insert(
        FocusSessionsCompanion.insert(
          taskId: Value(taskId),
          kind: 'focus',
          plannedSec: 1500,
          startedAt: start.toUtc(),
          endedAt: Value(start.add(const Duration(minutes: 25)).toUtc()),
          elapsedSec: 1500,
          completed: const Value(true),
        ),
      );
  for (final minute in [7 * 60 + 50, 8 * 60 + 20, 8 * 60 + 50]) {
    await focus(today.add(Duration(minutes: minute)), taskId: slides.id);
  }
  // Focus history for Insights: two sessions on weekdays for three weeks.
  for (var d = DateTime(2026, 10, 26); d.isBefore(today);) {
    if (d.weekday <= DateTime.friday) {
      await focus(DateTime(d.year, d.month, d.day, 10));
      await focus(DateTime(d.year, d.month, d.day, 14));
    }
    d = DateTime(d.year, d.month, d.day + 1);
  }
}
