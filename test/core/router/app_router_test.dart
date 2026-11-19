import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrltask/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester, {bool onboarded = true}) async {
    container = ProviderContainer();
    addTearDown(container.dispose);
    if (onboarded) {
      container.read(onboardingCompleteProvider.notifier).complete();
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();
  }

  Finder title(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Future<void> go(WidgetTester tester, String location) async {
    container.read(appRouterProvider).go(location);
    await tester.pumpAndSettle();
  }

  group('onboarding redirect', () {
    testWidgets('sends a new user to onboarding', (tester) async {
      await pumpApp(tester, onboarded: false);

      expect(find.text('Finish onboarding'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('finishing onboarding lands on Home', (tester) async {
      await pumpApp(tester, onboarded: false);

      await tester.tap(find.text('Finish onboarding'));
      await tester.pumpAndSettle();

      expect(title('Home'), findsOneWidget);
    });

    testWidgets('an onboarded user cannot go back to onboarding', (
      tester,
    ) async {
      await pumpApp(tester);

      await go(tester, Routes.onboarding);

      expect(title('Home'), findsOneWidget);
      expect(find.text('Finish onboarding'), findsNothing);
    });
  });

  testWidgets('tabs switch between the four branches', (tester) async {
    await pumpApp(tester);

    for (final tab in ['Tasks', 'Projects', 'Focus', 'Home']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(title(tab), findsOneWidget);
    }
  });

  testWidgets('quick add opens New task and back returns to the tab', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Quick add task'));
    await tester.pumpAndSettle();
    expect(title('New task'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(title('Projects'), findsOneWidget);
  });

  for (final (tooltip, screen) in [
    ('Search tasks', 'Search'),
    ('Settings', 'Settings'),
  ]) {
    testWidgets('$tooltip on Home opens $screen and back returns', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(title(screen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

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
    expect(find.byType(NavigationBar), findsNothing);
  });
}
