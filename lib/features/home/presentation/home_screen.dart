import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// shortcut: placeholder screen; built in its own task.
class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tabHome),
        actions: [
          IconButton(
            tooltip: context.l10n.searchTasks,
            icon: const Icon(Icons.search),
            onPressed: () => context.push(Routes.search),
          ),
          IconButton(
            tooltip: context.l10n.settings,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: Center(child: Text(context.l10n.tabHome)),
    );
  }
}
