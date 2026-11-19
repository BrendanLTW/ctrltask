import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

// shortcut: placeholder screen; built in its own task.
class FocusScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tabFocus)),
      body: const Center(child: Text('Focus')),
    );
  }
}
