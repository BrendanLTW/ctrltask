import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Quiet hours as minutes after midnight; equal ends mean off.
typedef QuietHours = ({int start, int end});

/// A time wheel in 5-minute steps, in the app's theme.
class TimeWheel extends StatelessWidget {
  const new({required this.minute, required this.onChanged, super.key});

  final int minute;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // The wheel only takes 5-minute steps.
    final start = minute - minute % 5;
    return SizedBox(
      height: 200,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: context.text.header.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          key: ValueKey(start),
          mode: CupertinoDatePickerMode.time,
          minuteInterval: 5,
          initialDateTime: DateTime(2000, 1, 1, start ~/ 60, start % 60),
          onDateTimeChanged: (t) => onChanged(t.hour * 60 + t.minute),
        ),
      ),
    );
  }
}

/// S39's Daily plan at: a time wheel. Resolves to the minute, or null.
Future<int?> showTimeSheet(
  BuildContext context, {
  required String title,
  required int minute,
}) => showAppSheet<int>(
  context,
  title: title,
  builder: (context) => _TimeSheet(minute: minute),
);

class _TimeSheet extends StatefulWidget {
  const new({required this.minute});

  final int minute;

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late int _minute = widget.minute;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TimeWheel(minute: _minute, onChanged: (m) => _minute = m),
      const SizedBox(height: 16),
      PrimaryButton(
        label: context.l10n.done,
        onPressed: () => Navigator.of(context).pop(_minute),
      ),
    ],
  );
}

/// S39's Default task reminder: the S16 options. Resolves to the choice.
Future<ReminderOffset?> showDefaultReminderSheet(
  BuildContext context, {
  required ReminderOffset offset,
}) => showAppSheet<ReminderOffset>(
  context,
  title: context.l10n.defaultTaskReminder,
  builder: (context) => _DefaultReminderSheet(offset: offset),
);

class _DefaultReminderSheet extends StatefulWidget {
  const new({required this.offset});

  final ReminderOffset offset;

  @override
  State<_DefaultReminderSheet> createState() => _DefaultReminderSheetState();
}

class _DefaultReminderSheetState extends State<_DefaultReminderSheet> {
  late ReminderOffset _offset = widget.offset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListGroup(
            inSheet: true,
            children: [
              for (final offset in ReminderOffset.values)
                Semantics(
                  selected: _offset == offset,
                  button: true,
                  child: InkWell(
                    onTap: () => setState(() => _offset = offset),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.reminderOption(offset.name),
                              style: context.text.rowTitle.copyWith(
                                color: context.colors.ink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          AppRadio(selected: _offset == offset),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.done,
            onPressed: () => Navigator.of(context).pop(_offset),
          ),
        ],
      ),
    );
  }
}

/// S39's Quiet hours: on or off, and From / To wheels. Resolves to the
/// hours (equal ends for off), or null if closed.
Future<QuietHours?> showQuietHoursSheet(
  BuildContext context, {
  required QuietHours hours,
}) => showAppSheet<QuietHours>(
  context,
  title: context.l10n.quietHours,
  builder: (context) => _QuietHoursSheet(hours: hours),
);

enum _End { from, to }

class _QuietHoursSheet extends StatefulWidget {
  const new({required this.hours});

  final QuietHours hours;

  @override
  State<_QuietHoursSheet> createState() => _QuietHoursSheetState();
}

class _QuietHoursSheetState extends State<_QuietHoursSheet> {
  late bool _on = widget.hours.start != widget.hours.end;
  // Off keeps no times; turning on starts from 11 PM – 7 AM.
  late int _start = _on ? widget.hours.start : 23 * 60;
  late int _end = _on ? widget.hours.end : 7 * 60;
  _End _editing = _End.from;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListGroup(
          inSheet: true,
          children: [
            ListGroupToggleRow(
              title: l10n.quietHours,
              value: _on,
              onChanged: (v) => setState(() => _on = v),
            ),
          ],
        ),
        if (_on) ...[
          const SizedBox(height: 16),
          SegmentedControl<_End>(
            inSheet: true,
            segments: [
              (value: _End.from, label: l10n.quietFrom, icon: null),
              (value: _End.to, label: l10n.quietTo, icon: null),
            ],
            selected: _editing,
            onChanged: (end) => setState(() => _editing = end),
          ),
          const SizedBox(height: 8),
          TimeWheel(
            key: ValueKey(_editing),
            minute: _editing == _End.from ? _start : _end,
            onChanged: (m) => _editing == _End.from ? _start = m : _end = m,
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: l10n.done,
          onPressed: () => Navigator.of(context).pop(
            // Off, or a span that's empty, is stored as equal ends.
            _on && _start != _end
                ? (start: _start, end: _end)
                : (start: 0, end: 0),
          ),
        ),
      ],
    );
  }
}
