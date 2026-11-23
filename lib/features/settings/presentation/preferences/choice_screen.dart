import 'dart:async';

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
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
    final text = context.text;
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
                        Semantics(
                          selected: c.value == selected,
                          button: true,
                          child: InkWell(
                            onTap: () => unawaited(onChanged(c.value)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                16,
                                18,
                                16,
                              ),
                              child: Row(
                                children: [
                                  if (c.leading case final leading?) ...[
                                    leading,
                                    const SizedBox(width: 16),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.title,
                                          style: text.rowTitle.copyWith(
                                            color: colors.ink,
                                          ),
                                        ),
                                        if (c.detail case final detail?)
                                          Text(
                                            detail,
                                            style: text.subline.copyWith(
                                              color: colors.muted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  AppRadio(selected: c.value == selected),
                                ],
                              ),
                            ),
                          ),
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
