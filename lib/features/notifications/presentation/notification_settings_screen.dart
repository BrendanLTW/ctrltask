import 'dart:async';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrltask/features/notifications/presentation/ask_permission.dart';
import 'package:ctrltask/features/notifications/presentation/timing_sheets.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many of S39's five notifications are on: S35's "3 on".
int notificationsOn(Preferences p) => [
  p.remindersOn,
  p.dailyPlanOn,
  p.overdueOn,
  p.focusEndOn,
  p.weeklyReviewOn,
].where((on) => on).length;

/// S39 Notifications (PRD §5.10): the five toggles, Timing, and a warning
/// when the phone blocks notifications. Choices save either way.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsState();
}

class _NotificationSettingsState
    extends ConsumerState<NotificationSettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from the phone's Settings, the permission may have changed.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsPermittedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _set(Preferences Function(Preferences) change) =>
      ref.read(preferencesRepositoryProvider).update(change);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final p = ref.watch(preferencesProvider).value ?? const Preferences();
    final permitted = ref.watch(notificationsPermittedProvider).value ?? true;
    final quietOn = p.quietStartMinute != p.quietEndMinute;

    Widget toggle(
      String title,
      String detail, {
      required bool value,
      required ValueChanged<bool> onChanged,
    }) => ListGroupToggleRow(
      title: title,
      subtitle: detail,
      value: value,
      onChanged: onChanged,
    );

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(title: l10n.notificationsTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  if (!permitted) ...[
                    _Blocked(asked: p.notificationsAsked),
                    const SizedBox(height: AppSpacing.cardGap),
                  ],
                  ListGroup(
                    children: [
                      toggle(
                        l10n.taskReminders,
                        l10n.notifyRemindersDetail,
                        value: p.remindersOn,
                        onChanged: (v) =>
                            unawaited(_set((q) => q.copyWith(remindersOn: v))),
                      ),
                      toggle(
                        l10n.dailyPlan,
                        l10n.notifyPlanDetail,
                        value: p.dailyPlanOn,
                        onChanged: (v) =>
                            unawaited(_set((q) => q.copyWith(dailyPlanOn: v))),
                      ),
                      toggle(
                        l10n.overdueNudges,
                        l10n.notifyOverdueDetail,
                        value: p.overdueOn,
                        onChanged: (v) =>
                            unawaited(_set((q) => q.copyWith(overdueOn: v))),
                      ),
                      toggle(
                        l10n.focusSessionEnd,
                        l10n.notifyFocusDetail,
                        value: p.focusEndOn,
                        onChanged: (v) =>
                            unawaited(_set((q) => q.copyWith(focusEndOn: v))),
                      ),
                      toggle(
                        l10n.weeklyReview,
                        l10n.notifyWeeklyDetail,
                        value: p.weeklyReviewOn,
                        onChanged: (v) => unawaited(
                          _set((q) => q.copyWith(weeklyReviewOn: v)),
                        ),
                      ),
                    ],
                  ),
                  SectionHeader(l10n.timingSection),
                  ListGroup(
                    children: [
                      ListGroupRow(
                        title: l10n.dailyPlanAtRow,
                        value: labels.time(p.dailyPlanMinute),
                        onTap: () async {
                          final minute = await showTimeSheet(
                            context,
                            title: l10n.dailyPlanAtRow,
                            minute: p.dailyPlanMinute,
                          );
                          if (minute != null) {
                            await _set(
                              (q) => q.copyWith(dailyPlanMinute: minute),
                            );
                          }
                        },
                      ),
                      ListGroupRow(
                        title: l10n.defaultTaskReminder,
                        value: l10n.reminderShort(p.defaultReminder.name),
                        onTap: () async {
                          final offset = await showDefaultReminderSheet(
                            context,
                            offset: p.defaultReminder,
                          );
                          if (offset != null) {
                            await _set(
                              (q) => q.copyWith(defaultReminder: offset),
                            );
                          }
                        },
                      ),
                      ListGroupRow(
                        title: l10n.quietHours,
                        value: quietOn
                            ? l10n.timeSpan(
                                labels.timeShort(p.quietStartMinute),
                                labels.timeShort(p.quietEndMinute),
                              )
                            : l10n.off,
                        onTap: () async {
                          final hours = await showQuietHoursSheet(
                            context,
                            hours: (
                              start: p.quietStartMinute,
                              end: p.quietEndMinute,
                            ),
                          );
                          if (hours != null) {
                            await _set(
                              (q) => q.copyWith(
                                quietStartMinute: hours.start,
                                quietEndMinute: hours.end,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The warning when the phone blocks notifications: Turn on asks if it
/// never has; after that only the phone's Settings can change it.
class _Blocked extends ConsumerWidget {
  const new({required this.asked});

  final bool asked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        decoration: BoxDecoration(
          color: colors.warningBox,
          borderRadius: BorderRadius.circular(AppRadius.r20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconView(AppIcon.warning, size: 22, color: colors.onWarningBox),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationsOffTitle,
                    style: text.rowTitle.copyWith(color: colors.onWarningBox),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    asked
                        ? l10n.notificationsOffBody
                        : l10n.notificationsNotAsked,
                    style: text.subline.copyWith(color: colors.onWarningBox),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Transform.translate(
                      // The link's own padding, lined up with the text.
                      offset: const Offset(-16, 0),
                      child: TextLink(
                        label: asked ? l10n.openPhoneSettings : l10n.turnOn,
                        onPressed: () => unawaited(
                          asked
                              ? ref
                                    .read(notificationSchedulerProvider)
                                    .openSystemSettings()
                              : askForNotifications(ref),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
