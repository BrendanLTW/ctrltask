import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:ctrltask/features/focus/domain/focus_timer_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
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
    // the app was closed.
    ref
      ..listen(focusTimerProvider, (_, timer) => _schedule(timer))
      ..onDispose(() => _end?.cancel());
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

  /// Start, Pause or Resume.
  Future<void> toggle() {
    final timer = _timer;
    return _save(
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

  /// Ends the session, saving it, and readies the next phase: a break
  /// after focus (long once the round is done), focus after a break.
  // shortcut: S32 Session complete and auto-start come with 3.2.
  Future<void> finish() async {
    final timer = _timer;
    if (timer.phase == TimerPhase.idle) return;
    await _endCurrent();
    final FocusKind next;
    if (timer.kind == FocusKind.focus) {
      final today = ref.read(clockProvider)();
      final sessions = await ref
          .read(focusSessionRepositoryProvider)
          .watchStartedBetween(today, today)
          .first;
      next =
          roundProgress(
            sessions,
            perRound: _prefs.sessionsPerRound,
          ).longBreakNext
          ? FocusKind.long
          : FocusKind.short;
    } else {
      next = FocusKind.focus;
    }
    await _save(timer.next(next, plannedFor(next, _prefs)));
  }

  Preferences get _prefs =>
      ref.read(preferencesProvider).value ?? const Preferences();

  Future<void> _endCurrent() async {
    if (_timer.ended(_now) case final session?) {
      await ref.read(focusSessionRepositoryProvider).add(session);
    }
  }
}
