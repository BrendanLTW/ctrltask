# Design notes

Where v1.0 knowingly differs from the exports in `docs/design/`, and why. Each screen was checked against DESIGN §13 in light and dark at 390 × 844 (PLAN 3.13, 4.1, 4.2). Anything not listed here matches.

## Data, not design

- **Counts, names and dates** come from the demo seed (`lib/core/dev/demo_seed.dart`), so they differ from the canvas wherever the canvas used made-up numbers. Examples are "342 tasks done", "6 inbox tasks" and Insights' bars.
- **Optional parts appear only when there's data.** For example, Project detail adds "· 3h 20m focused" only when the project has focus time, and S25 shows "Did you mean …?" only when a near match exists.

## v1.1 entry points, hidden

These belong to P2 (CLAUDE.md Scope) and come back with their features:

| Design | Where | v1.1 feature |
|---|---|---|
| "Detected **tomorrow 9 AM** from your words" (S10) | Quick add | Quick-add hints (PRD §6.8) |

## Board (S20, v1.1)

- **No Add task under Done.** A task becomes done only by completing it (CLAUDE.md: one completion path), so Done has no Add task. To do and In progress each have one, which starts the task in that column.
- **No filter button on the board.** The export shows it, but S20's spec has no board filters: the project chip chooses what's shown, and the button stays on the list.
- **The Board segment's icon** is Lucide's `kanban` (three bars). The export draws outlined columns, which aren't in the bundled set.
- **Dragging is one way to move a card.** Screen readers get "Move to To do / In progress / Done" actions on each card. Cards drop at the end of a column; there's no reordering within a column.

## Backup & restore (S42, S43, v1.1)

- **Backups go to the app's own folder.** On iOS it shows in Files as On My iPhone › ctrlTask › backups, so the design's "Files · ctrlTask" is accurate there. Writing to a folder of your choice needs native code on both platforms (security-scoped bookmarks on iOS, the Storage Access Framework on Android), so v1.1 doesn't. "Save backups to" and S43's **Choose another folder** explain where backups are instead. On Android they stay inside the app; Export (JSON) takes a copy off the phone.
- **Restore** offers the backups in the folder and **Choose a file…** for any backup elsewhere, such as iCloud Drive. It asks before replacing everything.
- **"Every night while charging"** runs when Android's WorkManager or iOS's BGTaskScheduler allows. iOS decides when, so on iOS it's a best effort.
- **The status box's text is `ink` and `chipText`** on the tinted box, as in the designs. A size never breaks between number and unit.

## Following the spec over one export

- **Priority tag flag and clock icon in Tasks rows (S19).** The Tasks · List view export leaves out the 12 px flag in the priority tag and the clock before the time. DESIGN §7 specifies both, and the Home export shows them, so every list uses one task row. As a result, a long title beside a tag wraps a little sooner in the list.

## Accessibility over the exports

- **Placeholders use `muted`, not `disabled`** (4.1). The exports' light grey reads about 2.5:1, but DESIGN §11 needs 4.5:1. DESIGN §3 now lists placeholders under `muted`.
- **The Welcome preview (S02) keeps normal text size at 200% text.** It's a picture of the app, hidden from screen readers, with a fixed height. The real title, body and buttons scale.
- **Text fields** make the whole drawn box the field, so the tap target is the full 56 px. They look the same.

## Screens or states without a design

- **S39 permission box** ("Notifications are off for ctrlTask"): the export shows notifications allowed. It uses the warning-box style, as Home's alerts do.
- **S34 power-day card:** cut off in both exports. It uses a yellow tile with a ⚡ (`zap`, from ctrlSpend's Lucide set).
- **S34 edge cases:** "No tasks were due" (with "—") and "Nothing was due before to compare". This month draws one bar per day, labelled every seventh day, with no values above.
- **S41 totals for CSV** list tasks and projects only, since CSV holds tasks (PRD §6.7). JSON adds focus sessions, as the export shows.
- **S41 custom range** uses S14's calendar for From and To (PRD notes it has no design of its own).

## Small substitutions

- **S08 empty-state icon:** the export draws a checklist inside a rounded square, which isn't in the bundled Lucide set. We use `list-checks` in the same grey circle.
- **Quick add's project chip has no ⌄** (S10). The export fits "● Inbox ⌄", three icon buttons and More in one row by drawing the buttons at 40 px. Ours are 44 px, DESIGN §11's minimum target, and at 390 px the extra 12 px leaves no room for the chevron without wrapping "Inbox". Tapping the chip still opens the project picker.
