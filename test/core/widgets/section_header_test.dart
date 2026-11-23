import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    group(name, () {
      testWidgets('a detail sits at the right edge', (tester) async {
        await pumpThemed(
          tester,
          const SizedBox(
            width: 358,
            child: SectionHeader('OVERDUE', detail: '1 task', alert: true),
          ),
          theme: theme,
        );
        final row = tester.getRect(find.byType(SectionHeader));
        final detail = tester.getRect(find.text('1 task'));
        // 8 px in from the edge.
        expect(detail.right, closeTo(row.right - 8, 1));
      });

      testWidgets('an alert label is negative, others muted', (tester) async {
        await pumpThemed(
          tester,
          const Column(
            children: [
              SectionHeader('OVERDUE', alert: true),
              SectionHeader('TODAY'),
            ],
          ),
          theme: theme,
        );
        Color? colorOf(String label) =>
            tester.widget<Text>(find.text(label)).style?.color;
        expect(colorOf('OVERDUE'), colors.negative);
        expect(colorOf('TODAY'), colors.muted);
      });

      testWidgets('a long detail wraps rather than overflow', (tester) async {
        await pumpThemed(
          tester,
          const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(
              width: 358,
              child: SectionHeader(
                'TOMORROW',
                detail: 'Swipe for quick actions',
              ),
            ),
          ),
          theme: theme,
        );
        expect(tester.takeException(), isNull);
      });
    });
  }
}
