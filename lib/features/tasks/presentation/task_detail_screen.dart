import 'package:flutter/material.dart';

// shortcut: placeholder screen with a hard-coded title; built in its own task.
class TaskDetailScreen extends StatelessWidget {
  const new({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task')),
      body: Center(child: Text('Task $taskId')),
    );
  }
}
