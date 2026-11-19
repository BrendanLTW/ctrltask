import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  late BuildContext context;

  Future<void> pumpHost(
    WidgetTester tester, {
    ThemeData? theme,
    bool reduced = false,
  }) => pumpThemed(
    tester,
    Builder(
      builder: (c) {
        context = c;
        return const SizedBox();
      },
    ),
    theme: theme,
    disableAnimations: reduced,
  );

  Future<DialogChoice> Function() openDialog() =>
      () => showAppDialog(
        context,
        icon: AppIcon.trash,
        title: 'Delete this task?',
        body: 'This can’t be undone.',
        confirmLabel: 'Delete task',
        secondaryLabel: 'Mark as done instead',
        destructive: true,
      );

  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('sheet: surface, title, close, leaves 100 px in $name', (
      tester,
    ) async {
      await pumpHost(tester, theme: theme);
      final done = showAppSheet<void>(
        context,
        title: 'Due date',
        builder: (_) => const SizedBox(height: 2000),
      );
      await tester.pumpAndSettle();

      expect(find.text('Due date'), findsOneWidget);
      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(sheet.backgroundColor, colors.surface);
      expect(
        tester.getTopLeft(find.byType(AppSheet)).dy,
        greaterThanOrEqualTo(100),
      );

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await done;
      expect(find.byType(AppSheet), findsNothing);
    });

    testWidgets('dialog: red confirm, soft second, muted Cancel in $name', (
      tester,
    ) async {
      await pumpHost(tester, theme: theme);
      openDialog()().ignore();
      await tester.pumpAndSettle();

      Material fill(String label) => tester.widget<Material>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Material))
            .first,
      );
      expect(fill('Delete task').color, colors.destructive);
      expect(fill('Mark as done instead').color, colors.fillSoft);
      expect(
        tester.widget<Text>(find.text('Cancel')).style!.color,
        colors.muted,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('dialog returns each choice; dismissing is Cancel', (
    tester,
  ) async {
    await pumpHost(tester);
    for (final (tap, choice) in [
      ('Delete task', DialogChoice.confirm),
      ('Mark as done instead', DialogChoice.secondary),
      ('Cancel', DialogChoice.cancel),
    ]) {
      final result = openDialog()();
      await tester.pumpAndSettle();
      await tester.tap(find.text(tap));
      await tester.pumpAndSettle();
      expect(await result, choice);
    }

    final result = openDialog()();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await result, DialogChoice.cancel);
  });

  testWidgets('dialog fades in over 200 ms', (tester) async {
    await pumpHost(tester);
    openDialog()().ignore();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with reduced motion sheets and dialogs appear at once', (
    tester,
  ) async {
    await pumpHost(tester, reduced: true);
    showAppSheet<void>(
      context,
      title: 'Repeat',
      builder: (_) => const SizedBox(height: 100),
    ).ignore();
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Repeat'), findsOneWidget);
    Navigator.of(context).pop();
    await tester.pump();
    await tester.pump();

    openDialog()().ignore();
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Delete this task?'), findsOneWidget);
  });
}
