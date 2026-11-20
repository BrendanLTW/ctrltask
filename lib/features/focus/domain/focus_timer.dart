import 'dart:math' as math;

import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_timer.freezed.dart';

/// [done]: the session has ended and is saved, and waits for the next
/// step (S32 Session complete, or S33's Break over).
enum TimerPhase { idle, running, paused, done }

/// A session as it's saved once it ends.
typedef EndedSession = ({
  FocusKind kind,
  int plannedSec,
  DateTime startedAt,
  DateTime endedAt,
  int elapsedSec,
  int? taskId,
  bool completed,
});

/// The focus timer between taps (PRD §6.6). It stores when it started and
/// what was banked before a pause, never a countdown, so the time left is
/// worked out from the clock and survives the app being killed. Times are
/// UTC.
@freezed
abstract class FocusTimer with _$FocusTimer {
  const factory({
    @Default(FocusKind.focus) FocusKind kind,
    @Default(TimerPhase.idle) TimerPhase phase,
    @Default(25 * 60) int plannedSec,
    int? taskId,

    /// When the session first started.
    DateTime? startedAt,

    /// When the current run began; null unless running.
    DateTime? runningSince,

    /// Seconds run before the last pause.
    @Default(0) int bankedSec,
  }) = _FocusTimer;
  const new _();

  /// Seconds run at [now], never past the planned length.
  int elapsedSec(DateTime now) => math.min(
    plannedSec,
    bankedSec +
        switch (runningSince) {
          final since? => math.max(0, now.difference(since).inSeconds),
          null => 0,
        },
  );

  int remainingSec(DateTime now) => plannedSec - elapsedSec(now);

  /// Whether a session under way has run its full length.
  bool isDone(DateTime now) =>
      (phase == TimerPhase.running || phase == TimerPhase.paused) &&
      elapsedSec(now) >= plannedSec;

  /// Starts an idle timer, or resumes a paused one.
  FocusTimer start(DateTime now) => switch (phase) {
    TimerPhase.idle => copyWith(
      phase: TimerPhase.running,
      startedAt: now,
      runningSince: now,
      bankedSec: 0,
    ),
    TimerPhase.paused => copyWith(phase: TimerPhase.running, runningSince: now),
    TimerPhase.running || TimerPhase.done => this,
  };

  FocusTimer pause(DateTime now) => phase != TimerPhase.running
      ? this
      : copyWith(
          phase: TimerPhase.paused,
          bankedSec: elapsedSec(now),
          runningSince: null,
        );

  /// Ended at [now], keeping what ran for S32's "25 min on …".
  FocusTimer finished(DateTime now) => copyWith(
    phase: TimerPhase.done,
    bankedSec: elapsedSec(now),
    runningSince: null,
  );

  /// Back to the start of the same session, keeping the mode and task.
  FocusTimer reset() => copyWith(
    phase: TimerPhase.idle,
    startedAt: null,
    runningSince: null,
    bankedSec: 0,
  );

  /// A fresh, idle [kind] of [plannedSec], keeping the task.
  FocusTimer next(FocusKind kind, int plannedSec) =>
      reset().copyWith(kind: kind, plannedSec: plannedSec);

  /// The session to save when it ends at [now]; null if it never started
  /// or is already saved.
  EndedSession? ended(DateTime now) => switch (startedAt) {
    final started? when phase != TimerPhase.done => (
      kind: kind,
      plannedSec: plannedSec,
      startedAt: started,
      endedAt: now,
      elapsedSec: elapsedSec(now),
      taskId: kind == FocusKind.focus ? taskId : null,
      completed: elapsedSec(now) >= plannedSec,
    ),
    _ => null,
  };
}

/// Where today's sessions leave the round (S30's "Session 3 of 4" and its
/// dots): focus sessions that count since the last long break.
({int done, int session, bool longBreakNext}) roundProgress(
  Iterable<FocusSession> todayOldestFirst, {
  required int perRound,
}) {
  var done = 0;
  for (final s in todayOldestFirst) {
    if (s.kind == FocusKind.long) {
      done = 0;
    } else if (s.kind == FocusKind.focus && s.counts) {
      done++;
    }
  }
  final inRound = done == 0 ? 0 : ((done - 1) % perRound) + 1;
  return (
    // Dots filled: a full round shows every dot until the long break.
    done: inRound,
    session: inRound == perRound ? perRound : inRound + 1,
    longBreakNext: inRound == perRound,
  );
}
