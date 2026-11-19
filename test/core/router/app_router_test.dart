import 'dart:async';

import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/core/widgets/app_shell_tab.dart';
import 'package:ctrltask/features/home/presentation/home_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/splash_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrltask/features/settings/domain/preferences.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/empty_repositories.dart';
import '../../helpers/fake_preferences_repository.dart';

/// Settings that never finish loading.
class _NeverLoads extends FakePreferencesRepository {
  @override
  Stream<Preferences> watch() => StreamController<Preferences>().stream;
}

void main() {
  late ProviderContainer container;
  late FakePreferencesRepository prefs;

  Future<void> pumpApp(
    WidgetTester tester, {
    bool onboarded = true,
    FakePreferencesRepository? repository,
    bool settle = true,
  }) async {
    prefs =
        repository ??
        FakePreferencesRepository(Preferences(onboardingComplete: onboarded));
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(prefs),
        ...emptyRepositories(),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    if (settle) await tester.pumpAndSettle();
  }

  Finder title(String text) => text == 'Home'
      ? find.byType(HomeScreen)
      : find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Finder tab(String label) =>
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == label);

  Future<void> go(WidgetTester tester, String location) async {
    container.read(appRouterProvider).go(location);
    await tester.pumpAndSettle();
  }

  group('splash and onboarding redirect', () {
    testWidgets('a new user goes from the splash to Welcome', (tester) async {
      await pumpApp(tester, onboarded: false, settle: false);
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('an onboarded user goes from the splash to Home', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(title('Home'), findsOneWidget);
    });

    testWidgets('tapping the splash moves on before the bar ends', (
      tester,
    ) async {
      await pumpApp(tester, settle: false);
      await tester.pump();
      await tester.tap(find.byType(SplashScreen));
      await tester.pump();
      await tester.pump();
      expect(title('Home'), findsOneWidget);
    });

    testWidgets('the splash waits for settings to load', (tester) async {
      await pumpApp(tester, repository: _NeverLoads(), settle: false);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Skip setup finishes onboarding and lands on Home', (
      tester,
    ) async {
      await pumpApp(tester, onboarded: false);
      await tester.tap(find.text('Skip setup'));
      await tester.pumpAndSettle();
      expect(title('Home'), findsOneWidget);
      expect((await prefs.read()).onboardingComplete, isTrue);
    });

    testWidgets('an onboarded user cannot go back to onboarding', (
      tester,
    ) async {
      await pumpApp(tester);
      await go(tester, Routes.onboardingName);
      expect(title('Home'), findsOneWidget);
    });
  });

  testWidgets('tabs switch between the four branches', (tester) async {
    await pumpApp(tester);
    for (final label in ['Tasks', 'Projects', 'Focus', 'Home']) {
      // Home has no app bar; the others are placeholders with one.
      await tester.tap(tab(label));
      await tester.pumpAndSettle();
      expect(title(label), findsOneWidget);
    }
  });

  testWidgets('quick add opens New task and back returns to the tab', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(tab('Projects'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quick add task'));
    await tester.pumpAndSettle();
    expect(title('New task'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(title('Projects'), findsOneWidget);
  });

  // With no tasks Home is S08, which has no search; Home's tests cover it.
  for (final (tooltip, screen) in [('Settings', 'Settings')]) {
    testWidgets('$tooltip on Home opens $screen and back returns', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(title(screen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(title('Home'), findsOneWidget);
    });
  }

  testWidgets('detail routes receive their id', (tester) async {
    await pumpApp(tester);
    await go(tester, Routes.task('42'));
    expect(find.text('42'), findsOneWidget);
    await go(tester, Routes.project('7'));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('Insights opens outside the shell', (tester) async {
    await pumpApp(tester);
    await go(tester, Routes.insights);
    expect(title('Insights'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });
}
