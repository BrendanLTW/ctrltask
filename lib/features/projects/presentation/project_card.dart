import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_progress_bar.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_calculations.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// "Due Mon, 30 Nov" or "No deadline".
String deadlineMeta(BuildContext context, Project project, DateLabels labels) {
  final l10n = context.l10n;
  return switch (project.deadline) {
    final deadline? => l10n.projectDue(labels.date(deadline)),
    null => l10n.noDeadline,
  };
}

/// A project card on S26 (DESIGN §7): tile, name, deadline, days left,
/// progress and counts.
class ProjectCard extends StatelessWidget {
  const new({
    required this.project,
    required this.progress,
    required this.today,
    required this.labels,
    required this.onTap,
    super.key,
  });

  final Project project;
  final Progress progress;
  final DateTime today;
  final DateLabels labels;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final palette = context.projectColors.of(project.colorKey);
    final meta = deadlineMeta(context, project, labels);
    final summary = l10n.projectProgressSemantics(
      progress.percent,
      progress.done,
      progress.total,
    );
    return Semantics(
      button: true,
      label: [
        project.name,
        meta,
        if (project.deadline case final d?) l10n.daysLeftLabel(d, today: today),
        summary,
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.r28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconTile.forProject(
                      project.iconKey,
                      color: project.colorKey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            // Tighter, as the design, so a name fits beside
                            // the days-left tag.
                            style: text.cardTitle.copyWith(
                              color: colors.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            meta,
                            style: text.caption.copyWith(color: colors.muted),
                          ),
                        ],
                      ),
                    ),
                    if (project.deadline case final deadline?) ...[
                      const SizedBox(width: 8),
                      // Shrinks and wraps with large text.
                      Flexible(
                        child: DaysLeftTag(
                          deadline: deadline,
                          today: today,
                          color: project.colorKey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                AppProgressBar(
                  value: progress.fraction,
                  color: palette.solid,
                  trackColor: palette.tile,
                  semanticLabel: summary,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.percent(progress.percent),
                              style: TextStyle(
                                color: colors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: l10n.completeSuffix),
                          ],
                        ),
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                    ),
                    Text(
                      l10n.tasksOfTotal(progress.done, progress.total),
                      style: text.caption.copyWith(color: colors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "13 days left" in the project's colours, red at 7 days or fewer.
class DaysLeftTag extends StatelessWidget {
  const new({
    required this.deadline,
    required this.today,
    required this.color,
    super.key,
  });

  final DateTime deadline;
  final DateTime today;
  final ProjectColorKey color;

  @override
  Widget build(BuildContext context) {
    final close = deadlineIsClose(daysLeft(deadline, today));
    final palette = context.projectColors.of(
      close ? ProjectColorKey.red : color,
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.tile,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        context.l10n.daysLeftLabel(deadline, today: today),
        textAlign: TextAlign.center,
        style: context.text.tag.copyWith(color: palette.icon),
      ),
    );
  }
}
