import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/l10n/app_localizations.dart';

/// Date labels with their words, built from [DateLabels] and the ARB copy.
extension DateText on AppLocalizations {
  /// "Today", "Yesterday", "Tomorrow" or "Thu, 19 Nov", with ", 10:00 AM"
  /// when [minute] is set.
  String dayLabel(
    DateLabels labels,
    DateTime date, {
    required DateTime today,
    int? minute,
  }) {
    final day = switch (DateLabels.relativeDay(date, today)) {
      RelativeDay.yesterday => relativeYesterday,
      RelativeDay.today => relativeToday,
      RelativeDay.tomorrow => relativeTomorrow,
      RelativeDay.other => labels.date(date),
    };
    return minute == null ? day : dayWithTime(day, labels.time(minute));
  }

  /// "Overdue · Mon".
  String overdueLabel(DateLabels labels, DateTime due) =>
      overdueOn(labels.weekday(due));

  /// "13 days left" until [deadline], "Due today", or "Overdue" once it's
  /// passed.
  String daysLeftLabel(DateTime deadline, {required DateTime today}) =>
      switch (DateLabels.daysBetween(today, deadline)) {
        < 0 => deadlineOverdue,
        0 => deadlineToday,
        final days => daysLeft(days),
      };

  /// "1h 15m", "2h 05m", "2h" or "25m".
  String durationLabel(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return durationMinutes(minutes);
    if (minutes == 0) return durationHours(hours);
    return durationHoursMinutes(hours, '$minutes'.padLeft(2, '0'));
  }
}
