import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

Material _fill(WidgetTester tester, Type of) => tester.widget<Material>(
  find.descendant(of: find.byType(of), matching: find.byType(Material)).first,
);

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    group(name, () {
      testWidgets('primary button: ink when on, buttonDisabled when off', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          SizedBox(
            width: 358,
            child: PrimaryButton(
              label: 'Add task',
              icon: AppIcon.add,
              onPressed: () {},
            ),
          ),
          theme: theme,
        );
        expect(_fill(tester, PrimaryButton).color, colors.ink);
        expect(
          tester.widget<Text>(find.text('Add task')).style!.color,
          colors.onInk,
        );
        expect(findAppIcon(AppIcon.add), findsOneWidget);
        expect(tester.getSize(find.byType(PrimaryButton)).height, 58);

        await pumpThemed(
          tester,
          const SizedBox(
            width: 358,
            child: PrimaryButton(label: 'Continue', onPressed: null),
          ),
          theme: theme,
        );
        expect(_fill(tester, PrimaryButton).color, colors.buttonDisabled);
        expect(
          tester.widget<Text>(find.text('Continue')).style!.color,
          colors.onButtonDisabled,
        );
      });

      testWidgets('pill button: ink, or raised when soft', (tester) async {
        await pumpThemed(
          tester,
          PillButton(label: 'Add a task', onPressed: () {}),
          theme: theme,
        );
        expect(_fill(tester, PillButton).color, colors.ink);
        expect(tester.getSize(find.byType(PillButton)).height, 48);

        await pumpThemed(
          tester,
          PillButton(
            label: 'Restore',
            soft: true,
            small: true,
            onPressed: () {},
          ),
          theme: theme,
        );
        expect(_fill(tester, PillButton).color, colors.raised);
        expect(tester.getSize(find.byType(PillButton)).height, 40);
      });

      testWidgets('text link colours', (tester) async {
        for (final (link, color) in [
          (TextLink(label: 'L', onPressed: () {}), colors.ink),
          (TextLink(label: 'L', muted: true, onPressed: () {}), colors.muted),
          (
            TextLink(label: 'L', destructive: true, onPressed: () {}),
            colors.negative,
          ),
          (const TextLink(label: 'L', onPressed: null), colors.disabled),
        ]) {
          await pumpThemed(tester, link, theme: theme);
          expect(tester.widget<Text>(find.text('L')).style!.color, color);
        }
      });
    });
  }

  testWidgets('disabled buttons say so to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const SizedBox(
        width: 358,
        child: PrimaryButton(label: 'Continue', onPressed: null),
      ),
    );
    expect(
      tester.getSemantics(find.byType(PrimaryButton)),
      isSemantics(label: 'Continue', isButton: true, hasEnabledState: true),
    );
    handle.dispose();
  });

  testWidgets('a text link has a 52 px touch area', (tester) async {
    await pumpThemed(tester, TextLink(label: 'Skip', onPressed: () {}));
    expect(
      tester.getSize(find.byType(TextLink)).height,
      greaterThanOrEqualTo(52),
    );
  });
}
