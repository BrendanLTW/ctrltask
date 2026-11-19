import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// A section label with an optional link on the right, "DUE TODAY · All
/// tasks ›" (DESIGN §5: 20 above, 10 below, inset 24).
class SectionHeader extends StatelessWidget {
  const new(this.label, {this.linkLabel, this.onLink, super.key})
    : assert((linkLabel == null) == (onLink == null), 'label + action');

  /// Uppercase in the ARB copy.
  final String label;
  final String? linkLabel;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.textX - AppSpacing.screenX,
        AppSpacing.sectionTop,
        0,
        10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                label,
                style: text.label.copyWith(color: colors.muted),
              ),
            ),
          ),
          if ((linkLabel, onLink) case (final link?, final onTap?))
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.only(left: 12, right: 4),
                foregroundColor: colors.ink,
                overlayColor: colors.raised,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(link, style: text.rowTitle.copyWith(color: colors.ink)),
                  const SizedBox(width: 2),
                  AppIconView(
                    AppIcon.chevronRight,
                    size: 18,
                    color: colors.ink,
                    stroke: AppIconStroke.chevron,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
