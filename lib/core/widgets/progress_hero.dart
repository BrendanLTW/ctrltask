import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Today's progress on the navy hero card (S07–S09, DESIGN §7): a ring with
/// the percentage, "2 of 6 done" and a sub line. Empty days read "Nothing
/// planned"; a finished day shows a check in a full ring.
class ProgressHero extends StatelessWidget {
  const new({
    required this.progress,
    required this.subline,
    this.onTap,
    super.key,
  });

  final Progress progress;

  /// "4 left · next: Review wireframes, 10:00 AM".
  final String subline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final (:done, :total) = progress;
    final finished = total > 0 && done == total;
    return Semantics(
      button: onTap != null,
      label:
          '${l10n.todaysProgress}, ${l10n.heroSemantics(done, total)}, '
          '$subline',
      excludeSemantics: true,
      child: Material(
        color: colors.hero,
        borderRadius: BorderRadius.circular(AppRadius.r32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    ProgressRing(
                      value: progress.fraction,
                      size: 76,
                      stroke: 9,
                      color: colors.onHero,
                      trackColor: colors.heroTrack,
                      semanticLabel: l10n.heroSemantics(done, total),
                      child: finished
                          ? AppIconView(
                              AppIcon.check,
                              size: 26,
                              color: colors.onHero,
                              stroke: 3,
                            )
                          : Text(
                              '${progress.percent}%',
                              style: text.body.copyWith(
                                color: colors.onHero,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.todaysProgress,
                            style: text.label.copyWith(color: colors.heroLabel),
                          ),
                          const SizedBox(height: 4),
                          if (total == 0)
                            Text(
                              l10n.nothingPlanned,
                              style: text.heroValue.copyWith(
                                color: colors.onHero,
                                fontSize: text.detailTitle.fontSize,
                              ),
                            )
                          else
                            Text.rich(
                              TextSpan(
                                text: '$done',
                                style: text.heroValue.copyWith(
                                  color: colors.onHero,
                                ),
                                children: [
                                  TextSpan(
                                    text: l10n.heroOfDone(total),
                                    style: text.heroUnit.copyWith(
                                      color: colors.heroUnit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            subline,
                            style: text.subline.copyWith(
                              color: colors.heroSubline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                PositionedDirectional(
                  top: 20,
                  end: 22,
                  child: AppIconView(
                    AppIcon.arrowUpRight,
                    size: 22,
                    color: colors.onHero,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
