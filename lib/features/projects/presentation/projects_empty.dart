import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/empty_state.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S29 No projects yet: what projects are for, Create a project, and
/// starter chips that prefill S28.
class ProjectsEmpty extends StatelessWidget {
  const new({required this.inboxCount, required this.onCreate, super.key});

  /// Open tasks with no project.
  final int inboxCount;

  /// Opens S28, prefilled when a starter chip was tapped.
  final ValueChanged<ProjectPreset?> onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final starters = <ProjectPreset>[
      (
        name: l10n.starterWork,
        color: ProjectColorKey.blue,
        icon: ProjectIconKey.briefcase,
      ),
      (
        name: l10n.starterHome,
        color: ProjectColorKey.green,
        icon: ProjectIconKey.home,
      ),
      (
        name: l10n.starterLearning,
        color: ProjectColorKey.purple,
        icon: ProjectIconKey.book,
      ),
      (
        name: l10n.starterTravel,
        color: ProjectColorKey.pink,
        icon: ProjectIconKey.plane,
      ),
    ];
    return EmptyState(
      icon: AppIcon.folderPlus,
      title: l10n.projectsEmptyTitle,
      body: l10n.projectsEmptyBody(inboxCount),
      actionLabel: l10n.createAProject,
      actionIcon: AppIcon.add,
      onAction: () => onCreate(null),
      footer: Column(
        children: [
          Text(
            l10n.popularStartingPoints.toUpperCase(),
            textAlign: TextAlign.center,
            style: context.text.label.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final starter in starters)
                AppChip(
                  label: starter.name,
                  leading: ProjectDot(starter.color),
                  onTap: () => onCreate(starter),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
