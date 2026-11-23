import 'package:ctrltask/core/widgets/app_shell.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_providers.dart';
import 'package:ctrltask/features/calendar/presentation/calendar_week_screen.dart';
import 'package:ctrltask/features/focus/presentation/focus_screen.dart';
import 'package:ctrltask/features/home/presentation/home_screen.dart';
import 'package:ctrltask/features/insights/presentation/insights_screen.dart';
import 'package:ctrltask/features/notifications/presentation/notification_settings_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/all_set_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/first_task_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/name_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrltask/features/onboarding/presentation/reminders_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/splash_screen.dart';
import 'package:ctrltask/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrltask/features/projects/presentation/archived_projects.dart';
import 'package:ctrltask/features/projects/presentation/project_detail_screen.dart';
import 'package:ctrltask/features/projects/presentation/project_form_screen.dart';
import 'package:ctrltask/features/projects/presentation/projects_screen.dart';
import 'package:ctrltask/features/settings/presentation/edit_name_screen.dart';
import 'package:ctrltask/features/settings/presentation/settings_screen.dart';
import 'package:ctrltask/features/tags/presentation/tags_manager_screen.dart';
import 'package:ctrltask/features/tasks/domain/task_draft.dart';
import 'package:ctrltask/features/tasks/presentation/quick_add_sheet.dart';
import 'package:ctrltask/features/tasks/presentation/search_screen.dart';
import 'package:ctrltask/features/tasks/presentation/task_detail_screen.dart';
import 'package:ctrltask/features/tasks/presentation/task_form_screen.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_providers.dart';
import 'package:ctrltask/features/tasks/presentation/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home = '/home';
  static const tasks = '/tasks';
  static String calendar(CalendarSpan span) => '/tasks/calendar/${span.name}';
  static const projects = '/projects';
  static const focus = '/focus';
  static const newTask = '/task/new';
  static String task(String id) => '/task/$id';
  static String editTask(String id) => '/task/$id/edit';
  static const newProject = '/project/new';
  static String project(String id) => '/project/$id';
  static String editProject(String id) => '/project/$id/edit';
  static const archivedProjects = '/settings/archived';
  static const tags = '/settings/tags';
  static const notifications = '/settings/notifications';
  static const search = '/search';
  static const insights = '/insights';
  static const settings = '/settings';
  static const editName = '/settings/name';
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const onboardingName = '/onboarding/name';
  static const onboardingTask = '/onboarding/task';
  static const onboardingReminders = '/onboarding/reminders';
  static const onboardingDone = '/onboarding/done';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Feeds the redirect without rebuilding the router, so the nav stack
  // survives when onboarding completes. Null until settings load.
  final onboarded = ValueNotifier<bool?>(ref.read(onboardingCompleteProvider));
  ref
    ..listen(onboardingCompleteProvider, (_, next) => onboarded.value = next)
    ..onDispose(onboarded.dispose);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final location = state.matchedLocation;
      // The splash screen moves on by itself once settings have loaded.
      if (location == Routes.splash) return null;
      final done = onboarded.value;
      if (done == null) return Routes.splash;
      final inOnboarding = location.startsWith(Routes.onboarding);
      if (!done) return inOnboarding ? null : Routes.onboarding;
      return inOnboarding ? Routes.home : null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          currentIndex: shell.currentIndex,
          onTabSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          // On the calendar (S21, S22), + plans the day picked there.
          onQuickAdd: () => showQuickAdd(
            context,
            date:
                state.uri.path.startsWith(Routes.tasks) &&
                    (state.uri.path != Routes.tasks ||
                        ref.read(tasksViewModeProvider) == TasksView.calendar)
                ? ref.read(calendarDayProvider)
                : null,
          ),
          child: shell,
        ),
        branches: [
          _branch(Routes.home, const HomeScreen()),
          _branch(
            Routes.tasks,
            const TasksScreen(),
            routes: [
              GoRoute(
                path: 'calendar/:span',
                builder: (context, state) => CalendarWeekScreen(
                  span: CalendarSpan.values.byName(
                    state.pathParameters['span']!,
                  ),
                ),
              ),
            ],
          ),
          _branch(Routes.projects, const ProjectsScreen()),
          _branch(Routes.focus, const FocusScreen()),
        ],
      ),
      // Listed before /task/:id so "new" isn't read as an id.
      GoRoute(
        path: Routes.newTask,
        builder: (context, state) =>
            TaskFormScreen(draft: state.extra as TaskDraft?),
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) =>
            TaskDetailScreen(taskId: int.parse(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                TaskFormScreen(taskId: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
      GoRoute(
        path: Routes.newProject,
        builder: (context, state) =>
            ProjectFormScreen(preset: state.extra as ProjectPreset?),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (context, state) => ProjectDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => ProjectFormScreen(
              projectId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.editName,
        builder: (context, state) => const EditNameScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: Routes.tags,
        builder: (context, state) => const TagsManagerScreen(),
      ),
      GoRoute(
        path: Routes.archivedProjects,
        builder: (context, state) => const ArchivedProjectsScreen(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) =>
            SearchScreen(initialQuery: state.extra as String?),
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
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'name',
            builder: (context, state) => const NameScreen(),
          ),
          GoRoute(
            path: 'task',
            builder: (context, state) => const FirstTaskScreen(),
          ),
          GoRoute(
            path: 'reminders',
            builder: (context, state) => const RemindersScreen(),
          ),
          GoRoute(
            path: 'done',
            builder: (context, state) => const AllSetScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

StatefulShellBranch _branch(
  String path,
  Widget screen, {
  List<RouteBase> routes = const [],
}) => StatefulShellBranch(
  routes: [
    GoRoute(path: path, builder: (context, state) => screen, routes: routes),
  ],
);
