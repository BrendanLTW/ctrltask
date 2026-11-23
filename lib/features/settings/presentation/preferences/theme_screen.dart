import 'dart:async';

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_radio.dart';
import 'package:ctrltask/core/widgets/message_box.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S36 Theme (PRD §5.10): Light, Dark and System as preview cards.
/// Picking one switches the app at once.
class ThemeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final selected =
        ref.watch(preferencesProvider).value?.theme ?? AppTheme.system;
    void pick(AppTheme theme) => unawaited(
      ref
          .read(preferencesRepositoryProvider)
          .update((p) => p.copyWith(theme: theme)),
    );
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(title: l10n.themeTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  8,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, theme) in AppTheme.values.indexed) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: theme == selected,
                            label: l10n.themeName(theme.name),
                            excludeSemantics: true,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => pick(theme),
                              child: Column(
                                children: [
                                  _Preview(
                                    theme: theme,
                                    selected: theme == selected,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppRadio(selected: theme == selected),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          l10n.themeName(theme.name),
                                          style: context.text.rowTitle.copyWith(
                                            color: colors.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  MessageBox(l10n.themeNote),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small drawing of the app in [theme]'s colours; System is light on the
/// left and dark on the right.
class _Preview extends StatelessWidget {
  const new({required this.theme, required this.selected});

  final AppTheme theme;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final face = switch (theme) {
      AppTheme.light => const _Face(AppColors.light),
      AppTheme.dark => const _Face(AppColors.dark),
      AppTheme.system => Stack(
        fit: StackFit.expand,
        children: [
          const _Face(AppColors.dark),
          ClipRect(clipper: _LeftHalf(), child: const _Face(AppColors.light)),
        ],
      ),
    };
    return AspectRatio(
      aspectRatio: 0.56,
      child: Container(
        padding: EdgeInsets.all(selected ? 3 : 1.5),
        decoration: BoxDecoration(
          color: selected ? colors.ink : colors.divider,
          borderRadius: BorderRadius.circular(AppRadius.r28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r28 - 2),
          child: face,
        ),
      ),
    );
  }
}

/// The app's ground, hero and rows in one palette.
class _Face extends StatelessWidget {
  const new(this.palette);

  final AppColors palette;

  @override
  Widget build(BuildContext context) {
    // In proportion, so the drawing fits any card size.
    Widget bar(int flex, {double widthFactor = 1, Color? color}) => Expanded(
      flex: flex,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.r14),
          ),
        ),
      ),
    );
    const gap = Spacer(flex: 8);
    return ColoredBox(
      color: palette.ground,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            bar(56, color: palette.hero),
            gap,
            bar(22),
            gap,
            bar(22),
            gap,
            bar(22),
            gap,
            bar(22, widthFactor: 0.6),
            const Spacer(flex: 10),
          ],
        ),
      ),
    );
  }
}

/// The left half: System's light side.
class _LeftHalf extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_LeftHalf oldClipper) => false;
}
