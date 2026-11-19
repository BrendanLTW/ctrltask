import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_radius.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// A text input (DESIGN §7; S03, S40): 56 high, radius 18, `surface`,
/// 17/500. Focus draws a 2 px `ink` outline, [error] a 2 px `negative`
/// one. [helper] sits underneath. [maxLength] stops typing past the limit.
class AppTextInput extends StatefulWidget {
  const new({
    required this.controller,
    required this.maxLength,
    this.hint,
    this.helper,
    this.error = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final int maxLength;
  final String? hint;
  final String? helper;
  final bool error;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final style = text.button.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: colors.ink,
    );
    final outline = widget.error
        ? colors.negative
        : _focus.hasFocus
        ? colors.ink
        : colors.surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r18),
            border: Border.all(color: outline, width: 2),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            maxLength: widget.maxLength,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: style,
            cursorColor: colors.ink,
            decoration: InputDecoration.collapsed(
              hintText: widget.hint,
              hintStyle: style.copyWith(color: colors.disabled),
            ).copyWith(counterText: ''),
          ),
        ),
        if (widget.helper case final helper?) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              helper,
              style: text.caption.copyWith(color: colors.muted),
            ),
          ),
        ],
      ],
    );
  }
}
