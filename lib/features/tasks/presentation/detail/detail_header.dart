import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/core/widgets/tag_chip.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tags/domain/tag.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S12's top: a large checkbox and the title, the priority, project and
/// tag chips, and the description.
class DetailHeader extends StatelessWidget {
  const new({
    required this.task,
    required this.project,
    required this.tags,
    required this.onToggle,
    required this.onProject,
    required this.onTags,
    super.key,
  });

  final Task task;
  final Project? project;
  final List<Tag> tags;
  final ValueChanged<bool> onToggle;

  /// Opens S17 to move the task.
  final VoidCallback onProject;

  /// Opens S18 to change the tags.
  final VoidCallback onTags;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final done = task.status == TaskStatus.done;
    final urgentOrHigh =
        task.priority == TaskPriority.urgent ||
        task.priority == TaskPriority.high;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskCheckbox(
              title: task.title,
              priority: task.priority,
              done: done,
              size: 28,
              onChanged: onToggle,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        task.title,
                        style: text.detailTitle.copyWith(
                          color: done ? colors.muted : colors.ink,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: colors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (urgentOrHigh) PriorityTag(task.priority),
                        _ProjectChip(project, onTap: onProject),
                        // 44 high to tap, like the project chip.
                        Semantics(
                          button: true,
                          label: context.l10n.tagsTitle,
                          child: InkWell(
                            onTap: onTags,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  for (final tag in tags) TagChip(tag.name),
                                  if (tags.isEmpty)
                                    AddTagChip(label: context.l10n.addTagChip),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (task.description case final description?) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              description,
              style: text.body.copyWith(color: colors.ink),
            ),
          ),
        ],
      ],
    );
  }
}

/// The project as a pill with its dot, or Inbox.
class _ProjectChip extends StatelessWidget {
  const new(this.project, {required this.onTap});

  final Project? project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 44 high to tap; the pill inside is 24, taller with large text, and
    // the name shrinks to fit.
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Align(widthFactor: 1, child: _pill(context)),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: colors.raised,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProjectDot(project?.colorKey ?? ProjectColorKey.grey),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              project?.name ?? context.l10n.inbox,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.tag.copyWith(color: colors.chipText),
            ),
          ),
        ],
      ),
    );
  }
}
