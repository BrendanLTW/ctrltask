import 'dart:math' as math;

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/features/calendar/domain/calendar_calculations.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S22's day timeline: hour rails, timed tasks as blocks in their project
/// colour, focus as purple blocks, and the now line on today.
class CalendarTimeline extends StatelessWidget {
  const new({
    required this.tasks,
    required this.focus,
    required this.projects,
    required this.taskTitles,
    required this.labels,
    required this.nowMinute,
    required this.onOpen,
    super.key,
  });

  /// Pixels per hour (DESIGN: 60).
  static const hourHeight = 60.0;

  /// Space above the first rail, for its label.
  static const top = 12.0;

  /// Where each task and focus block sits, in minutes after midnight. A
  /// done task is a slim 40-minute bar.
  static List<({int start, int end})> spansFor(
    List<Task> tasks,
    List<FocusBlock> focus,
  ) {
    int minuteOf(DateTime t) => t.hour * 60 + t.minute;
    return [
      for (final t in tasks)
        (
          start: t.dueMinute!,
          end: t.dueMinute! + (t.status == TaskStatus.done ? 40 : 60),
        ),
      for (final f in focus)
        (
          start: minuteOf(f.start),
          end: math.max(minuteOf(f.end), minuteOf(f.start) + 40),
        ),
    ];
  }

  /// The first and last rail: 8 AM to 8 PM, stretched to fit [spans]
  /// and [nowMinute].
  static ({int first, int last}) hours(
    List<({int start, int end})> spans,
    int? nowMinute,
  ) => (
    first: [
      8,
      for (final s in spans) s.start ~/ 60,
      ?(nowMinute == null ? null : nowMinute ~/ 60),
    ].reduce(math.min),
    last: [
      20,
      for (final s in spans) (s.end + 59) ~/ 60,
      ?(nowMinute == null ? null : nowMinute ~/ 60 + 1),
    ].reduce(math.max).clamp(0, 24),
  );

  /// The scroll offset that puts [minute] an hour from the top.
  static double offsetFor(int minute, int firstHour) =>
      math.max(0, (minute - 60 - firstHour * 60) / 60 * hourHeight);

  /// Timed tasks on the day, each drawn an hour long.
  final List<Task> tasks;
  final List<FocusBlock> focus;
  final Map<int, Project> projects;

  /// For focus blocks: the linked task's title.
  final Map<int, String> taskTitles;
  final DateLabels labels;

  /// Minutes after midnight now, on today only.
  final int? nowMinute;
  final ValueChanged<Task> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final palette = context.projectColors;
    final spans = spansFor(tasks, focus);
    final columns = timelineColumns(spans);
    final range = hours(spans, nowMinute);
    double y(int minute) => top + (minute - range.first * 60) / 60 * hourHeight;
    const railWidth = 56.0;

    String clock(int minute) =>
        labels.clock(DateTime(2000, 1, 1, minute ~/ 60, minute % 60));

    return LayoutBuilder(
      builder: (context, box) {
        final blockWidth = box.maxWidth - railWidth - 4;
        Widget place(int i, Widget child) {
          final span = spans[i];
          final c = columns[i];
          final width = blockWidth / c.columns;
          return Positioned(
            top: y(span.start) + 2,
            height: y(span.end) - y(span.start) - 4,
            left: railWidth + 4 + c.column * width,
            width: width - 4,
            child: child,
          );
        }

        return SizedBox(
          height: top + (range.last - range.first) * hourHeight + 16,
          child: Stack(
            children: [
              for (var h = range.first; h <= range.last; h++) ...[
                Positioned(
                  top: y(h * 60) - 9,
                  left: 0,
                  width: railWidth - 8,
                  child: Text(
                    labels.timeShort((h % 24) * 60),
                    textAlign: TextAlign.right,
                    style: text.labelSm.copyWith(color: colors.muted),
                  ),
                ),
                Positioned(
                  top: y(h * 60),
                  left: railWidth,
                  right: 0,
                  child: Divider(height: 1, color: colors.divider),
                ),
              ],
              for (final (i, task) in tasks.indexed)
                place(i, () {
                  final done = task.status == TaskStatus.done;
                  final key =
                      projects[task.projectId]?.colorKey ??
                      ProjectColorKey.grey;
                  final start = task.dueMinute!;
                  final urgentOrHigh =
                      task.priority == TaskPriority.urgent ||
                      task.priority == TaskPriority.high;
                  return _Block(
                    slim: done,
                    background: done ? colors.raised : palette.of(key).tile,
                    bar: done ? colors.disabled : palette.of(key).solid,
                    title: task.title,
                    detail: done
                        ? null
                        : [
                            l10n.timeRange(clock(start), clock(start + 60)),
                            if (urgentOrHigh)
                              priorityLabel(context, task.priority),
                          ].join(' · '),
                    done: done,
                    onTap: () => onOpen(task),
                  );
                }()),
              for (final (j, block) in focus.indexed)
                place(
                  tasks.length + j,
                  _Block(
                    background: palette.of(ProjectColorKey.purple).tile,
                    bar: palette.of(ProjectColorKey.purple).solid,
                    title: switch (taskTitles[block.taskId]) {
                      final title? => l10n.focusBlock(title),
                      null => l10n.focusBlockNoTask,
                    },
                    detail: [
                      l10n.timeRange(
                        labels.clock(block.start),
                        labels.clock(block.end),
                      ),
                      if (block.sessions > 1)
                        l10n.focusSessions(block.sessions),
                    ].join(' · '),
                  ),
                ),
              if (nowMinute case final minute?)
                Positioned(
                  top: y(minute) - 6,
                  left: railWidth - 6,
                  right: 0,
                  child: Semantics(
                    container: true,
                    label: l10n.nowLine(clock(minute)),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.negative,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Container(height: 2, color: colors.negative),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A block on the timeline: a coloured bar, the title and its times.
class _Block extends StatelessWidget {
  const new({
    required this.background,
    required this.bar,
    required this.title,
    required this.detail,
    this.done = false,
    this.slim = false,
    this.onTap,
  });

  final Color background;
  final Color bar;
  final String title;
  final String? detail;
  final bool done;

  /// A one-line bar with less padding (a done task).
  final bool slim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.r20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: slim ? 4 : 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: bar,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRect(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flexible: a short block clips its text rather than
                      // overflow with large text.
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.rowTitle.copyWith(
                            color: done ? colors.muted : colors.ink,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: colors.muted,
                          ),
                        ),
                      ),
                      if (detail case final detail?)
                        Flexible(
                          child: Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.caption.copyWith(
                              color: colors.chipText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
