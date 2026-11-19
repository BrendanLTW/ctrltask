import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_text_input.dart';
import 'package:ctrltask/core/widgets/onboarding_scaffold.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _When { today, tomorrow, none }

/// S04 What's one thing to get done today? (2 of 3). Adds the task with
/// the default priority and no project; going back and adding again
/// updates it instead of adding another.
class FirstTaskScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<FirstTaskScreen> createState() => _FirstTaskScreenState();
}

class _FirstTaskScreenState extends ConsumerState<FirstTaskScreen> {
  late final _title = TextEditingController(
    text: ref.read(onboardingFirstTaskProvider)?.title ?? '',
  )..addListener(() => setState(() {}));
  _When _when = _When.today;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  bool get _valid => _title.text.trim().isNotEmpty;

  Future<void> _add() async {
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final due = switch (_when) {
      _When.today => today,
      _When.tomorrow => DateTime(today.year, today.month, today.day + 1),
      _When.none => null,
    };
    final repo = ref.read(taskRepositoryProvider);
    final existing = ref.read(onboardingFirstTaskProvider);
    final Task task;
    if (existing == null) {
      final prefs = await ref.read(preferencesRepositoryProvider).read();
      task = await repo.add(
        TaskDraft(
          title: _title.text,
          dueDate: due,
          priority: prefs.defaultPriority,
        ),
      );
    } else {
      final details = (await repo.watchDetails(existing.id).first)!;
      await repo.update(
        details.copyWith(
          task: details.task.copyWith(title: _title.text, dueDate: due),
        ),
      );
      task = details.task.copyWith(title: _title.text.trim(), dueDate: due);
    }
    ref.read(onboardingFirstTaskProvider.notifier).task = task;
    if (mounted) await context.push(Routes.onboardingReminders);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final name = ref.watch(preferencesProvider).value?.userName ?? '';
    Widget label(String value) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.textX - AppSpacing.screenX,
        AppSpacing.sectionTop,
        0,
        6,
      ),
      child: Text(value, style: text.label.copyWith(color: colors.muted)),
    );
    return OnboardingScaffold(
      step: 2,
      onSkip: () => context.push(Routes.onboardingReminders),
      title: name.isEmpty
          ? l10n.firstTaskTitle
          : l10n.firstTaskTitleNamed(name),
      subtitle: l10n.firstTaskBody,
      primaryLabel: l10n.addTask,
      onPrimary: _valid ? _add : null,
      secondaryLabel: l10n.doItLater,
      onSecondary: () => context.push(Routes.onboardingReminders),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextInput(
            controller: _title,
            maxLength: maxTaskTitleLength,
            hint: l10n.firstTaskHint,
            autofocus: true,
          ),
          label(l10n.orPickOne),
          Wrap(
            spacing: 8,
            children: [
              for (final s in [
                l10n.suggestionPlanWeek,
                l10n.suggestionClearInbox,
                l10n.suggestionWalk,
                l10n.suggestionCallMum,
              ])
                AppChip(label: s, small: true, onTap: () => _title.text = s),
            ],
          ),
          label(l10n.whenLabel),
          Wrap(
            spacing: 8,
            children: [
              for (final (option, label) in [
                (_When.today, l10n.whenToday),
                (_When.tomorrow, l10n.whenTomorrow),
                (_When.none, l10n.whenNoDate),
              ])
                AppChip(
                  label: label,
                  small: true,
                  selected: _when == option,
                  onTap: () => setState(() => _when = option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
