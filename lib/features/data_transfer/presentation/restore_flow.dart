import 'dart:async';
import 'dart:io';

import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/widgets/app_dialog.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/app_sheet.dart';
import 'package:ctrltask/core/widgets/complete_toast.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/data_transfer/presentation/backup_providers.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:ctrltask/l10n/size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Restore from a backup (S42): pick one of the backups or any file,
/// confirm, then restore; a file that can't be restored says why and
/// changes nothing.
Future<void> restoreFlow(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final store = ref.read(backupStoreProvider);
  final backups = await store.list();
  if (!context.mounted) return;
  final file = await showAppSheet<BackupFile>(
    context,
    title: l10n.restoreFromBackup,
    builder: (sheet) => _RestoreSheet(backups: backups),
  );
  if (file == null || !context.mounted) return;

  final date = DateLabels(Localizations.localeOf(context).toLanguageTag())
      .dateYear(file.at);
  final choice = await showAppDialog(
    context,
    icon: AppIcon.reset,
    title: l10n.restoreTitle,
    body: l10n.restoreBody(date),
    confirmLabel: l10n.restoreConfirm,
    destructive: true,
  );
  if (choice != DialogChoice.confirm || !context.mounted) return;
  try {
    await store.restore(file);
    ref
      ..invalidate(backupSummaryProvider)
      ..invalidate(backupFailureProvider);
    if (context.mounted) {
      showCompleteToast(context, message: l10n.restoreDone(date));
    }
  } on BackupException catch (e) {
    if (!context.mounted) return;
    await showAppDialog(
      context,
      icon: AppIcon.warning,
      title: l10n.restoreFailedTitle,
      body: switch (e.problem) {
        BackupProblem.damaged => l10n.restoreDamaged,
        BackupProblem.notBackup => l10n.restoreNotBackup,
        BackupProblem.newer => l10n.restoreNewer,
        BackupProblem.tooOld => l10n.restoreTooOld,
      },
      confirmLabel: l10n.ok,
      cancel: false,
    );
  }
}

/// The backups in the folder, newest first, and "Choose a file…".
class _RestoreSheet extends ConsumerWidget {
  const new({required this.backups});

  final List<BackupFile> backups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final labels = DateLabels(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (backups.isNotEmpty) ...[
          SectionHeader(l10n.backupsInFolder),
          ListGroup(
            children: [
              for (final b in backups)
                ListGroupRow(
                  title: l10n.dayWithTime(
                    labels.dateYear(b.at),
                    labels.time(b.at.hour * 60 + b.at.minute),
                  ),
                  value: l10n.fileSize(b.bytes, locale),
                  onTap: () => Navigator.of(context).pop(b),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        ListGroup(
          children: [
            ListGroupRow(
              title: l10n.chooseFile,
              leading: const AppIconView(AppIcon.folder, size: 20),
              onTap: () async {
                final path = await ref.read(pickBackupFileProvider)();
                if (path == null || !context.mounted) return;
                final file = File(path);
                Navigator.of(context).pop<BackupFile>((
                  path: path,
                  at: file.lastModifiedSync(),
                  bytes: file.lengthSync(),
                ));
              },
            ),
          ],
        ),
      ],
    );
  }
}
