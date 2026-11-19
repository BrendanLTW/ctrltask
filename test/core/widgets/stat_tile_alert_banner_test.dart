import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/alert_banner.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/stat_tile.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('stat tile shows label, value and unit in $name', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 112,
          child: StatTile(
            icon: AppIcon.flame,
            color: ProjectColorKey.orange,
            label: 'STREAK',
            value: '12',
            unit: ' days',
            semanticLabel: 'Streak, 12 days',
          ),
        ),
        theme: theme,
      );
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('12 days', findRichText: true), findsOneWidget);
      final box =
          tester
                  .widget<Container>(
                    find
                        .descendant(
                          of: find.byType(StatTile),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(box.color, colors.surface);
    });

    testWidgets('alert banner is an errorBox with a red warning in $name', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        SizedBox(
          width: 358,
          child: AlertBanner(
            title: '1 overdue task',
            message: 'Send invoice to Lumen Studio · was due yesterday',
            onTap: () {},
          ),
        ),
        theme: theme,
      );
      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AlertBanner),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, colors.errorBox);
      expect(
        tester.widget<AppIconView>(findAppIcon(AppIcon.warning)).color,
        colors.negative,
      );
    });
  }

  testWidgets('stat tile reads as one label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const SizedBox(
        width: 112,
        child: StatTile(
          icon: AppIcon.timer,
          color: ProjectColorKey.purple,
          label: 'FOCUSED',
          value: '1h 15',
          unit: 'm',
          semanticLabel: 'Focused today, 1 hour 15 minutes',
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Focused today, 1 hour 15 minutes'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('alert banner is a button that opens the task', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: AlertBanner(
          title: '1 overdue task',
          message: 'Send invoice',
          onTap: () => taps++,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(AlertBanner)),
      isSemantics(label: '1 overdue task, Send invoice', isButton: true),
    );
    await tester.tap(find.byType(AlertBanner));
    expect(taps, 1);
    handle.dispose();
  });
}
