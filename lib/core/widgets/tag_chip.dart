import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A tag as "#name" on a `raised` pill (DESIGN §7).
class TagChip extends StatelessWidget {
  const new(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: colors.raised,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      // A Row keeps the chip to its text's width; long names shrink.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              context.l10n.tagLabel(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.tag.copyWith(color: colors.chipText),
            ),
          ),
        ],
      ),
    );
  }
}
