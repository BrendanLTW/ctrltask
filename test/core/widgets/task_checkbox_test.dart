import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

/// Holds a checkbox's done state, as a task card would.
class _Host extends StatefulWidget {
  const new({this.priority = TaskPriority.medium, this.done = false});

  final TaskPriority priority;
  final bool done;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late bool done = widget.done;

  @override
  Widget build(BuildContext context) => TaskCheckbox(
    title: 'Send invoice',
    priority: widget.priority,
    done: done,
    onChanged: (value) => setState(() => done = value),
  );
}

BoxDecoration _circle(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(TaskCheckbox),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(TaskCheckbox),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .entry(0, 0);

void main() {
  for (final (name, theme, colors, projects) in [
    ('light', buildLightTheme(), AppColors.light, ProjectColors.light),
    ('dark', buildDarkTheme(), AppColors.dark, ProjectColors.dark),
  ]) {
    group(name, () {
      for (final (priority, expected) in [
        (TaskPriority.urgent, projects.of(ProjectColorKey.red).solid),
        (TaskPriority.high, projects.of(ProjectColorKey.orange).solid),
        (TaskPriority.medium, projects.of(ProjectColorKey.blue).solid),
        (TaskPriority.low, colors.control),
      ]) {
        testWidgets('${priority.name} ring', (tester) async {
          await pumpThemed(tester, _Host(priority: priority), theme: theme);

          final circle = _circle(tester);
          expect(circle.border, Border.all(color: expected, width: 2));
          expect(circle.color, isNull);
          expect(findAppIcon(AppIcon.check), findsNothing);
        });
      }

      testWidgets('done is an ink fill with an onInk check', (tester) async {
        await pumpThemed(tester, const _Host(done: true), theme: theme);

        final circle = _circle(tester);
        expect(circle.color, colors.ink);
        expect(circle.border, isNull);
        final check = tester.widget<AppIconView>(findAppIcon(AppIcon.check));
        expect(check.color, colors.onInk);
        expect(check.size, 15);
      });

      testWidgets('pressing an open box fills it with fillSoft', (
        tester,
      ) async {
        await pumpThemed(tester, const _Host(), theme: theme);

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(TaskCheckbox)),
        );
        await tester.pump();
        expect(_circle(tester).color, colors.fillSoft);

        await gesture.cancel();
        await tester.pump();
        expect(_circle(tester).color, isNull);
      });
    });
  }

  testWidgets('is a 44 px target with a 26 px circle', (tester) async {
    await pumpThemed(tester, const _Host());

    expect(tester.getSize(find.byType(TaskCheckbox)), const Size(44, 44));
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(TaskCheckbox),
          matching: find.byType(DecoratedBox),
        ),
      ),
      const Size(26, 26),
    );
  });

  testWidgets('the subtask size is 22 inside the same 44 px target', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      TaskCheckbox(
        title: 'Step',
        priority: TaskPriority.low,
        done: false,
        size: 22,
        onChanged: (_) {},
      ),
    );

    expect(tester.getSize(find.byType(TaskCheckbox)), const Size(44, 44));
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(TaskCheckbox),
          matching: find.byType(DecoratedBox),
        ),
      ),
      const Size(22, 22),
    );
  });

  testWidgets('screen readers hear the action and the checked state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(tester, const _Host());

    expect(
      tester.getSemantics(find.byType(TaskCheckbox)),
      isSemantics(
        label: 'Complete: Send invoice',
        isButton: true,
        hasCheckedState: true,
        isChecked: false,
      ),
    );

    await tester.tap(find.byType(TaskCheckbox));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(TaskCheckbox)),
      isSemantics(
        label: 'Mark not done: Send invoice',
        isButton: true,
        hasCheckedState: true,
        isChecked: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('ticking springs from 0.7 past 1.18 back to 1 in 350 ms', (
    tester,
  ) async {
    await pumpThemed(tester, const _Host());

    await tester.tap(find.byType(TaskCheckbox));
    await tester.pump();
    expect(_scale(tester), closeTo(0.7, 0.01));

    await tester.pump(const Duration(milliseconds: 175));
    expect(_scale(tester), greaterThan(1));

    await tester.pump(const Duration(milliseconds: 175));
    expect(_scale(tester), 1);
  });

  testWidgets('with reduced motion the tick is instant', (tester) async {
    await pumpThemed(tester, const _Host(), disableAnimations: true);

    await tester.tap(find.byType(TaskCheckbox));
    await tester.pump();
    await tester.pump();

    expect(_scale(tester), 1);
    expect(tester.hasRunningAnimations, isFalse);
    expect(_circle(tester).color, AppColors.light.ink);
  });

  testWidgets('tapping a done box reports false', (tester) async {
    bool? reported;
    await pumpThemed(
      tester,
      TaskCheckbox(
        title: 'Done',
        priority: TaskPriority.high,
        done: true,
        onChanged: (value) => reported = value,
      ),
    );

    await tester.tap(find.byType(TaskCheckbox));

    expect(reported, isFalse);
  });
}
