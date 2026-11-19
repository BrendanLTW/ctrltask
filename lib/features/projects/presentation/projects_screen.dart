import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project_calculations.dart';
import 'package:ctrltask/features/projects/presentation/archived_projects.dart';
import 'package:ctrltask/features/projects/presentation/project_card.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/projects/presentation/projects_empty.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S26 Projects (PRD §5.7): active project cards, or the archived list,
/// and S29 when there are none.
class ProjectsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  var _archived = false;

  void _create([ProjectPreset? preset]) =>
      unawaited(context.push(Routes.newProject, extra: preset));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final active = ref.watch(activeProjectsProvider).value ?? const [];
    final archived = ref.watch(archivedProjectsProvider).value ?? const [];
    final tasks = ref.watch(allTasksProvider).value ?? const [];
    final loaded =
        ref.watch(activeProjectsProvider).hasValue &&
        ref.watch(archivedProjectsProvider).hasValue;
    final none = loaded && active.isEmpty && archived.isEmpty;
    // Back to Active once the last archived project is restored.
    final showArchived = _archived && archived.isNotEmpty;

    final Widget body;
    if (!loaded) {
      body = const SizedBox.shrink();
    } else if (showArchived) {
      body = const ArchivedProjectsList();
    } else if (active.isEmpty) {
      body = Padding(
        padding: EdgeInsets.only(top: none ? 120 : 64),
        child: ProjectsEmpty(
          inboxCount: tasks
              .where((t) => t.projectId == null && t.status == TaskStatus.open)
              .length,
          onCreate: _create,
        ),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final project in active) ...[
            ProjectCard(
              project: project,
              progress: projectProgress(
                tasks.where((t) => t.projectId == project.id),
              ),
              today: today,
              labels: labels,
              onTap: () =>
                  unawaited(context.push(Routes.project('${project.id}'))),
            ),
            const SizedBox(height: AppSpacing.cardGap),
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            12,
            AppSpacing.screenX,
            AppShell.contentBottomPadding,
          ),
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.textX - AppSpacing.screenX),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.tabProjects,
                        style: context.text.pageTitle.copyWith(
                          color: colors.ink,
                        ),
                      ),
                    ),
                  ),
                  if (!none)
                    PillButton(
                      label: l10n.newShort,
                      icon: AppIcon.add,
                      onPressed: _create,
                    ),
                ],
              ),
            ),
            if (!none) ...[
              const SizedBox(height: 12),
              SegmentedControl<bool>(
                segments: [
                  (
                    value: false,
                    label: l10n.activeCount(active.length),
                    icon: null,
                  ),
                  (
                    value: true,
                    label: l10n.archivedCount(archived.length),
                    icon: null,
                  ),
                ],
                selected: showArchived,
                onChanged: (value) => setState(() => _archived = value),
              ),
              const SizedBox(height: 16),
            ],
            body,
          ],
        ),
      ),
    );
  }
}
