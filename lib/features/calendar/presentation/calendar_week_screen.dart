import 'dart:async';
import 'dart:math';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/calendar/domain/calendar_calculations.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_providers.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_span_chips.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_timeline.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S22 Calendar · Week, or Day without the week strip (PRD §5.6).
class CalendarWeekScreen extends ConsumerStatefulWidget {
  const new({required this.span, super.key});

  final CalendarSpan span;

  @override
  ConsumerState<CalendarWeekScreen> createState() => _CalendarWeekState();
}

class _CalendarWeekState extends ConsumerState<CalendarWeekScreen> {
  final _scroll = ScrollController();
  var _scrolled = false;

  /// Once the day has loaded: an hour before now on today, else an hour
  /// before the first block.
  void _scrollOnce({
    required List<({int start, int end})> spans,
    required int? nowMinute,
    required double above,
  }) {
    if (_scrolled) return;
    _scrolled = true;
    final first = CalendarTimeline.hours(spans, nowMinute).first;
    final target =
        nowMinute ??
        (spans.isEmpty ? first * 60 : spans.map((s) => s.start).reduce(min));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(
        (above + CalendarTimeline.offsetFor(target, first)).clamp(
          0,
          _scroll.position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final day = ref.watch(calendarDayProvider);
    final weekStart =
        ref.watch(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    final week = weekOf(day, weekStart);
    final isWeek = widget.span == CalendarSpan.week;
    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final projects = {
      for (final p in ref.watch(activeProjectsProvider).value ?? <Project>[])
        p.id: p,
    };
    final onDay = tasksDueOn(tasks, day);
    final counts = rangeCounts(
      tasks,
      start: isWeek ? week.start : day,
      end: isWeek ? week.end : day,
      today: today,
    );
    final statuses = dayStatuses(tasks, today: today);
    final focus = focusBlocks(
      ref.watch(focusOnProvider(day)).value ?? const [],
    );
    final timed = [
      for (final t in onDay)
        if (t.dueMinute != null) t,
    ];
    final nowMinute = day == today ? now.hour * 60 + now.minute : null;
    if (ref.watch(allTasksProvider).hasValue) {
      _scrollOnce(
        spans: CalendarTimeline.spansFor(timed, focus),
        nowMinute: nowMinute,
        // The Anytime row above the timeline.
        above: onDay.any((t) => t.dueMinute == null) ? 54 : 0,
      );
    }
    void pick(DateTime d) => ref.read(calendarDayProvider.notifier).day = d;
    void open(Task task) => unawaited(context.push(Routes.task('${task.id}')));

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubScreenBar(
              title: isWeek
                  ? labels.weekRange(week.start, week.end)
                  : labels.date(day),
              actionLabel: l10n.relativeToday,
              onAction: day == today ? null : () => pick(today),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenX,
              ),
              // Chips left, counts right; they stack with large text.
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                children: [
                  CalendarSpanChips(
                    selected: widget.span,
                    onChanged: (span) {
                      if (span == widget.span) return;
                      if (span == CalendarSpan.month) {
                        context.pop();
                      } else {
                        context.replace(Routes.calendar(span));
                      }
                    },
                  ),
                  Text(
                    l10n.dueCounts(counts.due, counts.overdue),
                    style: text.chip.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            if (isWeek)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX - 4,
                  14,
                  AppSpacing.screenX - 4,
                  0,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: () {
                          final d = DateTime(
                            week.start.year,
                            week.start.month,
                            week.start.day + i,
                          );
                          return _DayTile(
                            weekday: labels.weekday(d),
                            date: d.day,
                            selected: d == day,
                            dot: statuses[d] != null,
                            onTap: () => pick(d),
                          );
                        }(),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  14,
                  AppSpacing.screenX,
                  AppShell.contentBottomPadding,
                ),
                children: [
                  if (onDay.where((t) => t.dueMinute == null).toList()
                      case final anytime when anytime.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          Text(
                            l10n.anytime,
                            style: text.label.copyWith(color: colors.muted),
                          ),
                          for (final task in anytime) ...[
                            const SizedBox(width: 10),
                            AppChip(
                              label: task.title,
                              leading: ProjectDot(
                                projects[task.projectId]?.colorKey ??
                                    ProjectColorKey.grey,
                              ),
                              onTap: () => open(task),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  CalendarTimeline(
                    tasks: timed,
                    focus: focus,
                    projects: projects,
                    taskTitles: {for (final t in tasks) t.id: t.title},
                    labels: labels,
                    nowMinute: nowMinute,
                    onOpen: open,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One day in S22's week strip.
class _DayTile extends StatelessWidget {
  const new({
    required this.weekday,
    required this.date,
    required this.selected,
    required this.dot,
    required this.onTap,
  });

  final String weekday;
  final int date;
  final bool selected;
  final bool dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final fg = selected ? colors.onInk : colors.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? colors.ink : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r22),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.r22),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    weekday,
                    style: text.caption.copyWith(
                      color: selected ? colors.onInk : colors.muted,
                    ),
                  ),
                  Text('$date', style: text.statValue.copyWith(color: fg)),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dot
                          ? (selected ? colors.onInk : colors.muted)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
