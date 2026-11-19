import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/pump_themed.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('a group is a surface card with dividers in $name', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        const SizedBox(
          width: 358,
          child: ListGroup(
            children: [
              ListGroupRow(title: 'Theme', value: 'System'),
              ListGroupRow(title: 'Week starts on', value: 'Monday'),
              KeyValueRow(label: 'Name', value: 'Alex'),
            ],
          ),
        ),
        theme: theme,
      );

      final card = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(ListGroup),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(card.color, colors.surface);
      final dividers = tester.widgetList<Divider>(find.byType(Divider));
      expect(dividers, hasLength(2));
      expect(dividers.first.color, colors.divider);
    });
  }

  testWidgets('a tappable row has a chevron and reads as a button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: ListGroupRow(
          title: 'Notifications',
          subtitle: 'Task reminders and more',
          value: '3 on',
          onTap: () => taps++,
        ),
      ),
    );

    expect(findAppIcon(AppIcon.chevronRight), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(ListGroupRow)),
      isSemantics(
        label: 'Notifications, Task reminders and more, 3 on',
        isButton: true,
      ),
    );
    expect(
      tester.getSize(find.byType(ListGroupRow)).height,
      greaterThanOrEqualTo(60),
    );
    await tester.tap(find.byType(ListGroupRow));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('a selected row shows a check instead', (tester) async {
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: ListGroupRow(title: 'Monday', selected: true, onTap: () {}),
      ),
    );
    expect(findAppIcon(AppIcon.check), findsOneWidget);
    expect(findAppIcon(AppIcon.chevronRight), findsNothing);
  });

  testWidgets('at 200% text the value moves under the title', (tester) async {
    await pumpThemed(
      tester,
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: SizedBox(
          width: 358,
          child: ListGroupRow(
            title: 'Default task reminder',
            value: '30 min before',
          ),
        ),
      ),
    );

    final title = tester.getRect(find.text('Default task reminder'));
    final value = tester.getRect(find.text('30 min before'));
    expect(value.top, greaterThan(title.top));
    expect(tester.takeException(), isNull);
  });

  group('the value takes what the title leaves', () {
    Future<void> pumpRow(WidgetTester tester, String title, String value) =>
        pumpThemed(
          tester,
          SizedBox(
            width: 358,
            child: ListGroupRow(
              title: title,
              value: value,
              leading: const SizedBox.square(dimension: 40),
              onTap: () {},
            ),
          ),
        );

    // Test text draws each character as a box its font size wide, so the
    // strings below are sized for that. One line is about 22 high.
    bool oneLine(WidgetTester tester, String text) =>
        tester.getSize(find.text(text)).height < 32;

    testWidgets('a short title leaves a long value on one line', (
      tester,
    ) async {
      // 168 wide: more than half the row's 236, less than what "Due"
      // leaves.
      await pumpRow(tester, 'Due', '17 Nov 10 AM');
      expect(oneLine(tester, '17 Nov 10 AM'), isTrue);
    });

    testWidgets('a short value leaves a long title on one line', (
      tester,
    ) async {
      await pumpRow(tester, 'Archived pro', '3');
      expect(oneLine(tester, 'Archived pro'), isTrue);
    });

    testWidgets('both long: the value wraps within half the row', (
      tester,
    ) async {
      await pumpRow(
        tester,
        'A rather long row title here',
        'An equally long value text',
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.text('An equally long value text')).width,
        lessThanOrEqualTo(358 / 2),
      );
    });
  });
}
