import 'dart:async';

import 'package:ctrltask/core/haptics/haptics.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/features/tasks/domain/task.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one way a checkbox changes a task (CLAUDE.md Tasks). Ticking
/// completes it with a light haptic and the "is done" toast, whose Undo
/// puts everything back, including a repeat's next occurrence. Unticking
/// reopens it quietly. The checkbox animates and strikes through itself.
Future<void> setTaskDone(
  BuildContext context,
  WidgetRef ref,
  Task task, {
  required bool done,
}) async {
  final repo = ref.read(taskRepositoryProvider);
  if (!done) {
    await repo.uncomplete(task.id);
    return;
  }
  final completion = await repo.complete(task.id);
  unawaited(ref.read(hapticsProvider).light());
  if (!context.mounted) return;
  showCompleteToast(
    context,
    message: context.l10n.completeToast(task.title),
    onUndo: () => unawaited(repo.undoComplete(completion)),
  );
}
