import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/links/link_opener.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/detail/delete_task_dialog.dart';
import 'package:ctrltask/features/tasks/presentation/detail/detail_header.dart';
import 'package:ctrltask/features/tasks/presentation/detail/due_section.dart';
import 'package:ctrltask/features/tasks/presentation/detail/link_rows.dart';
import 'package:ctrltask/features/tasks/presentation/detail/subtask_progress.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_detail_screen.g.dart';

@riverpod
Stream<TaskDetails?> taskDetails(Ref ref, int id) =>
    ref.watch(taskRepositoryProvider).watchDetails(id);

/// S12 Task detail (PRD §5.4): everything about one task, live. Completing
/// here goes through the shared use case; Delete asks first (S13).
class TaskDetailScreen extends ConsumerStatefulWidget {
  const new({required this.taskId, super.key});

  final int taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  var _leaving = false;

  void _leave() {
    if (_leaving || !mounted) return;
    _leaving = true;
    Navigator.of(context).maybePop();
  }

  Future<void> _update(TaskDetails details) =>
      ref.read(taskRepositoryProvider).update(details);

  Future<void> _openLink(TaskLink link) async {
    final opened = await ref.read(linkOpenerProvider).open(Uri.parse(link.url));
    if (!opened && mounted) {
      showCompleteToast(
        context,
        message: context.l10n.linkFailed,
        success: false,
      );
    }
  }

  Future<void> _pickDue(TaskDetails details) async {
    final task = details.task;
    final choice = await showDueDatePicker(
      context,
      date: task.dueDate,
      minute: task.dueMinute,
    );
    if (choice == null) return;
    await _update(
      details.copyWith(
        task: task.copyWith(dueDate: choice.date, dueMinute: choice.minute),
      ),
    );
  }

  Future<void> _delete(TaskDetails details, Project? project) async {
    final choice = await confirmDeleteTask(
      context,
      title: details.task.title,
      subtaskCount: details.subtasks.length,
      project: project?.name ?? context.l10n.inbox,
    );
    if (!mounted) return;
    switch (choice) {
      case DialogChoice.confirm:
        // shortcut: 3.7 also cancels the task's reminder here.
        _leaving = true;
        await ref.read(taskRepositoryProvider).delete(details.task.id);
        if (mounted) Navigator.of(context).maybePop();
      case DialogChoice.secondary:
        await setTaskDone(context, ref, details.task, done: true);
      case DialogChoice.cancel:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final async = ref.watch(taskDetailsProvider(widget.taskId));
    ref.listen(taskDetailsProvider(widget.taskId), (previous, next) {
      // Gone, deleted here or elsewhere: back to where we came from.
      if (previous?.value != null && next.hasValue && next.value == null) {
        _leave();
      }
    });
    final details = async.value;
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final projects = ref.watch(activeProjectsProvider).value ?? const [];
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(
              title: l10n.taskScreenTitle,
              actionLabel: l10n.edit,
              onAction: details == null
                  ? null
                  : () => context.push(Routes.editTask('${widget.taskId}')),
            ),
            if (details != null)
              Expanded(
                child: _body(
                  details,
                  projects
                      .where((p) => p.id == details.task.projectId)
                      .firstOrNull,
                  today,
                  prefs,
                  labels,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    TaskDetails details,
    Project? project,
    DateTime today,
    Preferences prefs,
    DateLabels labels,
  ) {
    final task = details.task;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenX,
        8,
        AppSpacing.screenX,
        40,
      ),
      children: [
        DetailHeader(
          task: task,
          project: project,
          tags: details.tags,
          onToggle: (done) =>
              unawaited(setTaskDone(context, ref, task, done: done)),
        ),
        DueSection(
          dueDate: task.dueDate,
          dueMinute: task.dueMinute,
          today: today,
          weekStart: prefs.weekStart,
          labels: labels,
          onMove: (date) => unawaited(
            _update(details.copyWith(task: task.copyWith(dueDate: date))),
          ),
          onPick: () => unawaited(_pickDue(details)),
        ),
        // shortcut: the Reminder and Repeat rows come with 3.5 and 3.7.
        if (details.links.isNotEmpty) ...[
          const SizedBox(height: 16),
          LinkRows(
            links: details.links,
            onOpen: (link) => unawaited(_openLink(link)),
          ),
        ],
        if (details.subtasks.isNotEmpty)
          SubtaskProgress(
            subtasks: details.subtasks,
            onToggle: (subtask, {required done}) => unawaited(
              _update(
                details.copyWith(
                  subtasks: [
                    for (final s in details.subtasks)
                      if (s.id == subtask.id) s.copyWith(done: done) else s,
                  ],
                ),
              ),
            ),
          ),
        // shortcut: Start a focus session comes with 3.1.
        const SizedBox(height: 24),
        Center(
          child: TextLink(
            label: context.l10n.deleteTask,
            destructive: true,
            onPressed: () => unawaited(_delete(details, project)),
          ),
        ),
      ],
    );
  }
}
