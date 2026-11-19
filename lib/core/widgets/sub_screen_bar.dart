import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A sub-screen's 60 px top bar (DESIGN §6): back, or Cancel when
/// [cancelLabel] is set, on the left; the title in the middle; an optional
/// text action on the right, disabled when [onAction] is null. With
/// [actionIcon] the action is that icon, labelled [actionLabel] (S27's •••).
class SubScreenBar extends StatelessWidget {
  const new({
    required this.title,
    this.cancelLabel,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    super.key,
  });

  final String title;
  final String? cancelLabel;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppIcon? actionIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void back() => Navigator.of(context).maybePop();
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Align(
              alignment: Alignment.centerLeft,
              child: cancelLabel == null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: back,
                        tooltip: context.l10n.back,
                        color: colors.ink,
                        icon: const AppIconView(
                          AppIcon.chevronLeft,
                          size: 28,
                          stroke: AppIconStroke.chevron,
                        ),
                      ),
                    )
                  : TextLink(label: cancelLabel!, muted: true, onPressed: back),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.header.copyWith(color: colors.ink),
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Align(
              alignment: Alignment.centerRight,
              child: switch ((actionLabel, actionIcon)) {
                (null, _) => null,
                (final label?, final icon?) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: onAction,
                    tooltip: label,
                    color: colors.ink,
                    icon: AppIconView(icon, size: 24),
                  ),
                ),
                (final label?, null) => TextLink(
                  label: label,
                  onPressed: onAction,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
