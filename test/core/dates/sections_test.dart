import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tue 17 Nov 2026, 9:41 AM, the canvas's "now".
  final now = DateTime(2026, 11, 17, 9, 41);

  TaskSection section(DateTime? due, {WeekStart start = WeekStart.mon}) =>
      sectionFor(dueDate: due, today: now, weekStart: start);

  group('sectionFor', () {
    test('every section, Monday weeks', () {
      expect(section(null), TaskSection.noDate);
      expect(section(DateTime(2026, 11, 16)), TaskSection.overdue);
      expect(section(DateTime(2026, 10)), TaskSection.overdue);
      expect(section(DateTime(2026, 11, 17)), TaskSection.today);
      expect(section(DateTime(2026, 11, 18)), TaskSection.tomorrow);
      expect(section(DateTime(2026, 11, 19)), TaskSection.thisWeek);
      expect(section(DateTime(2026, 11, 22)), TaskSection.thisWeek);
      expect(section(DateTime(2026, 11, 23)), TaskSection.later);
    });

    test('a passed time today stays in Today', () {
      expect(
        sectionFor(
          dueDate: DateTime(2026, 11, 17, 7),
          today: DateTime(2026, 11, 17, 23),
          weekStart: WeekStart.mon,
        ),
        TaskSection.today,
      );
    });

    test('the week end follows the week start', () {
      // Sat 21 Nov: the last day of a Sunday week, the first of a Saturday
      // week.
      final sat = DateTime(2026, 11, 21);
      expect(section(sat), TaskSection.thisWeek);
      expect(section(sat, start: WeekStart.sun), TaskSection.thisWeek);
      expect(section(sat, start: WeekStart.sat), TaskSection.later);
      // Sun 22 Nov ends a Monday week only.
      final sun = DateTime(2026, 11, 22);
      expect(section(sun, start: WeekStart.sun), TaskSection.later);
    });

    test('on the last day of the week, tomorrow is still Tomorrow', () {
      final lastDay = DateTime(2026, 11, 22);
      TaskSection from(DateTime due) =>
          sectionFor(dueDate: due, today: lastDay, weekStart: WeekStart.mon);
      expect(from(DateTime(2026, 11, 23)), TaskSection.tomorrow);
      expect(from(DateTime(2026, 11, 24)), TaskSection.later);
    });

    test('crosses a year end', () {
      final dec30 = DateTime(2026, 12, 30);
      TaskSection from(DateTime due) =>
          sectionFor(dueDate: due, today: dec30, weekStart: WeekStart.mon);
      expect(from(DateTime(2026, 12, 31)), TaskSection.tomorrow);
      expect(from(DateTime(2027, 1, 3)), TaskSection.thisWeek);
      expect(from(DateTime(2027, 1, 4)), TaskSection.later);
      expect(from(DateTime(2026, 12, 29)), TaskSection.overdue);
    });
  });

  group('isOverdue', () {
    bool overdue(DateTime? due, [int? minute]) =>
        isOverdue(dueDate: due, dueMinute: minute, now: now);

    test('no date is never overdue', () {
      expect(overdue(null), isFalse);
    });

    test('earlier days are overdue, with or without a time', () {
      expect(overdue(DateTime(2026, 11, 16)), isTrue);
      expect(overdue(DateTime(2026, 11, 16), 23 * 60), isTrue);
    });

    test('today without a time is not overdue', () {
      expect(overdue(DateTime(2026, 11, 17)), isFalse);
    });

    test('today becomes overdue the minute after its time', () {
      final today = DateTime(2026, 11, 17);
      expect(overdue(today, 9 * 60), isTrue);
      expect(overdue(today, 9 * 60 + 40), isTrue);
      expect(overdue(today, 9 * 60 + 41), isFalse, reason: 'the due minute');
      expect(overdue(today, 10 * 60), isFalse);
    });

    test('future days are not overdue', () {
      expect(overdue(DateTime(2026, 11, 18), 0), isFalse);
    });
  });
}
