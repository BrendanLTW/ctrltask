import 'dart:async';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/features/focus/presentation/focus_controller.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/notifications/domain/notification_plan.dart';
import 'package:ctrltask/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/l10n/app_localizations.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_sync.g.dart';

/// The one owner of scheduling (PRD §6.5, CLAUDE.md). It plans from the
/// open tasks, settings and focus timer, and reschedules everything when
/// any of them change, on launch and on resume. Completing, archiving or
/// deleting a task drops its reminder because it leaves the plan.
@Riverpod(keepAlive: true)
class NotificationSync extends _$NotificationSync {
  Future<void> _last = Future.value();
  var _queued = false;

  @override
  void build() {
    void changed(_, _) => _queue();
    ref
      ..listen(openTasksProvider, changed)
      ..listen(preferencesProvider, changed)
      ..listen(focusTimerProvider, changed);
    final lifecycle = AppLifecycleListener(onResume: _queue);
    ref.onDispose(lifecycle.dispose);
    _queue();
  }

  /// Coalesces a burst of changes into one pass, after the last one.
  void _queue() {
    if (_queued) return;
    _queued = true;
    _last = _last.then((_) async {
      // After the changes already queued, without a timer.
      await Future<void>.microtask(() {});
      _queued = false;
      await resync();
    });
  }

  /// Plans again and replaces everything scheduled.
  Future<void> resync() async {
    final tasks = ref.read(openTasksProvider).value;
    final prefs = ref.read(preferencesProvider).value;
    // Wait for data: rescheduling from nothing would cancel it all.
    if (tasks == null || prefs == null) return;
    final now = ref.read(clockProvider)();
    final plan = planNotifications(
      openTasks: tasks,
      prefs: prefs,
      timer: ref.read(focusTimerProvider),
      now: now,
    );
    final scheduler = ref.read(notificationSchedulerProvider);
    await scheduler.cancelAll();
    final l10n = lookupAppLocalizations(const Locale('en'));
    final labels = DateLabels('en');
    for (final (i, n) in plan.indexed) {
      final (title, body) = _words(l10n, labels, n, prefs);
      await scheduler.scheduleOnce(
        id: i + 1,
        at: n.at,
        title: title,
        body: body,
      );
    }
  }

  (String, String) _words(
    AppLocalizations l10n,
    DateLabels labels,
    PlannedNotification n,
    Preferences prefs,
  ) => switch (n.kind) {
    NotificationKind.reminder => (
      n.task!.title,
      _dueText(l10n, labels, n.task!, n.at),
    ),
    NotificationKind.dailyPlan => (
      l10n.notifyPlanTitle,
      l10n.notifyPlanBody(n.count, n.firstTitle!),
    ),
    NotificationKind.overdue => (
      l10n.overdueCount(n.count),
      l10n.notifyOverdueBody,
    ),
    NotificationKind.weeklyReview => (
      l10n.notifyWeeklyTitle,
      l10n.notifyWeeklyBody,
    ),
    NotificationKind.focusEnd =>
      n.isBreak
          ? (l10n.phaseBreakOver, l10n.notifyBreakOverBody)
          : (l10n.sessionComplete, l10n.notifySessionBody),
  };

  /// "Today, 3:00 PM" under the task's title, told from the day it fires.
  String _dueText(
    AppLocalizations l10n,
    DateLabels labels,
    Task task,
    DateTime at,
  ) => l10n.notifyDue(
    l10n.dayLabel(
      labels,
      task.dueDate!,
      today: DateTime(at.year, at.month, at.day),
      minute: task.dueMinute,
    ),
  );
}
