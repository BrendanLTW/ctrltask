import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// "Good morning" before noon, "Good afternoon" until 6 PM, then "Good
/// evening" (PRD §5.2), with the name when there is one.
String greeting(AppLocalizations l10n, DateTime now, String name) {
  final hello = now.hour < 12
      ? l10n.greetingMorning
      : now.hour < 18
      ? l10n.greetingAfternoon
      : l10n.greetingEvening;
  return name.isEmpty ? hello : l10n.greetingNamed(hello, name);
}

/// Home's header (S07): the date and greeting, search, and the avatar that
/// opens Settings.
class HomeHeader extends StatelessWidget {
  const new({
    required this.date,
    required this.greeting,
    required this.name,
    required this.onSearch,
    required this.onAvatar,
    super.key,
  });

  /// "Tue, 17 November"; shown uppercase.
  final String date;
  final String greeting;
  final String name;
  final VoidCallback onSearch;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.textX,
        8,
        AppSpacing.screenX,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.toUpperCase(),
                  style: text.label.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 2),
                Semantics(
                  header: true,
                  child: Text(
                    greeting,
                    style: text.header.copyWith(
                      color: colors.ink,
                      fontSize: text.detailTitle.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearch,
            tooltip: l10n.searchTasks,
            style: IconButton.styleFrom(
              fixedSize: const Size(48, 48),
              backgroundColor: colors.raised,
              foregroundColor: colors.ink,
            ),
            icon: const AppIconView(AppIcon.search, size: 22),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: l10n.settings,
            excludeFromSemantics: true,
            child: Semantics(
              button: true,
              label: l10n.settings,
              excludeSemantics: true,
              child: Material(
                color: colors.ink,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onAvatar,
                  child: SizedBox.square(
                    dimension: 48,
                    child: Center(
                      child: name.isEmpty
                          ? AppIconView(
                              AppIcon.user,
                              size: 22,
                              color: colors.onInk,
                            )
                          : Text(
                              name.characters.first.toUpperCase(),
                              style: text.heroUnit.copyWith(
                                color: colors.onInk,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
