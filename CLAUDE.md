# ctrlTask (`ctrltask`)

Offline-first personal task and focus app in Flutter (iOS and Android). Portfolio project: code quality, architecture, tests and design fidelity matter more than feature count. ctrlTask shares its design system with ctrlSpend (`ctrlspend`).

## Read first
- `docs/PRD.md`: requirements, screen IDs (S01–S46), acceptance criteria, data model, derived values. **The source of truth for behaviour.**
- `docs/PLAN.md`: the task list. Work through it in order.
- `docs/DESIGN.md`: design tokens, component specs, layout patterns, motion, dark mode and the Flutter theme mapping.
- `docs/design/`: exported screens, light and dark, named after the canvas title in PRD §4 (e.g. `Home · Today (tap a circle to complete).png` and `… · Dark.png`). **The source of truth for layout.** If the PRD and a screen disagree, follow the screen and tell me.

Before building a screen, read its section in the PRD and look at both its light and dark designs.

## Scope
- **v1.0** = P0 + P1 requirements in the PRD.
- **v1.1** = P2 (board view, backup and restore, quick-add hints, drag to reschedule). Do not build P2 code, tables or routes unless the current task says so. In v1.0 their entry points are hidden.

## Stack
- Flutter stable, Dart 3, null safety
- State: Riverpod with code generation (`riverpod_annotation`, `riverpod_generator`)
- Database: Drift (SQLite), reactive streams, versioned migrations
- Navigation: go_router with a `StatefulShellRoute` for the bottom bar
- Models: freezed + json_serializable
- Formatting: intl · Icons: flutter_svg with bundled Lucide SVGs (`AppIcon`)
- Notifications: flutter_local_notifications, timezone, flutter_timezone (P1)
- Export: `csv` package, share_plus, path_provider (P1)
- Backup: file_picker (v1.1 only)
- Testing: flutter_test, mocktail, integration_test
- Lints: very_good_analysis

Charts are simple enough to draw with `CustomPainter`; don't add a chart package without asking. Check pub.dev for current versions before adding a package. Don't add packages not listed here without asking.

## Architecture
Feature-first, three layers per feature:

```
lib/
  core/
    theme/         # tokens, ThemeData (light + dark), ThemeExtensions for colours and project colours
    router/        # go_router config, shell with 4 tabs + quick-add button
    db/            # Drift database, tables, migrations
    dates/         # weekOf(), sectionFor(), DateLabels, Clock (pure Dart)
    repeat/        # nextOccurrence() (pure Dart)
    widgets/       # shared widgets: TaskCheckbox, TaskCard, TaskRow, ProgressHero, ProgressRing,
                   # ListGroup, SegmentedControl, AppChip, AppSheet, AppDialog, CompleteToast, EmptyState
  features/
    onboarding/  home/  tasks/  calendar/  projects/  focus/  insights/
    tags/  notifications/  settings/  data_transfer/
    # v1.1: board/  backup/
      data/          # DAOs, repository implementations
      domain/        # freezed entities, repository interfaces, pure calculations
      presentation/  # screens, widgets, Riverpod controllers
  l10n/
  main.dart
```

Rules:
- Presentation never imports from `data/`; it uses repository interfaces through providers.
- `domain/`, `core/dates/` and `core/repeat/` are pure Dart: no Flutter, no Drift imports.
- Every derived value in PRD §8 (today's list and progress, overdue, streak, done this week, project progress, days left, completion rate, power day) is a pure function in a `domain/` file with unit tests.
- One widget per file once it passes ~80 lines. Screens are named after the PRD (e.g. `HomeScreen` for S07, `TaskDetailScreen` for S12).

## Non-negotiable conventions

**Dates and time**
- Due dates are local calendar dates with an optional time in minutes after midnight. Timestamps (`createdAt`, `completedAt`, focus sessions) are stored in UTC and shown in local time.
- Always use `weekOf(date, weekStart)` and `sectionFor(...)`. Never compute week bounds or list sections inline.
- Never call `DateTime.now()` in domain code; use the injected `Clock`.

**Tasks**
- Completing a task always goes through one use case: tick, strikethrough, haptic, toast with 3.5 s Undo, and (for repeating tasks) the next occurrence. Undo reverses all of it, including the streak.
- Repeating tasks advance from the **due date**, never the completion date. Always use `nextOccurrence`.
- Reminders are rescheduled on every task change and cancelled on complete, archive and delete. One notification service owns all scheduling.

**Focus timer**
- Store the session's start time and planned length; compute the remaining time from the clock. Never rely on a running timer surviving the background.
- A session counts toward focus time only if it ran at least 1 minute.

**Priority and status**
- Urgent red, High orange, Medium blue, Low grey. Use one shared mapping everywhere (checkbox ring, tag, filter chip, picker).
- Colour is always paired with text or a mark ("Urgent", "Overdue · Mon", a strikethrough).

**UI**
- Use theme tokens only: no hex colours, font sizes or radii hard-coded in widgets. Tokens and component specs are in `docs/DESIGN.md`.
- Navy `ink` is the accent. Brand orange `#F26A21` appears only in the logo, app icon and splash loader.
- Every screen works in light and dark.
- Font: Poppins, bundled as an asset (the app must work offline). No runtime font loading.
- Touch targets ≥ 44 px. Text contrast ≥ 4.5:1 in both themes.
- Icon-only buttons get a `Semantics`/tooltip label. Rings, progress bars and charts get a screen-reader label listing their values.
- Respect reduced motion.
- All user-facing strings go in ARB files. Use the exact copy from the designs and PRD.

**Privacy**
- No network calls, analytics or crash reporting. Data leaves the device only through export and backups the user chooses.

## Commands
- Install: `flutter pub get`
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Test: `flutter test`
- Integration: `flutter test integration_test`
- Run: `flutter run`

## Testing
- Unit tests for every repository, every derived value, `weekOf`, `sectionFor` and `nextOccurrence`. `nextOccurrence` needs exhaustive cases: every rule kind, monthly on the 29th–31st in short months and leap years, custom N of 1 and 12, and end dates.
- Use an in-memory Drift database in tests and an injected clock for anything date-based.
- Widget tests for every screen, in both light and dark themes, covering its PRD acceptance criteria.
- One end-to-end test: onboarding → quick add → complete → undo → start and finish a focus session.
- The dev seed (PLAN 1.10) reproduces the canvas sample data: Alex, Tue 17 Nov 2026.

## Definition of done
A task is done only when:
1. `flutter analyze` reports no issues.
2. `flutter test` passes, with new tests for the new behaviour.
3. Codegen is up to date.
4. Each screen touched matches its light and dark design in `docs/design/`.
5. The acceptance criteria for the touched PRD section are met.
6. The task is ticked off in `docs/PLAN.md`.
7. Changes are committed with a Conventional Commit message (`feat:`, `fix:`, `test:`, `refactor:`, `chore:`, `docs:`).

## Working style
- One task from `docs/PLAN.md` at a time. Don't start the next one unprompted.
- For anything touching 3+ files, propose a plan first and wait for approval.
- Keep diffs small and focused; don't refactor unrelated code.
- If the PRD, the designs and this file conflict, stop and ask rather than guess.
- Schema changes bump Drift's `schemaVersion` and add a migration step plus a migration test.
- If a package API is uncertain, check its pub.dev docs rather than guessing.

## Git commits
Never add "Co-Authored-By", "Claude-Session", or "Generated with Claude Code" lines to commit messages or PR descriptions.
