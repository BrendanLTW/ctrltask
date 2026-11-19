import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/widgets/app_text_input.dart';
import 'package:ctrltask/core/widgets/search_field.dart';
import 'package:ctrltask/core/widgets/title_field_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_themed.dart';

void main() {
  for (final (name, theme, colors) in [
    ('light', buildLightTheme(), AppColors.light),
    ('dark', buildDarkTheme(), AppColors.dark),
  ]) {
    testWidgets('text input outlines ink on focus, negative on error in '
        '$name', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      Color outline() =>
          ((tester
                              .widget<Container>(
                                find
                                    .descendant(
                                      of: find.byType(AppTextInput),
                                      matching: find.byType(Container),
                                    )
                                    .first,
                              )
                              .decoration!
                          as BoxDecoration)
                      .border!
                  as Border)
              .top
              .color;

      await pumpThemed(
        tester,
        SizedBox(
          width: 358,
          child: AppTextInput(controller: controller, maxLength: 30),
        ),
        theme: theme,
      );
      expect(outline(), colors.surface);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(outline(), colors.ink);

      await pumpThemed(
        tester,
        SizedBox(
          width: 358,
          child: AppTextInput(
            controller: controller,
            maxLength: 30,
            error: true,
          ),
        ),
        theme: theme,
      );
      expect(outline(), colors.negative);
    });

    testWidgets('search field is a 52 px pill, ground in sheets, in $name', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      for (final (inSheet, fill) in [
        (false, colors.surface),
        (true, colors.ground),
      ]) {
        await pumpThemed(
          tester,
          SizedBox(
            width: 358,
            child: SearchField(
              controller: controller,
              hint: 'Search projects',
              onChanged: (_) {},
              inSheet: inSheet,
            ),
          ),
          theme: theme,
        );
        expect(tester.getSize(find.byType(SearchField)).height, 52);
        expect(
          tester
              .widget<TextField>(find.byType(TextField))
              .decoration!
              .fillColor,
          fill,
        );
      }
    });
  }

  testWidgets('text input stops at its limit and shows its helper', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: AppTextInput(
          controller: controller,
          maxLength: 5,
          helper: 'You can change this any time in Settings.',
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Alexander');
    expect(controller.text, 'Alexa');
    expect(
      find.text('You can change this any time in Settings.'),
      findsOneWidget,
    );
  });

  testWidgets('search shows Clear once there is text, and clears', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: SearchField(
          controller: controller,
          hint: 'Search',
          onChanged: changes.add,
        ),
      ),
    );
    expect(find.byTooltip('Clear search'), findsNothing);
    await tester.enterText(find.byType(TextField), 'ryokan');
    await tester.pump();
    expect(find.byTooltip('Clear search'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(changes, ['ryokan', '']);
  });

  testWidgets('title card caps the title and description', (tester) async {
    final title = TextEditingController();
    final description = TextEditingController();
    addTearDown(title.dispose);
    addTearDown(description.dispose);
    await pumpThemed(
      tester,
      SizedBox(
        width: 358,
        child: TitleFieldCard(
          label: 'TITLE',
          titleController: title,
          titleHint: 'What needs doing?',
          titleMaxLength: 10,
          descriptionController: description,
          descriptionHint: 'Add a description',
          descriptionMaxLength: 5,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'x' * 20);
    await tester.enterText(find.byType(TextField).last, 'y' * 20);
    expect(title.text, hasLength(10));
    expect(description.text, hasLength(5));
  });
}
