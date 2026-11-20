import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_icon.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The pill search field (DESIGN §7): 52 high, `surface` (`ground` with
/// [inSheet]), a muted search icon and, once there's text, a 40 px "Clear
/// search" button.
class SearchField extends StatelessWidget {
  const new({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.inSheet = false,
    this.autofocus = false,
    this.onSubmitted,
    this.icon = AppIcon.search,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool inSheet;
  final bool autofocus;

  /// The keyboard's search key (S24 saves the search).
  final ValueChanged<String>? onSubmitted;

  /// 🔍, or S18's 🏷.
  final AppIcon icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.body.copyWith(
      color: colors.ink,
      fontWeight: FontWeight.w500,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide.none,
    );
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autofocus,
        style: style,
        cursorColor: colors.ink,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: style.copyWith(color: colors.muted),
          filled: true,
          fillColor: inSheet ? colors.ground : colors.surface,
          constraints: const BoxConstraints.tightFor(height: 52),
          contentPadding: EdgeInsets.zero,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: AppIconView(icon, size: 20, color: colors.muted),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: value.text.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    tooltip: context.l10n.clearSearch,
                    style: IconButton.styleFrom(
                      fixedSize: const Size(40, 40),
                      minimumSize: const Size(40, 40),
                      backgroundColor: colors.raised,
                      foregroundColor: colors.ink,
                    ),
                    icon: const AppIconView(AppIcon.close, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
                ),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
