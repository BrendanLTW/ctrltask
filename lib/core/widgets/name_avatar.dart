import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// The user's initial on `ink` (a person icon without a name): Home's
/// avatar (48), S35's name card (56) and S40 (88). Decorative; its parent
/// labels it.
class NameAvatar extends StatelessWidget {
  const new(this.name, {this.size = 48, super.key});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = switch (size) {
      >= 80 => text.heroValue,
      >= 56 => text.statValue,
      _ => text.heroUnit,
    };
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: colors.ink, shape: BoxShape.circle),
        child: name.trim().isEmpty
            ? AppIconView(AppIcon.user, size: size * 0.46, color: colors.onInk)
            : Text(
                name.trim().characters.first.toUpperCase(),
                style: style.copyWith(
                  color: colors.onInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
