import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/presentation/focus_controller.dart';
import 'package:ctrltask/features/focus/presentation/focus_task_picker.dart';
import 'package:ctrltask/features/focus/presentation/focus_timer_view.dart';
import 'package:ctrltask/features/focus/presentation/session_complete.dart';
import 'package:ctrltask/features/focus/presentation/timer_settings_sheet.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S30 Focus (PRD §5.8): modes, the task worked on, the timer ring and
/// controls, the round's dots and today's focus time.
class FocusScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  /// Repaints each second while running; the time comes from the clock.
  void _ticking({required bool running}) {
    if (running == (_tick != null)) return;
    _tick?.cancel();
    _tick = running
        ? Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final controller = ref.read(focusControllerProvider.notifier);
    final timer = ref.watch(focusTimerProvider);
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final sessions = ref.watch(focusTodayProvider).value ?? const [];
    final now = ref.watch(clockProvider)().toUtc();
    final round = roundProgress(sessions, perRound: prefs.sessionsPerRound);
    final focused = Duration(
      seconds: sessions
          .where((s) => s.kind == FocusKind.focus && s.counts)
          .fold(0, (sum, s) => sum + s.elapsedSec),
    );
    _ticking(running: timer.phase == TimerPhase.running);

    // Screen readers hear the phase change, not every second.
    ref.listen(focusTimerProvider, (previous, next) {
      if (previous == null) return;
      if (phaseLabel(l10n, previous) != phaseLabel(l10n, next)) {
        unawaited(
          SemanticsService.sendAnnouncement(
            View.of(context),
            phaseLabel(l10n, next),
            Directionality.of(context),
          ),
        );
      }
    });

    final task = (ref.watch(allTasksProvider).value ?? const <Task>[])
        .where((t) => t.id == timer.taskId)
        .firstOrNull;
    final complete =
        timer.kind == FocusKind.focus && timer.phase == TimerPhase.done;
    final time = l10n.durationLabel(focused);
    final todayLine = complete
        ? l10n.focusTodayRound(time, prefs.sessionsPerRound - round.done)
        : l10n.focusTodayLine(time, prefs.sessionsPerRound);
    final at = todayLine.indexOf(time);
    final footer = Column(
      children: [
        Semantics(
          label: l10n.sessionDots(round.done, prefs.sessionsPerRound),
          excludeSemantics: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < prefs.sessionsPerRound; i++)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < round.done ? colors.ink : colors.control,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: todayLine.substring(0, at)),
              TextSpan(
                text: time,
                style: TextStyle(
                  color: colors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: todayLine.substring(at + time.length)),
            ],
          ),
          textAlign: TextAlign.center,
          style: text.subline.copyWith(color: colors.muted),
        ),
      ],
    );

    Widget headerButton(AppIcon icon, String tooltip, VoidCallback onTap) =>
        IconButton(
          onPressed: onTap,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            fixedSize: const Size(48, 48),
            backgroundColor: colors.raised,
            foregroundColor: colors.ink,
          ),
          icon: AppIconView(icon, size: 22),
        );

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            12,
            AppSpacing.screenX,
            AppShell.contentBottomPadding,
          ),
          children: [
            Row(
              children: [
                const SizedBox(width: AppSpacing.textX - AppSpacing.screenX),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.tabFocus,
                      style: text.pageTitle.copyWith(color: colors.ink),
                    ),
                  ),
                ),
                // shortcut: opens the Insights placeholder until 3.10.
                headerButton(
                  AppIcon.chart,
                  l10n.focusStats,
                  () => unawaited(context.push(Routes.insights)),
                ),
                const SizedBox(width: 12),
                headerButton(
                  AppIcon.sliders,
                  l10n.timerSettings,
                  () => unawaited(showTimerSettings(context)),
                ),
              ],
            ),
            if (complete) ...[
              const SizedBox(height: 32),
              SessionComplete(
                minutes: (timer.bankedSec / 60).round(),
                taskTitle: task?.title,
                breakMinutes: round.longBreakNext
                    ? prefs.longMin
                    : prefs.shortMin,
                footer: footer,
                onStartBreak: () => unawaited(controller.startBreak()),
                onSkipBreak: () => unawaited(controller.skipBreak()),
                onMarkDone: task == null || task.status != TaskStatus.open
                    ? null
                    : () => unawaited(
                        setTaskDone(context, ref, task, done: true),
                      ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              SegmentedControl<FocusKind>(
                segments: [
                  (
                    value: FocusKind.focus,
                    label: l10n.focusModeFocus(prefs.focusMin),
                    icon: null,
                  ),
                  (
                    value: FocusKind.short,
                    label: l10n.focusModeShort(prefs.shortMin),
                    icon: null,
                  ),
                  (
                    value: FocusKind.long,
                    label: l10n.focusModeLong(prefs.longMin),
                    icon: null,
                  ),
                ],
                selected: timer.kind,
                onChanged: (kind) => unawaited(controller.selectMode(kind)),
              ),
              const SizedBox(height: 12),
              if (timer.kind == FocusKind.focus)
                _WorkingOn(
                  task: task,
                  onChange: () async {
                    final pick = await showFocusTaskPicker(
                      context,
                      current: timer.taskId,
                    );
                    if (pick != null) await controller.link(pick.taskId);
                  },
                )
              else
                const _BreakTip(),
              const SizedBox(height: 36),
              Center(
                child: FocusRing(
                  timer: timer,
                  now: now,
                  session: round.session,
                  perRound: prefs.sessionsPerRound,
                ),
              ),
              const SizedBox(height: 36),
              FocusControls(
                phase: timer.phase,
                onToggle: () => unawaited(controller.toggle()),
                onReset: () => unawaited(controller.reset()),
                // On a break, Finish ends it and starts focusing (S33).
                onFinish: () => unawaited(
                  timer.kind == FocusKind.focus
                      ? controller.finish()
                      : controller.endBreak(),
                ),
              ),
              // A break shows no round below its controls (S33).
              if (timer.kind == FocusKind.focus) ...[
                const SizedBox(height: 24),
                footer,
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// S33's tip card, in place of Working on during a break.
class _BreakTip extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: Row(
        children: [
          const IconTile(
            icon: AppIcon.coffee,
            color: ProjectColorKey.green,
            size: IconTileSize.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.breakTip,
              style: context.text.body.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// "WORKING ON" with the linked task in its project's tile, and Change.
class _WorkingOn extends ConsumerWidget {
  const new({required this.task, required this.onChange});

  final Task? task;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final project = (ref.watch(activeProjectsProvider).value ?? <Project>[])
        .where((p) => p.id == task?.projectId)
        .firstOrNull;
    return Container(
      // Change's own padding sets the right edge.
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: Row(
        children: [
          switch (project) {
            final p? => IconTile.forProject(
              p.iconKey,
              color: p.colorKey,
              size: IconTileSize.medium,
            ),
            null => IconTile(
              icon: task == null ? AppIcon.timer : AppIcon.inbox,
              color: ProjectColorKey.grey,
              size: IconTileSize.medium,
            ),
          },
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.workingOn,
                  style: text.labelSm.copyWith(color: colors.muted),
                ),
                Text(
                  task?.title ?? l10n.noTask,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // 15/600, as the design, so a typical title fits a line.
                  style: text.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: task == null ? colors.muted : colors.ink,
                  ),
                ),
              ],
            ),
          ),
          TextLink(label: l10n.change, muted: true, onPressed: onChange),
        ],
      ),
    );
  }
}
