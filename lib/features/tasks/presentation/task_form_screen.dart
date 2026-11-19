import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

// shortcut: placeholder screen; built in its own task.
class TaskFormScreen extends StatelessWidget {
  const new({this.initialTitle, super.key});

  /// Prefilled from S08's suggestion chips.
  final String? initialTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.newTask)),
      body: const Center(child: Text('New task')),
    );
  }
}
