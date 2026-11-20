import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/priority_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_list.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens S23 Filter & sort over S19.
Future<void> showFilterSort(BuildContext context) => showAppSheet<void>(
  context,
  title: context.l10n.filterSortTitle,
  trailing: const _Reset(),
  builder: (_) => const FilterSortSheet(),
);

/// Reset clears the sheet's choices, not the S19 chip (PRD §5.6).
class _Reset extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextLink(
    label: context.l10n.reset,
    muted: true,
    onPressed: () =>
        ref.read(filterSortDraftProvider.notifier).value = defaultListOptions,
  );
}

/// S23 Filter & sort (PRD §5.6): Sort by, Priority and Projects chips,
/// Show completed, and Show {n} tasks.
class FilterSortSheet extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final palette = context.projectColors;
    final draft = ref.watch(filterSortDraftProvider);
    void set(ListOptions next) =>
        ref.read(filterSortDraftProvider.notifier).value = next;
    final projects = ref.watch(activeProjectsProvider).value ?? <Project>[];
    final now = ref.watch(clockProvider)();
    final list = listFor(
      ref.watch(tasksFilterProvider),
      ref.watch(allTasksProvider).value ?? const <Task>[],
      draft,
      today: DateTime(now.year, now.month, now.day),
    );
    Set<T> toggle<T>(Set<T> set, T value) =>
        set.contains(value) ? ({...set}..remove(value)) : {...set, value};

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(l10n.sortBy),
          for (final (sort, label) in [
            (TaskSort.dueDate, l10n.sortDueDate),
            (TaskSort.priority, l10n.sortPriority),
            (TaskSort.project, l10n.sortProject),
            (TaskSort.added, l10n.sortAdded),
          ])
            Semantics(
              selected: draft.sort == sort,
              button: true,
              child: InkWell(
                onTap: () => set((
                  sort: sort,
                  priorities: draft.priorities,
                  projectIds: draft.projectIds,
                  showCompleted: draft.showCompleted,
                )),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: context.text.rowTitle.copyWith(
                            color: colors.ink,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      AppRadio(selected: draft.sort == sort),
                    ],
                  ),
                ),
              ),
            ),
          SectionHeader(l10n.priorityLabel),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in TaskPriority.values)
                AppChip(
                  label: priorityLabel(context, p),
                  small: true,
                  selected: draft.priorities.contains(p),
                  leading: AppIconView(
                    AppIcon.flagFilled,
                    size: 16,
                    color: p == TaskPriority.low
                        ? palette.of(ProjectColorKey.grey).solid
                        : context.priorityRing(p),
                  ),
                  onTap: () => set((
                    sort: draft.sort,
                    priorities: toggle(draft.priorities, p),
                    projectIds: draft.projectIds,
                    showCompleted: draft.showCompleted,
                  )),
                ),
            ],
          ),
          if (projects.isNotEmpty) ...[
            SectionHeader(l10n.projectsSection),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in projects)
                  AppChip(
                    label: p.name,
                    small: true,
                    selected: draft.projectIds.contains(p.id),
                    leading: ProjectDot(p.colorKey),
                    onTap: () => set((
                      sort: draft.sort,
                      priorities: draft.priorities,
                      projectIds: toggle(draft.projectIds, p.id),
                      showCompleted: draft.showCompleted,
                    )),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ListGroupToggleRow(
            title: l10n.showCompleted,
            value: draft.showCompleted,
            onChanged: (v) => set((
              sort: draft.sort,
              priorities: draft.priorities,
              projectIds: draft.projectIds,
              showCompleted: v,
            )),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l10n.showTasks(list.shown.length + list.completed.length),
            onPressed: () {
              ref.read(taskListOptionsProvider.notifier).options = draft;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
