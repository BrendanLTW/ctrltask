import 'package:ctrltask/features/calendar/domain/calendar_calculations.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 17);
  var id = 0;

  Task task({DateTime? due, DateTime? doneAt}) => Task(
    id: id++,
    title: 'T',
    priority: TaskPriority.medium,
    status: doneAt == null ? TaskStatus.open : TaskStatus.done,
    boardColumn: doneAt == null ? BoardColumn.todo : BoardColumn.done,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    sortOrder: 0,
    dueDate: due,
    completedAt: doneAt?.toUtc(),
  );

  group('dayStatuses', () {
    test('open tasks on their due day, done ones on their completion day', () {
      final statuses = dayStatuses([
        task(due: DateTime(2026, 11, 16)),
        task(due: DateTime(2026, 11, 19)),
        task(due: today),
        task(due: DateTime(2026, 11, 20), doneAt: DateTime(2026, 11, 16, 9)),
        task(),
      ], today: today);
      expect(statuses, {
        DateTime(2026, 11, 16): (
          pending: false,
          completed: true,
          overdue: true,
        ),
        DateTime(2026, 11, 17): (
          pending: true,
          completed: false,
          overdue: false,
        ),
        DateTime(2026, 11, 19): (
          pending: true,
          completed: false,
          overdue: false,
        ),
      });
    });
  });

  test('rangeCounts counts open tasks due in the range, and overdue ones', () {
    final counts = rangeCounts(
      [
        task(due: DateTime(2026, 11, 16)),
        task(due: today),
        task(due: DateTime(2026, 11, 22)),
        task(due: DateTime(2026, 11, 23)),
        task(due: today, doneAt: DateTime(2026, 11, 17, 8)),
      ],
      start: DateTime(2026, 11, 16),
      end: DateTime(2026, 11, 22),
      today: today,
    );
    expect(counts, (due: 3, overdue: 1));
  });

  group('focusBlocks', () {
    FocusSession session(
      int minute,
      int length, {
      int? taskId = 1,
      FocusKind kind = FocusKind.focus,
    }) {
      final start = DateTime(2026, 11, 17, 11).add(Duration(minutes: minute));
      return FocusSession(
        id: id++,
        kind: kind,
        plannedSec: length * 60,
        startedAt: start.toUtc(),
        endedAt: start.add(Duration(minutes: length)).toUtc(),
        elapsedSec: length * 60,
        taskId: taskId,
      );
    }

    test('back-to-back sessions on one task merge across a break', () {
      final blocks = focusBlocks([
        session(30, 25),
        session(55, 5, kind: FocusKind.short),
        session(60, 30),
      ]);
      expect(blocks, [
        (
          start: DateTime(2026, 11, 17, 11, 30),
          end: DateTime(2026, 11, 17, 12, 30),
          taskId: 1,
          sessions: 2,
        ),
      ]);
    });

    test('another task, a long gap or a too-short session stays apart', () {
      final blocks = focusBlocks([
        session(0, 25),
        session(25, 25, taskId: 2),
        session(120, 25, taskId: 2),
        session(150, 0),
      ]);
      expect(
        [for (final b in blocks) (b.taskId, b.sessions)],
        [(1, 1), (2, 1), (2, 1)],
      );
    });
  });

  group('timelineColumns', () {
    test('apart spans each get the full width', () {
      expect(timelineColumns([(start: 0, end: 60), (start: 60, end: 120)]), [
        (column: 0, columns: 1),
        (column: 0, columns: 1),
      ]);
    });

    test('overlapping spans share columns, reusing a free one', () {
      expect(
        timelineColumns([
          (start: 600, end: 660),
          (start: 630, end: 690),
          (start: 665, end: 720),
          (start: 900, end: 960),
        ]),
        [
          (column: 0, columns: 2),
          (column: 1, columns: 2),
          (column: 0, columns: 2),
          (column: 0, columns: 1),
        ],
      );
    });
  });
}
