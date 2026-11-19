import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/theme_mode_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
