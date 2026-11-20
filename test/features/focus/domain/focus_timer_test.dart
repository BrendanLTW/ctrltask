import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/focus/domain/focus_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 17, 1, 41);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));

  group('FocusTimer', () {
    test('idle shows the full length', () {
      const timer = FocusTimer(taskId: 3);
      expect(timer.remainingSec(t0), 25 * 60);
      expect(timer.isDone(t0), isFalse);
      expect(timer.ended(t0), isNull);
    });

    test('runs from the clock, pauses and resumes', () {
      final running = const FocusTimer().start(t0);
      expect(running.remainingSec(at(90)), 25 * 60 - 90);

      final paused = running.pause(at(90));
      expect(paused.phase, TimerPhase.paused);
      // Time stands still while paused.
      expect(paused.elapsedSec(at(600)), 90);

      final resumed = paused.start(at(600));
      expect(resumed.elapsedSec(at(630)), 120);
      expect(resumed.startedAt, t0, reason: 'the session keeps its start');
    });

    test('reopened after it ran out, it is done at its full length', () {
      final running = const FocusTimer(plannedSec: 300).start(t0);
      // The app was killed; it opens an hour later.
      final later = at(3600);
      expect(running.isDone(later), isTrue);
      expect(running.remainingSec(later), 0);
      final session = running.ended(later)!;
      expect((session.elapsedSec, session.completed), (300, true));
    });

    test('a clock set back never makes time negative', () {
      final running = const FocusTimer().start(t0);
      expect(running.elapsedSec(at(-30)), 0);
    });

    test('ending early saves what ran and is not completed', () {
      final session = const FocusTimer(taskId: 7).start(t0).ended(at(400))!;
      expect(
        (
          session.kind,
          session.startedAt,
          session.endedAt,
          session.elapsedSec,
          session.taskId,
          session.completed,
        ),
        (FocusKind.focus, t0, at(400), 400, 7, false),
      );
    });

    test('breaks are not linked to the task', () {
      final timer = const FocusTimer(taskId: 7).next(FocusKind.short, 300);
      expect(timer.start(t0).ended(at(10))!.taskId, isNull);
      expect(timer.taskId, 7, reason: 'kept for the next focus session');
    });

    test('reset keeps the mode and task', () {
      final reset = const FocusTimer(
        kind: FocusKind.long,
        plannedSec: 900,
        taskId: 2,
      ).start(t0).reset();
      expect(
        (reset.phase, reset.kind, reset.taskId, reset.startedAt),
        (TimerPhase.idle, FocusKind.long, 2, null),
      );
    });
  });

  group('roundProgress', () {
    var id = 0;
    FocusSession session(FocusKind kind, {int sec = 1500}) => FocusSession(
      id: id++,
      kind: kind,
      plannedSec: 1500,
      startedAt: t0,
      elapsedSec: sec,
    );

    test('counts focus sessions of a minute or more', () {
      final p = roundProgress([
        session(FocusKind.focus),
        session(FocusKind.short),
        session(FocusKind.focus),
        session(FocusKind.focus, sec: 40),
      ], perRound: 4);
      expect((p.done, p.session, p.longBreakNext), (2, 3, false));
    });

    test('a full round asks for the long break', () {
      final p = roundProgress([
        for (var i = 0; i < 4; i++) session(FocusKind.focus),
      ], perRound: 4);
      expect((p.done, p.session, p.longBreakNext), (4, 4, true));
    });

    test('a long break starts a new round', () {
      final p = roundProgress([
        for (var i = 0; i < 4; i++) session(FocusKind.focus),
        session(FocusKind.long),
        session(FocusKind.focus),
      ], perRound: 4);
      expect((p.done, p.session), (1, 2));
    });

    test('nothing yet is session 1', () {
      final p = roundProgress(const [], perRound: 4);
      expect((p.done, p.session), (0, 1));
    });
  });
}
