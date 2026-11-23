import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_data.g.dart';

/// One table's rows as Drift serialises them (docs/export-format.md).
typedef TableRows = List<Map<String, Object?>>;

/// A task with what its CSV row reads: project, tag names and repeat rule.
typedef ExportTask = ({
  Task task,
  Project? project,
  List<String> tags,
  RepeatRule? repeat,
});

/// Everything on the phone, read in one transaction: each table's rows for
/// JSON, and the entities that decide what's included and fill the CSV.
class ExportSnapshot {
  const new({
    required this.schemaVersion,
    required this.tables,
    required this.tasks,
    required this.projects,
    required this.sessions,
  });

  final int schemaVersion;

  /// By table name, in an order that restores without breaking a
  /// reference.
  final Map<String, TableRows> tables;
  final List<ExportTask> tasks;
  final List<Project> projects;
  final List<FocusSession> sessions;
}

/// Reads the [ExportSnapshot]; Drift's in `main.dart`.
abstract interface class ExportSource {
  Future<ExportSnapshot> read();
}

@Riverpod(keepAlive: true)
ExportSource exportSource(Ref ref) =>
    throw UnimplementedError('Override exportSourceProvider');

enum ExportFormat { csv, json }

/// S41's choices. `from` and `to` are local days, both included; null for
/// all time.
typedef ExportOptions = ({
  DateTime? from,
  DateTime? to,
  bool completed,
  bool archived,
  bool focus,
});

/// What S41's options keep, by id.
typedef ExportSelection = ({
  Set<int> taskIds,
  Set<int> projectIds,
  Set<int> sessionIds,
});

bool _inRange(DateTime at, ExportOptions o) {
  final day = at.toLocal();
  final d = DateTime(day.year, day.month, day.day);
  return (o.from == null || !d.isBefore(o.from!)) &&
      (o.to == null || !d.isAfter(o.to!));
}

/// Tasks created in the range, without done ones unless [ExportOptions]
/// includes completed; projects whole, archived ones (and their tasks) only
/// when included; focus sessions started in the range when included.
ExportSelection selectForExport(ExportSnapshot s, ExportOptions o) {
  final projectIds = {
    for (final p in s.projects)
      if (o.archived || p.archivedAt == null) p.id,
  };
  return (
    projectIds: projectIds,
    taskIds: {
      for (final (:task, project: _, tags: _, repeat: _) in s.tasks)
        if (_inRange(task.createdAt, o) &&
            (o.completed || task.status == TaskStatus.open) &&
            (task.projectId == null || projectIds.contains(task.projectId)))
          task.id,
    },
    sessionIds: {
      if (o.focus)
        for (final f in s.sessions)
          if (_inRange(f.startedAt, o)) f.id,
    },
  );
}

/// The CSV columns, in order (PRD §6.7).
const csvHeader = [
  'title',
  'status',
  'priority',
  'due_date',
  'due_time',
  'project',
  'tags',
  'repeat',
  'created_at',
  'completed_at',
  'description',
];

String _two(int n) => '$n'.padLeft(2, '0');

/// The selected tasks as CSV, in the order they were read. [repeatText]
/// reads a rule out ("Every Mon").
String tasksCsv(
  ExportSnapshot s,
  ExportSelection selection, {
  required String Function(RepeatRule) repeatText,
}) => csv.encode([
  csvHeader,
  for (final (:task, :project, :tags, :repeat) in s.tasks)
    if (selection.taskIds.contains(task.id))
      [
        task.title,
        task.status.name,
        task.priority.name,
        switch (task.dueDate) {
          final d? => '${d.year}-${_two(d.month)}-${_two(d.day)}',
          null => '',
        },
        switch (task.dueMinute) {
          final m? => '${_two(m ~/ 60)}:${_two(m % 60)}',
          null => '',
        },
        project?.name ?? '',
        tags.join(';'),
        if (repeat == null) '' else repeatText(repeat),
        task.createdAt.toUtc().toIso8601String(),
        task.completedAt?.toUtc().toIso8601String() ?? '',
        task.description ?? '',
      ],
]);

/// The selected rows of every table as JSON, with `schemaVersion` and
/// `exportedAt`. With everything selected it's an exact copy.
String exportJson(
  ExportSnapshot s,
  ExportSelection selection, {
  required DateTime exportedAt,
}) {
  bool byId(Map<String, Object?> row, Set<int> ids) => ids.contains(row['id']);
  bool byTask(Map<String, Object?> row) =>
      selection.taskIds.contains(row['taskId']);
  final ruleIds = {
    for (final t in s.tables['tasks'] ?? const <Map<String, Object?>>[])
      if (byId(t, selection.taskIds) && t['repeatRuleId'] != null)
        t['repeatRuleId']! as int,
  };
  final tables = {
    for (final MapEntry(key: name, value: rows) in s.tables.entries)
      name: [
        for (final row in rows)
          if (switch (name) {
            'projects' => byId(row, selection.projectIds),
            'repeat_rules' => byId(row, ruleIds),
            'tasks' => byId(row, selection.taskIds),
            'subtasks' || 'links' || 'task_tags' => byTask(row),
            'focus_sessions' => byId(row, selection.sessionIds),
            _ => true,
          })
            // A session keeps its time when its task isn't exported.
            if (name == 'focus_sessions' &&
                row['taskId'] != null &&
                !byTask(row))
              {...row, 'taskId': null}
            else
              row,
      ],
  };
  return const JsonEncoder.withIndent('  ').convert({
    'schemaVersion': s.schemaVersion,
    'exportedAt': exportedAt.toUtc().toIso8601String(),
    'tables': tables,
  });
}

/// `ctrltask-2026-11-17.csv`.
String exportFileName(ExportFormat format, DateTime today) =>
    'ctrltask-${today.year}-${_two(today.month)}-${_two(today.day)}'
    '.${format.name}';
