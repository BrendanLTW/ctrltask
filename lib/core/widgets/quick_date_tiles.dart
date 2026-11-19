import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

typedef QuickDate<T> = ({T value, String label, String detail});

/// Four quick date tiles (S14, DESIGN §7): Today · Tomorrow · Weekend ·
/// Next week, each 76 high on `fillSoft` with its day under the label,
/// both muted 13/500 as the S14 design shows.
class QuickDateTiles<T> extends StatelessWidget {
  const new({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<QuickDate<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Row(
      children: [
        for (final (i, option) in options.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              button: true,
              selected: option.value == selected,
              label: '${option.label}, ${option.detail}',
              excludeSemantics: true,
              child: Material(
                color: option.value == selected ? colors.ink : colors.fillSoft,
                borderRadius: BorderRadius.circular(AppRadius.r20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  highlightColor: colors.raised,
                  splashFactory: NoSplash.splashFactory,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 76),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            option.label,
                            textAlign: TextAlign.center,
                            style: text.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: option.value == selected
                                  ? colors.onInk
                                  : colors.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.detail,
                            textAlign: TextAlign.center,
                            style: text.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: option.value == selected
                                  ? colors.onInk
                                  : colors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
