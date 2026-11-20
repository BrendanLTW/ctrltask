import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/empty_state.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:ctrltask/core/widgets/search_field.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/task_row.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tasks/domain/recent_searches_repository.dart';
import 'package:ctrltask/features/tasks/domain/search_text.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/task_completion.dart';
import 'package:ctrltask/features/tasks/presentation/task_tile_data.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_screen.g.dart';

/// Tasks matching [query], open and done (PRD §5.6).
@riverpod
Stream<List<Task>> searchTasks(Ref ref, String query) =>
    ref.watch(taskRepositoryProvider).search(query);

/// Tag names, for S25's "Did you mean".
@riverpod
Stream<List<TagUsage>> searchTags(Ref ref) =>
    ref.watch(tagRepositoryProvider).watch();

@riverpod
Stream<List<String>> recentSearches(Ref ref) =>
    ref.watch(recentSearchesRepositoryProvider).watch();

enum _Type { all, tasks, projects, done }

/// S24 Search, and S25 when nothing matches (PRD §5.6).
class SearchScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();
  _Type _type = _Type.all;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String get _text => _query.text.trim();

  void _search(String text) => setState(() {
    _query.text = text;
    _query.selection = TextSelection.collapsed(offset: text.length);
  });

  Future<void> _remember() =>
      ref.read(recentSearchesRepositoryProvider).add(_text);

  void _open(String route) {
    unawaited(_remember());
    unawaited(context.push(route));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final query = _text;
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenX, 12, 4, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: _query,
                      hint: l10n.searchHint,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => unawaited(_remember()),
                    ),
                  ),
                  TextLink(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? _Recent(onPick: _search)
                  : _results(context, query),
            ),
          ],
        ),
      ),
    );
  }

  Widget _results(BuildContext context, String query) {
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final now = ref.watch(clockProvider)();
    final found = ref.watch(searchTasksProvider(query));
    final allProjects =
        ref.watch(activeProjectsProvider).value ?? const <Project>[];
    final projectsById = {for (final p in allProjects) p.id: p};
    final subtasks = ref.watch(subtaskProgressProvider).value ?? const {};
    final tasks = found.value ?? const <Task>[];
    final done = [
      for (final t in tasks)
        if (t.status == TaskStatus.done) t,
    ];
    bool matches(String? text) =>
        text != null && matchRanges(text, query).isNotEmpty;
    final projects = [
      for (final p in allProjects)
        if (matches(p.name) || matches(p.description)) p,
    ];
    if (!found.hasValue) return const SizedBox.shrink();
    if (tasks.isEmpty && projects.isEmpty) return _noResults(context, query);

    final showTasks = switch (_type) {
      _Type.all || _Type.tasks => tasks,
      _Type.done => done,
      _Type.projects => const <Task>[],
    };
    final showProjects = _type == _Type.all || _type == _Type.projects;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
      children: [
        FilterChips<_Type>(
          chips: [
            (
              value: _Type.all,
              label: l10n.searchTypeAll,
              count: tasks.length + projects.length,
            ),
            (
              value: _Type.tasks,
              label: l10n.searchTypeTasks,
              count: tasks.length,
            ),
            (
              value: _Type.projects,
              label: l10n.searchTypeProjects,
              count: projects.length,
            ),
            (value: _Type.done, label: l10n.searchTypeDone, count: done.length),
          ],
          selected: _type,
          onChanged: (type) => setState(() => _type = type),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTasks.isNotEmpty) ...[
                SectionHeader(l10n.tasksSection),
                ListGroup(
                  children: [
                    for (final task in showTasks)
                      TaskRow(
                        data: taskTileData(
                          task,
                          l10n: l10n,
                          labels: labels,
                          now: now,
                          projects: projectsById,
                          subtasks: subtasks,
                          highlight: query,
                          forSearch: true,
                        ),
                        trailingTag: false,
                        onToggle: (value) => unawaited(
                          setTaskDone(context, ref, task, done: value),
                        ),
                        onTap: () => _open(Routes.task('${task.id}')),
                      ),
                  ],
                ),
              ],
              if (showProjects && projects.isNotEmpty) ...[
                SectionHeader(l10n.projectsSection),
                ListGroup(
                  children: [
                    for (final p in projects)
                      ListGroupRow(
                        title: p.name,
                        // The note, when that's what matched.
                        subtitle: matches(p.name)
                            ? null
                            : switch (snippet(p.description ?? '', query)) {
                                final s? => l10n.noteMatches(s),
                                null => null,
                              },
                        leading: IconTile.forProject(
                          p.iconKey,
                          color: p.colorKey,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => _open(Routes.project('${p.id}')),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// S25: what to try instead.
  Widget _noResults(BuildContext context, String query) {
    final colors = context.colors;
    final l10n = context.l10n;
    final vocabulary = [
      for (final t in ref.watch(allTasksProvider).value ?? const <Task>[])
        t.title,
      for (final p in ref.watch(activeProjectsProvider).value ?? <Project>[])
        p.name,
      for (final u in ref.watch(searchTagsProvider).value ?? const <TagUsage>[])
        u.tag.name,
    ];
    final suggestion = didYouMean(query, vocabulary);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenX,
        72,
        AppSpacing.screenX,
        40,
      ),
      children: [
        EmptyState(
          icon: AppIcon.searchNone,
          title: l10n.noMatchesTitle(query),
          body: l10n.noMatchesBody,
          // Did you mean first, then Create task, as the design.
          footer: Column(
            children: [
              if (suggestion != null) ...[
                OutlinedButton(
                  onPressed: () => _search(suggestion),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(44, 48),
                    foregroundColor: colors.chipText,
                    side: BorderSide(color: colors.control, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text.rich(
                    _bold(l10n.didYouMean(suggestion), suggestion),
                    style: context.text.chip.copyWith(color: colors.chipText),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              PillButton(
                label: l10n.createTaskNamed(query),
                icon: AppIcon.add,
                onPressed: () => unawaited(showQuickAdd(context, title: query)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Recent searches, with Clear; tapping one runs it again.
class _Recent extends ConsumerWidget {
  const new({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recent = ref.watch(recentSearchesProvider).value ?? const [];
    if (recent.isEmpty) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenX,
        0,
        AppSpacing.screenX,
        40,
      ),
      children: [
        SectionHeader(
          l10n.recentSearches,
          linkLabel: l10n.clear,
          onLink: () =>
              unawaited(ref.read(recentSearchesRepositoryProvider).clear()),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final q in recent) AppChip(label: q, onTap: () => onPick(q)),
          ],
        ),
      ],
    );
  }
}

/// [text] with [word] in bold: "Did you mean **invoice**?".
TextSpan _bold(String text, String word) {
  final at = text.indexOf(word);
  if (at == -1) return TextSpan(text: text);
  return TextSpan(
    children: [
      TextSpan(text: text.substring(0, at)),
      TextSpan(
        text: word,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      TextSpan(text: text.substring(at + word.length)),
    ],
  );
}
