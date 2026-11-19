import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
import 'package:ctrltask/core/widgets/app_stepper.dart';
import 'package:ctrltask/core/widgets/app_toggle.dart';
import 'package:ctrltask/core/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    group(name, () {
      ShapeDecoration track(WidgetTester tester) =>
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as ShapeDecoration;

      testWidgets('toggle: control off, ink on with an onInk thumb', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          AppToggle(
            value: false,
            onChanged: (_) {},
            semanticLabel: 'Daily plan',
          ),
          theme: theme,
        );
        expect(track(tester).color, colors.control);

        await pumpThemed(
          tester,
          AppToggle(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Daily plan',
          ),
          theme: theme,
        );
        await tester.pumpAndSettle();
        expect(track(tester).color, colors.ink);
        final thumb =
            tester
                    .widget<Container>(
                      find.byWidgetPredicate(
                        (w) => w is Container && w.constraints?.maxWidth == 26,
                      ),
                    )
                    .decoration!
                as BoxDecoration;
        expect(thumb.color, colors.onInk);
      });

      testWidgets('radio: 2 px control ring off, 7 px ink ring on', (
        tester,
      ) async {
        for (final (selected, color, width) in [
          (false, colors.control, 2.0),
          (true, colors.ink, 7.0),
        ]) {
          await pumpThemed(tester, AppRadio(selected: selected), theme: theme);
          final ring =
              (tester.widget<Container>(find.byType(Container)).decoration!
                      as BoxDecoration)
                  .border!
                  .top;
          expect((ring.color, ring.width), (color, width));
        }
      });

      testWidgets('step indicator fills up to the current step', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          const StepIndicator(current: 2, total: 3),
          theme: theme,
        );
        final pills = [
          for (final c in tester.widgetList<Container>(find.byType(Container)))
            (c.decoration! as ShapeDecoration).color,
        ];
        expect(pills, [colors.ink, colors.ink, colors.raised]);
      });
    });
  }

  testWidgets('toggle flips, reads as a toggle and has a 44 px target', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final values = <bool>[];
    await pumpThemed(
      tester,
      AppToggle(
        value: false,
        onChanged: values.add,
        semanticLabel: 'Reminders',
      ),
    );
    expect(tester.getSize(find.byType(AppToggle)), const Size(52, 44));
    expect(
      tester.getSemantics(find.byType(AppToggle)),
      isSemantics(
        label: 'Reminders',
        hasToggledState: true,
        isToggled: false,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(AppToggle));
    expect(values, [true]);
    handle.dispose();
  });

  testWidgets('toggle slides in 200 ms, instantly with reduced motion', (
    tester,
  ) async {
    Duration duration() => tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .duration;
    await pumpThemed(
      tester,
      AppToggle(value: false, onChanged: (_) {}, semanticLabel: 'T'),
    );
    expect(duration(), const Duration(milliseconds: 200));
    await pumpThemed(
      tester,
      AppToggle(value: false, onChanged: (_) {}, semanticLabel: 'T'),
      disableAnimations: true,
    );
    expect(duration(), Duration.zero);
  });

  testWidgets('a tappable radio is a 44 px target in a group', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpThemed(
      tester,
      AppRadio(selected: true, onTap: () => taps++, semanticLabel: 'Monday'),
    );
    expect(tester.getSize(find.byType(AppRadio)), const Size(44, 44));
    expect(
      tester.getSemantics(find.byType(AppRadio)),
      isSemantics(
        label: 'Monday',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(AppRadio));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('stepper: 44 px keys, disabled at a limit, adjustable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var value = 25;
    await pumpThemed(
      tester,
      AppStepper(
        value: '25 min',
        semanticLabel: 'Focus',
        onDecrement: () => value -= 5,
        decreasedValue: '20 min',
        onIncrement: null,
      ),
    );
    final keys = find.descendant(
      of: find.byType(AppStepper),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(keys.first), const Size(44, 44));
    await tester.tap(keys.first);
    await tester.tap(keys.last);
    expect(value, 20, reason: 'only minus works at the maximum');

    final node = tester.getSemantics(find.byType(AppStepper));
    expect(node.label, 'Focus');
    expect(node.value, '25 min');
    expect(node.decreasedValue, '20 min');
    expect(node.getSemanticsData().hasAction(SemanticsAction.decrease), isTrue);
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.increase),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('step indicator reads its step', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(tester, const StepIndicator(current: 1, total: 3));
    expect(find.bySemanticsLabel('Step 1 of 3'), findsOneWidget);
    handle.dispose();
  });
}
