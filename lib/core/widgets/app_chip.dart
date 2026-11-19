import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A pill chip (DESIGN §7): 40 high on `surface`, or 36 on `fillSoft` when
/// [small]; `ink` when [selected]. It can lead with a project dot or a
/// priority flag, and a [count] follows at 60% opacity. Its touch area is
/// always 44 high.
class AppChip extends StatelessWidget {
  const new({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.small = false,
    this.leading,
    this.count,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool small;
  final Widget? leading;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style =
        (small
                ? text.chip.copyWith(fontSize: text.caption.fontSize)
                : text.chip)
            .copyWith(color: selected ? colors.onInk : colors.chipText);
    final height = small ? 36.0 : 40.0;
    return Semantics(
      button: true,
      selected: selected,
      label: count == null ? label : '$label, $count',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: (44 - height) / 2),
          child: Material(
            color: selected
                ? colors.ink
                : small
                ? colors.fillSoft
                : colors.surface,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              highlightColor: selected ? colors.inkPressed : colors.raised,
              splashFactory: NoSplash.splashFactory,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    // Centred when given a fixed width, as S05's time chips.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leading case final leading?) ...[
                        leading,
                        const SizedBox(width: 8),
                      ],
                      Flexible(child: Text(label, style: style)),
                      if (count case final count?) ...[
                        const SizedBox(width: 6),
                        Opacity(
                          opacity: 0.6,
                          child: Text('$count', style: style),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef ChipOption<T> = ({T value, String label, int? count});

/// A sideways-scrolling row of single-choice [AppChip]s, e.g. S19's All ·
/// Today · Upcoming with counts.
class FilterChips<T> extends StatelessWidget {
  const new({
    required this.chips,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<ChipOption<T>> chips;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenX),
    child: Row(
      children: [
        for (final (i, chip) in chips.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          AppChip(
            label: chip.label,
            count: chip.count,
            selected: chip.value == selected,
            onTap: () => onChanged(chip.value),
          ),
        ],
      ],
    ),
  );
}
