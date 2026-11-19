import 'dart:async';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/priority_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/title_field_card.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/move_to_project_sheet.dart';
import 'package:ctrltask/features/tasks/domain/subtask.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_link.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/features/tasks/presentation/form/add_link_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/form/link_section.dart';
import 'package:ctrltask/features/tasks/presentation/form/subtask_section.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S11 New task / Edit task (PRD §5.4): title and description, the
/// essentials, subtasks, and notes and links. New tasks may start from
/// quick add's [draft]; [taskId] edits a task with every field prefilled.
class TaskFormScreen extends ConsumerStatefulWidget {
  const new({this.draft, this.taskId, super.key});

  /// What quick add's More carried over (S10).
  final TaskDraft? draft;
  final int? taskId;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late final _title = TextEditingController(text: widget.draft?.title)
    ..addListener(() => setState(() {}));
  late final _description = TextEditingController(
    text: widget.draft?.description,
  );
  late DateTime? _dueDate = widget.draft?.dueDate;
  late int? _dueMinute = widget.draft?.dueMinute;
  late TaskPriority _priority = widget.draft?.priority ?? TaskPriority.medium;
  late int? _projectId = widget.draft?.projectId;
  late final List<Subtask> _subtasks = [
    for (final (i, title) in (widget.draft?.subtasks ?? const []).indexed)
      Subtask(id: 0, taskId: 0, title: title, sortOrder: i),
  ];
  late final List<TaskLink> _links = [
    for (final l
        in widget.draft?.links ?? const <({String title, String url})>[])
      TaskLink(id: 0, taskId: 0, title: l.title, url: l.url),
  ];

  /// The task being edited, as loaded.
  TaskDetails? _original;
  var _saving = false;

  bool get _editing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (widget.taskId case final id?) unawaited(_load(id));
  }

  Future<void> _load(int id) async {
    final details = await ref
        .read(taskRepositoryProvider)
        .watchDetails(id)
        .first;
    if (details == null || !mounted) return;
    final task = details.task;
    setState(() {
      _original = details;
      _title.text = task.title;
      _description.text = task.description ?? '';
      _dueDate = task.dueDate;
      _dueMinute = task.dueMinute;
      _priority = task.priority;
      _projectId = task.projectId;
      _subtasks
        ..clear()
        ..addAll(details.subtasks);
      _links
        ..clear()
        ..addAll(details.links);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _valid =>
      _title.text.trim().isNotEmpty &&
      !_saving &&
      (!_editing || _original != null);

  String? get _descriptionOrNull {
    final text = _description.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    final repo = ref.read(taskRepositoryProvider);
    final original = _original;
    if (original == null) {
      final task = await repo.add(
        TaskDraft(
          title: _title.text,
          description: _descriptionOrNull,
          dueDate: _dueDate,
          dueMinute: _dueMinute,
          priority: _priority,
          projectId: _projectId,
          subtasks: [for (final s in _subtasks) s.title],
          links: [for (final l in _links) (title: l.title, url: l.url)],
          reminder: widget.draft?.reminder ?? ReminderOffset.none,
          repeat: widget.draft?.repeat,
          tagIds: widget.draft?.tagIds ?? const {},
        ),
      );
      // A new task's subtasks start open; carry over any ticked here.
      if (_subtasks.any((s) => s.done)) {
        final details = (await repo.watchDetails(task.id).first)!;
        await repo.update(
          details.copyWith(
            subtasks: [
              for (final (i, s) in details.subtasks.indexed)
                if (i < _subtasks.length)
                  s.copyWith(done: _subtasks[i].done)
                else
                  s,
            ],
          ),
        );
      }
    } else {
      await repo.update(
        original.copyWith(
          task: original.task.copyWith(
            title: _title.text,
            description: _descriptionOrNull,
            dueDate: _dueDate,
            dueMinute: _dueMinute,
            priority: _priority,
            projectId: _projectId,
          ),
          subtasks: [
            for (final (i, s) in _subtasks.indexed) s.copyWith(sortOrder: i),
          ],
          links: _links,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDue() async {
    final choice = await showDueDatePicker(
      context,
      date: _dueDate,
      minute: _dueMinute,
    );
    if (choice == null) return;
    setState(() {
      _dueDate = choice.date;
      _dueMinute = choice.minute;
    });
  }

  Future<void> _pickProject() async {
    final pick = await showMoveToProject(context, current: _projectId);
    if (pick != null && mounted) setState(() => _projectId = pick.projectId);
  }

  Future<void> _addLink() async {
    final link = await showAddLinkSheet(context);
    if (link == null) return;
    setState(
      () => _links.add(
        TaskLink(id: 0, taskId: 0, title: link.title, url: link.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final palette = context.projectColors;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final projects = ref.watch(activeProjectsProvider).value ?? const [];
    final project = projects.where((p) => p.id == _projectId).firstOrNull;
    final due = switch ((_dueDate, _dueMinute)) {
      (null, _) => l10n.noDate,
      (final date?, null) => labels.date(date),
      (final date?, final minute?) => l10n.titleWithDetail(
        labels.date(date),
        labels.time(minute),
      ),
    };

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(
              title: _editing ? l10n.editTask : l10n.newTask,
              cancelLabel: l10n.cancel,
              actionLabel: l10n.save,
              onAction: _valid ? () => unawaited(_save()) : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  TitleFieldCard(
                    label: l10n.titleLabel,
                    titleController: _title,
                    titleHint: l10n.titleHint,
                    titleMaxLength: maxTaskTitleLength,
                    descriptionController: _description,
                    descriptionHint: l10n.descriptionHint,
                    descriptionMaxLength: maxTaskDescriptionLength,
                    autofocus: !_editing && widget.draft == null,
                  ),
                  SectionHeader(l10n.essentials),
                  ListGroup(
                    children: [
                      ListGroupRow(
                        title: l10n.due,
                        value: due,
                        valueEmphasis: _dueDate != null,
                        onTap: () => unawaited(_pickDue()),
                        leading: const IconTile(
                          icon: AppIcon.calendar,
                          color: ProjectColorKey.grey,
                          size: IconTileSize.medium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconTile(
                                  icon: AppIcon.flag,
                                  color: ProjectColorKey.grey,
                                  size: IconTileSize.medium,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  l10n.priority,
                                  style: text.rowTitle.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final p in TaskPriority.values)
                                  AppChip(
                                    label: priorityLabel(context, p),
                                    small: true,
                                    selected: _priority == p,
                                    leading: AppIconView(
                                      AppIcon.flagFilled,
                                      size: 16,
                                      color: p == TaskPriority.low
                                          ? palette
                                                .of(ProjectColorKey.grey)
                                                .solid
                                          : context.priorityRing(p),
                                    ),
                                    onTap: () => setState(() => _priority = p),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListGroupRow(
                        title: l10n.project,
                        value: project?.name ?? l10n.inbox,
                        valueEmphasis: project != null,
                        onTap: () => unawaited(_pickProject()),
                        leading: project == null
                            ? const IconTile(
                                icon: AppIcon.inbox,
                                color: ProjectColorKey.grey,
                                size: IconTileSize.medium,
                              )
                            : IconTile.forProject(
                                project.iconKey,
                                color: project.colorKey,
                                size: IconTileSize.medium,
                              ),
                      ),
                    ],
                  ),
                  // Tags, reminder and repeat (MORE DETAILS) come with
                  // tasks 3.4–3.7.
                  SubtaskSection(
                    subtasks: _subtasks,
                    onAdd: (title) => setState(
                      () => _subtasks.add(
                        Subtask(
                          id: 0,
                          taskId: _original?.task.id ?? 0,
                          title: title,
                          sortOrder: _subtasks.length,
                        ),
                      ),
                    ),
                    onToggle: (i, {required done}) => setState(
                      () => _subtasks[i] = _subtasks[i].copyWith(done: done),
                    ),
                    onRemove: (i) => setState(() => _subtasks.removeAt(i)),
                  ),
                  LinkSection(
                    links: _links,
                    onAdd: () => unawaited(_addLink()),
                    onRemove: (i) => setState(() => _links.removeAt(i)),
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
