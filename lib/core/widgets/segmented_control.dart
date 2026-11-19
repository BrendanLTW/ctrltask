import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

typedef Segment<T> = ({T value, String label, AppIcon? icon});

/// Equal-width segments with one selected (DESIGN §7): List · Calendar ·
/// Board, Active · Archived. Track `surface` (`fillSoft` with [inSheet]),
/// radius 24, padding 6; segments 44 high, selected `ink`.
class SegmentedControl<T> extends StatelessWidget {
  const new({
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.inSheet = false,
    super.key,
  });

  final List<Segment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool inSheet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const pad = 6.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inSheet ? colors.fillSoft : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r24),
      ),
      // Same height for every segment, even if one label wraps.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, segment) in segments.indexed)
              Expanded(
                child: _segment(
                  context,
                  segment,
                  EdgeInsets.fromLTRB(
                    i == 0 ? pad : 0,
                    pad,
                    i == segments.length - 1 ? pad : 0,
                    pad,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, Segment<T> segment, EdgeInsets pad) {
    final colors = context.colors;
    final on = segment.value == selected;
    final color = on ? colors.onInk : colors.muted;
    return Semantics(
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      label: segment.label,
      excludeSemantics: true,
      // The track's padding is part of each segment's tap area (56 high).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(segment.value),
        child: Padding(
          padding: pad,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? colors.ink : null,
              borderRadius: BorderRadius.circular(AppRadius.r18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (segment.icon case final icon?) ...[
                  AppIconView(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                ],
                // Two lines at large text sizes rather than "Calen…".
                Flexible(
                  child: Text(
                    segment.label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.chip.copyWith(color: color),
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
