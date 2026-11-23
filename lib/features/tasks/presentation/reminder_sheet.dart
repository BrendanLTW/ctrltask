import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/notifications/domain/notification_plan.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Opens S16 Reminder for a task due on [dueDate] at [dueMinute].
/// Resolves to the choice, or null if closed.
Future<ReminderOffset?> showReminderSheet(
  BuildContext context, {
  required ReminderOffset offset,
  required DateTime? dueDate,
  required int? dueMinute,
}) => showAppSheet<ReminderOffset>(
  context,
  title: context.l10n.reminderTitle,
  builder: (_) =>
      ReminderSheet(offset: offset, dueDate: dueDate, dueMinute: dueMinute),
);

/// S16 Reminder (PRD §5.5): each option with the time it would fire. A
/// timed option needs a due time; Morning of and Day before only a date.
class ReminderSheet extends StatefulWidget {
  const new({
    required this.offset,
    required this.dueDate,
    required this.dueMinute,
    super.key,
  });

  final ReminderOffset offset;
  final DateTime? dueDate;
  final int? dueMinute;

  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  late ReminderOffset _offset = widget.offset;

  DateTime? _at(ReminderOffset offset) =>
      reminderAt(offset, dueDate: widget.dueDate, dueMinute: widget.dueMinute);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    int minuteOf(DateTime t) => t.hour * 60 + t.minute;
    bool onDueDay(DateTime at) =>
        DateTime(at.year, at.month, at.day) == widget.dueDate;

    /// "2:30 PM", or "Wed, 3:00 PM" on another day.
    String when(DateTime at) {
      final time = labels.time(minuteOf(at));
      return onDueDay(at) ? time : l10n.dayWithTime(labels.weekday(at), time);
    }

    final due = switch ((widget.dueDate, widget.dueMinute)) {
      (null, _) => null,
      (final d?, null) => labels.date(d),
      (final d?, final m?) => l10n.titleWithDetail(
        labels.date(d),
        labels.time(m),
      ),
    };
    final chosen = _at(_offset);
    final (note, bold) = switch ((due, chosen)) {
      (null, _) => (l10n.reminderNoteNoDate, null),
      (final d?, null) => (l10n.reminderNoteNone(d), null),
      (final d?, final at?) => () {
        final phrase = onDueDay(at)
            ? l10n.remindedAt(labels.time(minuteOf(at)))
            : l10n.remindedOn(labels.weekday(at), labels.time(minuteOf(at)));
        return (l10n.reminderNote(d, phrase), phrase);
      }(),
    };
    final boldAt = bold == null ? -1 : note.indexOf(bold);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.infoBox,
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconView(AppIcon.info, size: 20, color: colors.onInfoBox),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text.rich(
                      boldAt < 0
                          ? TextSpan(text: note)
                          : TextSpan(
                              children: [
                                TextSpan(text: note.substring(0, boldAt)),
                                TextSpan(
                                  text: bold,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: note.substring(boldAt + bold!.length),
                                ),
                              ],
                            ),
                      style: text.subline.copyWith(color: colors.onInfoBox),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListGroup(
            inSheet: true,
            children: [
              for (final offset in ReminderOffset.values)
                () {
                  final at = _at(offset);
                  final enabled = offset == ReminderOffset.none || at != null;
                  return Semantics(
                    selected: _offset == offset,
                    button: true,
                    enabled: enabled,
                    child: InkWell(
                      onTap: enabled
                          ? () => setState(() => _offset = offset)
                          : null,
                      child: Opacity(
                        opacity: enabled ? 1 : 0.45,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.reminderOption(offset.name),
                                      style: text.rowTitle.copyWith(
                                        color: colors.ink,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (offset != ReminderOffset.none)
                                      Text(
                                        at == null
                                            ? l10n.needsDueTime
                                            : when(at),
                                        style: text.caption.copyWith(
                                          color: colors.muted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              AppRadio(selected: _offset == offset),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }(),
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
