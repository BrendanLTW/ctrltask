import 'dart:math' as math;

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';

/// S34's segments.
enum InsightsRange { week, month }

/// Local days from `start` to `end`, both included.
typedef DayRange = ({DateTime start, DateTime end});

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

bool _inRange(DateTime day, DayRange r) =>
    !day.isBefore(r.start) && !day.isAfter(r.end);

/// Last 7 days (today and the six before), or this month to today.
DayRange rangeFor(InsightsRange range, DateTime today) => switch (range) {
  InsightsRange.week => (
    start: DateTime(today.year, today.month, today.day - 6),
    end: today,
  ),
  InsightsRange.month => (start: DateTime(today.year, today.month), end: today),
};

/// The range S34 compares with: the 7 days before, or the same days of
/// last month (1–17 Oct for 1–17 Nov), cut to that month's length.
DayRange previousRange(InsightsRange range, DateTime today) {
  final current = rangeFor(range, today);
  return switch (range) {
    InsightsRange.week => (
      start: DateTime(today.year, today.month, today.day - 13),
      end: DateTime(today.year, today.month, today.day - 7),
    ),
    InsightsRange.month => (
      start: DateTime(today.year, today.month - 1),
      end: DateTime(
        today.year,
        today.month - 1,
        math.min(current.end.day, DateTime(today.year, today.month, 0).day),
      ),
    ),
  };
}

/// Each day of [range].
List<DateTime> daysOf(DayRange range) => [
  for (
    var d = range.start;
    !d.isAfter(range.end);
    d = DateTime(d.year, d.month, d.day + 1)
  )
    d,
];

/// Completion rate (PRD §8): of the tasks due in [range], the share done.
/// Null when nothing was due.
double? completionRate(Iterable<Task> tasks, DayRange range) {
  final due = [
    for (final t in tasks)
      if (t.dueDate case final d? when _inRange(d, range)) t,
  ];
  if (due.isEmpty) return null;
  return due.where((t) => t.status == TaskStatus.done).length / due.length;
}

/// The change between two rates, in whole points; null without both.
int? changeInPoints(double? rate, double? previous) =>
    rate == null || previous == null ? null : ((rate - previous) * 100).round();

/// The local day [task] was completed, or null if it's open.
DateTime? completedDay(Task task) => task.status == TaskStatus.done
    ? switch (task.completedAt) {
        final at? => _day(at.toLocal()),
        null => null,
      }
    : null;

/// Tasks completed on each day of [range].
List<int> completionsPerDay(Iterable<Task> tasks, DayRange range) {
  final counts = <DateTime, int>{};
  for (final t in tasks) {
    if (completedDay(t) case final d? when _inRange(d, range)) {
      counts[d] = (counts[d] ?? 0) + 1;
    }
  }
  return [for (final d in daysOf(range)) counts[d] ?? 0];
}

/// Minutes focused on each day of [range], counting only sessions of a
/// minute or more (§6.6), by the day they started.
List<int> focusMinutesPerDay(Iterable<FocusSession> sessions, DayRange range) {
  final seconds = <DateTime, int>{};
  for (final s in sessions) {
    if (s.kind != FocusKind.focus || !s.counts) continue;
    final d = _day(s.startedAt.toLocal());
    if (_inRange(d, range)) seconds[d] = (seconds[d] ?? 0) + s.elapsedSec;
  }
  return [for (final d in daysOf(range)) (seconds[d] ?? 0) ~/ 60];
}

/// The day with the most, latest first on a tie; null when all are 0.
int? bestIndex(List<int> values) {
  var best = -1;
  for (final (i, v) in values.indexed) {
    if (v > 0 && (best == -1 || v >= values[best])) best = i;
  }
  return best == -1 ? null : best;
}

/// A week on the 6-week trend: its first day and completion rate, counting
/// only what was due by the day the trend is drawn.
typedef TrendWeek = ({DateTime start, double? rate});

/// The last [weeks] weeks on [weekStart], oldest first, this week last.
List<TrendWeek> weeklyTrend(
  Iterable<Task> tasks, {
  required DateTime today,
  required WeekStart weekStart,
  int weeks = 6,
}) {
  final thisWeek = weekOf(today, weekStart).start;
  return [
    for (var i = weeks - 1; i >= 0; i--)
      () {
        final start = DateTime(
          thisWeek.year,
          thisWeek.month,
          thisWeek.day - 7 * i,
        );
        final end = DateTime(start.year, start.month, start.day + 6);
        return (
          start: start,
          rate: completionRate(tasks, (
            start: start,
            end: end.isAfter(today) ? today : end,
          )),
        );
      }(),
  ];
}

/// The trend's change: the latest rate less the earliest, in points.
int? trendChange(List<TrendWeek> trend) {
  final rates = [for (final w in trend) ?w.rate];
  return rates.length < 2 ? null : changeInPoints(rates.last, rates.first);
}

/// S34's power day (PRD §8): the weekday (1 = Monday) with the highest
/// average completions over the last 4 full weeks, and whether most of
/// them came before noon. Null with nothing completed then.
({int weekday, double average, bool beforeNoon})? powerDay(
  Iterable<Task> tasks, {
  required DateTime today,
  required WeekStart weekStart,
}) {
  final thisWeek = weekOf(today, weekStart).start;
  final range = (
    start: DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 28),
    end: DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 1),
  );
  final count = <int, int>{};
  final morning = <int, int>{};
  for (final t in tasks) {
    final day = completedDay(t);
    if (day == null || !_inRange(day, range)) continue;
    count[day.weekday] = (count[day.weekday] ?? 0) + 1;
    if (t.completedAt!.toLocal().hour < 12) {
      morning[day.weekday] = (morning[day.weekday] ?? 0) + 1;
    }
  }
  if (count.isEmpty) return null;
  final best = count.entries.reduce((a, b) => b.value > a.value ? b : a);
  return (
    weekday: best.key,
    average: best.value / 4,
    beforeNoon: (morning[best.key] ?? 0) * 2 > best.value,
  );
}

/// Whether there's enough history for charts (S34): 3 days or more since
/// the first task.
bool enoughHistory(Iterable<Task> tasks, DateTime today) {
  if (tasks.isEmpty) return false;
  final first = tasks
      .map((t) => _day(t.createdAt.toLocal()))
      .reduce((a, b) => a.isBefore(b) ? a : b);
  return DateLabels.daysBetween(first, today) + 1 >= 3;
}
