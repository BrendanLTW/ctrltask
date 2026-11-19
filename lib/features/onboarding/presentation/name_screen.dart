import 'dart:async';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_text_input.dart';
import 'package:ctrltask/core/widgets/onboarding_scaffold.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S03 What should we call you? (1 of 3). Continue needs a non-blank name;
/// it's trimmed and kept to 30 characters. Skip leaves it empty.
class NameScreen extends ConsumerStatefulWidget {
  const new({super.key});

  static const maxLength = 30;

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final _name = TextEditingController(
    text: ref.read(preferencesProvider).value?.userName ?? '',
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _save(String name) async {
    await ref
        .read(preferencesRepositoryProvider)
        .update((p) => p.copyWith(userName: name));
    if (mounted) await context.push(Routes.onboardingTask);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnboardingScaffold(
      step: 1,
      onSkip: () => _save(''),
      title: l10n.nameTitle,
      subtitle: l10n.nameBody,
      primaryLabel: l10n.continueAction,
      onPrimary: _valid ? () => _save(_name.text.trim()) : null,
      body: AppTextInput(
        controller: _name,
        maxLength: NameScreen.maxLength,
        hint: l10n.nameHint,
        helper: l10n.nameHelp,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) {
          if (_valid) unawaited(_save(_name.text.trim()));
        },
      ),
    );
  }
}
