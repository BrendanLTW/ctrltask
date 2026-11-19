import 'dart:math' as math;

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/primary_button.dart';
import 'package:ctrltask/core/widgets/step_indicator.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The onboarding layout (DESIGN §6, S02–S06): an optional top bar with
/// back, a step indicator and Skip; an optional [header]; the title and
/// copy inset 24 px; the step's content; and the primary button pinned
/// 34 px from the bottom, or 96 px with a [secondaryLabel] link below it.
class OnboardingScaffold extends StatelessWidget {
  const new({
    required this.title,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.body,
    this.header,
    this.topBar = true,
    this.centered = false,
    this.step,
    this.totalSteps = 3,
    this.onSkip,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  }) : assert(
         (secondaryLabel == null) == (onSecondary == null),
         'label + action',
       );

  final String title;
  final String? subtitle;
  final Widget? body;

  /// Above the title: S02's illustration, S06's success circle.
  final Widget? header;

  /// Back, step indicator and Skip; S02 and S06 have none.
  final bool topBar;

  /// Centres the title and copy (S06).
  final bool centered;

  /// 1-based; null hides the indicator.
  final int? step;
  final int totalSteps;
  final VoidCallback? onSkip;
  final String primaryLabel;

  /// Null disables the button, e.g. until a name is typed.
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final align = centered ? TextAlign.center : TextAlign.start;
    final bottom = math.max(34, MediaQuery.viewPaddingOf(context).bottom + 8);
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (topBar)
              SizedBox(
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: l10n.back,
                          color: colors.ink,
                          icon: const AppIconView(
                            AppIcon.chevronLeft,
                            size: 28,
                            stroke: AppIconStroke.chevron,
                          ),
                        ),
                      ),
                    ),
                    if (step case final step?)
                      StepIndicator(current: step, total: totalSteps),
                    if (onSkip case final onSkip?)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: TextLink(
                            label: l10n.skip,
                            onPressed: onSkip,
                            muted: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  topBar ? 12 : 16,
                  AppSpacing.screenX,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (header case final header?) ...[
                      header,
                      const SizedBox(height: 28),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.textX - AppSpacing.screenX,
                      ),
                      child: Column(
                        crossAxisAlignment: centered
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              textAlign: align,
                              style: text.onbTitle.copyWith(color: colors.ink),
                            ),
                          ),
                          if (subtitle case final subtitle?) ...[
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              textAlign: align,
                              style: text.body.copyWith(color: colors.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (body case final body?) ...[
                      const SizedBox(height: 24),
                      body,
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                bottom.toDouble(),
              ),
              child: Column(
                children: [
                  PrimaryButton(label: primaryLabel, onPressed: onPrimary),
                  if ((secondaryLabel, onSecondary) case (
                    final label?,
                    final onTap?,
                  )) ...[
                    const SizedBox(height: 10),
                    TextLink(label: label, onPressed: onTap),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
