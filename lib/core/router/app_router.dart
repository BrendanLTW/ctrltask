import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/features/focus/presentation/focus_screen.dart';
import 'package:ctrltask/features/home/presentation/home_screen.dart';
import 'package:ctrltask/features/insights/presentation/insights_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ctrltask/features/projects/presentation/project_detail_screen.dart';
import 'package:ctrltask/features/projects/presentation/projects_screen.dart';
import 'package:ctrltask/features/settings/presentation/settings_screen.dart';
import 'package:ctrltask/features/tasks/presentation/search_screen.dart';
import 'package:ctrltask/features/tasks/presentation/task_detail_screen.dart';
import 'package:ctrltask/features/tasks/presentation/task_form_screen.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home = '/home';
  static const tasks = '/tasks';
  static const projects = '/projects';
  static const focus = '/focus';
  static const newTask = '/task/new';
  static String task(String id) => '/task/$id';
  static String project(String id) => '/project/$id';
  static const search = '/search';
  static const insights = '/insights';
  static const settings = '/settings';
  static const onboarding = '/onboarding';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Feeds the redirect without rebuilding the router, so the nav stack
  // survives when onboarding completes.
  final onboarded = ValueNotifier(ref.read(onboardingCompleteProvider));
  ref
    ..listen(onboardingCompleteProvider, (_, next) => onboarded.value = next)
    ..onDispose(onboarded.dispose);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded.value) return atOnboarding ? null : Routes.onboarding;
      return atOnboarding ? Routes.home : null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          currentIndex: shell.currentIndex,
          onTabSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          // shortcut: opens the New task screen; 2.6 makes it the S10 sheet.
          onQuickAdd: () => context.push(Routes.newTask),
          child: shell,
        ),
        branches: [
          _branch(Routes.home, const HomeScreen()),
          _branch(Routes.tasks, const TasksScreen()),
          _branch(Routes.projects, const ProjectsScreen()),
          _branch(Routes.focus, const FocusScreen()),
        ],
      ),
      // Listed before /task/:id so "new" isn't read as an id.
      GoRoute(
        path: Routes.newTask,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) =>
            TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (context, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.insights,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
