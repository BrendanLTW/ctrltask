import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/progress_hero.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

void main() {
  Future<void> pumpHero(
    WidgetTester tester,
    Progress progress, {
    ThemeData? theme,
    VoidCallback? onTap,
  }) => pumpThemed(
    tester,
    SizedBox(
      width: 358,
      child: ProgressHero(
        progress: progress,
        subline: '4 left · next: Review wireframes',
        onTap: onTap,
      ),
    ),
    theme: theme,
  );

  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('matches the hero spec in $name', (tester) async {
      await pumpHero(tester, (done: 2, total: 6), theme: theme);

      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ProgressHero),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, colors.hero);
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(ProgressRing),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter!
              as RingPainter;
      expect(painter.color, colors.onHero);
      expect(painter.trackColor, colors.heroTrack);
      expect(painter.value, closeTo(1 / 3, 1e-9));
      expect(tester.getSize(find.byType(ProgressRing)), const Size(76, 76));
      expect(find.text('33%'), findsOneWidget);
      expect(find.text("TODAY'S PROGRESS"), findsOneWidget);
      expect(find.text('2 of 6 done', findRichText: true), findsOneWidget);
    });
  }

  testWidgets('screen readers hear the counts and it is a button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpHero(tester, (done: 2, total: 6), onTap: () {});
    expect(
      tester.getSemantics(find.byType(ProgressHero)),
      isSemantics(
        label:
            "TODAY'S PROGRESS, 2 of 6 tasks done today, "
            '4 left · next: Review wireframes',
        isButton: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the arrow shows only when it can be tapped', (tester) async {
    await pumpHero(tester, (done: 2, total: 6));
    expect(findAppIcon(AppIcon.arrowUpRight), findsNothing);
    await pumpHero(tester, (done: 2, total: 6), onTap: () {});
    expect(findAppIcon(AppIcon.arrowUpRight), findsOneWidget);
  });

  testWidgets('an empty day reads Nothing planned at 0%', (tester) async {
    await pumpHero(tester, (done: 0, total: 0));
    expect(find.text('Nothing planned'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('a finished day shows a check in a full ring', (tester) async {
    await pumpHero(tester, (done: 6, total: 6));
    expect(findAppIcon(AppIcon.check), findsOneWidget);
    expect(find.text('100%'), findsNothing);
    expect(find.text('6 of 6 done', findRichText: true), findsOneWidget);
  });

  test('the ring clamps and repaints only on change', () {
    const a = RingPainter(
      value: 0.5,
      stroke: 9,
      color: Color(0xFFFFFFFF),
      trackColor: Color(0xFF000000),
    );
    expect(a.shouldRepaint(a), isFalse);
    expect(
      a.shouldRepaint(
        const RingPainter(
          value: 0.6,
          stroke: 9,
          color: Color(0xFFFFFFFF),
          trackColor: Color(0xFF000000),
        ),
      ),
      isTrue,
    );
  });
}
