import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Project project(int id, {bool archived = false}) => Project(
    id: id,
    name: 'Project $id',
    colorKey: ProjectColorKey.blue,
    iconKey: ProjectIconKey.globe,
    createdAt: DateTime.utc(2026),
    sortOrder: id,
    archivedAt: archived ? DateTime.utc(2026, 11) : null,
  );

  Task task(
    int id, {
    DateTime? created,
    bool done = false,
    int? projectId,
    String title = 'Task',
    DateTime? due,
    int? minute,
    String? description,
  }) => Task(
    id: id,
    title: title,
    priority: TaskPriority.high,
    status: done ? TaskStatus.done : TaskStatus.open,
    boardColumn: done ? BoardColumn.done : BoardColumn.todo,
    createdAt: (created ?? DateTime(2026, 6, 1, 9)).toUtc(),
    updatedAt: DateTime.utc(2026),
    sortOrder: id,
    projectId: projectId,
    dueDate: due,
    dueMinute: minute,
    description: description,
    completedAt: done ? DateTime.utc(2026, 11, 2, 10) : null,
  );

  FocusSession session(int id, DateTime at) => FocusSession(
    id: id,
    kind: FocusKind.focus,
    plannedSec: 1500,
    startedAt: at.toUtc(),
    elapsedSec: 1500,
  );

  ExportTask entry(Task t, {Project? p, List<String> tags = const []}) =>
      (task: t, project: p, tags: tags, repeat: null);

  final active = project(1);
  final archived = project(2, archived: true);
  final snapshot = ExportSnapshot(
    schemaVersion: 1,
    tables: const {},
    projects: [active, archived],
    tasks: [
      entry(task(1, created: DateTime(2025, 12, 31, 23)), p: active),
      entry(task(2, done: true), p: active),
      entry(task(3, projectId: 2), p: archived),
      entry(task(4)),
    ],
    sessions: [
      session(1, DateTime(2025, 12, 31, 23)),
      session(2, DateTime(2026, 11, 2, 9)),
    ],
  );

  const all = (
    from: null,
    to: null,
    completed: true,
    archived: true,
    focus: true,
  );

  group('selectForExport', () {
    test('everything', () {
      final s = selectForExport(snapshot, all);
      expect(s.taskIds, {1, 2, 3, 4});
      expect(s.projectIds, {1, 2});
      expect(s.sessionIds, {1, 2});
    });

    test("S41's defaults leave out archived projects and their tasks", () {
      final s = selectForExport(snapshot, (
        from: null,
        to: null,
        completed: true,
        archived: false,
        focus: true,
      ));
      expect(s.projectIds, {1});
      expect(s.taskIds, {1, 2, 4});
    });

    test('without completed tasks or focus sessions', () {
      final s = selectForExport(snapshot, (
        from: null,
        to: null,
        completed: false,
        archived: true,
        focus: false,
      ));
      expect(s.taskIds, {1, 3, 4});
      expect(s.sessionIds, isEmpty);
    });

    test('a range by local creation and start day', () {
      final s = selectForExport(snapshot, (
        from: DateTime(2026),
        to: DateTime(2026, 12, 31),
        completed: true,
        archived: true,
        focus: true,
      ));
      expect(s.taskIds, {2, 3, 4});
      expect(s.sessionIds, {2});
      // Projects are kept whole.
      expect(s.projectIds, {1, 2});
    });
  });

  test('CSV has the columns in order, escaped', () {
    final s = ExportSnapshot(
      schemaVersion: 1,
      tables: const {},
      projects: [active],
      tasks: [
        (
          task: task(
            1,
            title: 'Call "Sam", then plan',
            due: DateTime(2026, 11, 19),
            minute: 9 * 60 + 5,
            projectId: 1,
            description: 'Line one\nLine two',
          ),
          project: active,
          tags: ['work', 'calls'],
          repeat: RepeatRule.weekly({DateTime.monday}),
        ),
        entry(task(2, done: true)),
      ],
      sessions: const [],
    );
    final csv = tasksCsv(
      s,
      selectForExport(s, all),
      repeatText: (_) => 'Every Mon',
    );
    final created = DateTime(2026, 6, 1, 9).toUtc().toIso8601String();
    final lines = csv.split(RegExp('\r?\n'));
    expect(lines.first, csvHeader.join(','));
    expect(
      csv,
      contains(
        [
          '"Call ""Sam"", then plan"',
          'open',
          'high',
          '2026-11-19',
          '09:05',
          'Project 1',
          'work;calls',
          'Every Mon',
          created,
          '',
          '"Line one\nLine two"',
        ].join(','),
      ),
    );
    expect(
      csv,
      contains(
        [
          'Task',
          'done',
          'high',
          '',
          '',
          '',
          '',
          '',
          created,
          '2026-11-02T10:00:00.000Z',
          '',
        ].join(','),
      ),
    );
  });

  test('the file name has the date and format', () {
    expect(
      exportFileName(ExportFormat.csv, DateTime(2026, 11, 7)),
      'ctrltask-2026-11-07.csv',
    );
    expect(
      exportFileName(ExportFormat.json, DateTime(2026, 11, 17)),
      'ctrltask-2026-11-17.json',
    );
  });
}
