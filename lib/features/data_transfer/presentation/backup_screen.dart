import 'dart:async';
import 'dart:io';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/message_box.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/data_transfer/presentation/backup_providers.dart';
import 'package:ctrltask/features/data_transfer/presentation/restore_flow.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:ctrltask/l10n/size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "today, 2:14 AM", "yesterday, …" or "Sun, 15 Nov, …" (S35, S42).
String backupWhen(BuildContext context, DateTime at, DateTime today) {
  final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
  return context.l10n.backupWhen(
    switch (DateLabels.relativeDay(at, today)) {
      RelativeDay.today => 'today',
      RelativeDay.yesterday => 'yesterday',
      _ => 'other',
    },
    labels.date(at),
    labels.time(at.hour * 60 + at.minute),
  );
}

/// S42 Backup & restore and S43 Backup failed (PRD §5.10, v1.1).
class BackupScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  var _busy = false;

  Future<void> _backUpNow() async {
    setState(() => _busy = true);
    try {
      final prefs = await ref.read(preferencesRepositoryProvider).read();
      await ref.read(backupStoreProvider).backUp(keep: prefs.backupKeep);
    } on Object {
      // Recorded by the store; the failure box shows it.
    } finally {
      ref
        ..invalidate(backupSummaryProvider)
        ..invalidate(backupFailureProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showFolder() => showAppDialog(
    context,
    icon: AppIcon.folder,
    title: context.l10n.saveBackupsTo,
    body: Platform.isIOS
        ? context.l10n.backupFolderIos
        : context.l10n.backupFolderAndroid,
    confirmLabel: context.l10n.ok,
    cancel: false,
  );

  Future<void> _pickKeep(int keep) async {
    final l10n = context.l10n;
    final chosen = await showAppSheet<int>(
      context,
      title: l10n.keepLabel,
      builder: (context) => ListGroup(
        children: [
          for (final n in backupKeepChoices)
            ListGroupRadioRow(
              title: l10n.keepValue(n),
              selected: n == keep,
              onTap: () => Navigator.of(context).pop(n),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(backupKeep: chosen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final summary = ref.watch(backupSummaryProvider).value;
    final failure = ref.watch(backupFailureProvider).value;
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubScreenBar(title: l10n.backupTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  24,
                ),
                children: [
                  _StatusBox(summary: summary, failure: failure, today: today),
                  const SizedBox(height: AppSpacing.cardGap),
                  ListGroup(
                    children: [
                      ListGroupToggleRow(
                        title: l10n.autoBackup,
                        subtitle: l10n.autoBackupDetail,
                        value: prefs.autoBackup,
                        onChanged: (on) => unawaited(
                          ref
                              .read(preferencesRepositoryProvider)
                              .update((p) => p.copyWith(autoBackup: on)),
                        ),
                      ),
                      ListGroupRow(
                        title: l10n.saveBackupsTo,
                        value: l10n.backupFolderName,
                        onTap: () => unawaited(_showFolder()),
                      ),
                      ListGroupRow(
                        title: l10n.keepLabel,
                        value: l10n.keepValue(prefs.backupKeep),
                        onTap: () => unawaited(_pickKeep(prefs.backupKeep)),
                      ),
                    ],
                  ),
                  if (failure == null) ...[
                    const SizedBox(height: AppSpacing.cardGap),
                    MessageBox(l10n.backupNote),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                8,
                AppSpacing.screenX,
                8,
              ),
              child: PrimaryButton(
                label: failure == null ? l10n.backUpNow : l10n.tryAgain,
                busy: _busy,
                onPressed: _busy ? null : () => unawaited(_backUpNow()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: failure == null
                    ? TextLink(
                        label: l10n.restoreFromBackup,
                        onPressed: () => unawaited(restoreFlow(context, ref)),
                      )
                    // The folder is the app's own (docs/design-notes.md),
                    // so this explains where it is.
                    : TextLink(
                        label: l10n.chooseAnotherFolder,
                        onPressed: () => unawaited(_showFolder()),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The box at the top: the last good backup (green), the last failure
/// (red, S43), or none yet.
class _StatusBox extends StatelessWidget {
  const new({
    required this.summary,
    required this.failure,
    required this.today,
  });

  final BackupSummary? summary;
  final BackupFailure? failure;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labels = DateLabels(locale);
    final (background, foreground, icon, iconColor, title, body) = switch ((
      failure,
      summary,
    )) {
      (final f?, final s) => (
        colors.errorBox,
        colors.onErrorBox,
        AppIcon.warning,
        colors.negative,
        f.automatic ? l10n.backupFailedNightly : l10n.backupFailedManual,
        [
          switch ((f.reason, f.neededBytes)) {
            (BackupFailureReason.noSpace, final n?) => l10n.backupNoSpace(
              l10n.fileSize(n, locale),
            ),
            _ => l10n.backupOtherError,
          },
          if (s != null) l10n.lastGoodBackup(labels.date(s.file.at)),
        ].join(' '),
      ),
      (null, final s?) => (
        colors.successBox,
        colors.onSuccessBox,
        AppIcon.check,
        colors.positive,
        l10n.backedUpAt(backupWhen(context, s.file.at, today)),
        l10n.backupDetail(
          l10n.taskCount(s.tasks),
          l10n.projectCount(s.projects),
          l10n.fileSize(s.file.bytes, locale),
        ),
      ),
      (null, null) => (
        colors.infoBox,
        colors.onInfoBox,
        AppIcon.info,
        colors.onInfoBox,
        l10n.backupNone,
        l10n.backupNoneBody,
      ),
    };
    return Semantics(
      liveRegion: failure != null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.r24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r13),
              ),
              child: Center(
                child: AppIconView(icon, size: 20, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.rowTitle.copyWith(color: colors.ink)),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: text.subline.copyWith(color: colors.chipText),
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
