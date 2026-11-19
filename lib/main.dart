import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/demo_seed.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/theme_mode_controller.dart';
import 'package:ctrltask/features/focus/data/drift_focus_session_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/projects/data/drift_project_repository.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tags/data/drift_tag_repository.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// `flutter run --dart-define=DEMO=true` opens the canvas sample data in an
/// in-memory database. Debug builds only; release builds drop it.
const bool _demo = bool.fromEnvironment('DEMO') && kDebugMode;

Future<void> main() async {
  if (_demo) {
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase(NativeDatabase.memory());
    await seedDemo(db);
    // Starts at the canvas's 9:41 AM and keeps ticking.
    final launched = DateTime.now();
    final container = ProviderContainer(
      overrides: [
        ...appOverrides(),
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(
          () => demoNow.add(DateTime.now().difference(launched)),
        ),
      ],
    );
    runApp(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    return;
  }
  runApp(ProviderScope(overrides: appOverrides(), child: const MainApp()));
}

/// The real implementations behind each repository. Wired here so screens
/// never import `data/`.
List<Override> appOverrides() => [
  taskRepositoryProvider.overrideWith(
    (ref) => DriftTaskRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  projectRepositoryProvider.overrideWith(
    (ref) => DriftProjectRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(clockProvider),
    ),
  ),
  tagRepositoryProvider.overrideWith(
    (ref) => DriftTagRepository(ref.watch(appDatabaseProvider)),
  ),
  preferencesRepositoryProvider.overrideWith(
    (ref) => DriftPreferencesRepository(ref.watch(appDatabaseProvider)),
  ),
  focusSessionRepositoryProvider.overrideWith(
    (ref) => DriftFocusSessionRepository(ref.watch(appDatabaseProvider)),
  ),
];

class MainApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(appThemeModeProvider),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
