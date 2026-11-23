import 'package:intl/intl.dart';

enum RelativeDay { yesterday, today, tomorrow, other }

/// Date and time formats from PRD §6.2. Pure Dart: words such as "Today" or
/// "days left" live in the ARB file and are added by `DateText`. Needs
/// intl's locale data, which the app's localization delegates load; tests call
/// `initializeDateFormatting` first.
class DateLabels {
  new(String locale)
    : _date = DateFormat('EEE, d MMM', locale),
      _dateLong = DateFormat('EEE, d MMMM', locale),
      _dateYear = DateFormat('EEE, d MMM y', locale),
      _dayMonth = DateFormat('d MMM', locale),
      _weekday = DateFormat('EEE', locale),
      _weekdayLong = DateFormat('EEEE', locale),
      _weekdayNarrow = DateFormat('EEEEE', locale),
      _time = DateFormat('h:mm a', locale),
      _clock = DateFormat('h:mm', locale),
      _dayMonthShort = DateFormat('d', locale),
      _hour = DateFormat('h a', locale);

  final DateFormat _date;
  final DateFormat _dateLong;
  final DateFormat _dateYear;
  final DateFormat _dayMonth;
  final DateFormat _weekday;
  final DateFormat _weekdayLong;
  final DateFormat _weekdayNarrow;
  final DateFormat _time;
  final DateFormat _clock;
  final DateFormat _dayMonthShort;
  final DateFormat _hour;

  /// "Tue, 17 Nov".
  String date(DateTime date) => _date.format(date);

  /// "Tue, 17 November", the Home header.
  String dateLong(DateTime date) => _dateLong.format(date);

  /// "Fri, 5 Feb 2027", S28's deadline.
  String dateYear(DateTime date) => _dateYear.format(date);

  /// "2 Sep", S45's "finished" date.
  String dayMonth(DateTime date) => _dayMonth.format(date);

  /// "M" for a `DateTime.weekday` value (1 = Monday): S15's day toggles.
  String weekdayNarrow(int weekday) =>
      _weekdayNarrow.format(DateTime(2024, 1, weekday));

  /// "Mon" for a `DateTime.weekday` value; 1 Jan 2024 was a Monday.
  String weekdayOf(int weekday) => _weekday.format(DateTime(2024, 1, weekday));

  /// "Mon".
  String weekday(DateTime date) => _weekday.format(date);

  /// "Monday": S34's power day and chart text.
  String weekdayLong(DateTime date) => _weekdayLong.format(date);

  /// "10:00 AM" for a time stored as minutes after midnight (0–1439).
  String time(int minute) {
    assert(minute >= 0 && minute < 24 * 60, 'minute out of range: $minute');
    return _time.format(DateTime(2000, 1, 1, minute ~/ 60, minute % 60));
  }

  /// "10:00" without AM or PM: S22's block times.
  String clock(DateTime time) => _clock.format(time);

  /// "16 – 22 Nov", or "30 Nov – 6 Dec" across months: S22's week.
  String weekRange(DateTime start, DateTime end) => start.month == end.month
      ? '${_dayMonthShort.format(start)} – ${dayMonth(end)}'
      : '${dayMonth(start)} – ${dayMonth(end)}';

  /// "9 AM" on the hour, else as [time]: S10's "Tomorrow · 9 AM".
  String timeShort(int minute) => minute % 60 == 0
      ? _hour.format(DateTime(2000, 1, 1, minute ~/ 60))
      : time(minute);

  /// Whole calendar days from [from] to [to], ignoring the time of day.
  /// Counted in UTC so a daylight-saving change can't shift it by one.
  static int daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  static RelativeDay relativeDay(DateTime date, DateTime today) =>
      switch (daysBetween(today, date)) {
        -1 => RelativeDay.yesterday,
        0 => RelativeDay.today,
        1 => RelativeDay.tomorrow,
        _ => RelativeDay.other,
      };
}
