import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tue 17 Nov 2026, the canvas's "today".
  final tue = DateTime(2026, 11, 17, 9, 41);

  test('each week start, from a Tuesday', () {
    expect(weekOf(tue, WeekStart.mon), (
      start: DateTime(2026, 11, 16),
      end: DateTime(2026, 11, 22),
    ));
    expect(weekOf(tue, WeekStart.sun), (
      start: DateTime(2026, 11, 15),
      end: DateTime(2026, 11, 21),
    ));
    expect(weekOf(tue, WeekStart.sat), (
      start: DateTime(2026, 11, 14),
      end: DateTime(2026, 11, 20),
    ));
  });

  test('the first and last day belong to their own week', () {
    for (final start in WeekStart.values) {
      final week = weekOf(tue, start);
      expect(weekOf(week.start, start), week, reason: '${start.name} first');
      expect(weekOf(week.end, start), week, reason: '${start.name} last');
      expect(week.start.weekday, start.weekday);
    }
  });

  test('the start is local midnight, whatever the time of day', () {
    final week = weekOf(DateTime(2026, 11, 22, 23, 59), WeekStart.mon);
    expect(week.start, DateTime(2026, 11, 16));
  });

  test('crosses a month and a year end', () {
    expect(weekOf(DateTime(2026, 12), WeekStart.mon), (
      start: DateTime(2026, 11, 30),
      end: DateTime(2026, 12, 6),
    ));
    expect(weekOf(DateTime(2027), WeekStart.mon), (
      start: DateTime(2026, 12, 28),
      end: DateTime(2027, 1, 3),
    ));
    expect(weekOf(DateTime(2026, 12, 31), WeekStart.sun), (
      start: DateTime(2026, 12, 27),
      end: DateTime(2027, 1, 2),
    ));
  });

  test('daylight-saving weeks keep midnight bounds', () {
    // Europe changes clocks on 29 Mar and 25 Oct 2026, the US on 8 Mar
    // and 1 Nov. Run with TZ=Europe/London or America/New_York to check.
    for (final date in [
      DateTime(2026, 3, 31),
      DateTime(2026, 10, 27),
      DateTime(2026, 3, 10),
      DateTime(2026, 11, 3),
    ]) {
      final week = weekOf(date, WeekStart.mon);
      expect(week.start.hour, 0, reason: '$date');
      expect(week.end.hour, 0, reason: '$date');
      expect(DateLabels.daysBetween(week.start, week.end), 6, reason: '$date');
      expect(week.start.weekday, DateTime.monday, reason: '$date');
    }
  });

  test('the coming Saturday is never today', () {
    expect(comingSaturday(tue), DateTime(2026, 11, 21));
    expect(comingSaturday(DateTime(2026, 11, 21, 10)), DateTime(2026, 11, 28));
    expect(comingSaturday(DateTime(2026, 12, 27)), DateTime(2027, 1, 2));
  });

  test('next week starts on the week start setting', () {
    expect(nextWeekStart(tue, WeekStart.mon), DateTime(2026, 11, 23));
    expect(nextWeekStart(tue, WeekStart.sun), DateTime(2026, 11, 22));
    expect(nextWeekStart(tue, WeekStart.sat), DateTime(2026, 11, 21));
    // On the first day of a week it's still the week after.
    expect(
      nextWeekStart(DateTime(2026, 11, 16), WeekStart.mon),
      DateTime(2026, 11, 23),
    );
  });
}
