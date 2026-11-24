import 'package:ctrltask/core/widgets/app_shell_tab.dart';
import 'package:ctrltask/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// PLAN 4.3's scroll benchmark on the 2,000-task data set. Profile mode on
/// a real device only (docs/performance.md):
///
///   flutter drive --profile --dart-define=PERF=true \
///     --driver=test_driver/perf_driver.dart \
///     --target=integration_test/perf_test.dart
///
/// Frame build and raster times land in `build/perf_summary.json`.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scroll Home and Tasks with 2,000 tasks', (tester) async {
    expect(
      const bool.fromEnvironment('PERF'),
      isTrue,
      reason: 'Run with --dart-define=PERF=true (docs/performance.md).',
    );
    await app.main();
    // The splash, then Home; the first launch also seeds the data.
    await tester.pumpAndSettle();

    Future<void> scroll() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(
          find.byType(Scrollable).first,
          Offset(0, i < 4 ? -1200 : 1200),
          3000,
        );
        await tester.pumpAndSettle();
      }
    }

    await binding.watchPerformance(scroll, reportKey: 'home_scroll');

    await tester.tap(
      find.byWidgetPredicate((w) => w is AppShellTab && w.label == 'Tasks'),
    );
    await tester.pumpAndSettle();
    await binding.watchPerformance(scroll, reportKey: 'tasks_scroll');
  });
}
