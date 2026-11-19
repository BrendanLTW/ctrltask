import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/empty_state.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S08's blank page: Add a task, and starter chips that open quick add with
/// their title, or Create a project.
class HomeFirstRun extends StatelessWidget {
  const new({
    required this.onAddTask,
    required this.onCreateProject,
    super.key,
  });

  /// With a suggestion's title, or null for a blank task.
  final ValueChanged<String?> onAddTask;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: EmptyState(
        icon: AppIcon.tasks,
        title: l10n.blankPageTitle,
        body: l10n.blankPageBody,
        actionLabel: l10n.addATask,
        actionIcon: AppIcon.add,
        onAction: () => onAddTask(null),
        footer: Column(
          children: [
            Text(
              l10n.startWithThese,
              textAlign: TextAlign.center,
              style: context.text.label.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                for (final title in [
                  l10n.suggestionPlanWeek,
                  l10n.suggestionClearInbox,
                  l10n.suggestionWalk,
                ])
                  AppChip(label: title, onTap: () => onAddTask(title)),
                AppChip(
                  label: l10n.createAProject,
                  leading: AppIconView(
                    AppIcon.folder,
                    size: 18,
                    color: colors.chipText,
                  ),
                  onTap: onCreateProject,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
