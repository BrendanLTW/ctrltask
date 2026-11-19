import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] in a localized MaterialApp with [theme] (light by default)
/// on a 390 × 844 screen.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  bool disableAnimations = false,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        disableAnimations: disableAnimations,
      ),
      child: MaterialApp(
        theme: theme ?? buildLightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}
