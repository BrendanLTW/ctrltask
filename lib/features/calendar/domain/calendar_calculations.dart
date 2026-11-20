import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/features/focus/domain/focus_session.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';

/// A day's dots on S21: something completed that day, an open task due,
/// or one due and now overdue.
typedef DayStatus = ({bool pending, bool completed, bool overdue});

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Every day with a dot, from [tasks]. Open tasks count on their due day,
/// done ones on the local day they were completed.
Map<DateTime, DayStatus> dayStatuses(
  Iterable<Task> tasks, {
  required DateTime today,
}) {
  final out = <DateTime, DayStatus>{};
  void mark(DateTime day, {bool p = false, bool c = false, bool o = false}) {
    final s = out[day] ?? (pending: false, completed: false, overdue: false);
    out[day] = (
      pending: s.pending || p,
      completed: s.completed || c,
      overdue: s.overdue || o,
    );
  }

  for (final t in tasks) {
    if (t.status == TaskStatus.done) {
      if (t.completedAt case final at?) mark(_day(at.toLocal()), c: true);
    } else if (t.dueDate case final due?) {
      final late = DateLabels.daysBetween(today, due) < 0;
      mark(due, p: !late, o: late);
    }
  }
  return out;
}

/// The tasks on [day]'s agenda: due that day, done or not.
List<Task> tasksDueOn(Iterable<Task> tasks, DateTime day) => [
  for (final t in tasks)
    if (t.dueDate == day) t,
];

/// S22's "5 due · 1 overdue": open tasks due from [start] to [end], and
/// how many of those are already overdue.
({int due, int overdue}) rangeCounts(
  Iterable<Task> tasks, {
  required DateTime start,
  required DateTime end,
  required DateTime today,
}) {
  var due = 0;
  var overdue = 0;
  for (final t in tasks) {
    final d = t.dueDate;
    if (t.status != TaskStatus.open || d == null) continue;
    if (d.isBefore(start) || d.isAfter(end)) continue;
    due++;
    if (d.isBefore(today)) overdue++;
  }
  return (due: due, overdue: overdue);
}

/// A run of focus on S22's timeline, in local time.
typedef FocusBlock = ({
  DateTime start,
  DateTime end,
  int? taskId,
  int sessions,
});

/// Focus sessions that count, as timeline blocks. Back-to-back sessions
/// on the same task, at most [gap] apart (a short break), merge.
List<FocusBlock> focusBlocks(
  Iterable<FocusSession> sessions, {
  Duration gap = const Duration(minutes: 15),
}) {
  final focus = [
    for (final s in sessions)
      if (s.kind == FocusKind.focus && s.counts) s,
  ]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  final out = <FocusBlock>[];
  for (final s in focus) {
    final start = s.startedAt.toLocal();
    final end = (s.endedAt ?? s.startedAt.add(Duration(seconds: s.elapsedSec)))
        .toLocal();
    if (out.isNotEmpty &&
        out.last.taskId == s.taskId &&
        !start.isAfter(out.last.end.add(gap))) {
      final last = out.removeLast();
      out.add((
        start: last.start,
        end: end,
        taskId: s.taskId,
        sessions: last.sessions + 1,
      ));
    } else {
      out.add((start: start, end: end, taskId: s.taskId, sessions: 1));
    }
  }
  return out;
}

/// Side-by-side columns for overlapping spans on a timeline, in minutes:
/// for each span, its column and how many columns its group needs.
List<({int column, int columns})> timelineColumns(
  List<({int start, int end})> spans,
) {
  final order = List.generate(spans.length, (i) => i)
    ..sort((a, b) => spans[a].start.compareTo(spans[b].start));
  final result = List.filled(spans.length, (column: 0, columns: 1));
  var group = <int>[];
  var groupEnd = -1;
  final columnEnds = <int>[];

  void close() {
    for (final i in group) {
      result[i] = (column: result[i].column, columns: columnEnds.length);
    }
    group = [];
    columnEnds.clear();
  }

  for (final i in order) {
    final span = spans[i];
    if (span.start >= groupEnd) {
      close();
      groupEnd = span.end;
    } else if (span.end > groupEnd) {
      groupEnd = span.end;
    }
    var column = columnEnds.indexWhere((end) => end <= span.start);
    if (column == -1) {
      column = columnEnds.length;
      columnEnds.add(span.end);
    } else {
      columnEnds[column] = span.end;
    }
    result[i] = (column: column, columns: 1);
    group.add(i);
  }
  close();
  return result;
}
