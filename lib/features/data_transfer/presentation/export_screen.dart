import 'dart:async';
import 'dart:convert';

import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/date_labels.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/segmented_control.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:ctrltask/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tasks/presentation/due_date_picker.dart';
import 'package:ctrltask/features/tasks/presentation/repeat_sheet.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum ExportRange { allTime, thisYear, custom }

/// S41 Export data (PRD §5.10): a format, a range, what to include, the
/// totals, and Export, which hands `ctrltask-YYYY-MM-DD.csv|json` to the
/// share sheet (docs/export-format.md).
class ExportScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _format = ExportFormat.csv;
  ExportRange _range = ExportRange.allTime;
  bool _completed = true;
  bool _archived = false;
  bool _focus = true;
  late final DateTime _today = _dayOf(ref.read(clockProvider)());

  /// The custom range; starts as this month.
  late DateTime _from = DateTime(_today.year, _today.month);
  late DateTime _to = _today;

  /// Read once when the screen opens.
  late final Future<ExportSnapshot> _snapshot = ref
      .read(exportSourceProvider)
      .read();

  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  ExportOptions get _options => (
    from: switch (_range) {
      ExportRange.allTime => null,
      ExportRange.thisYear => DateTime(_today.year),
      ExportRange.custom => _from,
    },
    to: _range == ExportRange.custom ? _to : null,
    completed: _completed,
    archived: _archived,
    focus: _focus,
  );

  String _contents(ExportSnapshot s, ExportSelection selection) {
    if (_format == ExportFormat.json) {
      return exportJson(s, selection, exportedAt: ref.read(clockProvider)());
    }
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final weekStart =
        ref.read(preferencesProvider).value?.weekStart ?? WeekStart.mon;
    return tasksCsv(
      s,
      selection,
      repeatText: (rule) =>
          repeatSummary(l10n, labels, rule, weekStart: weekStart),
    );
  }

  Future<void> _pick({required bool from}) async {
    final l10n = context.l10n;
    final choice = await showDueDatePicker(
      context,
      date: from ? _from : _to,
      showTime: false,
      title: from ? l10n.fromLabel : l10n.toLabel,
    );
    if (choice == null) return;
    // Keeps From on or before To.
    setState(() {
      if (from) {
        _from = choice.date;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = choice.date;
        if (_from.isAfter(_to)) _from = _to;
      }
    });
  }

  Future<void> _export(String contents) => ref
      .read(fileSharerProvider)
      .shareText(
        fileName: exportFileName(_format, _today),
        mimeType: _format == ExportFormat.csv ? 'text/csv' : 'application/json',
        contents: contents,
      );

  String _size(int bytes) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = context.l10n;
    if (bytes >= 1024 * 1024) {
      return l10n.sizeMb(
        NumberFormat('0.#', locale).format(bytes / (1024 * 1024)),
      );
    }
    // Rounded up, so a small file never reads "0 KB".
    return l10n.sizeKb('${(bytes / 1024).ceil()}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final labels = DateLabels(Localizations.localeOf(context).toLanguageTag());
    final csv = _format == ExportFormat.csv;

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: FutureBuilder(
          future: _snapshot,
          builder: (context, snap) {
            final snapshot = snap.data;
            final selection = snapshot == null
                ? null
                : selectForExport(snapshot, _options);
            final contents = snapshot == null
                ? null
                : _contents(snapshot, selection!);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SubScreenBar(title: l10n.exportTitle),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenX,
                      0,
                      AppSpacing.screenX,
                      24,
                    ),
                    children: [
                      SectionHeader(l10n.formatSection),
                      SegmentedControl<ExportFormat>(
                        segments: const [
                          (value: ExportFormat.csv, label: 'CSV', icon: null),
                          (value: ExportFormat.json, label: 'JSON', icon: null),
                        ],
                        selected: _format,
                        onChanged: (f) => setState(() => _format = f),
                      ),
                      SectionHeader(l10n.rangeSection),
                      ListGroup(
                        children: [
                          for (final (range, title) in [
                            (ExportRange.allTime, l10n.rangeAllTime),
                            (ExportRange.thisYear, l10n.rangeThisYear),
                            (ExportRange.custom, l10n.rangeCustom),
                          ])
                            ListGroupRadioRow(
                              title: title,
                              selected: _range == range,
                              onTap: () => setState(() => _range = range),
                            ),
                          if (_range == ExportRange.custom) ...[
                            ListGroupRow(
                              title: l10n.fromLabel,
                              value: labels.dateYear(_from),
                              onTap: () => unawaited(_pick(from: true)),
                            ),
                            ListGroupRow(
                              title: l10n.toLabel,
                              value: labels.dateYear(_to),
                              onTap: () => unawaited(_pick(from: false)),
                            ),
                          ],
                        ],
                      ),
                      SectionHeader(l10n.includeSection),
                      ListGroup(
                        children: [
                          ListGroupToggleRow(
                            title: l10n.includeCompleted,
                            value: _completed,
                            onChanged: (v) => setState(() => _completed = v),
                          ),
                          ListGroupToggleRow(
                            title: l10n.archivedProjectsTitle,
                            value: _archived,
                            onChanged: (v) => setState(() => _archived = v),
                          ),
                          ListGroupToggleRow(
                            title: l10n.includeFocus,
                            value: _focus,
                            onChanged: (v) => setState(() => _focus = v),
                          ),
                        ],
                      ),
                      if (selection != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          [
                            l10n.taskCount(selection.taskIds.length),
                            l10n.projectCount(selection.projectIds.length),
                            // CSV holds tasks only (PRD §6.7).
                            if (!csv)
                              l10n.focusSessionCount(
                                selection.sessionIds.length,
                              ),
                          ].join(' · '),
                          textAlign: TextAlign.center,
                          style: context.text.subline.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenX,
                    8,
                    AppSpacing.screenX,
                    16,
                  ),
                  child: PrimaryButton(
                    icon: AppIcon.download,
                    label: l10n.exportButton(
                      csv ? 'CSV' : 'JSON',
                      contents == null
                          ? '…'
                          : _size(utf8.encode(contents).length),
                    ),
                    onPressed: contents == null
                        ? null
                        : () => unawaited(_export(contents)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
