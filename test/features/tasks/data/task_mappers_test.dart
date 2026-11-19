import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/tasks/data/repeat_rule_mapper.dart';
import 'package:ctrltask/features/tasks/data/subtask_mapper.dart';
import 'package:ctrltask/features/tasks/data/task_link_mapper.dart';
import 'package:ctrltask/features/tasks/data/task_mapper.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final created = DateTime.utc(2026, 11, 15, 2, 30);
  final task = Task(
    id: 0,
    title: 'Review homepage wireframes',
    description: 'Check the hero and the pricing table.',
    dueDate: DateTime(2026, 11, 17),
    dueMinute: 600,
    priority: TaskPriority.high,
    status: TaskStatus.open,
    boardColumn: BoardColumn.doing,
    createdAt: created,
    updatedAt: created,
    sortOrder: 3,
    reminder: ReminderOffset.min30,
  );

  Future<Task> roundTrip(Task t) async {
    final row = await db
        .into(db.tasks)
        .insertReturning(t.toCompanion().copyWith(id: const Value.absent()));
    return row.toEntity();
  }

  group('Task', () {
    test('every field survives a round trip', () async {
      final back = await roundTrip(task);
      expect(back, task.copyWith(id: back.id));
      expect(back.dueDate, DateTime(2026, 11, 17));
      expect(back.dueDate!.isUtc, isFalse);
    });

    test('a done task with no date or project survives too', () async {
      final done = task.copyWith(
        dueDate: null,
        dueMinute: null,
        description: null,
        status: TaskStatus.done,
        boardColumn: BoardColumn.done,
        completedAt: DateTime.utc(2026, 11, 17, 1),
        reminder: ReminderOffset.none,
      );
      final back = await roundTrip(done);
      expect(back, done.copyWith(id: back.id));
    });

    test('every priority and reminder passes the SQL checks', () async {
      for (final priority in TaskPriority.values) {
        for (final reminder in ReminderOffset.values) {
          final back = await roundTrip(
            task.copyWith(priority: priority, reminder: reminder),
          );
          expect((back.priority, back.reminder), (priority, reminder));
        }
      }
    });

    test('every board column passes the SQL checks', () async {
      for (final column in BoardColumn.values) {
        final done = column == BoardColumn.done;
        final back = await roundTrip(
          task.copyWith(
            boardColumn: column,
            status: done ? TaskStatus.done : TaskStatus.open,
          ),
        );
        expect(back.boardColumn, column);
      }
    });

    test('a due date keeps its local day', () async {
      // Run with TZ=Europe/London and America/New_York.
      for (final day in [
        DateTime(2026, 3, 29),
        DateTime(2026, 10, 25),
        DateTime(2026, 12, 31),
      ]) {
        final back = await roundTrip(task.copyWith(dueDate: day));
        expect(back.dueDate, day);
      }
    });
  });

  test('Subtask and TaskLink survive a round trip', () async {
    final taskId = (await roundTrip(task)).id;
    const subtask = Subtask(
      id: 0,
      taskId: 0,
      title: 'Hero section',
      done: true,
      sortOrder: 1,
    );
    final subRow = await db
        .into(db.subtasks)
        .insertReturning(
          subtask
              .copyWith(taskId: taskId)
              .toCompanion()
              .copyWith(id: const Value.absent()),
        );
    expect(subRow.toEntity(), subtask.copyWith(id: subRow.id, taskId: taskId));

    const link = TaskLink(
      id: 0,
      taskId: 0,
      title: 'Figma',
      url: 'https://figma.com/file/abc',
    );
    final linkRow = await db
        .into(db.links)
        .insertReturning(
          link
              .copyWith(taskId: taskId)
              .toCompanion()
              .copyWith(id: const Value.absent()),
        );
    expect(linkRow.toEntity(), link.copyWith(id: linkRow.id, taskId: taskId));
  });

  group('RepeatRule', () {
    Future<RepeatRule> roundTripRule(RepeatRule rule) async =>
        (await db.into(db.repeatRules).insertReturning(rule.toCompanion()))
            .toEntity();

    test('every case survives a round trip', () async {
      final ends = DateTime(2027, 3, 31);
      for (final rule in [
        const RepeatRule.daily(),
        RepeatRule.daily(endsOn: ends),
        const RepeatRule.weekdays(),
        RepeatRule.weekly({DateTime.monday, DateTime.thursday}),
        RepeatRule.weekly({1, 2, 3, 4, 5, 6, 7}, endsOn: ends),
        const RepeatRule.monthly(31),
        const RepeatRule.custom(12, RepeatUnit.day),
        const RepeatRule.custom(2, RepeatUnit.week),
        RepeatRule.custom(3, RepeatUnit.month, dayOfMonth: 31, endsOn: ends),
      ]) {
        expect(await roundTripRule(rule), rule, reason: '$rule');
      }
    });

    test('weekdays are a bitmask with Monday as bit 0', () async {
      final id = await db
          .into(db.repeatRules)
          .insert(
            RepeatRule.weekly({DateTime.monday, DateTime.sunday}).toCompanion(),
          );
      final row = await (db.select(
        db.repeatRules,
      )..where((r) => r.id.equals(id))).getSingle();
      expect(row.weekdays, 1 | 64);
    });
  });
}
