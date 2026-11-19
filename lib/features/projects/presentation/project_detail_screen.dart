import 'package:flutter/material.dart';

// shortcut: placeholder screen with a hard-coded title; built in its own task.
class ProjectDetailScreen extends StatelessWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project')),
      body: Center(child: Text('Project $projectId')),
    );
  }
}
