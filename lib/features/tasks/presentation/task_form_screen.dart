import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

// shortcut: placeholder screen; built in its own task.
class TaskFormScreen extends StatelessWidget {
  const new({this.draft, super.key});

  /// What quick add's More carried over (S10).
  final TaskDraft? draft;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.newTask)),
      body: Center(child: Text(draft?.title ?? '')),
    );
  }
}
