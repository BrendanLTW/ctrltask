import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_progress_bar.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/project_dot.dart';
import 'package:ctrltask/core/widgets/tag_chip.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

BoxDecoration _box(WidgetTester tester, Finder of) =>
    tester
            .widget<Container>(
              find.descendant(of: of, matching: find.byType(Container)).first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  for (final (name, theme, colors, projects) in [
    ('light', buildLightTheme(), AppColors.light, ProjectColors.light),
    ('dark', buildDarkTheme(), AppColors.dark, ProjectColors.dark),
  ]) {
    group(name, () {
      testWidgets('project dot is 8 px in the solid colour', (tester) async {
        await pumpThemed(
          tester,
          const ProjectDot(ProjectColorKey.blue),
          theme: theme,
        );
        expect(tester.getSize(find.byType(ProjectDot)), const Size(8, 8));
        expect(
          _box(tester, find.byType(ProjectDot)).color,
          projects.of(ProjectColorKey.blue).solid,
        );
      });

      for (final (priority, label, key) in [
        (TaskPriority.urgent, 'Urgent', ProjectColorKey.red),
        (TaskPriority.high, 'High', ProjectColorKey.orange),
      ]) {
        testWidgets('$label tag uses its colour and names itself', (
          tester,
        ) async {
          await pumpThemed(tester, PriorityTag(priority), theme: theme);
          final tile = projects.of(key);
          expect(_box(tester, find.byType(PriorityTag)).color, tile.tile);
          expect(tester.widget<Text>(find.text(label)).style!.color, tile.icon);
          expect(tester.getSize(find.byType(PriorityTag)).height, 24);
        });
      }

      testWidgets('tag chip reads #name on raised', (tester) async {
        await pumpThemed(tester, const TagChip('design'), theme: theme);
        expect(find.text('#design'), findsOneWidget);
        expect(_box(tester, find.byType(TagChip)).color, colors.raised);
      });

      testWidgets('progress bar fills its share, clamped', (tester) async {
        await pumpThemed(
          tester,
          const SizedBox(
            width: 200,
            child: Column(
              children: [
                AppProgressBar(value: 0.25, semanticLabel: 'quarter'),
                AppProgressBar(value: 1.5, semanticLabel: 'over', thin: true),
              ],
            ),
          ),
          theme: theme,
        );
        final fills = find.descendant(
          of: find.byType(AppProgressBar),
          matching: find.byType(FractionallySizedBox),
        );
        expect(tester.getSize(fills.at(0)).width, 50);
        expect(tester.getSize(fills.at(1)).width, 200);
        final bars = find.byType(AppProgressBar);
        expect(tester.getSize(bars.at(0)).height, 10);
        expect(tester.getSize(bars.at(1)).height, 6);
        expect(find.bySemanticsLabel('quarter'), findsOneWidget);
      });
    });
  }

  testWidgets('icon tiles come in three sizes', (tester) async {
    await pumpThemed(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(icon: AppIcon.flame, color: ProjectColorKey.orange),
          IconTile(
            icon: AppIcon.flame,
            color: ProjectColorKey.orange,
            size: IconTileSize.medium,
          ),
          IconTile(
            icon: AppIcon.flame,
            color: ProjectColorKey.orange,
            size: IconTileSize.small,
          ),
        ],
      ),
    );
    final tiles = find.byType(IconTile);
    expect(tester.getSize(tiles.at(0)), const Size(48, 48));
    expect(tester.getSize(tiles.at(1)), const Size(40, 40));
    expect(tester.getSize(tiles.at(2)), const Size(28, 28));
  });

  test('every project icon key has an icon', () {
    for (final key in ProjectIconKey.values) {
      expect(projectIcon(key), isA<AppIcon>(), reason: key.name);
    }
    expect(projectIcon(ProjectIconKey.plane), AppIcon.plane);
  });
}
