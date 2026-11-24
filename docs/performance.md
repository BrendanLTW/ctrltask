# Performance

PLAN 4.3 measures ctrlTask against PRD §10 with a large, repeatable data set on a mid-range Android phone.

## Targets (PRD §10)

| What | Target |
|---|---|
| Cold start to an interactive Home | < 1.5 s |
| Scrolling lists with 2,000 tasks | 60 fps: frames built and rastered within 16.7 ms |
| Any change on screen | < 100 ms |

## The data set

`lib/core/dev/perf_seed.dart` (`seedPerf`) writes it in one batch:
- 2,000 tasks over 10 projects (two archived), with mixed priorities. Due dates run from a year ago to two months ahead, and one in ten has none. About two thirds are done, and the rest of the past ones stay overdue.
- Subtasks on every fifth task, a tag on every third, and a repeat on every fortieth.
- A year of focus sessions: three a day, 1,098 in all.

It's deterministic (fixed random seed), so runs are comparable. `test/core/dev/perf_seed_test.dart` checks the counts and the schema.

Run the app on it with `--dart-define=PERF=true`. It uses its own on-disk database, `ctrltask_perf`, never your real data. It seeds that database on the **first** launch only, so later launches time a real cold start. It works in debug and profile builds, and release builds leave it out.

## Measuring

Use a **real device in profile mode**. Debug builds and emulators give meaningless timings. List devices with `flutter devices`.

**Cold start:** time to first frame, as the median of 3 runs after an untimed seeding launch:

```sh
tool/measure_startup.sh <device-id>
```

**Scrolling:** flings Home and then the Tasks list (all 2,000), and reports frame build and raster times:

```sh
flutter drive --profile --dart-define=PERF=true -d <device-id> \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/perf_test.dart
```

The results are written to `build/perf_summary.json`, under `home_scroll` and `tasks_scroll`. Read `average_frame_build_time_millis`, `90th_percentile_frame_build_time_millis`, the raster equivalents and `missed_frame_build_budget_count`. A 90th percentile under 16.7 ms meets 60 fps.

**Changes on screen** (< 100 ms), such as ticking a task: use DevTools' Performance view on the same profile build.

## Results

Not measured yet: no mid-range Android device was available when the tools were built (Nov 2026). PLAN 4.3 stays open until this table is filled in.

| Device | Cold start (median) | Home scroll p90 build / raster | Tasks scroll p90 build / raster | Missed frames |
|---|---|---|---|---|
| — | — | — | — | — |
