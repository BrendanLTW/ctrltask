import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/insights/domain/insight_calculations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/task_factory.dart';

void main() {
  // Tue 17 Nov 2026.
  final today = DateTime(2026, 11, 17);
  DateTime nov(int day, [int hour = 12]) => DateTime(2026, 11, day, hour);

  FocusSession session(
    DateTime start,
    int seconds, {
    FocusKind kind = FocusKind.focus,
  }) => FocusSession(
    id: 0,
    kind: kind,
    plannedSec: 1500,
    startedAt: start.toUtc(),
    elapsedSec: seconds,
  );

  group('ranges', () {
    test('last 7 days and the 7 before', () {
      expect(rangeFor(InsightRange.last7Days, today), (
        start: nov(11, 0),
        end: nov(17, 0),
      ));
      expect(previousRange(InsightRange.last7Days, today), (
        start: nov(4, 0),
        end: nov(10, 0),
      ));
    });

    test('this month so far and last month to the same day', () {
      expect(rangeFor(InsightRange.thisMonth, today), (
        start: nov(1, 0),
        end: nov(17, 0),
      ));
      expect(previousRange(InsightRange.thisMonth, today), (
        start: DateTime(2026, 10),
        end: DateTime(2026, 10, 17),
      ));
    });

    test('last month is clamped to its length and crosses a year', () {
      expect(previousRange(InsightRange.thisMonth, DateTime(2027, 3, 31)), (
        start: DateTime(2027, 2),
        end: DateTime(2027, 2, 28),
      ));
      expect(previousRange(InsightRange.thisMonth, DateTime(2027, 1, 9)), (
        start: DateTime(2026, 12),
        end: DateTime(2026, 12, 9),
      ));
    });
  });

  group('completion rate', () {
    final range = rangeFor(InsightRange.last7Days, today);

    test('is the share of tasks due in the range that are done', () {
      final tasks = [
        task('done on time', dueDate: nov(12, 0), completedAt: nov(12)),
        task('done late', dueDate: nov(13, 0), completedAt: nov(16)),
        task('open', dueDate: nov(14, 0)),
        task('open', dueDate: nov(17, 0)),
        // Outside the range or undated: not counted.
        task('before', dueDate: nov(10, 0), completedAt: nov(15)),
        task('undated', completedAt: nov(15)),
      ];
      expect(completionRate(tasks, range), 0.5);
    });

    test('is null when nothing was due', () {
      expect(
        completionRate([task('undated', completedAt: nov(15))], range),
        isNull,
      );
    });

    test('change is in whole points against the previous range', () {
      final tasks = [
        // This week: 3 of 4.
        for (final d in [11, 12, 13])
          task('$d', dueDate: nov(d, 0), completedAt: nov(d)),
        task('14', dueDate: nov(14, 0)),
        // Week before: 2 of 3.
        task('4', dueDate: nov(4, 0), completedAt: nov(4)),
        task('5', dueDate: nov(5, 0), completedAt: nov(5)),
        task('6', dueDate: nov(6, 0)),
      ];
      expect(rateChange(tasks, InsightRange.last7Days, today), 8);
      expect(rateChange(tasks, InsightRange.thisMonth, today), isNull);
    });
  });

  group('per day', () {
    final range = rangeFor(InsightRange.last7Days, today);

    test('completions by local day, with the best day', () {
      final tasks = [
        task('a', completedAt: nov(12).toUtc()),
        for (var i = 0; i < 3; i++) task('b$i', completedAt: nov(13).toUtc()),
        for (var i = 0; i < 3; i++) task('c$i', completedAt: nov(15).toUtc()),
        task('open'),
        task('old', completedAt: nov(9).toUtc()),
      ];
      final perDay = completionsPerDay(tasks, range);
      expect([for (final e in perDay) e.count], [0, 1, 3, 0, 3, 0, 0]);
      expect(bestDay(perDay), nov(13, 0), reason: 'the earlier of a tie');
      expect(bestDay(completionsPerDay([], range)), isNull);
    });

    test('focus counts only focus sessions of a minute or more', () {
      final perDay = focusPerDay([
        session(nov(17, 9), 1500),
        session(nov(17, 14), 1500),
        session(nov(17, 15), 59),
        session(nov(17, 16), 300, kind: FocusKind.short),
        session(nov(16, 9), 600),
      ], range);
      expect([for (final e in perDay) e.seconds], [0, 0, 0, 0, 0, 600, 3000]);
      expect(dailyAverageSeconds(perDay), 3600 ~/ 7);
    });
  });

  group('6-week trend', () {
    test('one rate per week, oldest first, ending this week', () {
      final tasks = [
        // This week (Mon 16 Nov): 1 of 1.
        task('now', dueDate: nov(16, 0), completedAt: nov(16)),
        // Five weeks ago (Mon 12 Oct): 1 of 2.
        task('a', dueDate: DateTime(2026, 10, 12), completedAt: nov(1)),
        task('b', dueDate: DateTime(2026, 10, 13)),
      ];
      final trend = weeklyTrend(tasks, today, WeekStart.mon);
      expect(trend, [0.5, null, null, null, null, 1.0]);
      expect(trendChange(trend), 50);
      expect(trendChange([null, 0.5, null]), isNull);
    });
  });

  group('power day', () {
    test('the weekday with the most completions over 4 full weeks', () {
      // Thursdays 22 and 29 Oct, 5 and 12 Nov: 6 completions, mostly
      // mornings. Two Mondays. This week's completions don't count.
      final tasks = [
        for (final d in [22, 29])
          task('t$d', completedAt: DateTime(2026, 10, d, 9)),
        for (final d in [5, 12]) ...[
          task('m$d', completedAt: nov(d, 10)),
          task('a$d', completedAt: nov(d, 15)),
        ],
        task('mon', completedAt: nov(9, 9)),
        task('mon2', completedAt: nov(2, 9)),
        for (var i = 0; i < 9; i++) task('now$i', completedAt: nov(17, 9)),
      ];
      final power = powerDay(tasks, today, WeekStart.mon)!;
      expect(power.weekday, DateTime.thursday);
      expect(power.average, 1.5);
      expect(power.mostlyBeforeNoon, isTrue);
    });

    test('ties go to the day earlier in the week; none is null', () {
      final tasks = [
        task('sun', completedAt: nov(8, 18)),
        task('sat', completedAt: nov(7, 18)),
      ];
      expect(powerDay(tasks, today, WeekStart.mon)!.weekday, DateTime.saturday);
      expect(powerDay(tasks, today, WeekStart.sun)!.weekday, DateTime.sunday);
      expect(powerDay(tasks, today, WeekStart.mon)!.mostlyBeforeNoon, isFalse);
      expect(powerDay([], today, WeekStart.mon), isNull);
    });
  });

  group('enough history', () {
    test('needs 3 days from the first task or session', () {
      expect(hasEnoughHistory([], [], today), isFalse);
      expect(
        hasEnoughHistory([task('a', createdAt: nov(16).toUtc())], [], today),
        isFalse,
      );
      expect(
        hasEnoughHistory([task('a', createdAt: nov(15).toUtc())], [], today),
        isTrue,
      );
      expect(hasEnoughHistory([], [session(nov(15, 23), 60)], today), isTrue);
    });
  });
}
