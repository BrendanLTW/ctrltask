import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/pill_button.dart';
import 'package:flutter/material.dart';

/// The circle's tint (DESIGN §6).
enum StateTone { neutral, success, error }

/// An empty, done or error state (DESIGN §6, §7): a 96 px circle icon, a
/// title, muted copy, one pill action and an optional [footer].
/// [card] puts it on a `surface` card, as S09's "Day done" (StateCard).
class EmptyState extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
    this.tone = StateTone.neutral,
    this.bodySpan,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.footer,
    this.card = false,
    super.key,
  }) : assert((actionLabel == null) == (onAction == null), 'label + action');

  final AppIcon icon;
  final String title;

  /// What screen readers hear; also shown unless [bodySpan] is set.
  final String body;

  /// The body with emphasis, e.g. "Your streak is now **13 days**".
  final InlineSpan? bodySpan;
  final StateTone tone;
  final String? actionLabel;
  final AppIcon? actionIcon;
  final VoidCallback? onAction;

  /// Under the action, e.g. S08's suggestion chips.
  final Widget? footer;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final (circle, glyph) = switch (tone) {
      StateTone.neutral => (colors.raised, colors.ink),
      StateTone.success => (colors.successBox, colors.onSuccessBox),
      StateTone.error => (colors.errorBox, colors.onErrorBox),
    };
    final bodyStyle = text.body.copyWith(color: colors.muted);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            // 80 on S09's card, 96 elsewhere, as the designs show.
            width: card ? 80 : 96,
            height: card ? 80 : 96,
            decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
            child: AppIconView(icon, size: 40, stroke: 1.7, color: glyph),
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: text.stateTitle.copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: body,
          excludeSemantics: true,
          child: Text.rich(
            bodySpan ?? TextSpan(text: body),
            textAlign: TextAlign.center,
            style: bodyStyle,
          ),
        ),
        if ((actionLabel, onAction) case (final label?, final onTap?)) ...[
          const SizedBox(height: 22),
          PillButton(label: label, icon: actionIcon, onPressed: onTap),
        ],
        if (footer case final footer?) ...[const SizedBox(height: 28), footer],
      ],
    );
    if (!card) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: content,
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r28),
      ),
      child: content,
    );
  }
}
