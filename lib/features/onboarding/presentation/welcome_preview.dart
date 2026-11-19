import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/core/widgets/task_card.dart';
import 'package:ctrltask/core/widgets/task_content.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S02's illustration of a day in progress: a done task, a focus chip, a
/// 4-of-6 ring and an urgent task. Decorative.
class WelcomePreview extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;

    Widget chip(Widget leading, String label) => Container(
      height: 46,
      padding: const EdgeInsets.only(left: 9, right: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return ExcludeSemantics(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.hero,
          borderRadius: BorderRadius.circular(AppRadius.r36),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The chips shrink on narrow phones rather than overflow.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: chip(
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: AppIconView(
                        AppIcon.check,
                        size: 15,
                        color: colors.onInk,
                        stroke: 3,
                      ),
                    ),
                    l10n.welcomeDoneChip,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: chip(
                    const IconTile(
                      icon: AppIcon.timer,
                      color: ProjectColorKey.purple,
                      size: IconTileSize.small,
                    ),
                    l10n.welcomeFocusChip,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: ProgressRing(
                  value: 4 / 6,
                  size: 158,
                  stroke: 18,
                  color: colors.onHero,
                  trackColor: colors.heroTrack,
                  semanticLabel: '',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.welcomeRingValue,
                        style: text.heroValue.copyWith(color: colors.onHero),
                      ),
                      Text(
                        l10n.welcomeRingLabel,
                        style: text.chip.copyWith(
                          color: colors.heroLabel,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: TaskCard(
                data: TaskTileData(
                  title: l10n.welcomeTaskTitle,
                  priority: TaskPriority.urgent,
                  done: false,
                  timeLabel: l10n.welcomeTaskTime,
                ),
                onToggle: (_) {},
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
