import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/app_stepper.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens S31 Timer settings, from S30 and from Settings.
Future<void> showTimerSettings(BuildContext context) => showAppSheet<void>(
  context,
  title: context.l10n.timerSettings,
  builder: (_) => const TimerSettingsSheet(),
);

/// A stepper's range: S31 (PRD §5.8).
typedef StepRange = ({int min, int max, int step});

/// S31's durations and behaviour. Changes stay in the sheet until Save
/// as default; closing it discards them.
class TimerSettingsSheet extends ConsumerStatefulWidget {
  const new({super.key});

  static const StepRange focus = (min: 10, max: 90, step: 5);
  static const StepRange short = (min: 1, max: 15, step: 1);
  static const StepRange long = (min: 10, max: 45, step: 5);
  static const StepRange perRound = (min: 2, max: 8, step: 1);

  @override
  ConsumerState<TimerSettingsSheet> createState() => _TimerSettingsState();
}

class _TimerSettingsState extends ConsumerState<TimerSettingsSheet> {
  late Preferences _draft =
      ref.read(preferencesProvider).value ?? const Preferences();

  Future<void> _save() async {
    final draft = _draft;
    await ref
        .read(preferencesRepositoryProvider)
        .update(
          (p) => p.copyWith(
            focusMin: draft.focusMin,
            shortMin: draft.shortMin,
            longMin: draft.longMin,
            sessionsPerRound: draft.sessionsPerRound,
            autoStartBreaks: draft.autoStartBreaks,
            autoStartNext: draft.autoStartNext,
            silenceWhileFocusing: draft.silenceWhileFocusing,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Widget _stepper({
    required String title,
    required String detail,
    required int value,
    required StepRange range,
    required String Function(int) label,
    required Preferences Function(int) apply,
  }) {
    final down = value - range.step;
    final up = value + range.step;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.rowTitle.copyWith(
                    color: context.colors.ink,
                  ),
                ),
                Text(
                  detail,
                  style: context.text.caption.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
          AppStepper(
            value: label(value),
            semanticLabel: title,
            decreasedValue: down >= range.min ? label(down) : null,
            increasedValue: up <= range.max ? label(up) : null,
            onDecrement: down >= range.min
                ? () => setState(() => _draft = apply(down))
                : null,
            onIncrement: up <= range.max
                ? () => setState(() => _draft = apply(up))
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = _draft;
    String minutes(int m) => l10n.minutesValue(m);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(l10n.durationsSection),
          ListGroup(
            inSheet: true,
            children: [
              _stepper(
                title: l10n.focusLength,
                detail: l10n.focusLengthDetail,
                value: d.focusMin,
                range: TimerSettingsSheet.focus,
                label: minutes,
                apply: (v) => d.copyWith(focusMin: v),
              ),
              _stepper(
                title: l10n.shortBreak,
                detail: l10n.shortBreakDetail,
                value: d.shortMin,
                range: TimerSettingsSheet.short,
                label: minutes,
                apply: (v) => d.copyWith(shortMin: v),
              ),
              _stepper(
                title: l10n.longBreak,
                detail: l10n.longBreakDetail,
                value: d.longMin,
                range: TimerSettingsSheet.long,
                label: minutes,
                apply: (v) => d.copyWith(longMin: v),
              ),
              _stepper(
                title: l10n.sessionsPerRound,
                detail: l10n.sessionsPerRoundDetail,
                value: d.sessionsPerRound,
                range: TimerSettingsSheet.perRound,
                label: (v) => '$v',
                apply: (v) => d.copyWith(sessionsPerRound: v),
              ),
            ],
          ),
          SectionHeader(l10n.behaviourSection),
          ListGroup(
            inSheet: true,
            children: [
              ListGroupToggleRow(
                title: l10n.autoStartBreaks,
                value: d.autoStartBreaks,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(autoStartBreaks: v)),
              ),
              ListGroupToggleRow(
                title: l10n.autoStartNext,
                value: d.autoStartNext,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(autoStartNext: v)),
              ),
              // The notification planner holds task reminders back while
              // this is on.
              ListGroupToggleRow(
                title: l10n.silenceWhileFocusing,
                value: d.silenceWhileFocusing,
                onChanged: (v) => setState(
                  () => _draft = d.copyWith(silenceWhileFocusing: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: l10n.saveAsDefault, onPressed: _save),
        ],
      ),
    );
  }
}
