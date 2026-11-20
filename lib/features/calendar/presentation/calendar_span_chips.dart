import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S21's and S22's Day · Week · Month chips.
class CalendarSpanChips extends StatelessWidget {
  const new({required this.selected, required this.onChanged, super.key});

  final CalendarSpan selected;
  final ValueChanged<CalendarSpan> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (span, label) in [
          (CalendarSpan.day, l10n.calendarDay),
          (CalendarSpan.week, l10n.calendarWeek),
          (CalendarSpan.month, l10n.calendarMonth),
        ])
          AppChip(
            label: label,
            small: true,
            selected: span == selected,
            onTap: () => onChanged(span),
          ),
      ],
    );
  }
}
