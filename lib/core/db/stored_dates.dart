/// Calendar dates (a due date, a deadline, a repeat end) are stored
/// as UTC midnight, so a time zone change can't move them,
/// and used as local midnight.
DateTime storedDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

DateTime localDate(DateTime stored) {
  final utc = stored.toUtc();
  return DateTime(utc.year, utc.month, utc.day);
}
