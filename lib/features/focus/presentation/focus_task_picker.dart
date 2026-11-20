import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/search_field.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The task chosen to work on; a null `taskId` is No task.
typedef FocusTaskPick = ({int? taskId});

/// Opens the task picker behind S30's Change. It isn't designed; as PRD
/// §12 suggests, it follows S17: search, No task, then open tasks with
/// today's first. Resolves to the pick, or null if closed.
Future<FocusTaskPick?> showFocusTaskPicker(
  BuildContext context, {
  required int? current,
}) => showAppSheet<FocusTaskPick>(
  context,
  title: context.l10n.workingOn,
  builder: (_) => FocusTaskPicker(current: current),
);

class FocusTaskPicker extends ConsumerStatefulWidget {
  const new({required this.current, super.key});

  final int? current;

  @override
  ConsumerState<FocusTaskPicker> createState() => _FocusTaskPickerState();
}

class _FocusTaskPickerState extends ConsumerState<FocusTaskPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _choose(int? taskId) => Navigator.of(context).pop((taskId: taskId));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final query = _search.text.trim().toLowerCase();
    final open = ref.watch(openTasksProvider).value ?? const <Task>[];
    final projects = {
      for (final p in ref.watch(activeProjectsProvider).value ?? <Project>[])
        p.id: p,
    };
    final tasks = [
      ...orderToday(open.where((t) => t.dueDate == today)),
      ...open.where((t) => t.dueDate != today),
    ].where((t) => query.isEmpty || t.title.toLowerCase().contains(query));
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchField(
            controller: _search,
            hint: l10n.searchTasks,
            inSheet: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ListGroup(
            inSheet: true,
            children: [
              if (query.isEmpty)
                ListGroupRow(
                  title: l10n.noTask,
                  leading: const IconTile(
                    icon: AppIcon.timer,
                    color: ProjectColorKey.grey,
                    size: IconTileSize.medium,
                  ),
                  selected: widget.current == null,
                  chevron: false,
                  onTap: () => _choose(null),
                ),
              for (final task in tasks)
                ListGroupRow(
                  title: task.title,
                  subtitle: projects[task.projectId]?.name ?? l10n.inbox,
                  leading: switch (projects[task.projectId]) {
                    final p? => IconTile.forProject(
                      p.iconKey,
                      color: p.colorKey,
                      size: IconTileSize.medium,
                    ),
                    null => const IconTile(
                      icon: AppIcon.inbox,
                      color: ProjectColorKey.grey,
                      size: IconTileSize.medium,
                    ),
                  },
                  selected: widget.current == task.id,
                  chevron: false,
                  onTap: () => _choose(task.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
