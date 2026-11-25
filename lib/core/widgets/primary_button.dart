import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// The full-width primary button (DESIGN §7): 58 high, radius 22, `ink`,
/// with an optional 22 px leading icon. A null [onPressed] disables it;
/// [busy] keeps it `ink` with a spinner in place of the label (S43's Try
/// again) and ignores taps.
class PrimaryButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppIcon? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null || busy;
    final foreground = enabled ? colors.onInk : colors.onButtonDisabled;
    return Semantics(
      button: true,
      enabled: enabled && !busy,
      label: busy ? label : null,
      child: Material(
        color: enabled ? colors.ink : colors.buttonDisabled,
        borderRadius: BorderRadius.circular(AppRadius.r22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: busy ? null : onPressed,
          highlightColor: colors.inkPressed,
          splashFactory: NoSplash.splashFactory,
          // At least 58; taller when large text wraps the label.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 58,
              minWidth: double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: busy
                  ? Center(
                      child: SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: foreground,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon case final icon?) ...[
                          AppIconView(icon, size: 22, color: foreground),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: context.text.button.copyWith(
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
