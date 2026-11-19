import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/priority_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The priority's name, as on tags, chips and pickers (PRD §6.3).
String priorityLabel(BuildContext context, TaskPriority priority) {
  final l10n = context.l10n;
  return switch (priority) {
    TaskPriority.urgent => l10n.priorityUrgent,
    TaskPriority.high => l10n.priorityHigh,
    TaskPriority.medium => l10n.priorityMedium,
    TaskPriority.low => l10n.priorityLow,
  };
}

/// A pill with a flag and the priority's name, in its colour (DESIGN §7).
/// Rows show it for Urgent and High only.
class PriorityTag extends StatelessWidget {
  const new(this.priority, {super.key});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colors = context.projectColors.of(priority.colorKey);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.tile,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconView(AppIcon.flagFilled, size: 12, color: colors.icon),
          const SizedBox(width: 5),
          Text(
            priorityLabel(context, priority),
            style: context.text.tag.copyWith(color: colors.icon),
          ),
        ],
      ),
    );
  }
}
