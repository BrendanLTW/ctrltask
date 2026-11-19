import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_shadows.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/app_shell_tab.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';

void main() {
  late List<int> selected;
  late int adds;

  Future<void> pumpShell(
    WidgetTester tester, {
    ThemeData? theme,
    int currentIndex = 0,
    Size size = const Size(390, 844),
  }) async {
    selected = [];
    adds = 0;
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? buildLightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(
          currentIndex: currentIndex,
          onTabSelected: selected.add,
          onQuickAdd: () => adds++,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Finder tab(String label) =>
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == label);

  for (final (name, theme, colors, shadows) in [
    ('light', buildLightTheme(), AppColors.light, AppShadows.light),
    ('dark', buildDarkTheme(), AppColors.dark, AppShadows.dark),
  ]) {
    testWidgets('matches the design tokens and layout in $name', (
      tester,
    ) async {
      await pumpShell(tester, theme: theme);

      // Bar: 278 x 68, 16 from the left, 24 from the bottom of 844.
      final bar = find
          .ancestor(of: find.byType(Row), matching: find.byType(DecoratedBox))
          .first;
      expect(tester.getRect(bar), const Rect.fromLTWH(16, 752, 278, 68));
      final barBox =
          tester.widget<DecoratedBox>(bar).decoration as BoxDecoration;
      expect(barBox.color, colors.surface);
      expect(barBox.boxShadow, shadows.bottomBar);

      // Add button: 64 circle, 16 from the right, 26 from the bottom.
      final add = find.byTooltip('Quick add task');
      expect(tester.getRect(add), const Rect.fromLTWH(310, 754, 64, 64));
      final addBox =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: add,
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(addBox.boxShadow, shadows.quickAdd);
      final addFill = tester.widget<Material>(
        find.descendant(of: add, matching: find.byType(Material)),
      );
      expect(addFill.color, colors.ink);
      expect(
        tester.widget<AppIconView>(findAppIcon(AppIcon.add)).color,
        colors.onInk,
      );

      // Only the active tab shows its label, on a navSelected pill.
      expect(find.text('Home'), findsOneWidget);
      for (final other in ['Tasks', 'Projects', 'Focus']) {
        expect(find.text(other), findsNothing);
      }
      final pill = tester.widget<Material>(
        find.descendant(of: tab('Home'), matching: find.byType(Material)),
      );
      expect(pill.color, colors.navSelected);

      // A 130 px fade from transparent to ground sits behind the bar.
      final fade = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).gradient != null,
      );
      expect(tester.getRect(fade), const Rect.fromLTWH(0, 714, 390, 130));
      final gradient =
          (tester.widget<DecoratedBox>(fade).decoration as BoxDecoration)
                  .gradient!
              as LinearGradient;
      expect(gradient.colors, [
        colors.ground.withValues(alpha: 0),
        colors.ground,
      ]);
    });
  }

  testWidgets('every tab and the add button is a labelled 44px target', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpShell(tester, currentIndex: 2);

    for (final label in ['Home', 'Tasks', 'Projects', 'Focus']) {
      final size = tester.getSize(tab(label));
      expect(size.width, greaterThanOrEqualTo(44), reason: label);
      expect(size.height, greaterThanOrEqualTo(44), reason: label);
      expect(
        tester.getSemantics(tab(label)),
        isSemantics(
          label: label,
          isButton: true,
          isSelected: label == 'Projects',
        ),
      );
    }
    expect(find.bySemanticsLabel('Quick add task'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the fade lets taps through to the content', (tester) async {
    var taps = 0;
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(
          currentIndex: 0,
          onTabSelected: (_) {},
          onQuickAdd: () {},
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    // Inside the fade, above the bar.
    await tester.tapAt(const Offset(195, 730));

    expect(taps, 1);
  });

  testWidgets('taps report the tab index and the add press', (tester) async {
    await pumpShell(tester);

    await tester.tap(tab('Focus'));
    await tester.tap(tab('Home'));
    await tester.tap(find.byTooltip('Quick add task'));

    expect(selected, [3, 0]);
    expect(adds, 1);
  });

  testWidgets('the bar shrinks to clear the add button on narrow phones', (
    tester,
  ) async {
    await pumpShell(tester, size: const Size(320, 640), currentIndex: 3);

    final barRight = tester.getRect(tab('Projects')).right;
    final addLeft = tester.getRect(find.byTooltip('Quick add task')).left;
    expect(barRight, lessThan(addLeft));
    for (final label in ['Home', 'Tasks', 'Projects', 'Focus']) {
      expect(tester.getSize(tab(label)).width, greaterThanOrEqualTo(44));
    }
    expect(tester.takeException(), isNull);
  });
}
