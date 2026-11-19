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
        builder: (context, state, shell) => _TempShell(shell: shell),
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

// shortcut: stand-in bottom bar with hard-coded labels; task 0.6 replaces it
// with AppShell, 0.5 moves the strings to ARB and 2.6 makes quick add the S10
// sheet.
class _TempShell extends StatelessWidget {
  const new({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Quick add task',
        onPressed: () => context.push(Routes.newTask),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            label: 'Focus',
          ),
        ],
      ),
    );
  }
}
