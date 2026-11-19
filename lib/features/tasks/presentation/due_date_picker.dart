import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/month_calendar.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/quick_date_tiles.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A due date with its optional time, in minutes after midnight.
typedef DueChoice = ({DateTime date, int? minute});

/// Opens S14 Due date on [date] (today when null) and [minute]. Resolves
/// to the choice, or null if closed.
Future<DueChoice?> showDueDatePicker(
  BuildContext context, {
  DateTime? date,
  int? minute,
}) => showAppSheet<DueChoice>(
  context,
  title: context.l10n.dueDateTitle,
  builder: (_) => DueDatePicker(date: date, minute: minute),
);

/// S14's content (PRD §5.5): quick tiles, a month calendar on the user's
/// week start, time chips, and a button that reads the choice back.
class DueDatePicker extends ConsumerStatefulWidget {
  const new({this.date, this.minute, super.key});

  final DateTime? date;
  final int? minute;

  /// 9:00 AM, 12:00 PM, 3:00 PM and 6:00 PM.
  static const List<int> times = [9 * 60, 12 * 60, 15 * 60, 18 * 60];

  @override
  ConsumerState<DueDatePicker> createState() => _DueDatePickerState();
}

class _DueDatePickerState extends ConsumerState<DueDatePicker> {
  late final DateTime _today = () {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }();
  late DateTime _date = widget.date ?? _today;
  late int? _minute = widget.minute;
  late DateTime _month = DateTime(_date.year, _date.month);

  void _pick(DateTime date) => setState(() {
    _date = DateTime(date.year, date.month, date.day);
    _month = DateTime(date.year, date.month);
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final weekStart =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    DateTime plus(int days) =>
        DateTime(_today.year, _today.month, _today.day + days);
    final tiles = <QuickDate<DateTime>>[
      (value: _today, label: l10n.whenToday, detail: labels.weekday(_today)),
      (
        value: plus(1),
        label: l10n.whenTomorrow,
        detail: labels.weekday(plus(1)),
      ),
      for (final (label, date) in [
        (l10n.weekend, comingSaturday(_today)),
        (l10n.whenNextWeek, nextWeekStart(_today, weekStart)),
      ])
        (value: date, label: label, detail: labels.weekday(date)),
    ];
    // Keeps a time that isn't one of the chips, so it isn't lost.
    final times = {...DueDatePicker.times, ?widget.minute}.toList()..sort();
    final when = _minute == null
        ? labels.date(_date)
        : l10n.titleWithDetail(labels.date(_date), labels.time(_minute!));

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuickDateTiles<DateTime>(
            options: tiles,
            selected: tiles.any((t) => t.value == _date) ? _date : null,
            onChanged: _pick,
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: MonthCalendar(
              month: _month,
              today: _today,
              weekStart: weekStart,
              selected: _date,
              onSelected: _pick,
              onMonthChanged: (month) => setState(() => _month = month),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                ExcludeSemantics(
                  child: AppIconView(
                    AppIcon.clock,
                    size: 22,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(width: 12),
                for (final time in times) ...[
                  AppChip(
                    label: labels.time(time),
                    small: true,
                    selected: _minute == time,
                    onTap: () => setState(() => _minute = time),
                  ),
                  const SizedBox(width: 8),
                ],
                AppChip(
                  label: l10n.noTime,
                  small: true,
                  selected: _minute == null,
                  onTap: () => setState(() => _minute = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: l10n.setDue(when),
            onPressed: () =>
                Navigator.of(context).pop((date: _date, minute: _minute)),
          ),
        ],
      ),
    );
  }
}
