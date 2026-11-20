import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/app_stepper.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The rule picked on S15; a null `rule` is Never.
typedef RepeatPick = ({RepeatRule? rule});

/// The week's days from [weekStart], as `DateTime.weekday` values.
List<int> weekOrder(WeekStart weekStart) {
  final first = switch (weekStart) {
    WeekStart.mon => DateTime.monday,
    WeekStart.sun => DateTime.sunday,
    WeekStart.sat => DateTime.saturday,
  };
  return [for (var i = 0; i < 7; i++) (first - 1 + i) % 7 + 1];
}

/// A rule read back (S15): "Every Tue, Thu" for a row, or with [button]
/// "Repeat every Tue, Thu". Null [rule] reads "Never" / "Don't repeat".
String repeatSummary(
  AppLocalizations l10n,
  DateLabels labels,
  RepeatRule? rule, {
  required WeekStart weekStart,
  bool button = false,
}) {
  String dayNames(Set<int> set) => [
    for (final d in weekOrder(weekStart))
      if (set.contains(d)) labels.weekdayOf(d),
  ].join(', ');
  final text = switch (rule) {
    null => button ? l10n.repeatButtonNever : l10n.repeatNever,
    DailyRepeat() => button ? l10n.repeatButtonDaily : l10n.repeatDaily,
    WeekdaysRepeat() =>
      button ? l10n.repeatButtonWeekdays : l10n.summaryWeekdays,
    WeeklyRepeat(:final days) =>
      button
          ? l10n.repeatButtonWeekly(dayNames(days))
          : l10n.summaryWeekly(dayNames(days)),
    MonthlyRepeat(:final dayOfMonth) =>
      button
          ? l10n.repeatButtonMonthly(l10n.ordinalDay('$dayOfMonth'))
          : l10n.summaryMonthly(l10n.ordinalDay('$dayOfMonth')),
    CustomRepeat(:final interval, :final unit) => switch (unit) {
      RepeatUnit.day =>
        button
            ? l10n.repeatButtonDays(interval)
            : l10n.summaryEveryDays(interval),
      RepeatUnit.week =>
        button
            ? l10n.repeatButtonWeeks(interval)
            : l10n.summaryEveryWeeks(interval),
      RepeatUnit.month =>
        button
            ? l10n.repeatButtonMonths(interval)
            : l10n.summaryEveryMonths(interval),
    },
  };
  return switch (rule?.endsOn) {
    final end? => l10n.summaryUntil(text, labels.dayMonth(end)),
    null => text,
  };
}

/// Opens S15 for [rule], with [dueDate] (today when null) setting the
/// weekly and monthly defaults. Resolves to the pick, or null if closed.
Future<RepeatPick?> showRepeatSheet(
  BuildContext context, {
  required RepeatRule? rule,
  required DateTime? dueDate,
}) => showAppSheet<RepeatPick>(
  context,
  title: context.l10n.repeatTitle,
  builder: (_) => RepeatSheet(rule: rule, dueDate: dueDate),
);

enum _Kind { never, daily, weekdays, weekly, monthly, custom }

/// S15 Repeat (PRD §5.5, §6.4).
class RepeatSheet extends ConsumerStatefulWidget {
  const new({required this.rule, required this.dueDate, super.key});

  final RepeatRule? rule;
  final DateTime? dueDate;

  @override
  ConsumerState<RepeatSheet> createState() => _RepeatSheetState();
}

class _RepeatSheetState extends ConsumerState<RepeatSheet> {
  late final DateTime _anchor = () {
    final now = ref.read(clockProvider)();
    return widget.dueDate ?? DateTime(now.year, now.month, now.day);
  }();

  late _Kind _kind = switch (widget.rule) {
    null => _Kind.never,
    DailyRepeat() => _Kind.daily,
    WeekdaysRepeat() => _Kind.weekdays,
    WeeklyRepeat() => _Kind.weekly,
    MonthlyRepeat() => _Kind.monthly,
    CustomRepeat() => _Kind.custom,
  };
  late Set<int> _days = switch (widget.rule) {
    WeeklyRepeat(:final days) => {...days},
    _ => {_anchor.weekday},
  };
  late int _interval = switch (widget.rule) {
    CustomRepeat(:final interval) => interval,
    _ => 2,
  };
  late RepeatUnit _unit = switch (widget.rule) {
    CustomRepeat(:final unit) => unit,
    _ => RepeatUnit.week,
  };
  late DateTime? _endsOn = widget.rule?.endsOn;

  /// The rule as picked; null for Never, or Every week with no days.
  RepeatRule? get _rule => switch (_kind) {
    _Kind.never => null,
    _Kind.daily => RepeatRule.daily(endsOn: _endsOn),
    _Kind.weekdays => RepeatRule.weekdays(endsOn: _endsOn),
    _Kind.weekly when _days.isEmpty => null,
    _Kind.weekly => RepeatRule.weekly({..._days}, endsOn: _endsOn),
    _Kind.monthly => RepeatRule.monthly(_anchor.day, endsOn: _endsOn),
    _Kind.custom => RepeatRule.custom(
      _interval,
      _unit,
      dayOfMonth: _unit == RepeatUnit.month ? _anchor.day : null,
      endsOn: _endsOn,
    ),
  };

  Future<void> _pickEnd() async {
    final choice = await showDueDatePicker(
      context,
      date: _endsOn ?? _anchor,
      showTime: false,
      title: context.l10n.ends,
    );
    if (choice != null) setState(() => _endsOn = choice.date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final weekStart =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    final rule = _rule;
    final valid = _kind != _Kind.weekly || _days.isNotEmpty;

    Widget option(_Kind kind, String title, [String? detail]) => Semantics(
      selected: _kind == kind,
      button: true,
      child: InkWell(
        onTap: () => setState(() => _kind = kind),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.rowTitle.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (detail != null)
                      Text(
                        detail,
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                  ],
                ),
              ),
              AppRadio(selected: _kind == kind),
            ],
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListGroup(
            inSheet: true,
            children: [
              option(_Kind.never, l10n.repeatNever),
              option(_Kind.daily, l10n.repeatDaily),
              option(
                _Kind.weekdays,
                l10n.repeatWeekdays,
                l10n.repeatWeekdaysDetail,
              ),
              option(_Kind.weekly, l10n.repeatWeekly, l10n.repeatWeeklyDetail),
              option(
                _Kind.monthly,
                l10n.repeatMonthly,
                l10n.repeatMonthlyDetail(l10n.ordinalDay('${_anchor.day}')),
              ),
              option(_Kind.custom, l10n.repeatCustom, l10n.repeatCustomDetail),
            ],
          ),
          if (_kind == _Kind.weekly) ...[
            SectionHeader(l10n.onTheseDays),
            Row(
              children: [
                for (final day in weekOrder(weekStart))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _DayToggle(
                        label: labels.weekdayNarrow(day),
                        semanticLabel: labels.weekdayOf(day),
                        on: _days.contains(day),
                        onTap: () => setState(
                          () => _days = _days.contains(day)
                              ? ({..._days}..remove(day))
                              : {..._days, day},
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (_kind == _Kind.custom) ...[
            const SizedBox(height: 16),
            ListGroup(
              inSheet: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.every,
                          style: text.rowTitle.copyWith(color: colors.ink),
                        ),
                      ),
                      AppStepper(
                        value: '$_interval',
                        semanticLabel: l10n.every,
                        decreasedValue: _interval > 1
                            ? '${_interval - 1}'
                            : null,
                        increasedValue: _interval < 12
                            ? '${_interval + 1}'
                            : null,
                        onDecrement: _interval > 1
                            ? () => setState(() => _interval--)
                            : null,
                        onIncrement: _interval < 12
                            ? () => setState(() => _interval++)
                            : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final (unit, label) in <(RepeatUnit, String)>[
                        (RepeatUnit.day, l10n.repeatUnitDays),
                        (RepeatUnit.week, l10n.repeatUnitWeeks),
                        (RepeatUnit.month, l10n.repeatUnitMonths),
                      ])
                        AppChip(
                          label: label,
                          small: true,
                          selected: _unit == unit,
                          onTap: () => setState(() => _unit = unit),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (_kind != _Kind.never) ...[
            const SizedBox(height: 16),
            ListGroup(
              inSheet: true,
              children: [
                ListGroupRow(
                  title: l10n.ends,
                  value: switch (_endsOn) {
                    final d? => labels.dateYear(d),
                    null => l10n.repeatNever,
                  },
                  valueEmphasis: _endsOn != null,
                  trailing: _endsOn == null
                      ? null
                      : IconButton(
                          tooltip: l10n.removeEndDate,
                          onPressed: () => setState(() => _endsOn = null),
                          icon: AppIconView(
                            AppIcon.close,
                            size: 18,
                            color: colors.muted,
                          ),
                        ),
                  onTap: () => unawaited(_pickEnd()),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            label: repeatSummary(
              l10n,
              labels,
              rule,
              weekStart: weekStart,
              button: true,
            ),
            onPressed: valid
                ? () => Navigator.of(context).pop((rule: rule))
                : null,
          ),
        ],
      ),
    );
  }
}

/// One of S15's seven day toggles.
class _DayToggle extends StatelessWidget {
  const new({
    required this.label,
    required this.semanticLabel,
    required this.on,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      button: true,
      toggled: on,
      excludeSemantics: true,
      child: Material(
        color: on ? colors.ink : colors.fillSoft,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                style: context.text.chip.copyWith(
                  color: on ? colors.onInk : colors.chipText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
