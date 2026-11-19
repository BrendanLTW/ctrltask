import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/onboarding_scaffold.dart';
import 'package:ctrltask/features/onboarding/presentation/welcome_preview.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S02 Welcome. Get started begins the steps; Skip setup finishes
/// onboarding and opens Home.
class WelcomeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return OnboardingScaffold(
      topBar: false,
      header: const WelcomePreview(),
      title: l10n.welcomeTitle,
      subtitle: l10n.welcomeBody,
      primaryLabel: l10n.getStarted,
      onPrimary: () => context.push(Routes.onboardingName),
      secondaryLabel: l10n.skipSetup,
      // The router moves to Home once the setting is saved.
      onSecondary: () => ref
          .read(preferencesRepositoryProvider)
          .update((p) => p.copyWith(onboardingComplete: true)),
    );
  }
}
