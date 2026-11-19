import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/onboarding_scaffold.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S05 Want a nudge? (3 of 3). Both buttons save the choices; the
/// permission prompt behind Allow notifications comes with task 3.7.
class RemindersScreen extends ConsumerStatefulWidget {
  const new({super.key});

  /// The Daily plan at choices, in hours.
  static const hours = [7, 8, 9, 10];

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  late Preferences _prefs =
      ref.read(preferencesProvider).value ?? const Preferences();

  void _set(Preferences Function(Preferences) change) =>
      setState(() => _prefs = change(_prefs));

  Future<void> _save() async {
    final chosen = _prefs;
    await ref
        .read(preferencesRepositoryProvider)
        .update(
          (p) => p.copyWith(
            remindersOn: chosen.remindersOn,
            dailyPlanOn: chosen.dailyPlanOn,
            overdueOn: chosen.overdueOn,
            dailyPlanMinute: chosen.dailyPlanMinute,
          ),
        );
    if (mounted) await context.push(Routes.onboardingDone);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return OnboardingScaffold(
      step: 3,
      onSkip: _save,
      title: l10n.remindersTitle,
      subtitle: l10n.remindersBody,
      primaryLabel: l10n.allowNotifications,
      onPrimary: _save,
      secondaryLabel: l10n.notNow,
      onSecondary: _save,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListGroup(
            children: [
              ListGroupToggleRow(
                title: l10n.taskReminders,
                subtitle: l10n.taskRemindersDetail,
                value: _prefs.remindersOn,
                onChanged: (v) => _set((p) => p.copyWith(remindersOn: v)),
              ),
              ListGroupToggleRow(
                title: l10n.dailyPlan,
                subtitle: l10n.dailyPlanDetail,
                value: _prefs.dailyPlanOn,
                onChanged: (v) => _set((p) => p.copyWith(dailyPlanOn: v)),
              ),
              ListGroupToggleRow(
                title: l10n.overdueNudges,
                subtitle: l10n.overdueNudgesDetail,
                value: _prefs.overdueOn,
                onChanged: (v) => _set((p) => p.copyWith(overdueOn: v)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textX - AppSpacing.screenX,
              AppSpacing.sectionTop,
              0,
              6,
            ),
            child: Text(
              l10n.dailyPlanAt,
              style: text.label.copyWith(color: colors.muted),
            ),
          ),
          Row(
            children: [
              for (final (i, hour) in RemindersScreen.hours.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: AppChip(
                    label: '$hour:00',
                    small: true,
                    selected: _prefs.dailyPlanMinute == hour * 60,
                    onTap: () =>
                        _set((p) => p.copyWith(dailyPlanMinute: hour * 60)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
