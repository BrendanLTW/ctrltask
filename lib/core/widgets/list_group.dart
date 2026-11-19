import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_toggle.dart';
import 'package:ctrltask/core/widgets/large_text.dart';
import 'package:flutter/material.dart';

/// A rounded card of rows with dividers between them (DESIGN §7).
class ListGroup extends StatelessWidget {
  const new({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r28),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: colors.divider),
            child,
          ],
        ],
      ),
    );
  }
}

/// A row in a [ListGroup]: optional leading tile, title and sub line,
/// optional value, and a chevron when it can be tapped (DESIGN §7).
class ListGroupRow extends StatelessWidget {
  const new({
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.valueEmphasis = false,
    this.titleColor,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.chevron = true,
    super.key,
  });

  final String title;

  /// A muted second line.
  final String? subtitle;
  final Widget? leading;
  final String? value;

  /// The value in `ink` 600 rather than `muted`, as a chosen value (S11's
  /// Due).
  final bool valueEmphasis;

  /// Defaults to `ink`; `negative` for Erase all data (S35).
  final Color? titleColor;

  /// A widget in the value's place, e.g. a toggle. Not read out.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shows a check instead of the chevron, for single-choice lists.
  final bool selected;

  /// False hides the chevron on a tappable row, as "Add subtask".
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    // With large text the value goes under the title, so neither is
    // squeezed into a narrow column (DESIGN §11).
    final stacked = largeText(context);
    final valueText = switch (value) {
      final value? => Text(
        value,
        style: text.chip.copyWith(color: colors.muted),
      ),
      null => null,
    };
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: [title, ?subtitle, ?value].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        highlightColor: colors.rowPressed,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                if (leading case final leading?) ...[
                  leading,
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(
                          color: titleColor ?? colors.ink,
                        ),
                      ),
                      if (subtitle case final subtitle?) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: text.caption.copyWith(color: colors.muted),
                        ),
                      ],
                      if (valueText case final valueText? when stacked) ...[
                        const SizedBox(height: 2),
                        valueText,
                      ],
                    ],
                  ),
                ),
                // Shrinks and wraps before it pushes the row off screen.
                if (valueText case final valueText? when !stacked)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: valueText,
                    ),
                  ),
                if (trailing case final trailing?)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: trailing,
                  ),
                if (selected || (onTap != null && chevron))
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: AppIconView(
                      selected ? AppIcon.check : AppIcon.chevronRight,
                      size: 20,
                      color: selected ? colors.ink : colors.muted,
                      stroke: AppIconStroke.chevron,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A label on the left in `muted` and a value on the right in 600 (S06).
class KeyValueRow extends StatelessWidget {
  const new({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Semantics(
      label: '$label, $value',
      excludeSemantics: true,
      // At least 58 high; taller when large text stacks the value.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 58),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Center(
            heightFactor: 1,
            child: SpreadOrStack(
              start: Text(
                label,
                style: text.body.copyWith(color: colors.muted),
              ),
              end: Text(
                value,
                style: text.body.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [ListGroup] row with a toggle (S05, S31, S39). The whole row toggles
/// and reads as one toggle to screen readers.
class ListGroupToggleRow extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        highlightColor: colors.rowPressed,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                      ),
                      if (subtitle case final subtitle?) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: text.caption.copyWith(color: colors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppToggle(
                  value: value,
                  onChanged: onChanged,
                  semanticLabel: title,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
