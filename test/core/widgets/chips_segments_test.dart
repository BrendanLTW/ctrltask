import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  const segments = <Segment<String>>[
    (value: 'list', label: 'List', icon: AppIcon.tasks),
    (value: 'calendar', label: 'Calendar', icon: null),
    (value: 'board', label: 'Board', icon: null),
  ];

  Material chipFill(WidgetTester tester) => tester.widget<Material>(
    find
        .descendant(of: find.byType(AppChip), matching: find.byType(Material))
        .first,
  );

  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    group(name, () {
      testWidgets('segments: surface track, ink on the selected one', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          SizedBox(
            width: 358,
            child: SegmentedControl(
              segments: segments,
              selected: 'list',
              onChanged: (_) {},
            ),
          ),
          theme: theme,
        );
        final track =
            tester
                    .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                    .decoration
                as BoxDecoration;
        expect(track.color, colors.surface);
        expect(
          tester.widget<Text>(find.text('List')).style!.color,
          colors.onInk,
        );
        expect(
          tester.widget<Text>(find.text('Board')).style!.color,
          colors.muted,
        );
      });

      testWidgets('chips: surface, fillSoft when small, ink when on', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          AppChip(label: 'Today', onTap: () {}),
          theme: theme,
        );
        expect(chipFill(tester).color, colors.surface);
        await pumpThemed(
          tester,
          AppChip(label: 'Today', small: true, onTap: () {}),
          theme: theme,
        );
        expect(chipFill(tester).color, colors.fillSoft);
        await pumpThemed(
          tester,
          AppChip(label: 'Today', selected: true, onTap: () {}),
          theme: theme,
        );
        expect(chipFill(tester).color, colors.ink);
        expect(
          tester.widget<Text>(find.text('Today')).style!.color,
          colors.onInk,
        );
      });
    });
  }

  testWidgets('a segment reports its value and selected state', (tester) async {
    final handle = tester.ensureSemantics();
    final picked = <String>[];
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: SegmentedControl(
          segments: segments,
          selected: 'list',
          onChanged: picked.add,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Calendar')),
      isSemantics(
        label: 'Calendar',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    await tester.tap(find.text('Board'));
    expect(picked, ['board']);
    expect(
      tester.getSize(find.byType(SegmentedControl<String>)).height,
      greaterThanOrEqualTo(56),
    );
    handle.dispose();
  });

  testWidgets('a chip is a 44 px target that reads its count', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpThemed(
      tester,
      AppChip(label: 'Upcoming', count: 7, small: true, onTap: () => taps++),
    );
    expect(tester.getSize(find.byType(AppChip)).height, 44);
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: find.text('7'), matching: find.byType(Opacity)),
          )
          .opacity,
      0.6,
    );
    expect(
      tester.getSemantics(find.byType(AppChip)),
      isSemantics(
        label: 'Upcoming, 7',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
      ),
    );
    await tester.tap(find.byType(AppChip));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('filter chips select one value', (tester) async {
    final picked = <int>[];
    await pumpThemed(
      tester,
      SizedBox(
        width: 390,
        child: FilterChips<int>(
          chips: const [
            (value: 0, label: 'All', count: 14),
            (value: 1, label: 'Today', count: 6),
          ],
          selected: 0,
          onChanged: picked.add,
        ),
      ),
    );
    await tester.tap(find.text('Today'));
    expect(picked, [1]);
  });
}
