import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// "18:42" or "05:00": minutes and seconds left, as S30 and S33 show.
String clockText(int seconds) {
  String two(int n) => '$n'.padLeft(2, '0');
  return '${two(seconds ~/ 60)}:${two(seconds % 60)}';
}

/// The phase S30 shows above the time, in sentence case.
String phaseLabel(
  AppLocalizations l10n,
  FocusTimer timer,
) => switch (timer.phase) {
  TimerPhase.idle => l10n.phaseReady,
  TimerPhase.paused => l10n.phasePaused,
  TimerPhase.running when timer.kind == FocusKind.focus => l10n.phaseFocusing,
  TimerPhase.running => l10n.phaseBreak,
  TimerPhase.done when timer.kind == FocusKind.focus => l10n.sessionComplete,
  TimerPhase.done => l10n.phaseBreakOver,
};

/// S30's ring: elapsed time as the arc, the phase, the time left and
/// where the session sits in the round. Breaks draw in green.
class FocusRing extends StatelessWidget {
  const new({
    required this.timer,
    required this.now,
    required this.session,
    required this.perRound,
    super.key,
  });

  final FocusTimer timer;
  final DateTime now;
  final int session;
  final int perRound;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final left = clockText(timer.remainingSec(now));
    final isBreak = timer.kind != FocusKind.focus;
    final detail = isBreak
        ? l10n.nextSessionOf(session, perRound)
        : l10n.sessionOf(session, perRound);
    return ProgressRing(
      value: timer.elapsedSec(now) / timer.plannedSec,
      size: 270,
      stroke: 14,
      color: isBreak
          ? context.projectColors.of(ProjectColorKey.green).solid
          : colors.ink,
      trackColor: colors.raised,
      // Read on focus only; phase changes are announced by the screen.
      semanticLabel: [
        phaseLabel(l10n, timer),
        l10n.timeLeft(left),
        detail,
      ].join(', '),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phaseLabel(l10n, timer).toUpperCase(),
            style: text.label.copyWith(color: colors.muted),
          ),
          FittedBox(
            child: Text(
              left,
              style: text.timer.copyWith(
                color: colors.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(detail, style: text.subline.copyWith(color: colors.muted)),
        ],
      ),
    );
  }
}

/// Reset, Start / Pause / Resume, and Finish session.
class FocusControls extends StatelessWidget {
  const new({
    required this.phase,
    required this.onToggle,
    required this.onReset,
    required this.onFinish,
    super.key,
  });

  final TimerPhase phase;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final started = phase != TimerPhase.idle;
    Widget side(AppIcon icon, String tooltip, VoidCallback onPressed) =>
        IconButton(
          onPressed: started ? onPressed : null,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            fixedSize: const Size(56, 56),
            backgroundColor: colors.surface,
            foregroundColor: colors.ink,
            disabledBackgroundColor: colors.surface,
            disabledForegroundColor: colors.disabled,
          ),
          icon: AppIconView(icon, size: 22),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        side(AppIcon.reset, l10n.resetTimer, onReset),
        const SizedBox(width: 20),
        IconButton(
          onPressed: onToggle,
          tooltip: switch (phase) {
            TimerPhase.idle => l10n.startTimer,
            TimerPhase.running => l10n.pauseTimer,
            TimerPhase.paused => l10n.resumeTimer,
            // Only a break shows its controls once over (S33).
            TimerPhase.done => l10n.startFocusing,
          },
          style: IconButton.styleFrom(
            fixedSize: const Size(80, 80),
            backgroundColor: colors.ink,
            foregroundColor: colors.onInk,
          ),
          icon: AppIconView(
            phase == TimerPhase.running ? AppIcon.pause : AppIcon.play,
            size: 30,
          ),
        ),
        const SizedBox(width: 20),
        side(AppIcon.skipForward, l10n.finishSession, onFinish),
      ],
    );
  }
}
