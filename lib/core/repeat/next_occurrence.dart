import 'dart:math' as math;

import 'package:ctrltask/core/repeat/repeat_rule.dart';

/// The next due date after [dueDate] under [rule], as a local date at
/// midnight, or null when it would fall after the rule's end date.
/// Repeats advance from the due date, never the completion date (PRD §6.4).
DateTime? nextOccurrence(RepeatRule rule, DateTime dueDate) {
  final next = switch (rule) {
    DailyRepeat() => _addDays(dueDate, 1),
    WeekdaysRepeat() => _nextWeekday(dueDate, const {1, 2, 3, 4, 5}),
    WeeklyRepeat(:final days) => _nextWeekday(dueDate, days),
    MonthlyRepeat(:final dayOfMonth) => _monthly(dueDate, dayOfMonth),
    CustomRepeat(:final interval, unit: RepeatUnit.day) => _addDays(
      dueDate,
      interval,
    ),
    CustomRepeat(:final interval, unit: RepeatUnit.week) => _addDays(
      dueDate,
      7 * interval,
    ),
    CustomRepeat(:final interval, unit: RepeatUnit.month, :final dayOfMonth) =>
      _onDay(dueDate.year, dueDate.month + interval, dayOfMonth!),
  };
  final endsOn = rule.endsOn;
  return endsOn != null && next.isAfter(_addDays(endsOn, 0)) ? null : next;
}

// Day arithmetic through the constructor, so a DST change can't shift it.
DateTime _addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

DateTime _nextWeekday(DateTime dueDate, Set<int> weekdays) {
  for (var i = 1; i <= 7; i++) {
    final day = _addDays(dueDate, i);
    if (weekdays.contains(day.weekday)) return day;
  }
  throw StateError('no weekday in $weekdays');
}

DateTime _monthly(DateTime dueDate, int dayOfMonth) {
  final thisMonth = _onDay(dueDate.year, dueDate.month, dayOfMonth);
  return thisMonth.isAfter(_addDays(dueDate, 0))
      ? thisMonth
      : _onDay(dueDate.year, dueDate.month + 1, dayOfMonth);
}

/// [day] of the given month, or its last day if the month is shorter.
/// [month] may run past 12; it rolls into the next year.
DateTime _onDay(int year, int month, int day) {
  final first = DateTime(year, month);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, math.min(day, lastDay));
}
