import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// A pill button (DESIGN §7): 48 high, padding 0 22, 15/600 on `ink`; or
/// 40 high, 0 16, 14/600 when [small]. [soft] is `raised` with `ink` text.
class PillButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.soft = false,
    this.small = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool soft;
  final bool small;

  /// A leading icon, as S08's "+ Add a task".
  final AppIcon? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = small
        ? text.chip
        : text.body.copyWith(fontWeight: FontWeight.w600);
    return Semantics(
      button: true,
      child: Material(
        color: soft ? colors.raised : colors.ink,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          highlightColor: soft ? colors.fillSoft : colors.inkPressed,
          splashFactory: NoSplash.splashFactory,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: small ? 40 : 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: small ? 16 : 22,
                vertical: 8,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon case final icon?) ...[
                      AppIconView(
                        icon,
                        size: 20,
                        color: soft ? colors.ink : colors.onInk,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                          color: soft ? colors.ink : colors.onInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
