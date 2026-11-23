import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/insights/domain/insights_calculations.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tue 17 Nov 2026.
  final today = DateTime(2026, 11, 17);
  var id = 0;

  Task task({DateTime? due, DateTime? doneAt, DateTime? created}) => Task(
    id: id++,
    title: 'T',
    priority: TaskPriority.medium,
    status: doneAt == null ? TaskStatus.open : TaskStatus.done,
    boardColumn: BoardColumn.todo,
    createdAt: (created ?? DateTime(2026)).toUtc(),
    updatedAt: DateTime.utc(2026),
    sortOrder: 0,
    dueDate: due,
    completedAt: doneAt?.toUtc(),
  );

  group('ranges', () {
    test('Last 7 days and the 7 before', () {
      expect(rangeFor(InsightsRange.week, today), (
        start: DateTime(2026, 11, 11),
        end: today,
      ));
      expect(previousRange(InsightsRange.week, today), (
        start: DateTime(2026, 11, 4),
        end: DateTime(2026, 11, 10),
      ));
    });

    test('This month and the same days of last month', () {
      expect(rangeFor(InsightsRange.month, today), (
        start: DateTime(2026, 11),
        end: today,
      ));
      expect(previousRange(InsightsRange.month, today), (
        start: DateTime(2026, 10),
        end: DateTime(2026, 10, 17),
      ));
    });

    test("31 March compares with February's last day", () {
      expect(
        previousRange(InsightsRange.month, DateTime(2027, 3, 31)).end,
        DateTime(2027, 2, 28),
      );
    });
  });

  group('completion rate', () {
    final range = rangeFor(InsightsRange.week, today);

    test('done ÷ due in the range', () {
      final rate = completionRate([
        task(due: DateTime(2026, 11, 12), doneAt: DateTime(2026, 11, 12)),
        task(due: DateTime(2026, 11, 13), doneAt: DateTime(2026, 11, 20)),
        task(due: DateTime(2026, 11, 14)),
        task(due: DateTime(2026, 11, 15)),
        // Outside the range.
        task(due: DateTime(2026, 11, 3), doneAt: DateTime(2026, 11, 3)),
        task(doneAt: DateTime(2026, 11, 12)),
      ], range);
      expect(rate, 0.5);
    });

    test('nothing due: none', () {
      expect(completionRate(const [], range), isNull);
    });

    test('the change in points', () {
      expect(changeInPoints(0.78, 0.72), 6);
      expect(changeInPoints(0.5, null), isNull);
    });
  });

  test('completions per day, and the best day (latest on a tie)', () {
    final range = rangeFor(InsightsRange.week, today);
    final perDay = completionsPerDay([
      task(doneAt: DateTime(2026, 11, 12, 9)),
      task(doneAt: DateTime(2026, 11, 12, 15)),
      task(doneAt: DateTime(2026, 11, 16, 9)),
      task(doneAt: DateTime(2026, 11, 16, 10)),
      task(doneAt: DateTime(2026, 11)),
      task(),
    ], range);
    expect(perDay, [0, 2, 0, 0, 0, 2, 0]);
    expect(bestIndex(perDay), 5);
    expect(bestIndex([0, 0]), isNull);
  });

  test('focus minutes per day count focus of a minute or more', () {
    FocusSession session(
      DateTime at,
      int sec, {
      FocusKind kind = FocusKind.focus,
    }) => FocusSession(
      id: id++,
      kind: kind,
      plannedSec: 1500,
      startedAt: at.toUtc(),
      elapsedSec: sec,
    );
    final minutes = focusMinutesPerDay([
      session(DateTime(2026, 11, 17, 9), 1500),
      session(DateTime(2026, 11, 17, 10), 1500),
      session(DateTime(2026, 11, 17, 11), 59),
      session(DateTime(2026, 11, 17, 12), 300, kind: FocusKind.short),
      session(DateTime(2026, 11, 16, 9), 900),
    ], rangeFor(InsightsRange.week, today));
    expect(minutes, [0, 0, 0, 0, 0, 15, 50]);
  });

  test('the 6-week trend on the week start, with its change', () {
    final trend = weeklyTrend(
      [
        // Five weeks ago: 1 of 2 done.
        task(due: DateTime(2026, 10, 13), doneAt: DateTime(2026, 10, 13)),
        task(due: DateTime(2026, 10, 14)),
        // This week, up to today: 1 of 1; Thursday's isn't due yet.
        task(due: DateTime(2026, 11, 16), doneAt: DateTime(2026, 11, 16)),
        task(due: DateTime(2026, 11, 19)),
      ],
      today: today,
      weekStart: WeekStart.mon,
    );
    expect(trend, hasLength(6));
    expect(trend.first.start, DateTime(2026, 10, 12));
    expect(trend.last.start, DateTime(2026, 11, 16));
    expect(trend.first.rate, 0.5);
    expect(trend.last.rate, 1);
    expect(trendChange(trend), 50);
  });

  group('power day', () {
    test('the weekday with most completions over 4 full weeks', () {
      final day = powerDay(
        [
          // Thursdays 22 Oct and 29 Oct and 12 Nov, mostly mornings.
          task(doneAt: DateTime(2026, 10, 22, 9)),
          task(doneAt: DateTime(2026, 10, 29, 10)),
          task(doneAt: DateTime(2026, 11, 12, 15)),
          task(doneAt: DateTime(2026, 11, 12, 8)),
          // A Monday.
          task(doneAt: DateTime(2026, 11, 9, 9)),
          // This week and older than 4 weeks: not counted.
          task(doneAt: DateTime(2026, 11, 16, 9)),
          task(doneAt: DateTime(2026, 10, 15, 9)),
        ],
        today: today,
        weekStart: WeekStart.mon,
      )!;
      expect(day.weekday, DateTime.thursday);
      expect(day.average, 1);
      expect(day.beforeNoon, isTrue);
    });

    test('afternoons, and none with nothing done', () {
      final day = powerDay(
        [
          task(doneAt: DateTime(2026, 11, 10, 15)),
          task(doneAt: DateTime(2026, 11, 10, 16)),
        ],
        today: today,
        weekStart: WeekStart.mon,
      )!;
      expect(day.beforeNoon, isFalse);
      expect(
        powerDay(const [], today: today, weekStart: WeekStart.mon),
        isNull,
      );
    });
  });

  test('enough history means 3 days since the first task', () {
    expect(enoughHistory(const [], today), isFalse);
    expect(
      enoughHistory([task(created: DateTime(2026, 11, 16))], today),
      isFalse,
    );
    expect(
      enoughHistory([task(created: DateTime(2026, 11, 15))], today),
      isTrue,
    );
  });
}
