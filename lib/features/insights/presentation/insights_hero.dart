import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S34's hero: the completion rate ring, the rate and its change.
class InsightsHero extends StatelessWidget {
  const new({required this.rate, required this.subline, super.key});

  /// 0–1, or null when nothing was due.
  final double? rate;

  /// "+6 pts vs previous 7 days".
  final String subline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final percent = rate == null ? '—' : '${(rate! * 100).round()}%';
    return Semantics(
      label: '${l10n.completionRateSemantics(percent)}, $subline',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: colors.hero,
          borderRadius: BorderRadius.circular(AppRadius.r32),
        ),
        child: Row(
          children: [
            ProgressRing(
              value: rate ?? 0,
              size: 72,
              stroke: 9,
              color: colors.onHero,
              trackColor: colors.heroTrack,
              semanticLabel: l10n.completionRateSemantics(percent),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.completionRateLabel,
                    style: text.label.copyWith(color: colors.heroLabel),
                  ),
                  Text(
                    percent,
                    style: text.heroValue.copyWith(color: colors.onHero),
                  ),
                  Text(
                    subline,
                    style: text.subline.copyWith(color: colors.heroSubline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
