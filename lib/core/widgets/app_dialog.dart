import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_motion.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_shadows.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/core/widgets/text_link.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Which of a dialog's actions was chosen.
enum DialogChoice { confirm, secondary, cancel }

/// Opens a dialog (DESIGN §6, S13, S44). It fades and scales in over
/// 200 ms (instant with reduced motion). Dismissing it counts as Cancel.
Future<DialogChoice> showAppDialog(
  BuildContext context, {
  required AppIcon icon,
  required String title,
  required String body,
  required String confirmLabel,
  String? secondaryLabel,
  bool destructive = false,
  bool cancel = true,
}) async {
  final motion = AppMotion.of(context);
  final choice = await showGeneralDialog<DialogChoice>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.colors.scrim,
    transitionDuration: motion.dialog,
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.easeOut,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, _, _) => AppDialog(
      icon: icon,
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      secondaryLabel: secondaryLabel,
      cancel: cancel,
      destructive: destructive,
    ),
  );
  return choice ?? DialogChoice.cancel;
}

/// The dialog's content; use [showAppDialog] to open one. Actions stack:
/// confirm (red when [destructive]), an optional `fillSoft` secondary, then
/// Cancel as a muted link.
class AppDialog extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.secondaryLabel,
    this.destructive = false,
    this.cancel = true,
    super.key,
  });

  final AppIcon icon;
  final String title;
  final String body;
  final String confirmLabel;
  final String? secondaryLabel;
  final bool destructive;

  /// Whether Cancel shows; off for a message with just OK.
  final bool cancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    void pop(DialogChoice choice) => Navigator.of(context).pop(choice);
    final (circle, glyph) = destructive
        ? (colors.errorBox, colors.negative)
        : (colors.raised, colors.ink);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r28),
          boxShadow: context.shadows.dialog,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: circle,
                      shape: BoxShape.circle,
                    ),
                    child: AppIconView(icon, size: 26, color: glyph),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: text.header.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: text.body.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 22),
              _DialogButton(
                label: confirmLabel,
                fill: destructive ? colors.destructive : colors.ink,
                foreground: destructive ? colors.onDestructive : colors.onInk,
                onPressed: () => pop(DialogChoice.confirm),
              ),
              if (secondaryLabel case final label?) ...[
                const SizedBox(height: 10),
                _DialogButton(
                  label: label,
                  fill: colors.fillSoft,
                  foreground: colors.ink,
                  onPressed: () => pop(DialogChoice.secondary),
                ),
              ],
              if (cancel) ...[
                const SizedBox(height: 4),
                TextLink(
                  label: context.l10n.cancel,
                  muted: true,
                  onPressed: () => pop(DialogChoice.cancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 52 high, radius 18 (DESIGN §7 destructive button).
class _DialogButton extends StatelessWidget {
  const new({
    required this.label,
    required this.fill,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color fill;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: fill,
      borderRadius: BorderRadius.circular(AppRadius.r18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        highlightColor: context.colors.scrim,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              heightFactor: 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.rowTitle.copyWith(color: foreground),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
