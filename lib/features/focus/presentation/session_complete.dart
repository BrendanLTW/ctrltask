import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/progress_ring.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S32 Session complete (PRD §5.8): a full ring with a check, what was
/// done, and the next step. [footer] is the round's dots and today line.
class SessionComplete extends StatelessWidget {
  const new({
    required this.minutes,
    required this.taskTitle,
    required this.breakMinutes,
    required this.footer,
    required this.onStartBreak,
    required this.onSkipBreak,
    required this.onMarkDone,
    super.key,
  });

  final int minutes;
  final String? taskTitle;
  final int breakMinutes;
  final Widget footer;
  final VoidCallback onStartBreak;
  final VoidCallback onSkipBreak;

  /// Null hides Mark task done: no task, or it's done.
  final VoidCallback? onMarkDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final detail = switch (taskTitle) {
      final title? => l10n.minutesOn(minutes, title),
      null => l10n.minutesOfFocus(minutes),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ProgressRing(
            value: 1,
            size: 270,
            stroke: 14,
            color: colors.ink,
            trackColor: colors.raised,
            semanticLabel: l10n.titleWithDetail(l10n.sessionComplete, detail),
            // With large text the content shrinks to stay inside the ring.
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 226,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.successBox,
                          shape: BoxShape.circle,
                        ),
                        child: AppIconView(
                          AppIcon.check,
                          size: 34,
                          color: colors.onSuccessBox,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.sessionComplete,
                        textAlign: TextAlign.center,
                        style: text.stateTitle.copyWith(color: colors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.subline.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        footer,
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.startBreak(breakMinutes),
          onPressed: onStartBreak,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            PillButton(
              label: l10n.skipBreak,
              soft: true,
              onPressed: onSkipBreak,
            ),
            if (onMarkDone case final onTap?)
              PillButton(
                label: l10n.markTaskDone,
                icon: AppIcon.check,
                soft: true,
                onPressed: onTap,
              ),
          ],
        ),
      ],
    );
  }
}
