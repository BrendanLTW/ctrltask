# ctrlTask — Build Plan

Work top to bottom. Each task is sized for one Claude Code session and follows the definition of done in `CLAUDE.md`.

- Run `/next` to pick up the first unchecked task, or paste a task as a prompt.
- Run `/clear` between tasks.
- **Refs** point to screen IDs and sections in `docs/PRD.md` (`PRD §5.2`) and `docs/DESIGN.md` (`DESIGN §7`).
- Tasks in Phases 0–4 build **v1.0** (P0 + P1). Phase 5 is **v1.1** (P2). Do not start Phase 5 until v1.0 is released.

---

## Before you start (you, not Claude Code)

- [ ] Create the GitHub repo `ctrltask` and add `CLAUDE.md`, `docs/PRD.md`, `docs/DESIGN.md` and this file.
- [ ] Export every canvas artboard to `docs/design/` as PNG, named after its canvas title (`Splash.png`, `Splash · Dark.png`, `Settings (full scroll).png`, …).
- [ ] Copy the ctrlSpend `.claude/commands/` (`/next`) into the repo, if you use them there.
- [ ] Add the three missing designs to the canvas, or accept the fallbacks in PRD §12: Custom repeat (S15), Export custom range (S41), the task picker behind **Change** on S30.
- [ ] Draw the app icon and adaptive icon from the brand mark and save the SVGs in `assets/brand/`.

---

## Phase 0 — Foundation

- [x] **0.1 Project setup.** Create the Flutter project `ctrltask` (android, ios). Add the v1.0 packages from `CLAUDE.md` (not the v1.1 ones), set up very_good_analysis, and make `flutter analyze` and `flutter test` pass on the template.
  Refs: CLAUDE.md Stack
- [x] **0.2 Folder structure and routing.** Create the `core/` and `features/` folders from `CLAUDE.md`. Set up go_router with a `StatefulShellRoute` for Home, Tasks, Projects and Focus (placeholder screens), plus routes for Task detail, New task, Project detail, Search, Insights, Settings and Onboarding. Add an onboarding redirect driven by a placeholder provider.
  Refs: PRD §4, DESIGN §6
- [x] **0.3 Colour tokens.** Build `AppColors` as a `ThemeExtension` with every token in DESIGN §3.1–3.3 for light and dark, plus `ProjectColors` (DESIGN §3.4: tile, icon and solid for 8 keys). Add `context.colors` and `context.projectColors`. Test that every token has a light and a dark value.
  Refs: DESIGN §3, §12
- [x] **0.4 Type, spacing, motion and theme.** Bundle Poppins 400–800 as assets. Build `AppTypography` (DESIGN §4, tabular figures), `AppSpacing`, `AppRadius`, `AppShadows`, `AppMotion`, and `buildLightTheme()` / `buildDarkTheme()`. Add a theme-mode provider (default System). Widget-test a sample screen in both themes.
  Refs: DESIGN §4, §5, §9, §12
- [x] **0.5 Localisation and dates.** Set up `flutter gen-l10n` with an English ARB file. Build `DateLabels` in `core/dates` (pure Dart): "Tue, 17 Nov", "10:00 AM", "Today, 10:00", "Yesterday", "Overdue · Mon", "13 days left", "1h 15m". Unit tests.
  Refs: PRD §6.2
- [x] **0.6 App shell.** Build `AppShell`: the floating pill bottom bar (four tabs, active tab expands with label), the separate round quick-add button and the bottom fade, with labels and the shadows from DESIGN §5. Widget tests in both themes; compare with `Home · Today (tap a circle to complete).png` and its `· Dark` version.
  Refs: PRD §4, DESIGN §6, §7
- [x] **0.7 Task checkbox and completion feedback.** `TaskCheckbox` (four priority rings, done state, 44 px target, spring animation, reduced motion), `CompleteToast` with Undo and a 3.5 s timer, and a `Haptics` wrapper. Widget tests for each state.
  Refs: PRD §6.1, DESIGN §7, §9
- [x] **0.8 CI.** GitHub Actions on every push: set up Flutter, `pub get`, codegen, `flutter analyze`, `flutter test`. Add the status badge to `README.md`.
  Refs: PRD §10
- [x] **0.9 Spike (no production code).** On Android and iOS: schedule a local notification with flutter_local_notifications (with the permission prompt), and check that a timer computed from a stored start time survives backgrounding and killing the app. Record findings and setup steps in `docs/spikes.md`.
  Refs: PRD §6.5, §6.6, §12

## Phase 1 — Data

- [x] **1.1 Days and weeks.** Implement `weekOf(date, weekStart)`, `sectionFor(task, today, weekStart)` (Overdue, Today, Tomorrow, This week, Later, No date) and an injectable `Clock` provider in `core/dates`. Unit tests: each week start, month and year boundaries, tasks with and without times, a time already passed today.
  Refs: PRD §6.2, §6.3
- [x] **1.2 Repeat rules.** Implement `nextOccurrence(rule, dueDate)` in `core/repeat` (pure Dart). Exhaustive unit tests: daily, weekdays across weekends, weekly with one and several days, monthly on the 15th, 29th, 30th and 31st (short months and leap years), custom every N days, weeks and months for N 1 and 12, end dates.
  Refs: PRD §6.4
- [x] **1.3 Database schema v1.** Drift database in `core/db` with Task, Subtask, Tag, TaskTag, Link, Project, RepeatRule, FocusSession and a key-value Preferences table (schemaVersion 1). Provide it through Riverpod; use an in-memory database in tests.
  Refs: PRD §8
- [x] **1.4 Domain entities.** freezed entities for every table, enums for priority, status, board column, reminder, colour key and icon key, and mappers to and from Drift rows.
  Refs: PRD §8, DESIGN §3.4, §8
- [x] **1.5 Task repository.** Watch today's list, sections, by project, by date range, and search; add, update, complete (creating the next occurrence for repeating tasks), uncomplete, delete with subtasks, tags and links, and exact restore for undo. Enforce the field rules in PRD §8. Unit tests.
  Refs: PRD §5.4, §6.1, §6.4, §8
- [x] **1.6 Project and tag repositories.** Projects: watch active and archived, add, update, archive, restore, delete (move tasks to Inbox or delete them). Tags: watch with counts, create, rename, merge, delete. Unique-name rules. Unit tests.
  Refs: PRD §5.7, §5.10, §8
- [x] **1.7 Preferences repository.** Read and watch every key in PRD §8 with its default. Wire the theme-mode provider from 0.4 to it. Unit tests.
  Refs: PRD §8
- [x] **1.8 Progress calculations.** Pure domain functions with tests: today's list order, today's progress, overdue, streak (including undo and day boundaries), done this week, project progress and days left.
  Refs: PRD §8 Derived values
- [x] **1.9 Insight calculations.** Pure domain functions with tests: completion rate and change for 7 days and this month, completions per day, focus per day and daily average, 6-week trend, power day, and the "not enough data" rule.
  Refs: PRD §5.9, §8 Derived values
- [x] **1.10 Dev seed.** A debug-only seed that reproduces the canvas: Alex, Tue 17 Nov 2026, the six projects, today's tasks, overdue and upcoming tasks, tags, focus sessions and a 12-day streak. A debug toggle to load it.
  Refs: CLAUDE.md Testing

## Phase 2 — Core (P0)

- [x] **2.1 Shared widgets, part 1.** `TaskCard`, `TaskRow`, `PriorityTag`, `ProjectDot`, `TagChip`, `IconTile`, `ListGroup` / `ListGroupRow` / `KeyValueRow`, `AppProgressBar`, `ProgressRing`, `ProgressHero`, `StatTile`, `AlertBanner`. Widget tests in both themes.
  Refs: DESIGN §7, §12
- [x] **2.2 Shared widgets, part 2.** `SegmentedControl`, `AppChip`, `SearchField`, `AppToggle`, `AppRadio`, `AppStepper`, `AppTextInput`, `TitleFieldCard`, `StepIndicator`, `EmptyState`, `StateCard`, `AppSheet`, `AppDialog`, `MessageBox`, `MonthCalendar`, `QuickDateTiles`. Widget tests in both themes.
  Refs: DESIGN §7, §12
- [x] **2.3 Onboarding.** S01 Splash (with "by BrendanLTW"), S02 Welcome (illustration panel), S03 Your name, S04 First task, S05 Reminders (saves choices only; the permission prompt comes in 3.7), S06 All set, and `OnboardingScaffold`. The onboarding redirect now uses `onboardingComplete`. Back keeps values on every step.
  Refs: S01–S06, PRD §5.1, FR-01
- [x] **2.4 Home.** S07 with header (date, greeting by time of day, search, avatar → Settings), the progress hero, stat tiles, overdue banner, Due today cards with completion and Undo, and Upcoming deadlines. Figures update live.
  Refs: S07, PRD §5.2, FR-02
- [x] **2.5 Home states.** S08 first run (empty state and suggestion chips that prefill quick add) and S09 all done (celebration card, Plan tomorrow, tomorrow's list).
  Refs: S08, S09, PRD §5.2, FR-02
- [x] **2.6 Quick add.** S10 sheet: title and send, When chips, Priority chips, project chip (S17 comes in 2.10; use Inbox until then), More → S11 with values carried over. Opens from the quick-add button on every tab.
  Refs: S10, PRD §5.3, FR-03
- [x] **2.7 Task form.** S11 new and edit: title and description, Essentials (Due, Priority, Project), subtasks with add and tick, notes and links. Tags, reminder and repeat rows are hidden until 3.4–3.7.
  Refs: S11, PRD §5.4, FR-04
- [x] **2.8 Task detail and delete.** S12 with chips, description, quick reschedule chips, subtasks with progress, Edit, and Delete task → S13 dialog (Delete, Mark as done instead, Cancel). Start a focus session is hidden until 3.1.
  Refs: S12, S13, PRD §5.4, FR-04, FR-05
- [x] **2.9 Due-date picker.** S14 sheet: quick tiles, month calendar on the user's week start, time chips and no time, read-back button. Used from S10, S11 and S12.
  Refs: S14, PRD §5.5, FR-05
- [x] **2.10 Projects.** S26 list (Active and Archived), S27 detail (header, open tasks, add task in project, Completed row), S28 new and edit (name, description, colour, icon, deadline; archive and delete from edit), S29 empty state, S45 archived list with Restore, and S17 Move to project sheet.
  Refs: S17, S26–S29, S45, PRD §5.7, FR-06
- [x] **2.11 Tasks list.** S19 title, List segment (Calendar and Board show placeholders), filter chips with counts, sections, task rows, swipe right to complete and swipe left for Reschedule (→ S14) and Delete (→ S13).
  Refs: S19, PRD §5.6, FR-07
- [x] **2.12 Settings shell.** S35 with the name card (→ S40 Edit name), the insights banner (placeholder until 3.10), and the Preferences, Manage and Data rows for what exists so far; the rest hidden. Footer "ctrlTask {version} · by BrendanLTW".
  Refs: S35, S40, PRD §5.10
- [x] **2.13 P0 review.** Walk through every acceptance criterion for FR-01 to FR-07 and every P0 screen against its light and dark design. List gaps, fix them, and confirm all P0 tests pass.
  Refs: PRD §7

## Phase 3 — Complete (P1)

- [x] **3.1 Focus timer.** S30 with modes, Working on (with a task picker reusing S17's sheet), the timer ring, Reset / Play-Pause / Finish, session dots and today's total. Time is computed from the stored start (§6.6). Wire **Start a focus session** on S12.
  Refs: S30, PRD §5.8, §6.6, FR-08
- [x] **3.2 Focus states and settings.** S32 Session complete (Start break, Skip break, Mark task done), S33 Short break (green ring, tip card), long break after N sessions, auto-start options, and S31 timer settings sheet (also from Settings → Default focus length). Sessions are saved with the 1-minute rule.
  Refs: S31–S33, PRD §5.8, FR-08
- [x] **3.3 Calendar.** S21 month view (status dots, legend, agenda for the selected day) and S22 week view (week strip, Anytime chips, day timeline with tasks, focus sessions and the now line). Quick add from a day prefills the date.
  Refs: S21, S22, PRD §5.6, FR-09
- [x] **3.4 Filter, sort and search.** S23 sheet combined with the S19 chips and the filter dot; S24 search with type chips, highlights and recent searches; S25 no results with Did you mean and Create task.
  Refs: S23–S25, PRD §5.6, FR-10
- [x] **3.5 Repeat.** S15 sheet (all rules, weekly day toggles, Custom, Ends) on S10, S11 and S12; the repeat icon on rows; completing a repeating task creates the next occurrence and Undo removes it.
  Refs: S15, PRD §5.5, §6.4, FR-11
- [x] **3.6 Tags.** S18 sheet (search, create, select, Save) on S10 and S11, tag chips on S12, and S46 tag manager (rename, merge, delete; a tag opens S24 filtered to it).
  Refs: S18, S46, PRD §5.5, §5.10, FR-13
- [x] **3.7 Reminders and notifications.** A notification service using the spike findings: permission request from S05 and S39; task reminders from S16 (rescheduled on every change, cancelled on complete, archive and delete); daily plan; overdue nudge; focus session end with the soft bell; weekly review; quiet hours; silence while focusing. Keep at most 14 days of reminders scheduled; reschedule on launch and resume. Tests with a fake scheduler and an injected clock.
  Refs: S05, S16, S39, PRD §6.5, FR-12
- [x] **3.8 Notification settings.** S39 toggles, Timing rows (time pickers and the default reminder) and the permission-denied warning box with Open phone settings.
  Refs: S39, PRD §5.10, FR-12
- [x] **3.9 Preferences screens.** S36 Theme (preview cards), S37 Week starts on, S38 Default priority. Changes apply at once everywhere.
  Refs: S36–S38, PRD §5.10, FR-15
- [ ] **3.10 Insights.** S34 with the range segments, completion-rate hero and change, stat tiles, tasks and focus bar charts with text alternatives, 6-week trend, power day, and the not-enough-data state. Wire the S35 banner and the stats button on S30.
  Refs: S34, PRD §5.9, FR-14
- [ ] **3.11 Export.** S41 format, range (custom range with From and To via S14), include toggles, totals and estimated size; `ctrltask-YYYY-MM-DD.csv|json` via the share sheet. Define the formats in `docs/export-format.md`. Round-trip test for JSON.
  Refs: S41, PRD §6.7, FR-17
- [ ] **3.12 Erase all data.** S44 dialog with Export a copy first; erase every table and preference in one transaction, cancel every notification and return to S01.
  Refs: S44, PRD §5.10, FR-17
- [ ] **3.13 Dark mode audit.** Check every v1.0 screen against its dark design; make sure every screen's widget tests run in both themes; fix any hard-coded colours.
  Refs: FR-16, DESIGN §10

## Phase 4 — Ship v1.0

- [ ] **4.1 Accessibility pass.** Screen-reader labels, ring and chart text alternatives, 44 px targets, contrast in both themes, reduced motion, and 200% text scale on every screen.
  Refs: DESIGN §11, PRD §9
- [ ] **4.2 Design fidelity pass.** Run the DESIGN §13 checklist for every v1.0 screen in light and dark; fix differences or log intentional ones in `docs/design-notes.md`.
  Refs: DESIGN §13
- [ ] **4.3 Performance.** A debug-only generator for 2,000 tasks across 10 projects and a year of focus sessions; measure cold start and list scrolling on a mid-range Android device; fix anything below target.
  Refs: PRD §10
- [ ] **4.4 End-to-end test.** Integration test: onboarding → quick add → complete → undo → start and finish a focus session.
  Refs: PRD §10
- [ ] **4.5 README and release.** README with screenshots in both themes, an architecture diagram and key decisions (offline-first, navy over purple, timer from timestamps). Build the release APK, attach it to a GitHub Release and tag `v1.0.0`.
  Refs: PRD §2

## Phase 5 — v1.1

- [ ] **5.1 Board view.** S20 with the project selector, three columns, counts, long-press drag between columns (Done completes, out of Done reopens), Add task per column. Wire the Board segment on S19 and the Board view link on S27.
  Refs: S20, PRD §5.6, FR-18
- [ ] **5.2 Backup domain.** JSON backup of every table with `schemaVersion`; atomic write (temp file then rename); keep the newest N; restore validates the whole file, then replaces everything in one transaction. Unit tests, including a corrupt file and an older schema.
  Refs: PRD §5.10, §6.7, FR-19
- [ ] **5.3 Backup screens.** S42 (status, automatic backup, folder, keep, Back up now, Restore with confirmation) and S43 (error box, Try again, Choose another folder). Nightly automatic backup while charging. Unhide the Settings row.
  Refs: S42, S43, FR-19
- [ ] **5.4 Quick-add hints.** Parse dates, times, `!priority`, `#tag` and `@project` in the S10 title, show what was detected, and strip it on save. Unit tests for the parser.
  Refs: S10, PRD §6.8, FR-20
- [ ] **5.5 Drag to reschedule.** Long-press a task in the S21 agenda and drop it on a day; the date changes and the time stays.
  Refs: S21, PRD §5.6, FR-20
- [ ] **5.6 v1.1 release.** Run the accessibility and fidelity checklists for the new screens, update the README, and tag `v1.1.0`.
  Refs: PRD §11
