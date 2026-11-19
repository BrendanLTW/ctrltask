import 'package:ctrltask/core/dates/sections.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_list.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tue 17 Nov 2026.
  final today = DateTime(2026, 11, 17);
  var nextId = 1;

  Task task(
    String title, {
    DateTime? due,
    int? minute,
    TaskPriority priority = TaskPriority.medium,
    DateTime? doneAt,
  }) => Task(
    id: nextId++,
    title: title,
    priority: priority,
    status: doneAt == null ? TaskStatus.open : TaskStatus.done,
    boardColumn: doneAt == null ? BoardColumn.todo : BoardColumn.done,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    sortOrder: nextId,
    dueDate: due,
    dueMinute: minute,
    completedAt: doneAt?.toUtc(),
  );

  final overdue = task('Invoice', due: DateTime(2026, 11, 16));
  final slides = task(
    'Slides',
    due: today,
    minute: 17 * 60,
    priority: TaskPriority.urgent,
  );
  final call = task('Call', due: today, minute: 14 * 60 + 30);
  final doneToday = task('Gym', due: today, doneAt: DateTime(2026, 11, 17, 8));
  final doneBefore = task('Old', doneAt: DateTime(2026, 11, 10, 8));
  final tomorrow = task(
    'Tiles',
    due: DateTime(2026, 11, 18),
    priority: TaskPriority.high,
  );
  final sunday = task('Plan', due: DateTime(2026, 11, 22));
  final friday = task('Groceries', due: DateTime(2026, 11, 20));
  final later = task('Taxes', due: DateTime(2026, 12, 3));
  final someday = task('Read');
  final all = [
    overdue,
    slides,
    call,
    doneToday,
    doneBefore,
    tomorrow,
    sunday,
    friday,
    later,
    someday,
  ];

  List<String> titles(Iterable<Task> tasks) => [for (final t in tasks) t.title];

  test('each chip picks its tasks', () {
    expect(titles(tasksFor(TaskFilter.all, all, today: today)), [
      'Invoice',
      'Slides',
      'Call',
      'Gym',
      'Tiles',
      'Plan',
      'Groceries',
      'Taxes',
      'Read',
    ]);
    expect(titles(tasksFor(TaskFilter.today, all, today: today)), [
      'Slides',
      'Call',
      'Gym',
    ]);
    expect(titles(tasksFor(TaskFilter.upcoming, all, today: today)), [
      'Tiles',
      'Plan',
      'Groceries',
      'Taxes',
    ]);
    expect(titles(tasksFor(TaskFilter.high, all, today: today)), [
      'Slides',
      'Tiles',
    ]);
    // Most recent first.
    expect(titles(tasksFor(TaskFilter.done, all, today: today)), [
      'Gym',
      'Old',
    ]);
  });

  test('counts match what each chip shows', () {
    expect(filterCounts(all, today: today), {
      TaskFilter.all: 9,
      TaskFilter.today: 3,
      TaskFilter.upcoming: 4,
      TaskFilter.high: 2,
      TaskFilter.done: 2,
    });
  });

  test('done today means completed on the local day', () {
    expect(doneOn(doneToday, today), isTrue);
    expect(doneOn(doneBefore, today), isFalse);
    expect(doneOn(slides, today), isFalse);
  });

  test('sections run in order, by date, then as Today orders them', () {
    final sections = sectionTasks(
      tasksFor(TaskFilter.all, all, today: today),
      today: today,
      weekStart: WeekStart.mon,
    );
    expect(
      [
        for (final (s, tasks) in sections)
          '${s.name}: ${titles(tasks).join(', ')}',
      ],
      [
        'overdue: Invoice',
        // Urgent first, then by time; done last.
        'today: Slides, Call, Gym',
        'tomorrow: Tiles',
        'thisWeek: Groceries, Plan',
        'later: Taxes',
        'noDate: Read',
      ],
    );
  });

  test('this week ends on the week start setting', () {
    final sections = sectionTasks(
      [sunday],
      today: today,
      weekStart: WeekStart.sun,
    );
    expect(sections.single.$1, TaskSection.later);
  });
}
