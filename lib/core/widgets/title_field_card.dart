import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// The task form's title and description card (S11, DESIGN §7): a label,
/// the title in 20/600 and the description in 15/1.5 below it.
class TitleFieldCard extends StatelessWidget {
  const new({
    required this.label,
    required this.titleController,
    required this.titleHint,
    required this.titleMaxLength,
    required this.descriptionController,
    required this.descriptionHint,
    required this.descriptionMaxLength,
    this.autofocus = false,
    super.key,
  });

  /// Uppercase in the ARB copy: "TITLE".
  final String label;
  final TextEditingController titleController;
  final String titleHint;
  final int titleMaxLength;
  final TextEditingController descriptionController;
  final String descriptionHint;
  final int descriptionMaxLength;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final title = text.header.copyWith(
      color: colors.ink,
      fontWeight: FontWeight.w600,
    );
    final body = text.body.copyWith(color: colors.ink);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(
              label,
              style: text.labelSm.copyWith(color: colors.muted),
            ),
          ),
          // The gaps around the fields are part of them, so each is at least
          // 44 px tall to tap; the card looks the same.
          TextField(
            controller: titleController,
            autofocus: autofocus,
            maxLength: titleMaxLength,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            style: title,
            cursorColor: colors.ink,
            decoration:
                InputDecoration.collapsed(
                  hintText: titleHint,
                  hintStyle: title.copyWith(color: colors.muted),
                ).copyWith(
                  counterText: '',
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                ),
          ),
          TextField(
            controller: descriptionController,
            maxLength: descriptionMaxLength,
            maxLines: null,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            style: body,
            cursorColor: colors.ink,
            decoration:
                InputDecoration.collapsed(
                  hintText: descriptionHint,
                  hintStyle: body.copyWith(color: colors.muted),
                ).copyWith(
                  counterText: '',
                  contentPadding: const EdgeInsets.only(bottom: 4),
                ),
          ),
        ],
      ),
    );
  }
}
