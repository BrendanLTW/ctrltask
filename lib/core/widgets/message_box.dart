import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// The four message boxes (DESIGN §3.3).
enum MessageKind { error, warning, success, info }

/// An inline message (DESIGN §3.3): radius 18, a 20 px icon and 13/500
/// text. Errors are announced as they appear.
class MessageBox extends StatelessWidget {
  const new(this.text, {this.kind = MessageKind.info, this.action, super.key});

  final String text;
  final MessageKind kind;

  /// A link under the text, e.g. S39's "Open phone settings". It stays its
  /// own control for screen readers.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground, icon) = switch (kind) {
      MessageKind.error => (colors.errorBox, colors.onErrorBox, AppIcon.alert),
      MessageKind.warning => (
        colors.warningBox,
        colors.onWarningBox,
        AppIcon.warning,
      ),
      MessageKind.success => (
        colors.successBox,
        colors.onSuccessBox,
        AppIcon.success,
      ),
      MessageKind.info => (colors.infoBox, colors.onInfoBox, AppIcon.info),
    };
    final message = Text(
      text,
      style: context.text.message.copyWith(color: foreground),
    );
    return Semantics(
      container: true,
      liveRegion: kind == MessageKind.error,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.r18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: AppIconView(icon, size: 20, stroke: 2, color: foreground),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: action == null
                  ? message
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [message, action!],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
