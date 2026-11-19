import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

void main() {
  late int undos;

  Future<void> pumpAndShow(
    WidgetTester tester, {
    ThemeData? theme,
    String message = 'Nice. “Send invoice” is done',
  }) async {
    undos = 0;
    await pumpThemed(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showCompleteToast(
            context,
            message: message,
            onUndo: () => undos++,
          ),
          child: const Text('show'),
        ),
      ),
      theme: theme,
    );
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
  }

  // Lets the toast's timer run out, so no timer is left when the test ends.
  Future<void> finish(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 4));

  for (final (name, theme, colors, check) in [
    ('light', buildLightTheme(), AppColors.light, AppColors.dark.positive),
    ('dark', buildDarkTheme(), AppColors.dark, AppColors.light.positive),
  ]) {
    testWidgets('matches the design in $name', (tester) async {
      await pumpAndShow(tester, theme: theme);

      final box =
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byType(CompleteToast),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      expect(box.color, colors.ink);
      expect(
        tester.widget<AppIconView>(findAppIcon(AppIcon.check)).color,
        check,
      );
      final undo = tester.widget<Text>(find.text('Undo'));
      expect(undo.style!.color, colors.onInk);
      expect(undo.style!.decoration, TextDecoration.underline);

      // 106 px from the bottom, 16 from each side.
      final rect = tester.getRect(find.byType(CompleteToast));
      expect(rect.bottom, 844 - 106);
      expect((rect.left, rect.right), (16, 374));
      expect(rect.height, greaterThanOrEqualTo(56));
      await finish(tester);
    });
  }

  testWidgets('Undo runs the callback and hides the toast', (tester) async {
    await pumpAndShow(tester);

    await tester.tap(find.text('Undo'));
    await tester.pump();

    expect(undos, 1);
    expect(find.byType(CompleteToast), findsNothing);
  });

  testWidgets('hides itself after 3.5 seconds', (tester) async {
    await pumpAndShow(tester);

    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.byType(CompleteToast), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byType(CompleteToast), findsNothing);
    expect(undos, 0);
  });

  testWidgets('a new toast replaces the current one', (tester) async {
    await pumpAndShow(tester, message: 'first');
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.byType(CompleteToast), findsOneWidget);
    await finish(tester);
    expect(find.byType(CompleteToast), findsNothing);
  });
}
