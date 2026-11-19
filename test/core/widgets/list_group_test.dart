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
}
