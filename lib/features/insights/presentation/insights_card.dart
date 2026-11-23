import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// A chart card on S34: an uppercase label, an optional [detail] on the
/// right ("Best: Thu, 6"), and the chart, or "Not enough data yet" when
/// [child] is null.
class InsightsCard extends StatelessWidget {
  const new({required this.label, this.detail, this.child, super.key});

  final String label;
  final Widget? detail;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(label, style: text.label.copyWith(color: colors.muted)),
              if (child != null) ?detail,
            ],
          ),
          const SizedBox(height: 20),
          child ??
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  context.l10n.notEnoughData,
                  textAlign: TextAlign.center,
                  style: text.subline.copyWith(color: colors.muted),
                ),
              ),
        ],
      ),
    );
  }
}

/// "Best: **Thu, 6**": a muted label and a bold value.
class CardDetail extends StatelessWidget {
  const new({required this.label, required this.value, this.color, super.key});

  final String label;
  final String value;

  /// The value's colour; `ink` by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Text.rich(
      TextSpan(
        text: label.isEmpty ? '' : '$label ',
        style: text.subline.copyWith(color: colors.muted),
        children: [
          TextSpan(
            text: value,
            style: text.rowTitle.copyWith(color: color ?? colors.ink),
          ),
        ],
      ),
    );
  }
}
