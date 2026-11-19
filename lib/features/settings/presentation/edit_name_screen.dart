import 'dart:async';

import 'package:ctrltask/core/theme/app_colors.dart';
import 'package:ctrltask/core/theme/app_spacing.dart';
import 'package:ctrltask/core/theme/app_typography.dart';
import 'package:ctrltask/core/widgets/app_text_input.dart';
import 'package:ctrltask/core/widgets/name_avatar.dart';
import 'package:ctrltask/core/widgets/sub_screen_bar.dart';
import 'package:ctrltask/features/onboarding/presentation/name_screen.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S40 Edit name (PRD §5.10): the S03 field with a live avatar.
class EditNameScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends ConsumerState<EditNameScreen> {
  final _name = TextEditingController();
  var _edited = false;

  @override
  void initState() {
    super.initState();
    // The saved name, once settings load, unless the user has typed.
    ref.listenManual(preferencesProvider, (_, next) {
      final saved = next.value?.userName;
      if (saved != null && !_edited) _name.text = saved;
    }, fireImmediately: true);
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_valid) return;
    final name = _name.text.trim();
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(userName: name));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenBar(
              title: l10n.editName,
              cancelLabel: l10n.cancel,
              actionLabel: l10n.save,
              onAction: _valid ? () => unawaited(_save()) : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  12,
                  AppSpacing.screenX,
                  40,
                ),
                children: [
                  Center(child: NameAvatar(_name.text, size: 88)),
                  const SizedBox(height: 20),
                  AppTextInput(
                    controller: _name,
                    maxLength: NameScreen.maxLength,
                    hint: l10n.nameHint,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _edited = true,
                    onSubmitted: (_) => unawaited(_save()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.textX - AppSpacing.screenX,
                      10,
                      AppSpacing.textX - AppSpacing.screenX,
                      0,
                    ),
                    child: Text(
                      l10n.editNameNote,
                      style: context.text.subline.copyWith(color: colors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
