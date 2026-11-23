import 'dart:async';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrltask/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S44 Erase all data (PRD §5.10): asks first, with the counts and
/// "Export a copy first" (→ S41), then erases everything in one go,
/// cancels every scheduled notification and restarts at S01, which moves
/// on to onboarding.
Future<void> confirmAndEraseAllData(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  // Archived projects and their tasks count too.
  final projectRepo = ref.read(projectRepositoryProvider);
  final tasks =
      (await ref.read(taskRepositoryProvider).watchForInsights().first).length;
  final projects =
      (await projectRepo.watchActive().first).length +
      (await projectRepo.watchArchived().first).length;
  if (!context.mounted) return;
  final choice = await showAppDialog(
    context,
    icon: AppIcon.trash,
    title: l10n.eraseTitle,
    body: l10n.eraseBody(l10n.taskCount(tasks), l10n.projectCount(projects)),
    confirmLabel: l10n.eraseEverything,
    secondaryLabel: l10n.exportCopyFirst,
    destructive: true,
  );
  if (!context.mounted) return;
  switch (choice) {
    case DialogChoice.secondary:
      unawaited(context.push(Routes.export));
    case DialogChoice.confirm:
      final router = ref.read(appRouterProvider);
      await ref.read(dataEraserProvider).eraseAll();
      // After the erase, so the sync's last plan is cancelled too; with
      // onboarding undone it plans nothing more.
      await ref.read(notificationSchedulerProvider).cancelAll();
      router.go(Routes.splash);
    case DialogChoice.cancel:
      break;
  }
}
