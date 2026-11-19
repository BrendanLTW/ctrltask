import 'dart:async';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/message_box.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/projects/domain/project.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S45 Archived projects, from Settings (2.12).
class ArchivedProjectsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.ground,
    body: SafeArea(
      child: Column(
        children: [
          SubScreenBar(title: context.l10n.archivedProjectsTitle),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                8,
                AppSpacing.screenX,
                40,
              ),
              children: const [ArchivedProjectsList()],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Archived project cards with Restore, and the note: S45, and S26's
/// Archived segment.
class ArchivedProjectsList extends ConsumerWidget {
  const new({super.key});

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final l10n = context.l10n;
    try {
      await ref.read(projectRepositoryProvider).restore(project.id);
      if (!context.mounted) return;
      showCompleteToast(context, message: l10n.projectRestored(project.name));
    } on DuplicateProjectNameException {
      if (!context.mounted) return;
      showCompleteToast(
        context,
        message: l10n.restoreNameTaken(project.name),
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final projects = ref.watch(archivedProjectsProvider).value ?? const [];
    final counts = ref.watch(projectTaskCountsProvider).value ?? const {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final project in projects) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r28),
            ),
            child: Row(
              children: [
                IconTile.forProject(project.iconKey, color: project.colorKey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: text.cardTitle.copyWith(color: colors.ink),
                      ),
                      Text(
                        l10n.archivedMeta(
                          counts[project.id] ?? 0,
                          labels.dayMonth(project.archivedAt!.toLocal()),
                        ),
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PillButton(
                  label: l10n.restore,
                  soft: true,
                  small: true,
                  onPressed: () => unawaited(_restore(context, ref, project)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        MessageBox(l10n.archivedNote),
      ],
    );
  }
}
