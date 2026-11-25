import 'package:ctrltask/features/tasks/domain/task_priority.dart';

/// A piece of the title that was read as a hint, `start` to `end`.
typedef HintSpan = ({int start, int end});

/// What quick add read from a title (PRD §6.8), and the title without it.
typedef QuickAddHints = ({
  String title,
  DateTime? date,
  int? minute,
  TaskPriority? priority,
  List<String> tags,
  int? projectId,
  List<HintSpan> spans,
});

/// Not after a letter or digit, so "Monday" in "Mondays" or "#a" in
/// "a#a" don't count.
const _start = r'(?<![\p{L}\p{N}])';
const _end = r'(?![\p{L}\p{N}])';

final _day = RegExp(
  '$_start(today|tomorrow|monday|tuesday|wednesday|thursday|friday|'
  'saturday|sunday)$_end',
  caseSensitive: false,
  unicode: true,
);
final _time12 = RegExp(
  r'(?<![\p{L}\p{N}:])(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)'
  '$_end',
  caseSensitive: false,
  unicode: true,
);
final _time24 = RegExp(
  r'(?<![\p{L}\p{N}:])(?:at\s+)?(\d{1,2}):(\d{2})(?![\p{L}\p{N}:])',
  caseSensitive: false,
  unicode: true,
);
final _priority = RegExp(
  r'(?<!\S)!(urgent|high|medium|low)'
  '$_end',
  caseSensitive: false,
  unicode: true,
);
final _tag = RegExp(r'(?<!\S)#([\p{L}\p{N}_-]+)', unicode: true);
final _space = RegExp(r'\s+');
final _letterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);

const _weekdays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

/// Reads [text] for `today`, `tomorrow`, a weekday name, a time (`9am`,
/// `9:30 pm`, `14:30`, optionally after "at"), `!urgent` / `!high` /
/// `!medium` / `!low`, `#tags` and `@project` (one of [projects], by name,
/// any case). The first of each kind counts; an `@` that names no project
/// is left as written. A weekday is its next one after [today], as S10's
/// Saturday chip; a time alone is today. If nothing but hints were typed,
/// the title stays as typed.
QuickAddHints parseQuickAddHints(
  String text, {
  required DateTime today,
  List<({int id, String name})> projects = const [],
}) {
  final spans = <HintSpan>[];
  bool free(int start, int end) =>
      !spans.any((s) => start < s.end && end > s.start);
  HintSpan? take(Match? m) {
    if (m == null || !free(m.start, m.end)) return null;
    final span = (start: m.start, end: m.end);
    spans.add(span);
    return span;
  }

  DateTime plus(int days) =>
      DateTime(today.year, today.month, today.day + days);

  // Times first, so "at 9am" isn't read any other way.
  int? minute;
  for (final m in _time12.allMatches(text)) {
    final hour = int.parse(m[1]!);
    final min = m[2] == null ? 0 : int.parse(m[2]!);
    if (hour < 1 || hour > 12 || min > 59) continue;
    final pm = m[3]!.toLowerCase() == 'pm';
    if (take(m) == null) continue;
    minute = (hour % 12 + (pm ? 12 : 0)) * 60 + min;
    break;
  }
  if (minute == null) {
    for (final m in _time24.allMatches(text)) {
      final hour = int.parse(m[1]!);
      final min = int.parse(m[2]!);
      if (hour > 23 || min > 59 || take(m) == null) continue;
      minute = hour * 60 + min;
      break;
    }
  }

  DateTime? date;
  for (final m in _day.allMatches(text)) {
    if (take(m) == null) continue;
    final word = m[1]!.toLowerCase();
    date = switch (word) {
      'today' => plus(0),
      'tomorrow' => plus(1),
      _ => () {
        final days = (_weekdays.indexOf(word) + 1 - today.weekday) % 7;
        return plus(days == 0 ? 7 : days);
      }(),
    };
    break;
  }
  if (minute != null) date ??= plus(0);

  TaskPriority? priority;
  for (final m in _priority.allMatches(text)) {
    if (take(m) == null) continue;
    priority = TaskPriority.values.byName(m[1]!.toLowerCase());
    break;
  }

  final tags = <String>[];
  for (final m in _tag.allMatches(text)) {
    if (take(m) == null) continue;
    final name = m[1]!;
    if (!tags.any((t) => t.toLowerCase() == name.toLowerCase())) {
      tags.add(name);
    }
  }

  // The longest project name that follows an @, so "@Website redesign"
  // beats a project called "Website".
  int? projectId;
  final byLength = [...projects]
    ..sort((a, b) => b.name.length.compareTo(a.name.length));
  for (var i = text.indexOf('@'); i >= 0; i = text.indexOf('@', i + 1)) {
    if (i > 0 && !_space.hasMatch(text[i - 1])) continue;
    final rest = text.substring(i + 1).toLowerCase();
    for (final p in byLength) {
      final name = p.name.toLowerCase();
      if (!rest.startsWith(name)) continue;
      final end = i + 1 + name.length;
      // A whole name: "@Website" isn't "@Websites".
      final boundary =
          end == text.length || !_letterOrDigit.hasMatch(text[end]);
      if (boundary && free(i, end)) {
        spans.add((start: i, end: end));
        projectId = p.id;
        break;
      }
    }
    if (projectId != null) break;
  }

  spans.sort((a, b) => a.start.compareTo(b.start));
  final kept = StringBuffer();
  var from = 0;
  for (final s in spans) {
    kept.write(text.substring(from, s.start));
    from = s.end;
  }
  kept.write(text.substring(from));
  final title = kept.toString().replaceAll(_space, ' ').trim();
  return (
    title: title.isEmpty ? text.trim() : title,
    date: date,
    minute: minute,
    priority: priority,
    tags: tags,
    projectId: projectId,
    spans: spans,
  );
}
