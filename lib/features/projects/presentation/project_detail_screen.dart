import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/task_row.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_calculations.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_header.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/features/tasks/presentation/task_tile_data.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S27 Project detail (PRD §5.7): the header card, open tasks, Add task,
/// and the Completed row, all live.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  const new({required this.projectId, super.key});

  final int projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  var _showDone = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final projects = ref.watch(activeProjectsProvider);
    final project = projects.value
        ?.where((p) => p.id == widget.projectId)
        .firstOrNull;
    final tasks =
        ref.watch(projectTasksProvider(widget.projectId)).value ?? const [];
    final focused = Duration(
      seconds:
          ref.watch(projectFocusedSecondsProvider(widget.projectId)).value ?? 0,
    );
    final subtasks = ref.watch(subtaskProgressProvider).value ?? const {};
    final open = [
      for (final t in tasks)
        if (t.status == TaskStatus.open) t,
    ];
    final done = [
      for (final t in tasks)
        if (t.status == TaskStatus.done) t,
    ]..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    TaskRow row(Task task) => TaskRow(
      data: taskTileData(
        task,
        l10n: l10n,
        labels: labels,
        now: now,
        projects: const {},
        subtasks: subtasks,
        showDay: true,
      ),
      onToggle: (value) =>
          unawaited(setTaskDone(context, ref, task, done: value)),
      onTap: () => unawaited(context.push(Routes.task('${task.id}'))),
    );

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(
              title: '',
              actionLabel: l10n.editProject,
              actionIcon: AppIcon.ellipsis,
              onAction: project == null
                  ? null
                  : () => unawaited(
                      context.push(Routes.editProject('${project.id}')),
                    ),
            ),
            if (project != null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenX,
                    8,
                    AppSpacing.screenX,
                    40,
                  ),
                  children: [
                    ProjectHeader(
                      project: project,
                      progress: projectProgress(tasks),
                      focused: focused,
                      today: today,
                      labels: labels,
                    ),
                    // shortcut: the Board view link comes with S20 (v1.1).
                    SectionHeader(l10n.openCount(open.length).toUpperCase()),
                    ListGroup(
                      children: [
                        ...open.map(row),
                        _AddTaskRow(project: project),
                      ],
                    ),
                    if (done.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.cardGap),
                      ListGroup(
                        children: [
                          ListGroupRow(
                            title: l10n.completed,
                            subtitle: done.map((t) => t.title).join(', '),
                            subtitleMaxLines: 2,
                            value: '${done.length}',
                            leading: const IconTile(
                              icon: AppIcon.check,
                              color: ProjectColorKey.green,
                              size: IconTileSize.medium,
                            ),
                            onTap: () => setState(() => _showDone = !_showDone),
                          ),
                        ],
                      ),
                      if (_showDone) ...[
                        const SizedBox(height: AppSpacing.cardGap),
                        ListGroup(children: done.map(row).toList()),
                      ],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "+ Add task to {project}": S10 with the project set.
class _AddTaskRow extends StatelessWidget {
  const new({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListGroupRow(
      title: context.l10n.addTaskTo(project.name),
      titleColor: colors.muted,
      leading: SizedBox(
        width: 40,
        child: AppIconView(AppIcon.add, size: 22, color: colors.muted),
      ),
      chevron: false,
      onTap: () => unawaited(showQuickAdd(context, projectId: project.id)),
    );
  }
}
