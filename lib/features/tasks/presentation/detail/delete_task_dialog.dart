import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S13 Delete this task?: Delete task, Mark as done instead, or Cancel.
Future<DialogChoice> confirmDeleteTask(
  BuildContext context, {
  required String title,
  required int subtaskCount,
  required String project,
}) {
  final l10n = context.l10n;
  return showAppDialog(
    context,
    icon: AppIcon.trash,
    title: l10n.deleteTaskTitle,
    body: subtaskCount == 0
        ? l10n.deleteTaskBodyNoSubtasks(title, project)
        : l10n.deleteTaskBody(title, subtaskCount, project),
    confirmLabel: l10n.deleteTask,
    secondaryLabel: l10n.markDoneInstead,
    destructive: true,
  );
}
