import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/core/widgets/task_card.dart';
import 'package:ctrltask/core/widgets/task_checkbox.dart';
import 'package:ctrltask/core/widgets/task_content.dart';
import 'package:ctrltask/core/widgets/task_row.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

const _wireframes = TaskTileData(
  title: 'Review homepage wireframes',
  priority: TaskPriority.high,
  done: false,
  timeLabel: '10:00 AM',
  projectName: 'Website redesign',
  projectColor: ProjectColorKey.blue,
  subtasks: (done: 2, total: 4),
  repeats: true,
);

void main() {
  late List<bool> toggles;
  late int taps;

  Future<void> pumpCard(
    WidgetTester tester,
    TaskTileData data, {
    ThemeData? theme,
    bool row = false,
    double textScale = 1,
  }) {
    toggles = [];
    taps = 0;
    return pumpThemed(
      tester,
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: SizedBox(
          width: 358,
          child: row
              ? ListGroup(
                  children: [
                    TaskRow(
                      data: data,
                      onToggle: toggles.add,
                      onTap: () => taps++,
                    ),
                  ],
                )
              : TaskCard(
                  data: data,
                  onToggle: toggles.add,
                  onTap: () => taps++,
                ),
        ),
      ),
      theme: theme,
    );
  }

  Text title(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text));

  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('card shows the full meta line in $name', (tester) async {
      await pumpCard(tester, _wireframes, theme: theme);

      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(TaskCard),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, colors.surface);
      expect(
        title(tester, 'Review homepage wireframes').style!.color,
        colors.ink,
      );
      expect(find.byType(PriorityTag), findsOneWidget);
      expect(
        find.textContaining('10:00 AM', findRichText: true),
        findsOneWidget,
      );
      expect(findAppIcon(AppIcon.clock), findsOneWidget);
      expect(find.byType(ProjectDot), findsOneWidget);
      expect(
        find.textContaining('Website redesign', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('2/4', findRichText: true), findsOneWidget);
      expect(findAppIcon(AppIcon.repeat), findsOneWidget);
    });

    testWidgets('a done task is struck through and loses its tag in $name', (
      tester,
    ) async {
      await pumpCard(
        tester,
        const TaskTileData(
          title: 'Pay TNB electricity bill',
          priority: TaskPriority.urgent,
          done: true,
          timeLabel: '9:00 AM',
        ),
        theme: theme,
      );
      final style = title(tester, 'Pay TNB electricity bill').style!;
      expect(style.decoration, TextDecoration.lineThrough);
      expect(style.color, colors.muted);
      expect(find.byType(PriorityTag), findsNothing);
    });

    testWidgets('overdue replaces the time, in red, in $name', (tester) async {
      await pumpCard(
        tester,
        const TaskTileData(
          title: 'Send invoice to Lumen Studio',
          priority: TaskPriority.high,
          done: false,
          timeLabel: '10:00 AM',
          overdueLabel: 'Overdue · Mon',
        ),
        theme: theme,
      );
      expect(find.textContaining('10:00 AM', findRichText: true), findsNothing);
      expect(title(tester, 'Overdue · Mon').style!.color, colors.negative);
    });
  }

  testWidgets('Medium and Low get no tag', (tester) async {
    for (final priority in [TaskPriority.medium, TaskPriority.low]) {
      await pumpCard(
        tester,
        TaskTileData(title: 'T', priority: priority, done: false),
      );
      expect(find.byType(PriorityTag), findsNothing, reason: '$priority');
    }
  });

  testWidgets('a row puts the tag on the right, not in the meta line', (
    tester,
  ) async {
    await pumpCard(tester, _wireframes, row: true);
    final tag = tester.getRect(find.byType(PriorityTag));
    final time = tester.getRect(
      find.textContaining('10:00 AM', findRichText: true),
    );
    expect(tag.left, greaterThan(time.right));
    expect(tag.top, lessThan(time.top));
  });

  testWidgets('the checkbox toggles; the rest opens the task', (tester) async {
    for (final row in [false, true]) {
      await pumpCard(tester, _wireframes, row: row);
      await tester.tap(find.byType(TaskCheckbox));
      await tester.tap(find.text('Review homepage wireframes'));
      expect(toggles, [true], reason: row ? 'row' : 'card');
      expect(taps, 1, reason: row ? 'row' : 'card');
    }
  });

  testWidgets('screen readers hear the subtask count in words', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCard(tester, _wireframes);
    // The card reads as one button; the checkbox stays its own.
    expect(
      find.bySemanticsLabel(
        RegExp('2 of 4 subtasks done.*Repeats', dotAll: true),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Complete: Review homepage wireframes'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('at 200% text the meta line wraps without overflow', (
    tester,
  ) async {
    await pumpCard(tester, _wireframes, textScale: 2);
    expect(tester.takeException(), isNull);
    await pumpCard(tester, _wireframes, textScale: 2, row: true);
    expect(tester.takeException(), isNull);
  });
}
