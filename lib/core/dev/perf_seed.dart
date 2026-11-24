import 'dart:math';

import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/db/stored_dates.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:drift/drift.dart';

/// How much [seedPerf] writes (PLAN 4.3).
abstract final class PerfSize {
  static const projects = 10;
  static const tasks = 2000;
  static const tags = 8;

  /// A year of focus, about three sessions a day.
  static const sessionDays = 365;
}

/// Fills an empty [db] with a large, repeatable data set to measure against
/// PRD §10: [PerfSize.tasks] tasks over [PerfSize.projects] projects, due
/// across the year around [today] (about two thirds done, some with
/// subtasks, tags and repeats), and a year of focus sessions. One batch, so
/// the first launch stays quick. Through `--dart-define=PERF=true`; never in
/// release.
Future<void> seedPerf(AppDatabase db, {required DateTime today}) async {
  final random = Random(42);
  final day = DateTime(today.year, today.month, today.day);
  DateTime on(int offset) => DateTime(day.year, day.month, day.day + offset);
  T pick<T>(List<T> items) => items[random.nextInt(items.length)];

  await DriftPreferencesRepository(db)
      .update((p) => p.copyWith(userName: 'Perf', onboardingComplete: true));

  const words = [
    'Review',
    'Draft',
    'Call',
    'Fix',
    'Plan',
    'Send',
    'Update',
    'Book',
    'Write',
    'Check',
    'Order',
    'Clean',
    'Prepare',
    'Finish',
    'Read',
    'Pay',
  ];
  const things = [
    'homepage',
    'invoice',
    'slides',
    'report',
    'contractor',
    'budget',
    'tickets',
    'notes',
    'pull request',
    'tiles',
    'dentist',
    'newsletter',
  ];

  await db.batch((b) {
    for (var p = 1; p <= PerfSize.projects; p++) {
      b.insert(
        db.projects,
        ProjectsCompanion.insert(
          id: Value(p),
          name: 'Project $p',
          colorKey: ProjectColorKey.values[p % 8].name,
          iconKey: ProjectIconKey.values[p % 12].name,
          createdAt: on(-400).toUtc(),
          sortOrder: p,
          deadline: Value(p.isEven ? storedDate(on(p * 9)) : null),
          // Two archived, as people keep finished projects.
          archivedAt: Value(p > PerfSize.projects - 2 ? on(-30).toUtc() : null),
        ),
      );
    }
    for (var t = 1; t <= PerfSize.tags; t++) {
      b.insert(db.tags, TagsCompanion.insert(id: Value(t), name: 'tag$t'));
    }
    b.insertAll(db.repeatRules, [
      RepeatRulesCompanion.insert(id: const Value(1), kind: 'daily'),
      RepeatRulesCompanion.insert(
        id: const Value(2),
        kind: 'weekly',
        weekdays: const Value(1 | 4),
      ),
      RepeatRulesCompanion.insert(
        id: const Value(3),
        kind: 'monthly',
        dayOfMonth: const Value(15),
      ),
    ]);

    for (var i = 1; i <= PerfSize.tasks; i++) {
      // Due from a year ago to two months ahead; one in ten has no date.
      final dueOffset = random.nextInt(425) - 365;
      final hasDue = random.nextInt(10) != 0;
      final created = on(min(dueOffset, 0) - random.nextInt(30));
      // Three in four past tasks are done; the rest stay overdue.
      final done = dueOffset < 0
          ? random.nextInt(4) != 0
          : random.nextInt(8) == 0;
      final minute = random.nextBool() ? (8 + random.nextInt(11)) * 60 : null;
      b.insert(
        db.tasks,
        TasksCompanion.insert(
          id: Value(i),
          title: '${pick(words)} ${pick(things)} $i',
          description: Value(i % 7 == 0 ? 'Notes for task $i' : null),
          dueDate: Value(hasDue ? storedDate(on(dueOffset)) : null),
          dueMinute: Value(hasDue ? minute : null),
          priority: pick(const ['urgent', 'high', 'medium', 'medium', 'low']),
          // One in five in the inbox.
          projectId: Value(
            random.nextInt(5) == 0
                ? null
                : 1 + random.nextInt(PerfSize.projects),
          ),
          status: done ? 'done' : 'open',
          completedAt: Value(
            done
                ? on(min(dueOffset, 0))
                      .add(Duration(hours: 9 + random.nextInt(9)))
                      .toUtc()
                : null,
          ),
          createdAt: created.toUtc(),
          updatedAt: created.toUtc(),
          boardColumn: done ? 'done' : 'todo',
          sortOrder: i,
          repeatRuleId: Value(i % 40 == 0 ? 1 + i ~/ 40 % 3 : null),
        ),
      );
      if (i % 5 == 0) {
        for (var s = 0; s < 3; s++) {
          b.insert(
            db.subtasks,
            SubtasksCompanion.insert(
              taskId: i,
              title: 'Step ${s + 1}',
              done: Value(done || s == 0),
              sortOrder: s,
            ),
          );
        }
      }
      if (i % 3 == 0) {
        b.insert(
          db.taskTags,
          TaskTagsCompanion.insert(
            taskId: i,
            tagId: 1 + random.nextInt(PerfSize.tags),
          ),
        );
      }
    }

    for (var d = PerfSize.sessionDays; d >= 0; d--) {
      for (var s = 0; s < 3; s++) {
        final start = on(-d).add(Duration(hours: 9 + s * 2));
        final elapsed = 25 * 60 - (random.nextInt(4) == 0 ? 600 : 0);
        b.insert(
          db.focusSessions,
          FocusSessionsCompanion.insert(
            taskId: Value(1 + random.nextInt(PerfSize.tasks)),
            kind: 'focus',
            plannedSec: 25 * 60,
            startedAt: start.toUtc(),
            endedAt: Value(start.add(Duration(seconds: elapsed)).toUtc()),
            elapsedSec: elapsed,
            completed: Value(elapsed == 25 * 60),
          ),
        );
      }
    }
  });
}
