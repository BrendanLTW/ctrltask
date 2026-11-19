import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The day each S12 quick chip moves a task to: today, tomorrow, or the
/// first day of next week on the user's week start.
DateTime quickDue(String chip, DateTime today, WeekStart weekStart) {
  final day = DateTime(today.year, today.month, today.day);
  return switch (chip) {
    'today' => day,
    'tomorrow' => DateTime(day.year, day.month, day.day + 1),
    _ => () {
      final end = weekOf(day, weekStart).end;
      return DateTime(end.year, end.month, end.day + 1);
    }(),
  };
}

/// S12's Due: the date and time, and chips that move it in one tap,
/// keeping the time (PRD §5.4).
class DueSection extends StatelessWidget {
  const new({
    required this.dueDate,
    required this.dueMinute,
    required this.today,
    required this.weekStart,
    required this.labels,
    required this.onMove,
    super.key,
  });

  final DateTime? dueDate;
  final int? dueMinute;
  final DateTime today;
  final WeekStart weekStart;
  final DateLabels labels;
  final ValueChanged<DateTime> onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final when = switch ((dueDate, dueMinute)) {
      (null, _) => l10n.noDate,
      (final date?, null) => labels.date(date),
      (final date?, final minute?) => l10n.titleWithDetail(
        labels.date(date),
        labels.time(minute),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          dueDate == null ? when.toUpperCase() : l10n.dueOn(when.toUpperCase()),
        ),
        // shortcut: the Pick chip that opens S14 comes with 2.9.
        Wrap(
          spacing: 8,
          children: [
            for (final (key, label) in [
              ('today', l10n.whenToday),
              ('tomorrow', l10n.whenTomorrow),
              ('nextWeek', l10n.whenNextWeek),
            ])
              AppChip(
                label: label,
                onTap: () => onMove(quickDue(key, today, weekStart)),
              ),
          ],
        ),
      ],
    );
  }
}
