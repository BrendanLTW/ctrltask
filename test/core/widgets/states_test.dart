import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_chip.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/empty_state.dart';
import 'package:ctrltask/core/widgets/message_box.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('message boxes use their tokens in $name', (tester) async {
      for (final (kind, background, foreground) in [
        (MessageKind.error, colors.errorBox, colors.onErrorBox),
        (MessageKind.warning, colors.warningBox, colors.onWarningBox),
        (MessageKind.success, colors.successBox, colors.onSuccessBox),
        (MessageKind.info, colors.infoBox, colors.onInfoBox),
      ]) {
        await pumpThemed(
          tester,
          SizedBox(width: 358, child: MessageBox('Note', kind: kind)),
          theme: theme,
        );
        final box =
            tester.widget<Container>(find.byType(Container).first).decoration!
                as BoxDecoration;
        expect(box.color, background, reason: '$kind');
        expect(
          tester.widget<Text>(find.text('Note')).style!.color,
          foreground,
          reason: '$kind',
        );
      }
    });

    testWidgets('state circles take their tone in $name', (tester) async {
      for (final (tone, circle) in [
        (StateTone.neutral, colors.raised),
        (StateTone.success, colors.successBox),
        (StateTone.error, colors.errorBox),
      ]) {
        await pumpThemed(
          tester,
          SizedBox(
            width: 358,
            child: EmptyState(
              icon: AppIcon.check,
              title: 'Day done. Nice work.',
              body: 'Body',
              tone: tone,
            ),
          ),
          theme: theme,
        );
        final box =
            tester.widget<Container>(find.byType(Container).first).decoration!
                as BoxDecoration;
        expect(box.color, circle, reason: '$tone');
      }
    });
  }

  testWidgets('an error box is announced as it appears', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      const SizedBox(
        width: 358,
        child: MessageBox('Backup failed', kind: MessageKind.error),
      ),
    );
    expect(
      tester.getSemantics(find.byType(MessageBox)),
      isSemantics(label: 'Backup failed', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('empty state: title, action with icon, and a footer', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var adds = 0;
    final picked = <String>[];
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: EmptyState(
          icon: AppIcon.tasks,
          title: 'Your day is a blank page',
          body: 'Add the first thing you want to get done today.',
          actionLabel: 'Add a task',
          actionIcon: AppIcon.add,
          onAction: () => adds++,
          footer: Wrap(
            children: [
              for (final s in ['Plan my week', 'Clear my inbox'])
                AppChip(label: s, small: true, onTap: () => picked.add(s)),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Your day is a blank page')),
      isSemantics(label: 'Your day is a blank page', isHeader: true),
    );
    await tester.tap(find.byType(PillButton));
    await tester.tap(find.text('Clear my inbox'));
    expect(adds, 1);
    expect(picked, ['Clear my inbox']);
    expect(find.byType(AppChip), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(PillButton),
        matching: find.byType(AppIconView),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the card variant sits on a surface card', (tester) async {
    await pumpThemed(
      tester,
      const SizedBox(
        width: 358,
        child: EmptyState(
          icon: AppIcon.check,
          title: 'Day done. Nice work.',
          body: 'Your streak is now 13 days.',
          bodySpan: TextSpan(
            children: [
              TextSpan(text: 'Your streak is now '),
              TextSpan(
                text: '13 days',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: '.'),
            ],
          ),
          tone: StateTone.success,
          card: true,
        ),
      ),
    );
    final card =
        tester.widget<Container>(find.byType(Container).first).decoration!
            as BoxDecoration;
    expect(card.color, AppColors.light.surface);
    expect(
      find.text('Your streak is now 13 days.', findRichText: true),
      findsOneWidget,
    );
  });
}
