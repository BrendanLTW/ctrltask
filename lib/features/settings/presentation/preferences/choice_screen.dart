import 'dart:async';

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/message_box.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:flutter/material.dart';

/// An option on S37 or S38.
typedef Choice<T> = ({T value, String title, String? detail, Widget? leading});

/// S37 and S38: a sub-screen with one choice from a list, saved the
/// moment it's tapped, and a note.
class ChoiceScreen<T> extends StatelessWidget {
  const new({
    required this.title,
    required this.choices,
    required this.selected,
    required this.onChanged,
    required this.note,
    super.key,
  });

  final String title;
  final List<Choice<T>> choices;
  final T selected;
  final Future<void> Function(T) onChanged;
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(title: title),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  ListGroup(
                    children: [
                      for (final c in choices)
                        ListGroupRadioRow(
                          title: c.title,
                          subtitle: c.detail,
                          leading: c.leading,
                          selected: c.value == selected,
                          onTap: () => unawaited(onChanged(c.value)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  MessageBox(note),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
