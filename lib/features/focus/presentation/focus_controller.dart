import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/domain/focus_timer_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_controller.g.dart';

/// The saved timer, or a fresh focus session before one is saved.
@Riverpod(keepAlive: true)
Stream<FocusTimer?> savedFocusTimer(Ref ref) =>
    ref.watch(focusTimerRepositoryProvider).watch();

/// How long [kind] runs, in seconds, from the settings (S31).
int plannedFor(FocusKind kind, Preferences prefs) =>
    60 *
    switch (kind) {
      FocusKind.focus => prefs.focusMin,
      FocusKind.short => prefs.shortMin,
      FocusKind.long => prefs.longMin,
    };

/// The focus timer as S30 shows it. An idle timer takes its length from
/// the settings, so a change there shows at once.
@riverpod
FocusTimer focusTimer(Ref ref) {
  final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
  final saved = ref.watch(savedFocusTimerProvider).value ?? const FocusTimer();
  return saved.phase == TimerPhase.idle
      ? saved.copyWith(plannedSec: plannedFor(saved.kind, prefs))
      : saved;
}

/// Runs the focus timer (PRD §5.8, §6.6): every change is saved, and a
/// session that reaches its end is saved and followed by the next phase,
/// whichever screen is open. Kept alive by the app.
@Riverpod(keepAlive: true)
class FocusController extends _$FocusController {
  Timer? _end;

  @override
  void build() {
    // Finish a running session on time, or at once if it ran out while
    // the app was closed. A suspended app's timers don't count down, so
    // check again on return too (CLAUDE.md: never rely on a timer
    // surviving the background).
    final lifecycle = AppLifecycleListener(onResume: () => _schedule(_timer));
    ref
      ..listen(focusTimerProvider, (_, timer) => _schedule(timer))
      ..onDispose(() {
        _end?.cancel();
        lifecycle.dispose();
      });
  }

  DateTime get _now => ref.read(clockProvider)().toUtc();

  FocusTimer get _timer => ref.read(focusTimerProvider);

  Future<void> _save(FocusTimer timer) =>
      ref.read(focusTimerRepositoryProvider).save(timer);

  void _schedule(FocusTimer timer) {
    _end?.cancel();
    if (timer.phase != TimerPhase.running) return;
    final left = timer.remainingSec(_now);
    if (left <= 0) {
      unawaited(finish());
    } else {
      _end = Timer(Duration(seconds: left), () => unawaited(finish()));
    }
  }

  /// Start, Pause or Resume; on a finished session, the next step:
  /// the break after focus (S32), focus after a break (S33).
  Future<void> toggle() async {
    final timer = _timer;
    if (timer.phase == TimerPhase.done) {
      return timer.kind == FocusKind.focus
          ? await startBreak()
          : await _startFocus();
    }
    await _save(
      timer.phase == TimerPhase.running ? timer.pause(_now) : timer.start(_now),
    );
  }

  /// Back to the start of this session; nothing is saved.
  Future<void> reset() => _save(_timer.reset());

  /// Links [taskId] (null for no task) to this and later sessions.
  Future<void> link(int? taskId) => _save(_timer.copyWith(taskId: taskId));

  /// Switches to [kind], saving whatever ran of the current session.
  Future<void> selectMode(FocusKind kind) async {
    if (kind == _timer.kind && _timer.phase == TimerPhase.idle) return;
    await _endCurrent();
    await _save(_timer.next(kind, plannedFor(kind, _prefs)));
  }

  /// Ends the session and saves it. After focus: S32, or the break at
  /// once with "Start breaks automatically". After a break: Break over, or
  /// the next session with "Start next session automatically" (§6.6).
  Future<void> finish() async {
    final timer = _timer;
    if (timer.phase == TimerPhase.idle || timer.phase == TimerPhase.done) {
      return;
    }
    await _endCurrent();
    if (timer.kind == FocusKind.focus) {
      if (_prefs.autoStartBreaks) return await startBreak();
    } else if (_prefs.autoStartNext) {
      return await _startFocus();
    }
    await _save(timer.finished(_now));
  }

  /// S33's Finish: ends the break, saving it, and starts focusing.
  Future<void> endBreak() async {
    await _endCurrent();
    await _startFocus();
  }

  /// S32's Start break: short, or long once the round is done.
  Future<void> startBreak() async {
    final today = ref.read(clockProvider)();
    final sessions = await ref
        .read(focusSessionRepositoryProvider)
        .watchStartedBetween(today, today)
        .first;
    final kind =
        roundProgress(sessions, perRound: _prefs.sessionsPerRound).longBreakNext
        ? FocusKind.long
        : FocusKind.short;
    await _save(_timer.next(kind, plannedFor(kind, _prefs)).start(_now));
  }

  /// S32's Skip break: the next focus session, ready to start.
  Future<void> skipBreak() =>
      _save(_timer.next(FocusKind.focus, plannedFor(FocusKind.focus, _prefs)));

  Future<void> _startFocus() => _save(
    _timer
        .next(FocusKind.focus, plannedFor(FocusKind.focus, _prefs))
        .start(_now),
  );

  Preferences get _prefs =>
      ref.read(preferencesProvider).value ?? const Preferences();

  Future<void> _endCurrent() async {
    if (_timer.ended(_now) case final session?) {
      await ref.read(focusSessionRepositoryProvider).add(session);
    }
  }
}
