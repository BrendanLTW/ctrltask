import 'dart:async';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/core/widgets/title_field_card.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/projects/presentation/project_style_pickers.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What S29's starter chips fill in on S28.
typedef ProjectPreset = ({
  String name,
  ProjectColorKey color,
  ProjectIconKey icon,
});

/// S28 New project, or Edit project with [projectId] (PRD §5.7). A new
/// project pops with the [Project] it created, so S17 can select it.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const new({this.projectId, this.preset, super.key});

  final int? projectId;
  final ProjectPreset? preset;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  late final _name = TextEditingController(text: widget.preset?.name)
    ..addListener(() => setState(() => _duplicate = false));
  final _description = TextEditingController();
  late ProjectColorKey _colour = widget.preset?.color ?? ProjectColorKey.orange;
  late ProjectIconKey _icon = widget.preset?.icon ?? ProjectIconKey.bag;
  DateTime? _deadline;
  Project? _original;
  var _saving = false;
  var _duplicate = false;

  bool get _editing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    if (widget.projectId case final id?) unawaited(_load(id));
  }

  Future<void> _load(int id) async {
    final projects = await ref
        .read(projectRepositoryProvider)
        .watchActive()
        .first;
    final project = projects.where((p) => p.id == id).firstOrNull;
    if (project == null || !mounted) return;
    setState(() {
      _original = project;
      _name.text = project.name;
      _description.text = project.description ?? '';
      _colour = project.colorKey;
      _icon = project.iconKey;
      _deadline = project.deadline;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      !_saving &&
      (!_editing || _original != null);

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    final repo = ref.read(projectRepositoryProvider);
    final description = _description.text.trim();
    try {
      if (_original case final original?) {
        await repo.update(
          original.copyWith(
            name: _name.text,
            description: description.isEmpty ? null : description,
            colorKey: _colour,
            iconKey: _icon,
            deadline: _deadline,
          ),
        );
        if (mounted) context.pop();
      } else {
        final project = await repo.add(
          name: _name.text,
          description: description.isEmpty ? null : description,
          colorKey: _colour,
          iconKey: _icon,
          deadline: _deadline,
        );
        if (mounted) context.pop(project);
      }
    } on DuplicateProjectNameException {
      if (mounted) {
        setState(() {
          _saving = false;
          _duplicate = true;
        });
      }
    }
  }

  Future<void> _pickDeadline() async {
    final choice = await showDueDatePicker(
      context,
      date: _deadline,
      showTime: false,
      title: context.l10n.deadline,
    );
    if (choice != null) setState(() => _deadline = choice.date);
  }

  Future<void> _archive(Project project) async {
    // shortcut: 3.7 also cancels the project's task reminders here.
    await ref.read(projectRepositoryProvider).archive(project.id);
    if (mounted) context.go(Routes.projects);
  }

  Future<void> _delete(Project project) async {
    final l10n = context.l10n;
    final count = ref.read(projectTaskCountsProvider).value?[project.id] ?? 0;
    final choice = await showAppDialog(
      context,
      icon: AppIcon.trash,
      title: l10n.deleteProjectTitle(project.name),
      body: count == 0
          ? l10n.deleteProjectBodyEmpty
          : l10n.deleteProjectBody(count),
      confirmLabel: count == 0 ? l10n.deleteProject : l10n.moveTasksToInbox,
      secondaryLabel: count == 0 ? null : l10n.deleteTasksToo,
      destructive: count == 0,
    );
    if (choice == DialogChoice.cancel || !mounted) return;
    // shortcut: 3.7 also cancels the deleted tasks' reminders here.
    await ref
        .read(projectRepositoryProvider)
        .delete(project.id, deleteTasks: choice == DialogChoice.secondary);
    if (mounted) context.go(Routes.projects);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final palette = context.projectColors.of(_colour);
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    // For the delete dialog's count.
    ref.watch(projectTaskCountsProvider);
    final original = _original;

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(
              title: _editing ? l10n.editProject : l10n.newProject,
              cancelLabel: l10n.cancel,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  24,
                ),
                children: [
                  Center(
                    child: ExcludeSemantics(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: palette.tile,
                          borderRadius: BorderRadius.circular(AppRadius.r24),
                        ),
                        child: AppIconView(
                          projectIcon(_icon),
                          size: 34,
                          color: palette.icon,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TitleFieldCard(
                    label: l10n.projectNameLabel,
                    titleController: _name,
                    titleHint: l10n.projectNameHint,
                    titleMaxLength: maxProjectNameLength,
                    descriptionController: _description,
                    descriptionHint: l10n.projectDescriptionHint,
                    descriptionMaxLength: maxProjectDescriptionLength,
                    autofocus: !_editing && widget.preset == null,
                  ),
                  if (_duplicate)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.textX - AppSpacing.screenX,
                        8,
                        0,
                        0,
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.duplicateProjectName(_name.text.trim()),
                          style: text.caption.copyWith(color: colors.negative),
                        ),
                      ),
                    ),
                  SectionHeader(l10n.colourLabel.toUpperCase()),
                  ColourSwatches(
                    selected: _colour,
                    onChanged: (key) => setState(() => _colour = key),
                  ),
                  SectionHeader(l10n.iconLabel.toUpperCase()),
                  ProjectIconPicker(
                    selected: _icon,
                    onChanged: (key) => setState(() => _icon = key),
                  ),
                  const SizedBox(height: 18),
                  ListGroup(
                    children: [
                      ListGroupRow(
                        title: l10n.deadline,
                        value: switch (_deadline) {
                          final d? => labels.dateYear(d),
                          null => l10n.noDeadline,
                        },
                        valueEmphasis: _deadline != null,
                        leading: const IconTile(
                          icon: AppIcon.flag,
                          color: ProjectColorKey.grey,
                          size: IconTileSize.medium,
                        ),
                        trailing: _deadline == null
                            ? null
                            : IconButton(
                                tooltip: l10n.removeDeadline,
                                onPressed: () =>
                                    setState(() => _deadline = null),
                                icon: AppIconView(
                                  AppIcon.close,
                                  size: 18,
                                  color: colors.muted,
                                ),
                              ),
                        onTap: () => unawaited(_pickDeadline()),
                      ),
                    ],
                  ),
                  if (original != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: TextLink(
                        label: l10n.archiveProject,
                        onPressed: () => unawaited(_archive(original)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: TextLink(
                        label: l10n.deleteProject,
                        destructive: true,
                        onPressed: () => unawaited(_delete(original)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                8,
                AppSpacing.screenX,
                16,
              ),
              child: PrimaryButton(
                label: _editing ? l10n.save : l10n.createProject,
                onPressed: _valid ? () => unawaited(_save()) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
