import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/repeat/repeat_rule.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_stepper.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/features/tasks/domain/task_details.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/presentation/repeat_sheet.dart';
import 'package:ctrltask/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../projects/presentation/projects_app.dart';

void main() {
  late ProjectsApp app;
  // Thu 19 Nov 2026.
  final thursday = DateTime(2026, 11, 19);

  setUpAll(() async {
    await initializeDateFormatting('en');
    registerProjectFallbacks();
    registerFallbackValue(TaskDetails(task: testTask(0, '')));
  });

  group('repeatSummary', () {
    final l10n = AppLocalizationsEn();
    late DateLabels labels;
    setUpAll(() => labels = DateLabels('en'));
    String row(RepeatRule? rule, {WeekStart start = WeekStart.mon}) =>
        repeatSummary(l10n, labels, rule, weekStart: start);
    String button(RepeatRule? rule) => repeatSummary(
      l10n,
      labels,
      rule,
      weekStart: WeekStart.mon,
      button: true,
    );

    test('reads each rule back for rows', () {
      expect(row(null), 'Never');
      expect(row(const RepeatRule.daily()), 'Every day');
      expect(row(const RepeatRule.weekdays()), 'Weekdays');
      expect(row(RepeatRule.weekly({4, 2})), 'Every Tue, Thu');
      expect(row(const RepeatRule.monthly(19)), 'Every month on the 19th');
      expect(row(const RepeatRule.monthly(22)), 'Every month on the 22nd');
      expect(row(const RepeatRule.custom(2, RepeatUnit.week)), 'Every 2 weeks');
      expect(
        row(const RepeatRule.custom(3, RepeatUnit.month, dayOfMonth: 5)),
        'Every 3 months',
      );
    });

    test('days follow the week start; an end date is added', () {
      expect(
        row(RepeatRule.weekly({1, 7}), start: WeekStart.sun),
        'Every Sun, Mon',
      );
      expect(
        row(RepeatRule.daily(endsOn: DateTime(2027, 2, 5))),
        'Every day until 5 Feb',
      );
    });

    test('reads each rule back for the button', () {
      expect(button(null), "Don't repeat");
      expect(button(const RepeatRule.weekdays()), 'Repeat on weekdays');
      expect(button(RepeatRule.weekly({2, 4})), 'Repeat every Tue, Thu');
      expect(
        button(const RepeatRule.custom(1, RepeatUnit.day)),
        'Repeat every day',
      );
    });
  });

  group('S15', () {
    setUp(() {
      app = ProjectsApp();
      app.taskList.value = [
        testTask(1, 'Review wireframes', dueDate: thursday),
      ];
      when(() => app.tasks.watchDetails(any())).thenAnswer(
        (_) => app.taskList.stream.map(
          (all) => TaskDetails(task: all.first, repeat: savedRule),
        ),
      );
      when(() => app.tasks.update(any())).thenAnswer((i) async {
        savedRule = (i.positionalArguments.single as TaskDetails).repeat;
        app.taskList.value = [...app.taskList.value];
      });
    });

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.ensureVisible(find.text(text).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    /// Opens S15 from S12's Repeat row.
    Future<void> openFromDetail(WidgetTester tester) async {
      await app.pump(tester, location: Routes.task('1'));
      await tapText(tester, 'Repeat');
      expect(find.byType(RepeatSheet), findsOneWidget);
    }

    PrimaryButton setButton(WidgetTester tester) =>
        tester.widget<PrimaryButton>(find.byType(PrimaryButton).last);

    Future<void> set(WidgetTester tester) async {
      await tester.ensureVisible(find.byType(PrimaryButton).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PrimaryButton).last);
      await tester.pumpAndSettle();
    }

    for (final (option, rule, label) in [
      ('Every day', const RepeatRule.daily(), 'Every day'),
      ('Weekdays', const RepeatRule.weekdays(), 'Weekdays'),
      ('Every month', const RepeatRule.monthly(19), 'Every month on the 19th'),
    ]) {
      testWidgets('S12: $option saves and reads back', (tester) async {
        savedRule = null;
        await openFromDetail(tester);
        await tapText(tester, option);
        await set(tester);
        expect(savedRule, rule);
        expect(find.text(label), findsOneWidget);
      });
    }

    testWidgets('Every week starts on the due day; no days disables it', (
      tester,
    ) async {
      savedRule = null;
      await openFromDetail(tester);
      await tapText(tester, 'Every week');
      expect(find.text('ON THESE DAYS'), findsOneWidget);
      expect(find.text('Repeat every Thu'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Thu'));
      await tester.pumpAndSettle();
      expect(setButton(tester).onPressed, isNull);

      await tester.tap(find.bySemanticsLabel('Tue'));
      await tester.tap(find.bySemanticsLabel('Thu'));
      await tester.pumpAndSettle();
      await set(tester);
      expect(savedRule, RepeatRule.weekly({2, 4}));
    });

    testWidgets('Custom: every 1–12 days, weeks or months', (tester) async {
      savedRule = null;
      await openFromDetail(tester);
      await tapText(tester, 'Custom');
      final stepper = find.byType(AppStepper);
      await tester.ensureVisible(stepper);
      expect(find.text('Repeat every 2 weeks'), findsOneWidget);
      for (var i = 0; i < 12; i++) {
        tester.widget<AppStepper>(stepper).onIncrement?.call();
        await tester.pump();
      }
      expect(tester.widget<AppStepper>(stepper).onIncrement, isNull);
      expect(tester.widget<AppStepper>(stepper).value, '12');
      await tapText(tester, 'Months');
      await set(tester);
      expect(
        savedRule,
        const RepeatRule.custom(12, RepeatUnit.month, dayOfMonth: 19),
      );
    });

    testWidgets('Ends picks a date, and can be removed', (tester) async {
      savedRule = null;
      await openFromDetail(tester);
      await tapText(tester, 'Every day');
      await tapText(tester, 'Ends');
      expect(find.text('No time'), findsNothing, reason: 'a date only');
      await tapText(tester, 'Tomorrow');
      await tester.tap(find.byType(PrimaryButton).last);
      await tester.pumpAndSettle();
      expect(find.text('Repeat every day until 18 Nov'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove end date'));
      await tester.pumpAndSettle();
      expect(find.text('Repeat every day'), findsOneWidget);
    });

    testWidgets('Never clears it; closing changes nothing', (tester) async {
      savedRule = const RepeatRule.daily();
      await openFromDetail(tester);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      verifyNever(() => app.tasks.update(any()));

      await tapText(tester, 'Repeat');
      // The option, not the Ends row's "Never".
      await tester.tap(find.text('Never').first);
      await tester.pumpAndSettle();
      await set(tester);
      expect(savedRule, isNull);
    });

    testWidgets('S11: the Repeat row is saved with the task', (tester) async {
      await app.pump(tester, location: Routes.newTask);
      await tester.enterText(find.byType(TextField).first, 'Gym');
      await tapText(tester, 'Repeat');
      await tapText(tester, 'Weekdays');
      await set(tester);
      expect(find.text('Weekdays'), findsOneWidget);
      await tapText(tester, 'Save');
      final draft =
          verify(() => app.tasks.add(captureAny())).captured.single
              as TaskDraft;
      expect(draft.repeat, const RepeatRule.weekdays());
    });

    testWidgets('S10: the ↻ button sets the rule and fills in', (tester) async {
      await app.pump(tester);
      await tester.tap(find.byTooltip('Quick add task'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Stretch');
      await tester.pump();
      await tester.tap(find.byTooltip('Repeat'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Every day');
      await set(tester);
      expect(find.byTooltip('Repeat · Every day'), findsOneWidget);
      await tester.tap(find.byTooltip('Add task'));
      await tester.pumpAndSettle();
      final draft =
          verify(() => app.tasks.add(captureAny())).captured.single
              as TaskDraft;
      expect(draft.repeat, const RepeatRule.daily());
    });

    for (final brightness in Brightness.values) {
      testWidgets('S15 lays out at 200% in ${brightness.name}', (tester) async {
        await app.pump(
          tester,
          location: Routes.task('1'),
          brightness: brightness,
          textScale: 2,
        );
        await tapText(tester, 'Repeat');
        await tapText(tester, 'Every week');
        expect(tester.takeException(), isNull);
      });
    }
  });
}

RepeatRule? savedRule;
