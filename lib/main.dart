import 'package:ctrltask/core/dates/clock.dart';
import 'package:ctrltask/core/db/app_database.dart';
import 'package:ctrltask/core/dev/demo_seed.dart';
import 'package:ctrltask/core/dev/perf_seed.dart';
import 'package:ctrltask/core/router/app_router.dart';
import 'package:ctrltask/core/theme/app_theme.dart';
import 'package:ctrltask/core/theme/theme_mode_controller.dart';
import 'package:ctrltask/features/data_transfer/data/drift_backup_store.dart';
import 'package:ctrltask/features/data_transfer/data/drift_data_eraser.dart';
import 'package:ctrltask/features/data_transfer/data/drift_export_source.dart';
import 'package:ctrltask/features/data_transfer/data/file_picker_backup.dart';
import 'package:ctrltask/features/data_transfer/data/nightly_backup.dart';
import 'package:ctrltask/features/data_transfer/data/share_plus_file_sharer.dart';
import 'package:ctrltask/features/data_transfer/domain/backup.dart';
import 'package:ctrltask/features/data_transfer/domain/data_eraser.dart';
import 'package:ctrltask/features/data_transfer/domain/export_data.dart';
import 'package:ctrltask/features/data_transfer/domain/file_sharer.dart';
import 'package:ctrltask/features/data_transfer/presentation/backup_providers.dart';
import 'package:ctrltask/features/focus/data/drift_focus_session_repository.dart';
import 'package:ctrltask/features/focus/data/drift_focus_timer_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_session_repository.dart';
import 'package:ctrltask/features/focus/domain/focus_timer_repository.dart';
import 'package:ctrltask/features/focus/presentation/focus_controller.dart';
import 'package:ctrltask/features/notifications/data/local_notification_scheduler.dart';
import 'package:ctrltask/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrltask/features/notifications/presentation/notification_sync.dart';
import 'package:ctrltask/features/projects/data/drift_project_repository.dart';
import 'package:ctrltask/features/projects/domain/project_repository.dart';
import 'package:ctrltask/features/settings/data/drift_preferences_repository.dart';
import 'package:ctrltask/features/settings/domain/preferences_repository.dart';
import 'package:ctrltask/features/tags/data/drift_tag_repository.dart';
import 'package:ctrltask/features/tags/domain/tag_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_recent_searches_repository.dart';
import 'package:ctrltask/features/tasks/data/drift_task_repository.dart';
import 'package:ctrltask/features/tasks/domain/recent_searches_repository.dart';
import 'package:ctrltask/features/tasks/domain/task_repository.dart';
import 'package:ctrltask/l10n/l10n.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// `flutter run --dart-define=DEMO=true` opens the canvas sample data in an
/// in-memory database. Debug builds only; release builds drop it.
const bool _demo = bool.fromEnvironment('DEMO') && kDebugMode;

/// `flutter run --profile --dart-define=PERF=true` runs on its own on-disk
/// database of 2,000 tasks and a year of focus (PLAN 4.3, docs/performance.md),
/// seeded on the first launch only, so later launches time a real cold
/// start. Profile builds too, since timings mean nothing in debug; never in
/// release.
const bool _perf = bool.fromEnvironment('PERF') && !kReleaseMode;

Future<void> main() async {
  if (_perf) {
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase(driftDatabase(name: 'ctrltask_perf'));
    final empty =
        await (db.select(db.tasks)..limit(1)).getSingleOrNull() == null;
    if (empty) await seedPerf(db, today: DateTime.now());
    runApp(
      ProviderScope(
        overrides: [
          ...appOverrides(),
          ...platformOverrides(),
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MainApp(),
      ),
    );
    return;
  }
  if (_demo) {
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase(NativeDatabase.memory());
    await seedDemo(db);
    // Starts at the canvas's 9:41 AM and keeps ticking.
    final launched = DateTime.now();
    final container = ProviderContainer(
      overrides: [
        ...appOverrides(),
        ...platformOverrides(),
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
  runApp(
    ProviderScope(
      overrides: [...appOverrides(), ...platformOverrides()],
      child: const MainApp(),
    ),
  );
}

/// The phone's own services, kept apart from [appOverrides] so tests and
/// the demo seed can run the app's data with a fake in their place.
List<Override> platformOverrides() => [
  notificationSchedulerProvider.overrideWithValue(LocalNotificationScheduler()),
  fileSharerProvider.overrideWithValue(SharePlusFileSharer()),
  backupSchedulerProvider.overrideWithValue(WorkmanagerBackupScheduler()),
  // On the platform's documents folder (path_provider).
  backupStoreProvider.overrideWith(
    (ref) => DriftBackupStore(
      ref.watch(appDatabaseProvider),
      backupFolder,
      ref.watch(clockProvider),
    ),
  ),
  pickBackupFileProvider.overrideWithValue(pickBackupFileWithFilePicker),
];

/// The real implementations behind each repository. Wired here so screens
/// never import `data/`.
List<Override> appOverrides() => [
  dataEraserProvider.overrideWith(
    (ref) => DriftDataEraser(ref.watch(appDatabaseProvider)),
  ),
  exportSourceProvider.overrideWith(
    (ref) => DriftExportSource(ref.watch(appDatabaseProvider)),
  ),
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
  recentSearchesRepositoryProvider.overrideWith(
    (ref) => DriftRecentSearchesRepository(ref.watch(appDatabaseProvider)),
  ),
  focusTimerRepositoryProvider.overrideWith(
    (ref) => DriftFocusTimerRepository(ref.watch(appDatabaseProvider)),
  ),
];

class MainApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the focus timer running on whatever screen is open (§6.6).
    ref
      ..watch(focusControllerProvider)
      // The one owner of notification scheduling (§6.5).
      ..watch(notificationSyncProvider)
      // Keeps the nightly backup booked (S42).
      ..watch(backupScheduleSyncProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
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
