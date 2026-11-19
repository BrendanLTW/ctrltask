import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/priority_colors.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/move_to_project_sheet.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opens S10 Quick add. [title] prefills the field (S08's chips), [date]
/// picks the day (a calendar day) and [projectId] the project (S27).
Future<void> showQuickAdd(
  BuildContext context, {
  String? title,
  DateTime? date,
  int? projectId,
}) => showAppSheet<void>(
  context,
  title: context.l10n.newTask,
  builder: (_) => QuickAddSheet(title: title, date: date, projectId: projectId),
);

typedef _When = ({String label, DateTime? date, int? minute});

/// S10's content: a title and send, When, Priority, the project, and More.
/// Only the title is required (PRD §5.3).
class QuickAddSheet extends ConsumerStatefulWidget {
  const new({this.title, this.date, this.projectId, super.key});

  final String? title;
  final DateTime? date;
  final int? projectId;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late final _title = TextEditingController(text: widget.title)
    ..addListener(() => setState(() {}));

  /// The user's pick; until then the default priority, live, so it's
  /// right even if settings load after the sheet opens.
  TaskPriority? _picked;

  /// [watch] in build, read in callbacks.
  TaskPriority _priority({bool watch = false}) =>
      _picked ??
      (watch ? ref.watch(preferencesProvider) : ref.read(preferencesProvider))
          .value
          ?.defaultPriority ??
      TaskPriority.medium;
  int? _when;
  var _sending = false;

  /// A day and time picked on S14, shown as its own chip.
  DueChoice? _pickedDue;

  late int? _projectId = widget.projectId;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _valid => _title.text.trim().isNotEmpty && !_sending;

  /// No date, Today, Tomorrow · 9 AM, the coming Saturday, and a preset
  /// day that matches none of them.
  List<_When> _options(DateLabels labels) {
    final l10n = context.l10n;
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    DateTime plus(int days) =>
        DateTime(today.year, today.month, today.day + days);
    final saturday = comingSaturday(today);
    const nineAm = 9 * 60;
    final options = <_When>[
      (label: l10n.whenNoDate, date: null, minute: null),
      (label: l10n.whenToday, date: today, minute: null),
      (
        label: l10n.whenTomorrowAt(labels.timeShort(nineAm)),
        date: plus(1),
        minute: nineAm,
      ),
      (label: labels.weekday(saturday), date: saturday, minute: null),
    ];
    if (widget.date case final preset?
        when !options.any((o) => o.date == preset)) {
      options.add((label: labels.date(preset), date: preset, minute: null));
    }
    if (_pickedDue case (:final date, :final minute)
        when !options.any((o) => o.date == date && o.minute == minute)) {
      options.add((
        label: minute == null
            ? labels.date(date)
            : l10n.titleWithDetail(labels.date(date), labels.timeShort(minute)),
        date: date,
        minute: minute,
      ));
    }
    return options;
  }

  int _initialWhen(List<_When> options) {
    final preset = widget.date;
    // Today unless a day was given: Home is about today (PRD §1).
    if (preset == null) return 1;
    return options.indexWhere((o) => o.date == preset && o.minute == null);
  }

  TaskDraft _draft(List<_When> options) {
    final when = options[_when!];
    return TaskDraft(
      title: _title.text.trim(),
      dueDate: when.date,
      dueMinute: when.minute,
      priority: _priority(),
      projectId: _projectId,
    );
  }

  Future<void> _pick(List<_When> options) async {
    final current = options[_when!];
    final choice = await showDueDatePicker(
      context,
      date: current.date,
      minute: current.minute,
    );
    if (choice == null || !mounted) return;
    setState(() {
      _pickedDue = choice;
      _when = _options(
        DateLabels(Localizations.localeOf(context).toLanguageTag()),
      ).indexWhere((o) => o.date == choice.date && o.minute == choice.minute);
    });
  }

  Future<void> _pickProject() async {
    final pick = await showMoveToProject(context, current: _projectId);
    if (pick != null && mounted) setState(() => _projectId = pick.projectId);
  }

  Future<void> _send(List<_When> options) async {
    if (!_valid) return;
    setState(() => _sending = true);
    await ref.read(taskRepositoryProvider).add(_draft(options));
    if (mounted) Navigator.of(context).pop();
  }

  void _more(List<_When> options) {
    final draft = _draft(options);
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(router.push(Routes.newTask, extra: draft));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final palette = context.projectColors;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final options = _options(labels);
    final shown = _priority(watch: true);
    _when ??= _initialWhen(options);
    final projects = ref.watch(activeProjectsProvider).value ?? const [];
    final project = projects.where((p) => p.id == _projectId).firstOrNull;
    final titleStyle = text.header.copyWith(
      color: colors.ink,
      fontWeight: FontWeight.w600,
    );

    Widget label(String value) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.textX - AppSpacing.screenX,
        20,
        0,
        6,
      ),
      child: Text(value, style: text.label.copyWith(color: colors.muted)),
    );

    Widget chipRow(List<Widget> chips) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (i, chip) in chips.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            chip,
          ],
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.textX - AppSpacing.screenX,
                  ),
                  child: TextField(
                    controller: _title,
                    autofocus: true,
                    maxLength: maxTaskTitleLength,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => unawaited(_send(options)),
                    style: titleStyle,
                    cursorColor: colors.ink,
                    decoration: InputDecoration.collapsed(
                      hintText: l10n.taskTitleHint,
                      hintStyle: titleStyle.copyWith(color: colors.disabled),
                    ).copyWith(counterText: ''),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _valid ? () => unawaited(_send(options)) : null,
                tooltip: l10n.addTask,
                style: IconButton.styleFrom(
                  fixedSize: const Size(44, 44),
                  backgroundColor: colors.ink,
                  foregroundColor: colors.onInk,
                  disabledBackgroundColor: colors.buttonDisabled,
                  disabledForegroundColor: colors.onButtonDisabled,
                ),
                icon: const AppIconView(AppIcon.arrowUp, size: 22),
              ),
            ],
          ),
          label(l10n.whenLabel),
          chipRow([
            for (final (i, option) in options.indexed)
              AppChip(
                label: option.label,
                small: true,
                selected: _when == i,
                onTap: () => setState(() => _when = i),
              ),
            AppChip(
              label: l10n.pick,
              small: true,
              leading: const AppIconView(AppIcon.calendar, size: 16),
              onTap: () => unawaited(_pick(options)),
            ),
          ]),
          label(l10n.priorityLabel),
          chipRow([
            for (final priority in TaskPriority.values)
              AppChip(
                label: priorityLabel(context, priority),
                small: true,
                selected: shown == priority,
                leading: AppIconView(
                  AppIcon.flagFilled,
                  size: 16,
                  color: priority == TaskPriority.low
                      ? palette.of(ProjectColorKey.grey).solid
                      : context.priorityRing(priority),
                ),
                onTap: () => setState(() => _picked = priority),
              ),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              // shortcut: the tag, reminder and repeat buttons come with
              // 3.4–3.7.
              Flexible(
                child: AppChip(
                  label: project?.name ?? l10n.inbox,
                  small: true,
                  leading: ProjectDot(
                    project?.colorKey ?? ProjectColorKey.grey,
                  ),
                  onTap: () => unawaited(_pickProject()),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _more(options),
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  foregroundColor: colors.ink,
                  overlayColor: colors.raised,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.more,
                      style: text.rowTitle.copyWith(color: colors.ink),
                    ),
                    const SizedBox(width: 2),
                    AppIconView(
                      AppIcon.chevronRight,
                      size: 18,
                      color: colors.ink,
                      stroke: AppIconStroke.chevron,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
