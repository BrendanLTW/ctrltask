import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/onboarding_scaffold.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S06 You're all set: a summary of the setup. Either button finishes
/// onboarding.
class AllSetScreen extends ConsumerWidget {
  const new({super.key});

  Future<void> _finish(WidgetRef ref) => ref
      .read(preferencesRepositoryProvider)
      .update((p) => p.copyWith(onboardingComplete: true));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final task = ref.watch(onboardingFirstTaskProvider);
    final name = prefs.userName;
    // A date in the week start's weekday, for its name.
    final weekStartDay = DateTime(2026, 11, 16 + prefs.weekStart.weekday - 1);
    return OnboardingScaffold(
      topBar: false,
      centered: true,
      header: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Center(
          child: ExcludeSemantics(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.successBox,
                shape: BoxShape.circle,
              ),
              child: AppIconView(
                AppIcon.check,
                size: 40,
                stroke: 2.4,
                color: colors.onSuccessBox,
              ),
            ),
          ),
        ),
      ),
      title: name.isEmpty ? l10n.allSetTitle : l10n.allSetTitleNamed(name),
      subtitle: task == null ? l10n.allSetBodyNoTask : l10n.allSetBody,
      primaryLabel: l10n.goToToday,
      // The router moves to Home once the setting is saved.
      onPrimary: () => _finish(ref),
      secondaryLabel: l10n.createProjectFirst,
      onSecondary: () async {
        await _finish(ref);
        // shortcut: opens the Projects tab; 2.10 opens S28 New project.
        if (context.mounted) context.go(Routes.projects);
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textX - AppSpacing.screenX,
              0,
              0,
              10,
            ),
            child: Text(
              l10n.yourSetup,
              style: text.label.copyWith(color: colors.muted),
            ),
          ),
          ListGroup(
            children: [
              KeyValueRow(
                label: l10n.setupName,
                value: name.isEmpty ? l10n.notSet : name,
              ),
              KeyValueRow(
                label: l10n.setupFirstTask,
                value: task?.title ?? l10n.notSet,
              ),
              KeyValueRow(
                label: l10n.setupDailyPlan,
                value: prefs.dailyPlanOn
                    ? DateLabels(locale).time(prefs.dailyPlanMinute)
                    : l10n.off,
              ),
              KeyValueRow(
                label: l10n.setupWeekStart,
                value: DateFormat.EEEE(locale).format(weekStartDay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
