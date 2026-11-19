import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// The red overdue banner on Home (S07, DESIGN §7): a warning tile, a
/// title, a message and a chevron.
class AlertBanner extends StatelessWidget {
  const new({
    required this.title,
    required this.message,
    required this.onTap,
    super.key,
  });

  /// "1 overdue task".
  final String title;

  /// "Send invoice to Lumen Studio · was due yesterday".
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      button: true,
      label: '$title, $message',
      excludeSemantics: true,
      child: Material(
        color: colors.errorBox,
        borderRadius: BorderRadius.circular(AppRadius.r22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r13),
                  ),
                  child: AppIconView(
                    AppIcon.warning,
                    size: 20,
                    color: colors.negative,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.body.copyWith(
                          color: colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        message,
                        style: text.caption.copyWith(color: colors.chipText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AppIconView(
                  AppIcon.chevronRight,
                  size: 20,
                  color: colors.ink,
                  stroke: AppIconStroke.chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
