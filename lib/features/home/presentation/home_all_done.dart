import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/empty_state.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S09's celebration card: what the day added up to, the new streak, and
/// Plan tomorrow.
class DayDoneCard extends StatelessWidget {
  const new({
    required this.tasksDone,
    required this.focused,
    required this.streak,
    required this.onPlanTomorrow,
    super.key,
  });

  final int tasksDone;
  final Duration focused;
  final int streak;
  final VoidCallback onPlanTomorrow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = focused == Duration.zero
        ? l10n.dayDoneTasksOnly(tasksDone)
        : l10n.dayDoneTasks(tasksDone, l10n.durationLabel(focused));
    final days = l10n.dayCount(streak);
    final streakLine = l10n.dayDoneStreak(days);
    final cut = streakLine.indexOf(days);
    return Stack(
      children: [
        EmptyState(
          card: true,
          tone: StateTone.success,
          icon: AppIcon.check,
          title: l10n.dayDoneTitle,
          body: '$summary $streakLine',
          // The streak in bold: "Your streak is now **13 days**."
          bodySpan: TextSpan(
            children: [
              TextSpan(text: '$summary ${streakLine.substring(0, cut)}'),
              TextSpan(
                text: days,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: streakLine.substring(cut + days.length)),
            ],
          ),
          actionLabel: l10n.planTomorrow,
          onAction: onPlanTomorrow,
        ),
        const Positioned.fill(child: IgnorePointer(child: _Confetti())),
      ],
    );
  }
}

/// A few still flecks in project colours around the circle. Decorative.
class _Confetti extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final palette = context.projectColors;
    Widget fleck(
      ProjectColorKey color,
      Alignment at,
      Size size, {
      double radius = 3,
      double turn = 0,
    }) => Align(
      alignment: at,
      child: Transform.rotate(
        angle: turn,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: palette.of(color).solid,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
    return ExcludeSemantics(
      child: Stack(
        children: [
          fleck(
            ProjectColorKey.orange,
            const Alignment(-0.78, -0.79),
            const Size(11, 11),
            turn: 0.3,
          ),
          fleck(
            ProjectColorKey.pink,
            const Alignment(0.72, -0.84),
            const Size(12, 6),
            turn: -0.4,
          ),
          fleck(
            ProjectColorKey.blue,
            const Alignment(-0.56, -0.38),
            const Size(8, 8),
            radius: 4,
          ),
          fleck(
            ProjectColorKey.purple,
            const Alignment(0.79, -0.6),
            const Size(7, 7),
            radius: 4,
          ),
          fleck(
            ProjectColorKey.yellow,
            const Alignment(0.47, -0.41),
            const Size(9, 9),
            turn: 0.8,
          ),
        ],
      ),
    );
  }
}
