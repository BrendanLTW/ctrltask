import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/task_factory.dart';

void main() {
  // Tue 17 Nov 2026, 9:41 AM local.
  final now = DateTime(2026, 11, 17, 9, 41);
  final today = DateTime(2026, 11, 17);
  DateTime at(int day, [int hour = 12, int minute = 0]) =>
      DateTime(2026, 11, day, hour, minute).toUtc();

  group('orderToday', () {
    test('open by priority, then time with untimed last', () {
      final ordered = orderToday([
        task('low, untimed', priority: TaskPriority.low),
        task('medium 14:30', dueMinute: 870),
        task('high 10:00', priority: TaskPriority.high, dueMinute: 600),
        task('urgent 17:00', priority: TaskPriority.urgent, dueMinute: 1020),
        task('medium 9:00', dueMinute: 540),
        task('medium untimed'),
      ]);
      expect(
        [for (final t in ordered) t.title],
        [
          'urgent 17:00',
          'high 10:00',
          'medium 9:00',
          'medium 14:30',
          'medium untimed',
          'low, untimed',
        ],
      );
    });

    test('then sortOrder', () {
      final ordered = orderToday([
        task('b', sortOrder: 2),
        task('a', sortOrder: 1),
      ]);
      expect([for (final t in ordered) t.title], ['a', 'b']);
    });

    test('done last, latest completion at the bottom', () {
      final ordered = orderToday([
        task('done 9:05', completedAt: at(17, 9, 5)),
        task('open', priority: TaskPriority.low),
        task('done 7:40', completedAt: at(17, 7, 40)),
      ]);
      expect(
        [for (final t in ordered) t.title],
        ['open', 'done 7:40', 'done 9:05'],
      );
    });
  });

  group('nextTask', () {
    test('is the earliest timed open task', () {
      final next = nextTask([
        task('urgent 17:00', priority: TaskPriority.urgent, dueMinute: 1020),
        task('high 10:00', priority: TaskPriority.high, dueMinute: 600),
        task('done 7:00', dueMinute: 420, completedAt: at(17, 7)),
        task('untimed', priority: TaskPriority.urgent),
      ]);
      expect(next?.title, 'high 10:00');
    });

    test('falls back to untimed by priority, or none', () {
      expect(
        nextTask([
          task('low', priority: TaskPriority.low),
          task('high', priority: TaskPriority.high),
        ])?.title,
        'high',
      );
      expect(nextTask([task('done', completedAt: at(17))]), isNull);
    });
  });

  group('todayProgress', () {
    test('counts done out of the whole list', () {
      final p = todayProgress([
        task('a', completedAt: at(17)),
        task('b', completedAt: at(17)),
        task('c'),
        task('d'),
        task('e'),
        task('f'),
      ]);
      expect(p, (done: 2, total: 6));
      expect(p.percent, 33);
    });

    test('an empty day is 0%, a full one 100%', () {
      expect(todayProgress([]).fraction, 0);
      expect(todayProgress([task('a', completedAt: at(17))]).percent, 100);
      expect((done: 2, total: 3).percent, 67);
    });
  });

  group('overdueTasks', () {
    test('open tasks due before today or at a time already passed', () {
      final overdue = overdueTasks([
        task('yesterday', dueDate: DateTime(2026, 11, 16)),
        task('9:00 today', dueDate: today, dueMinute: 540),
        task('10:00 today', dueDate: today, dueMinute: 600),
        task('today, no time', dueDate: today),
        task('no date'),
        task(
          'done yesterday',
          dueDate: DateTime(2026, 11, 16),
          completedAt: at(16),
        ),
      ], now);
      expect([for (final t in overdue) t.title], ['yesterday', '9:00 today']);
    });

    test('most urgent first: priority, then the oldest', () {
      final overdue = overdueTasks([
        task(
          'low, old',
          priority: TaskPriority.low,
          dueDate: DateTime(2026, 11),
        ),
        task(
          'high, recent',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 16),
        ),
        task(
          'high, old',
          priority: TaskPriority.high,
          dueDate: DateTime(2026, 11, 10),
        ),
      ], now);
      expect(
        [for (final t in overdue) t.title],
        ['high, old', 'high, recent', 'low, old'],
      );
    });
  });

  group('streak', () {
    test('counts back from today', () {
      final tasks = [
        for (var d = 6; d <= 17; d++) task('$d', completedAt: at(d)),
      ];
      expect(streak(tasks, today), 12);
    });

    test('still counts when today has nothing yet', () {
      final tasks = [
        for (var d = 10; d <= 16; d++) task('$d', completedAt: at(d)),
      ];
      expect(streak(tasks, today), 7);
    });

    test('is 0 when neither today nor yesterday has a completion', () {
      expect(streak([task('a', completedAt: at(15))], today), 0);
      expect(streak([], today), 0);
    });

    test('stops at a gap and counts a busy day once', () {
      final tasks = [
        task('a', completedAt: at(17, 8)),
        task('b', completedAt: at(17, 20)),
        task('c', completedAt: at(16)),
        // Gap on the 15th.
        task('d', completedAt: at(14)),
      ];
      expect(streak(tasks, today), 2);
    });

    test('uses the local day at the edges', () {
      final tasks = [
        task('just before midnight', completedAt: at(16, 23, 59)),
        task('just after midnight', completedAt: at(17, 0)),
      ];
      expect(streak(tasks, today), 2);
    });

    test('undo takes it back: the open task no longer counts', () {
      final done = [
        task('yesterday', completedAt: at(16)),
        task('today', completedAt: at(17)),
      ];
      expect(streak(done, today), 2);
      final undone = [done.first, task('today')];
      expect(streak(undone, DateTime(2026, 11, 17)), 1);
    });

    test('crosses a daylight-saving change', () {
      // Run with TZ=Europe/London: clocks go back on 25 Oct 2026.
      final tasks = [
        for (var d = 24; d <= 26; d++)
          task('$d', completedAt: DateTime(2026, 10, d, 12).toUtc()),
      ];
      expect(streak(tasks, DateTime(2026, 10, 26)), 3);
    });
  });

  group('doneThisWeek', () {
    final tasks = [
      task('Sat 14', completedAt: at(14)),
      task('Sun 15', completedAt: at(15)),
      task('Mon 16 00:00', completedAt: at(16, 0)),
      task('Tue 17', completedAt: at(17)),
      task('Sun 22 23:59', completedAt: at(22, 23, 59)),
      task('Mon 23', completedAt: at(23)),
      task('open'),
    ];

    test('follows the week start', () {
      expect(doneThisWeek(tasks, today, WeekStart.mon), 3);
      expect(doneThisWeek(tasks, today, WeekStart.sun), 3);
      expect(doneThisWeek(tasks, today, WeekStart.sat), 4);
    });
  });
}
