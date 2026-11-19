import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A status dot under a calendar day (S21 legend).
enum CalendarDot { pending, completed, overdue }

/// A month grid on the user's week start (DESIGN §7; S14, S21).
/// Controlled: the screen holds [month] and [selected]. Days from the
/// neighbouring months fill the first and last weeks, muted.
class MonthCalendar extends StatelessWidget {
  const new({
    required this.month,
    required this.today,
    required this.weekStart,
    required this.onSelected,
    required this.onMonthChanged,
    this.selected,
    this.dotsFor,
    super.key,
  });

  /// Any day in the month to show.
  final DateTime month;
  final DateTime today;
  final WeekStart weekStart;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  /// Called with the first day of the previous or next month.
  final ValueChanged<DateTime> onMonthChanged;

  /// Up to three status dots per day (S21). Overdue days also get a red
  /// number.
  final Set<CalendarDot> Function(DateTime day)? dotsFor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    final start = weekOf(first, weekStart).start;
    final weeks =
        (DateTime.utc(last.year, last.month, last.day)
                .difference(DateTime.utc(start.year, start.month, start.day))
                .inDays ~/
            7) +
        1;

    Widget navButton(AppIcon icon, String tooltip, int delta) => IconButton(
      onPressed: () =>
          onMonthChanged(DateTime(month.year, month.month + delta)),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: colors.raised,
        foregroundColor: colors.ink,
      ),
      icon: AppIconView(icon, size: 20, stroke: AppIconStroke.chevron),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.yMMMM(locale).format(first),
                style: text.header.copyWith(color: colors.ink),
              ),
            ),
            navButton(AppIcon.chevronLeft, l10n.previousMonth, -1),
            const SizedBox(width: 8),
            navButton(AppIcon.chevronRight, l10n.nextMonth, 1),
          ],
        ),
        const SizedBox(height: 14),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    DateFormat.EEEEE(
                      locale,
                    ).format(DateTime(start.year, start.month, start.day + i)),
                    textAlign: TextAlign.center,
                    style: text.tag.copyWith(color: colors.muted),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        for (var w = 0; w < weeks; w++)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: _Day(
                        date: DateTime(
                          start.year,
                          start.month,
                          start.day + w * 7 + d,
                        ),
                        calendar: this,
                        locale: locale,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _Day extends StatelessWidget {
  const new({required this.date, required this.calendar, required this.locale});

  final DateTime date;
  final MonthCalendar calendar;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.projectColors;
    final today = calendar.today;
    final isSelected =
        calendar.selected != null && _sameDay(date, calendar.selected!);
    final isToday = _sameDay(date, today);
    final inMonth = date.month == calendar.month.month;
    final dots = calendar.dotsFor?.call(date) ?? const <CalendarDot>{};
    final numberColor = isSelected
        ? colors.onInk
        : dots.contains(CalendarDot.overdue)
        ? colors.negative
        : colors.ink;
    final dotColors = {
      CalendarDot.pending: isSelected ? colors.onInk : colors.ink,
      CalendarDot.completed: palette.of(ProjectColorKey.green).solid,
      CalendarDot.overdue: palette.of(ProjectColorKey.red).solid,
    };
    return Semantics(
      button: true,
      selected: isSelected,
      label: DateFormat.yMMMMEEEEd(locale).format(date),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => calendar.onSelected(date),
        child: Opacity(
          opacity: inMonth || isSelected ? 1 : 0.55,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: isSelected ? colors.ink : null,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              border: isToday && !isSelected
                  ? Border.all(color: colors.control, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: context.text.body.copyWith(
                    color: inMonth || isSelected ? numberColor : colors.muted,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                if (dots.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final dot in CalendarDot.values)
                          if (dots.contains(dot))
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dotColors[dot],
                              ),
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
