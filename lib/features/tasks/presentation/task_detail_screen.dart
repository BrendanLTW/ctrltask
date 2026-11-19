import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

// shortcut: placeholder screen; built in its own task.
class TaskDetailScreen extends StatelessWidget {
  const new({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.task)),
      body: Center(child: Text(taskId)),
    );
  }
}
