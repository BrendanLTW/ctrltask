/// The user's first day of the week (S37), as stored in preferences.
enum WeekStart {
  mon(DateTime.monday),
  sun(DateTime.sunday),
  sat(DateTime.saturday);

  new(this.weekday);

  /// The `DateTime.weekday` value of the first day.
  final int weekday;
}

/// The week containing [date]: local midnight of its first day and the date
/// of its last day. The one place week bounds are computed (CLAUDE.md).
({DateTime start, DateTime end}) weekOf(DateTime date, WeekStart weekStart) {
  final offset = (date.weekday - weekStart.weekday) % 7;
  // Day arithmetic through the constructor, so a DST change can't shift it.
  return (
    start: DateTime(date.year, date.month, date.day - offset),
    end: DateTime(date.year, date.month, date.day - offset + 6),
  );
}
