import 'dart:math' as math;

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';

/// The S34 range segments.
enum InsightRange { last7Days, thisMonth }

/// Local calendar dates at midnight, both inclusive.
typedef DateRange = ({DateTime start, DateTime end});

/// [range] ending on [today]: the last 7 days, or this month so far.
DateRange rangeFor(InsightRange range, DateTime today) {
  final day = _day(today);
  return switch (range) {
    InsightRange.last7Days => (start: _addDays(day, -6), end: day),
    InsightRange.thisMonth => (start: DateTime(day.year, day.month), end: day),
  };
}

/// The range [range] is compared with: the 7 days before, or last month up
/// to the same day (clamped, so 31 Mar compares with 28 Feb).
DateRange previousRange(InsightRange range, DateTime today) {
  final day = _day(today);
  return switch (range) {
    InsightRange.last7Days => (
      start: _addDays(day, -13),
      end: _addDays(day, -7),
    ),
    InsightRange.thisMonth => (
      start: DateTime(day.year, day.month - 1),
      end: DateTime(
        day.year,
        day.month - 1,
        math.min(day.day, DateTime(day.year, day.month, 0).day),
      ),
    ),
  };
}

/// Of the tasks due in [range], the share that are done, whenever they
/// were ticked: 0–1. Null when nothing was due.
double? completionRate(Iterable<Task> tasks, DateRange range) {
  final due = [
    for (final t in tasks)
      if (t.dueDate case final d? when _inRange(d, range)) t,
  ];
  if (due.isEmpty) return null;
  return due.where((t) => t.status == TaskStatus.done).length / due.length;
}

/// The rate for [range] minus the previous range's, in whole points
/// ("+6 pts"). Null when either has no rate.
int? rateChange(Iterable<Task> tasks, InsightRange range, DateTime today) {
  final now = completionRate(tasks, rangeFor(range, today));
  final before = completionRate(tasks, previousRange(range, today));
  return now == null || before == null ? null : _points(now - before);
}

/// Completions on each day of [range], in order.
List<({DateTime day, int count})> completionsPerDay(
  Iterable<Task> tasks,
  DateRange range,
) {
  final counts = <DateTime, int>{};
  for (final t in tasks) {
    if (t.status != TaskStatus.done || t.completedAt == null) continue;
    final day = _day(t.completedAt!.toLocal());
    counts[day] = (counts[day] ?? 0) + 1;
  }
  return [for (final day in _days(range)) (day: day, count: counts[day] ?? 0)];
}

/// Counted focus time (focus sessions of a minute or more, PRD §6.6) on
/// each day of [range], in seconds, by the day the session started.
List<({DateTime day, int seconds})> focusPerDay(
  Iterable<FocusSession> sessions,
  DateRange range,
) {
  final totals = <DateTime, int>{};
  for (final s in sessions) {
    if (s.kind != FocusKind.focus || !s.counts) continue;
    final day = _day(s.startedAt.toLocal());
    totals[day] = (totals[day] ?? 0) + s.elapsedSec;
  }
  return [
    for (final day in _days(range)) (day: day, seconds: totals[day] ?? 0),
  ];
}

/// The day with the most, earliest on a tie; null when every day is 0.
/// "Best: Thu, 6" (S34).
DateTime? bestDay(List<({DateTime day, int count})> perDay) {
  ({DateTime day, int count})? best;
  for (final entry in perDay) {
    if (entry.count > (best?.count ?? 0)) best = entry;
  }
  return best?.day;
}

/// The average per day across the whole range, in seconds.
int dailyAverageSeconds(List<({DateTime day, int seconds})> perDay) =>
    perDay.isEmpty
    ? 0
    : perDay.fold(0, (sum, e) => sum + e.seconds) ~/ perDay.length;

/// The completion rate of each of the last [weeks] weeks, oldest first,
/// ending with the current week. Null for weeks with nothing due.
List<double?> weeklyTrend(
  Iterable<Task> tasks,
  DateTime today,
  WeekStart weekStart, {
  int weeks = 6,
}) {
  final thisWeek = weekOf(today, weekStart);
  return [
    for (var i = weeks - 1; i >= 0; i--)
      completionRate(tasks, (
        start: _addDays(thisWeek.start, -7 * i),
        end: _addDays(thisWeek.end, -7 * i),
      )),
  ];
}

/// The last week's rate minus the first's, in points, using the first and
/// last weeks that have a rate. Null with fewer than two.
int? trendChange(List<double?> trend) {
  final rates = trend.whereType<double>().toList();
  return rates.length < 2 ? null : _points(rates.last - rates.first);
}

/// The weekday (1 = Monday) with the most completions on average over the
/// last 4 full weeks, before the current one. Ties go to the day earlier in
/// the user's week. Null when nothing was completed then.
({int weekday, double average, bool mostlyBeforeNoon})? powerDay(
  Iterable<Task> tasks,
  DateTime today,
  WeekStart weekStart,
) {
  final current = weekOf(today, weekStart);
  final window = (
    start: _addDays(current.start, -28),
    end: _addDays(current.start, -1),
  );
  final byDay = <int, List<DateTime>>{};
  for (final t in tasks) {
    if (t.status != TaskStatus.done || t.completedAt == null) continue;
    final at = t.completedAt!.toLocal();
    if (!_inRange(at, window)) continue;
    (byDay[at.weekday] ??= []).add(at);
  }
  int? best;
  for (var i = 0; i < 7; i++) {
    final weekday = (weekStart.weekday - 1 + i) % 7 + 1;
    if ((byDay[weekday]?.length ?? 0) > (byDay[best]?.length ?? 0)) {
      best = weekday;
    }
  }
  if (best == null) return null;
  final times = byDay[best]!;
  return (
    weekday: best,
    average: times.length / 4,
    mostlyBeforeNoon: times.where((t) => t.hour < 12).length * 2 > times.length,
  );
}

/// S34 charts need at least 3 days of history, counted from the first task
/// or focus session to [today].
bool hasEnoughHistory(
  Iterable<Task> tasks,
  Iterable<FocusSession> sessions,
  DateTime today,
) {
  final starts = [
    for (final t in tasks) t.createdAt.toLocal(),
    for (final s in sessions) s.startedAt.toLocal(),
  ];
  if (starts.isEmpty) return false;
  final first = starts.reduce((a, b) => a.isBefore(b) ? a : b);
  return DateLabels.daysBetween(first, today) + 1 >= 3;
}

int _points(double difference) => (difference * 100).round();

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

// Day arithmetic through the constructor, so a DST change can't shift it.
DateTime _addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

bool _inRange(DateTime date, DateRange range) {
  final day = _day(date);
  return !day.isBefore(range.start) && !day.isAfter(range.end);
}

Iterable<DateTime> _days(DateRange range) sync* {
  for (var d = range.start; !d.isAfter(range.end); d = _addDays(d, 1)) {
    yield d;
  }
}
