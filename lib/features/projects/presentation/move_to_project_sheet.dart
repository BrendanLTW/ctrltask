import 'dart:async';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/search_field.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The project picked on S17; a null `projectId` is Inbox.
typedef ProjectPick = ({int? projectId});

typedef _Choice = ({int? projectId, bool create});

/// Opens S17 Move to project with [current] ticked. Resolves to the pick,
/// or null if closed. New project opens S28 and picks what it creates.
Future<ProjectPick?> showMoveToProject(
  BuildContext context, {
  required int? current,
}) async {
  final choice = await showAppSheet<_Choice>(
    context,
    title: context.l10n.moveToProject,
    builder: (_) => MoveToProjectSheet(current: current),
  );
  if (choice == null) return null;
  if (!choice.create) return (projectId: choice.projectId);
  if (!context.mounted) return null;
  final created = await context.push<Project>(Routes.newProject);
  return created == null ? null : (projectId: created.id);
}

/// S17's content (PRD §5.5): search, Inbox, active projects with their
/// open counts, and New project. Choosing closes the sheet.
class MoveToProjectSheet extends ConsumerStatefulWidget {
  const new({required this.current, super.key});

  final int? current;

  @override
  ConsumerState<MoveToProjectSheet> createState() => _MoveToProjectSheetState();
}

class _MoveToProjectSheetState extends ConsumerState<MoveToProjectSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _choose(int? projectId, {bool create = false}) =>
      Navigator.of(context).pop((projectId: projectId, create: create));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final query = _search.text.trim().toLowerCase();
    bool matches(String name) =>
        query.isEmpty || name.toLowerCase().contains(query);
    final projects = [
      for (final p in ref.watch(activeProjectsProvider).value ?? <Project>[])
        if (matches(p.name)) p,
    ];
    final open = <int, int>{};
    for (final task in ref.watch(openTasksProvider).value ?? const <Task>[]) {
      if (task.projectId case final id?) open[id] = (open[id] ?? 0) + 1;
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchField(
            controller: _search,
            hint: l10n.searchProjects,
            inSheet: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ListGroup(
            inSheet: true,
            children: [
              if (matches(l10n.inbox))
                ListGroupRow(
                  title: l10n.inbox,
                  subtitle: l10n.noProject,
                  leading: const IconTile(
                    icon: AppIcon.inbox,
                    color: ProjectColorKey.grey,
                    size: IconTileSize.medium,
                  ),
                  selected: widget.current == null,
                  chevron: false,
                  onTap: () => _choose(null),
                ),
              for (final project in projects)
                ListGroupRow(
                  title: project.name,
                  subtitle: l10n.openTasksCount(open[project.id] ?? 0),
                  leading: IconTile.forProject(
                    project.iconKey,
                    color: project.colorKey,
                    size: IconTileSize.medium,
                  ),
                  selected: widget.current == project.id,
                  chevron: false,
                  onTap: () => _choose(project.id),
                ),
              ListGroupRow(
                title: l10n.newProject,
                titleColor: colors.muted,
                leading: SizedBox(
                  width: 40,
                  child: AppIconView(
                    AppIcon.add,
                    size: 22,
                    color: colors.muted,
                  ),
                ),
                chevron: false,
                onTap: () => _choose(null, create: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
