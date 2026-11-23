import 'dart:async';

import 'package:ctrltask/core/app_info.dart';
import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/dates/week.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/icon_tile.dart';
import 'package:ctrltask/core/widgets/list_group.dart';
import 'package:ctrltask/core/widgets/name_avatar.dart';
import 'package:ctrltask/core/widgets/priority_tag.dart';
import 'package:ctrltask/core/widgets/section_header.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/data_transfer/presentation/erase_all_data.dart';
import 'package:ctrltask/features/focus/presentation/timer_settings_sheet.dart';
import 'package:ctrltask/features/home/presentation/home_providers.dart';
import 'package:ctrltask/features/notifications/presentation/notification_settings_screen.dart';
import 'package:ctrltask/features/projects/domain/project_keys.dart';
import 'package:ctrltask/features/projects/presentation/project_providers.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tags/presentation/tag_providers.dart';
import 'package:ctrltask/features/tasks/domain/task_calculations.dart';
import 'package:ctrltask/features/tasks/domain/task_priority.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S35 Settings (PRD §5.10): the name card, the insights banner, and the
/// rows whose screens exist so far.
// shortcut: Backup & restore (S42) is v1.1, so its row is hidden.
class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value;
    final name = prefs?.userName ?? '';
    final done = ref.watch(doneTasksProvider).value ?? const [];
    final archived = ref.watch(archivedProjectsProvider).value ?? const [];
    final tags = ref.watch(tagUsagesProvider).value ?? const [];
    final now = ref.watch(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    void open(String route) => unawaited(context.push(route));

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(title: l10n.settings),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  Semantics(
                    button: true,
                    label: l10n.titleWithDetail(
                      name.isEmpty ? l10n.addYourName : name,
                      l10n.nameCardDetail,
                    ),
                    excludeSemantics: true,
                    child: Material(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.r28),
                      child: InkWell(
                        onTap: () => open(Routes.editName),
                        borderRadius: BorderRadius.circular(AppRadius.r28),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          child: Row(
                            children: [
                              NameAvatar(name, size: 56),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isEmpty ? l10n.addYourName : name,
                                      style: text.header.copyWith(
                                        color: colors.ink,
                                      ),
                                    ),
                                    Text(
                                      l10n.nameCardDetail,
                                      style: text.subline.copyWith(
                                        color: colors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              AppIconView(
                                AppIcon.chevronRight,
                                size: 20,
                                color: colors.muted,
                                stroke: AppIconStroke.chevron,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  Material(
                    color: colors.hero,
                    borderRadius: BorderRadius.circular(AppRadius.r28),
                    child: InkWell(
                      onTap: () => open(Routes.insights),
                      borderRadius: BorderRadius.circular(AppRadius.r28),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 18, 22),
                        child: Row(
                          children: [
                            AppIconView(
                              AppIcon.chart,
                              size: 26,
                              color: colors.onHero,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.insightsBannerLabel,
                                    style: text.label.copyWith(
                                      color: colors.heroLabel,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.insightsBannerSummary(
                                      streak(done, today),
                                      done.length,
                                    ),
                                    style: text.cardTitle.copyWith(
                                      color: colors.onHero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppIconView(
                              AppIcon.chevronRight,
                              size: 22,
                              color: colors.onHero,
                              stroke: AppIconStroke.chevron,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SectionHeader(l10n.preferencesSection),
                  ListGroup(
                    children: [
                      ListGroupRow(
                        title: l10n.themeTitle,
                        value: l10n.themeName(
                          (prefs?.theme ?? AppTheme.system).name,
                        ),
                        leading: const IconTile(
                          icon: AppIcon.palette,
                          color: ProjectColorKey.purple,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.theme),
                      ),
                      ListGroupRow(
                        title: l10n.weekStartTitle,
                        value: l10n.weekStartName(
                          (prefs?.weekStart ?? WeekStart.mon).name,
                        ),
                        leading: const IconTile(
                          icon: AppIcon.calendar,
                          color: ProjectColorKey.orange,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.weekStart),
                      ),
                      ListGroupRow(
                        title: l10n.defaultPriorityTitle,
                        value: priorityLabel(
                          context,
                          prefs?.defaultPriority ?? TaskPriority.medium,
                        ),
                        leading: const IconTile(
                          icon: AppIcon.flag,
                          color: ProjectColorKey.blue,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.defaultPriority),
                      ),
                      ListGroupRow(
                        title: l10n.defaultFocusLength,
                        value: l10n.minutesValue(prefs?.focusMin ?? 25),
                        leading: const IconTile(
                          icon: AppIcon.timer,
                          color: ProjectColorKey.green,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => unawaited(showTimerSettings(context)),
                      ),
                      ListGroupRow(
                        title: l10n.notificationsTitle,
                        value: l10n.notificationsOnCount(
                          notificationsOn(prefs ?? const Preferences()),
                        ),
                        leading: const IconTile(
                          icon: AppIcon.bell,
                          color: ProjectColorKey.yellow,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.notifications),
                      ),
                    ],
                  ),
                  SectionHeader(l10n.manageSection),
                  ListGroup(
                    children: [
                      ListGroupRow(
                        title: l10n.archivedProjectsTitle,
                        value: '${archived.length}',
                        leading: const IconTile(
                          icon: AppIcon.folder,
                          color: ProjectColorKey.pink,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.archivedProjects),
                      ),
                      ListGroupRow(
                        title: l10n.tagsTitle,
                        value: '${tags.length}',
                        leading: const IconTile(
                          icon: AppIcon.tag,
                          color: ProjectColorKey.grey,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.tags),
                      ),
                      ListGroupRow(
                        title: l10n.exportTitle,
                        subtitle: l10n.exportSubtitle,
                        leading: const IconTile(
                          icon: AppIcon.download,
                          color: ProjectColorKey.blue,
                          size: IconTileSize.medium,
                        ),
                        onTap: () => open(Routes.export),
                      ),
                    ],
                  ),
                  SectionHeader(l10n.dataSection),
                  ListGroup(
                    children: [
                      ListGroupRow(
                        title: l10n.eraseAllData,
                        titleColor: colors.negative,
                        leading: const IconTile(
                          icon: AppIcon.trash,
                          color: ProjectColorKey.red,
                          size: IconTileSize.medium,
                        ),
                        onTap: () =>
                            unawaited(confirmAndEraseAllData(context, ref)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.textX - AppSpacing.screenX,
                      24,
                      0,
                      0,
                    ),
                    child: Text(
                      l10n.settingsFooter(appVersionShort),
                      style: text.subline.copyWith(color: colors.muted),
                    ),
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
