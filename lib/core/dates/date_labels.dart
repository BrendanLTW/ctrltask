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
      _weekday = DateFormat('EEE', locale),
      _time = DateFormat('h:mm a', locale),
      _hour = DateFormat('h a', locale);

  final DateFormat _date;
  final DateFormat _dateLong;
  final DateFormat _weekday;
  final DateFormat _time;
  final DateFormat _hour;

  /// "Tue, 17 Nov".
  String date(DateTime date) => _date.format(date);

  /// "Tue, 17 November", the Home header.
  String dateLong(DateTime date) => _dateLong.format(date);

  /// "Mon".
  String weekday(DateTime date) => _weekday.format(date);

  /// "10:00 AM" for a time stored as minutes after midnight (0–1439).
  String time(int minute) {
    assert(minute >= 0 && minute < 24 * 60, 'minute out of range: $minute');
    return _time.format(DateTime(2000, 1, 1, minute ~/ 60, minute % 60));
  }

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
