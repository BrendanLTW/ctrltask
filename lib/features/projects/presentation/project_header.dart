import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/theme/project_palette.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_progress_bar.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/tasks/domain/progress.dart';
import 'package:ctrltask/l10n/date_text.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S27's header card in the project's colour (DESIGN §7): icon, name,
/// deadline and days left, description, progress and focus time.
class ProjectHeader extends StatelessWidget {
  const new({
    required this.project,
    required this.progress,
    required this.focused,
    required this.today,
    required this.labels,
    super.key,
  });

  final Project project;
  final Progress progress;
  final Duration focused;
  final DateTime today;
  final DateLabels labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final palette = context.projectColors.of(project.colorKey);
    final meta = switch (project.deadline) {
      final d? => l10n.titleWithDetail(
        l10n.projectDue(labels.date(d)),
        l10n.daysLeftLabel(d, today: today),
      ),
      null => l10n.noDeadline,
    };
    final done = l10n.projectTasksDone(progress.done, progress.total);
    final style = text.caption.copyWith(color: colors.chipText);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.tile,
        borderRadius: BorderRadius.circular(AppRadius.r32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r16),
                  ),
                  child: AppIconView(
                    projectIcon(project.iconKey),
                    size: 22,
                    color: palette.icon,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        project.name,
                        style: text.detailTitle.copyWith(color: colors.ink),
                      ),
                    ),
                    Text(meta, style: style),
                  ],
                ),
              ),
            ],
          ),
          if (project.description case final description?) ...[
            const SizedBox(height: 14),
            Text(description, style: style),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppProgressBar(
                  value: progress.fraction,
                  color: palette.solid,
                  trackColor: colors.surface,
                  semanticLabel: l10n.projectProgressSemantics(
                    progress.percent,
                    progress.done,
                    progress.total,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ExcludeSemantics(
                child: Text(
                  l10n.percent(progress.percent),
                  style: text.cardTitle.copyWith(color: colors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            focused == Duration.zero
                ? done
                : l10n.titleWithDetail(
                    done,
                    l10n.focusedFor(l10n.durationLabel(focused)),
                  ),
            style: style,
          ),
        ],
      ),
    );
  }
}
