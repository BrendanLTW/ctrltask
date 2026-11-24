# Design notes

Where v1.0 knowingly differs from the exports in `docs/design/`, and why. Each screen was checked against DESIGN §13 in light and dark at 390 × 844 (PLAN 3.13, 4.1, 4.2). Anything not listed here matches.

## Data, not design

- **Counts, names and dates** come from the demo seed (`lib/core/dev/demo_seed.dart`), so they differ from the canvas wherever the canvas used made-up numbers. Examples are "342 tasks done", "6 inbox tasks" and Insights' bars.
- **Optional parts appear only when there's data.** For example, Project detail adds "· 3h 20m focused" only when the project has focus time, and S25 shows "Did you mean …?" only when a near match exists.

## v1.1 entry points, hidden

These belong to P2 (CLAUDE.md Scope) and come back with their features:

| Design | Where | v1.1 feature |
|---|---|---|
| **Board** segment (S19) and **Board view ›** (S28) | Tasks, Project detail | Board view (S20) |
| **Backup & restore** row (S35), S42, S43 | Settings | Backup and restore |
| "Detected **tomorrow 9 AM** from your words" (S10) | Quick add | Quick-add hints (PRD §6.8) |

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
