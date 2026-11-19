import 'dart:async';

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_motion.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_shadows.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The toast (DESIGN §7): an `ink` pill with a green check, the message and
/// an optional underlined Undo.
class CompleteToast extends StatelessWidget {
  const new({required this.message, this.onUndo, super.key});

  final String message;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    // The toast is the other theme's colours, so its check is too.
    final other = Theme.of(context).brightness == Brightness.light
        ? AppColors.dark
        : AppColors.light;
    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.only(left: 18, right: 6),
        decoration: BoxDecoration(
          color: colors.ink,
          borderRadius: BorderRadius.circular(AppRadius.r20),
          boxShadow: context.shadows.toast,
        ),
        child: Row(
          children: [
            AppIconView(AppIcon.check, size: 22, color: other.positive),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  message,
                  style: text.chip.copyWith(
                    color: colors.onInk,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (onUndo case final onUndo?)
              TextButton(
                onPressed: onUndo,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor: colors.onInk,
                ),
                child: Text(
                  context.l10n.undo,
                  style: text.chip.copyWith(
                    color: colors.onInk,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.onInk,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

({OverlayEntry entry, Timer timer})? _current;

/// Shows a toast above the bottom bar for 3.5 s (DESIGN §9), replacing any
/// toast already showing. Tapping Undo runs [onUndo] and hides it.
void showCompleteToast(
  BuildContext context, {
  required String message,
  VoidCallback? onUndo,
}) {
  hideCompleteToast();
  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 16,
      right: 16,
      // DESIGN §7: 106 px from the bottom, clear of the bar.
      bottom: 106 + MediaQuery.paddingOf(context).bottom,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: AppMotion.of(context).toast,
        curve: AppMotion.easeOut,
        builder: (context, offset, child) =>
            FractionalTranslation(translation: Offset(0, offset), child: child),
        child: Material(
          type: MaterialType.transparency,
          child: CompleteToast(
            message: message,
            onUndo: onUndo == null
                ? null
                : () {
                    hideCompleteToast();
                    onUndo();
                  },
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  _current = (
    entry: entry,
    timer: Timer(AppMotion.toastHold, hideCompleteToast),
  );
}

/// Hides the current toast, if any.
void hideCompleteToast() {
  final current = _current;
  _current = null;
  if (current == null) return;
  current.timer.cancel();
  // If its overlay is already gone (the app was torn down), there's
  // nothing to remove, and disposing would assert.
  if (current.entry.mounted) {
    current.entry
      ..remove()
      ..dispose();
  }
}
