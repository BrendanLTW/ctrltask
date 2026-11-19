import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/month_calendar.dart';
import 'package:ctrltask/core/widgets/quick_date_tiles.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  final today = DateTime(2026, 11, 17);
  late List<DateTime> picked;
  late List<DateTime> months;

  Future<void> pumpCalendar(
    WidgetTester tester, {
    WeekStart weekStart = WeekStart.mon,
    ThemeData? theme,
    Set<CalendarDot> Function(DateTime)? dotsFor,
  }) {
    picked = [];
    months = [];
    return pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: MonthCalendar(
          month: DateTime(2026, 11),
          today: today,
          weekStart: weekStart,
          selected: DateTime(2026, 11, 19),
          onSelected: picked.add,
          onMonthChanged: months.add,
          dotsFor: dotsFor,
        ),
      ),
      theme: theme,
    );
  }

  Text day(WidgetTester tester, String n) =>
      tester.widget<Text>(find.text(n).first);

  testWidgets('the grid starts on the user’s week start', (tester) async {
    for (final (start, firstCell, rows) in [
      (WeekStart.mon, '26', 6),
      (WeekStart.sun, '1', 5),
      (WeekStart.sat, '31', 5),
    ]) {
      await pumpCalendar(tester, weekStart: start);
      final cells = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(MonthCalendar),
          matching: find.byWidgetPredicate(
            (w) => w is Text && RegExp(r'^\d+$').hasMatch(w.data ?? ''),
          ),
        ),
      );
      expect(cells.first.data, firstCell, reason: start.name);
      expect(cells.length, rows * 7, reason: start.name);
    }
  });

  testWidgets('weekday initials follow the week start', (tester) async {
    await pumpCalendar(tester, weekStart: WeekStart.sun);
    final initials = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(MonthCalendar),
            matching: find.byWidgetPredicate(
              (w) => w is Text && RegExp(r'^[A-Z]$').hasMatch(w.data ?? ''),
            ),
          ),
        )
        .map((t) => t.data)
        .toList();
    expect(initials, ['S', 'M', 'T', 'W', 'T', 'F', 'S']);
  });

  for (final (name, theme, colors, projects) in [
    ('light', buildLightTheme(), AppColors.light, ProjectColors.light),
    ('dark', buildDarkTheme(), AppColors.dark, ProjectColors.dark),
  ]) {
    testWidgets('today ringed, selected filled, overdue red in $name', (
      tester,
    ) async {
      await pumpCalendar(
        tester,
        theme: theme,
        dotsFor: (d) => switch (d.day) {
          16 when d.month == 11 => {CalendarDot.overdue},
          18 when d.month == 11 => {CalendarDot.pending, CalendarDot.completed},
          _ => const {},
        },
      );
      BoxDecoration cell(String n) =>
          tester
                  .widget<Container>(
                    find
                        .ancestor(
                          of: find.text(n).first,
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;

      expect(cell('17').border, Border.all(color: colors.control, width: 2));
      expect(cell('19').color, colors.ink);
      expect(day(tester, '19').style!.color, colors.onInk);
      expect(day(tester, '16').style!.color, colors.negative);
      expect(day(tester, '15').style!.color, colors.ink);

      final dots = [
        for (final c in tester.widgetList<Container>(
          find.descendant(
            of: find
                .ancestor(
                  of: find.text('18').first,
                  matching: find.byType(Column),
                )
                .first,
            matching: find.byWidgetPredicate(
              (w) => w is Container && w.constraints?.maxWidth == 5,
            ),
          ),
        ))
          (c.decoration! as BoxDecoration).color,
      ];
      expect(dots, [colors.ink, projects.of(ProjectColorKey.green).solid]);
    });
  }

  testWidgets('days outside the month are muted at 55%', (tester) async {
    await pumpCalendar(tester);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('26').first, matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0.55);
  });

  testWidgets('taps pick a day and move between months', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCalendar(tester);
    await tester.tap(find.text('24'));
    await tester.tap(find.byTooltip('Next month'));
    await tester.tap(find.byTooltip('Previous month'));
    expect(picked, [DateTime(2026, 11, 24)]);
    expect(months, [DateTime(2026, 12), DateTime(2026, 10)]);
    expect(
      tester.getSemantics(find.text('19')),
      isSemantics(
        label: 'Thursday, November 19, 2026',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('quick date tiles select one, 76 high', (tester) async {
    final chosen = <int>[];
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: QuickDateTiles<int>(
          options: const [
            (value: 0, label: 'Today', detail: 'Tue'),
            (value: 1, label: 'Tomorrow', detail: 'Wed'),
            (value: 2, label: 'Weekend', detail: 'Sat'),
            (value: 3, label: 'Next week', detail: 'Mon'),
          ],
          selected: 1,
          onChanged: chosen.add,
        ),
      ),
    );
    final tile = find
        .descendant(
          of: find.byType(QuickDateTiles<int>),
          matching: find.byType(Material),
        )
        .at(1);
    expect(tester.widget<Material>(tile).color, AppColors.light.ink);
    expect(tester.getSize(tile).height, 76);
    await tester.tap(find.text('Weekend'));
    expect(chosen, [2]);
  });
}
