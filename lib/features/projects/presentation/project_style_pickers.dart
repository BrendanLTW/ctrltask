import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S28's eight colour swatches (DESIGN §7): 36 px circles; the selected
/// one gets a gap and an `ink` ring.
class ColourSwatches extends StatelessWidget {
  const new({required this.selected, required this.onChanged, super.key});

  final ProjectColorKey selected;
  final ValueChanged<ProjectColorKey> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.projectColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final key in ProjectColorKey.values)
          Semantics(
            label: context.l10n.colourSemantics(key.name),
            selected: key == selected,
            button: true,
            excludeSemantics: true,
            onTap: () => onChanged(key),
            child: GestureDetector(
              onTap: () => onChanged(key),
              behavior: HitTestBehavior.opaque,
              child: SizedBox.square(
                dimension: 44,
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: key == selected
                          ? Border.all(color: colors.ink, width: 2)
                          : null,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.of(key).solid,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// S28's icons, in the designs' order, scrolling sideways past the first
/// six. The selected one is `ink`.
class ProjectIconPicker extends StatelessWidget {
  const new({required this.selected, required this.onChanged, super.key});

  static const List<ProjectIconKey> order = [
    ProjectIconKey.bag,
    ProjectIconKey.globe,
    ProjectIconKey.home,
    ProjectIconKey.code,
    ProjectIconKey.plane,
    ProjectIconKey.book,
    ProjectIconKey.chart,
    ProjectIconKey.briefcase,
    ProjectIconKey.box,
    ProjectIconKey.gift,
    ProjectIconKey.palette,
    ProjectIconKey.heart,
  ];

  final ProjectIconKey selected;
  final ValueChanged<ProjectIconKey> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (i, key) in order.indexed) ...[
            if (i > 0) const SizedBox(width: 9),
            Semantics(
              label: context.l10n.iconSemantics(key.name),
              selected: key == selected,
              button: true,
              excludeSemantics: true,
              onTap: () => onChanged(key),
              child: Material(
                color: key == selected ? colors.ink : colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r18),
                child: InkWell(
                  onTap: () => onChanged(key),
                  borderRadius: BorderRadius.circular(AppRadius.r18),
                  child: SizedBox.square(
                    dimension: 52,
                    child: AppIconView(
                      projectIcon(key),
                      size: 22,
                      color: key == selected ? colors.onInk : colors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
