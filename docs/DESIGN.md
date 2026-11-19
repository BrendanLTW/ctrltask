# ctrlTask — Design System

This is the single reference for how ctrlTask looks. Values come from the "CtrlTask UI" canvas: the design-system board and the 46 screens. ctrlTask is built on the ctrlSpend design system, so most tokens are shared with `ctrl_spend/docs/DESIGN.md`. If a screen and this file disagree, the screen wins and this file is updated.

- Behaviour and copy: `docs/PRD.md`
- Code conventions: `CLAUDE.md`
- Screen exports: `docs/design/<File>.png` and `<File>Dark.png`

---

## 1. Principles

1. **Today first.** Every tab leads with what matters now: today's progress, today's list, the running timer. History and stats sit one level deeper.
2. **Soft and roomy.** A cool off-white ground, white cards with large radii, and generous padding. Cards have no borders; separation comes from space and surface colour.
3. **Navy does the work.** Near-black navy (`ink`) is both the text colour and the accent. It's used for primary buttons, selected states, filled checkboxes, the hero card and the quick-add button. Colour is reserved for projects, priority and status.
4. **Colour always has words.** Priority, overdue and error states always come with text ("Urgent", "Overdue · Mon", "Last night's backup failed").
5. **Feel the tick.** Completing a task is the one place with motion: a spring, a haptic, a strikethrough and an Undo toast.
6. **Same layout, flipped tokens.** Dark mode never changes layout; only tokens change.

---

## 2. Brand

| Item | Rule |
|---|---|
| Name | **ctrlTask** — lowercase "ctrl", capital "T". Package `ctrl_task`. |
| Wordmark | "ctrl" in Poppins 400, grey `#5D6169` (on dark `#98A2B3`), then "Task" in Poppins 700, `#15171C` (on dark `#FFFFFF`). Letter-spacing −2%. |
| Symbol | An orange check on a charcoal keycap: `assets/brand/ctrltask_mark.svg` in the app, `ctrltask_app_icon.svg` (full-bleed, square corners) for the app icon |
| Keycap | Base `#111318`, radius 28 on a 120 grid; skirt gradient `#262A32 → #191C22`; inset face 102 × 96, radius 21, gradient `#3B404B → #2C3038`, with a 9% white rim; check stroke 11, round caps |
| Brand orange | `#F26A21`, only in the logo, the app icon and the splash loader. Never elsewhere in the UI. |
| Parent | ctrlWorks. In sentences: "ctrlTask, from ctrlWorks". Never "ctrlWorks Task". |
| Endorsed lockup | "ctrlTask by ctrlWorks" — App Store page and website |
| Maker credit | "by BrendanLTW" — splash footer and Settings footer |
| Small sizes | The symbol must stay legible at 24 px. Below 48 px, use the symbol without the wordmark. |

The app icon and splash use the keycap. The Android adaptive icon is the check on `#2C3038`, inside the 66 dp safe zone, with a one-colour check for themed icons.

---

## 3. Colour

### 3.1 Core tokens

| Token | Light | Dark | Use |
|---|---|---|---|
| `ground` | `#F7F8FA` | `#0B1018` | Screen background |
| `surface` | `#FFFFFF` | `#161D29` | Cards, rows, list groups, chips, fields, sheets, dialogs, nav bar |
| `raised` | `#EEF1F6` | `#232C3A` | Icon buttons, empty-state circles, progress tracks, soft pills, pressed rows |
| `ink` | `#101828` | `#F2F4F7` | Primary text **and** primary accent (buttons, selected states, filled checkboxes, quick-add button, avatar) |
| `onInk` | `#FFFFFF` | `#0B1018` | Text and icons on `ink` fills |
| `inkPressed` | `#1D2939` | `#D0D5DD` | Pressed state of `ink` fills |
| `muted` | `#5B6B86` | `#98A2B3` | Secondary text, captions, labels, unselected segments, done task titles |
| `positive` | `#067647` | `#47CD89` | Success, "Backed up", positive changes ("▲ 17 pts") |
| `negative` | `#D92D20` | `#F97066` | Overdue dates, destructive actions, error outlines |
| `warning` | `#B54708` | `#FDB022` | Warnings |
| `hero` | `#101828` | `#1C2536` | Progress hero, insights banner, splash and welcome panels |
| `heroTrack` | `#475467` | `#344054` | Ring and bar track on the hero |

### 3.2 Neutral scale (supporting)

Reference them through tokens, never as raw hex in widgets.

| Token | Light | Dark | Use |
|---|---|---|---|
| `divider` | `#EEF1F6` | `#232C3A` | Lines between rows in a list group, timeline rails |
| `fillSoft` | `#F2F4F7` | `#232C3A` | Small chips, steppers, segmented track and rows inside sheets |
| `control` | `#D0D5DD` | `#475467` | Toggle off, radio border, unticked checkbox (Low), "today" ring in the calendar |
| `buttonDisabled` | `#D0D5DD` | `#2A3444` | Disabled primary button fill (label `#FFFFFF` / `#667085`) |
| `disabled` | `#98A2B3` | `#667085` | Past dates, placeholders, disabled text |
| `chipText` | `#344054` | `#D0D5DD` | Unselected chip label, tag chip label, text in tinted boxes |
| `navSelected` | `#EEF1F6` | `#2A3444` | Active tab pill in the bottom bar |
| `rowPressed` | `#FAFBFC` | `#1B2331` | Pressed list row |
| `scrim` | `rgba(16,24,40,.42)` | `rgba(0,0,0,.6)` | Behind sheets and dialogs |
| `destructive` | `#D92D20` | `#F04438` | Destructive button fill (label white) |

### 3.3 Message boxes

Each has a 20 px icon (alert, check or info) followed by 13/500 text.

| Box | Light background / text | Dark background / text | Used on |
|---|---|---|---|
| `errorBox` | `#FEE4E2` / `#B42318` | `rgba(240,68,56,.16)` / `#FDA29B` | S43 |
| `warningBox` | `#FEF0C7` / `#93370D` | `rgba(247,144,9,.16)` / `#FEC84B` | S39 (permission denied) |
| `successBox` | `#C9F3D5` / `#05603A` | `rgba(23,178,106,.16)` / `#75E0A7` | S42 |
| `infoBox` | `#EEF1F6` / `#344054` | `#232C3A` / `#D0D5DD` | S16, S36–S38, S42, S45, S46 |

### 3.4 Project colours

Eight colour keys, used for projects, priority, icon tiles and charts. Each has a **tile** background, an **icon** colour, and a **solid** colour for dots, rings, bars and checkbox rings. In dark mode, the tile becomes a translucent wash and the icon gets lighter.

| Key | Light tile / icon / solid | Dark tile / icon / solid |
|---|---|---|
| orange | `#FFE2B8` / `#C25E00` / `#FB8C00` | `rgba(251,140,0,.20)` / `#FFB547` / `#FFB547` |
| yellow | `#FFF0B8` / `#8A6100` / `#F5B800` | `rgba(245,184,0,.20)` / `#FFD34D` / `#FFD34D` |
| green | `#C9F3D5` / `#1E8A43` / `#17B26A` | `rgba(23,178,106,.22)` / `#5BD996` / `#47CD89` |
| blue | `#CDE6FB` / `#1769C2` / `#2196F3` | `rgba(33,150,243,.22)` / `#6CB8FF` / `#6CB8FF` |
| purple | `#E4DBF7` / `#6D3FD1` / `#7C4DDB` | `rgba(124,77,219,.26)` / `#B69BFF` / `#B69BFF` |
| pink | `#FBD3E1` / `#C8174F` / `#F0457A` | `rgba(240,69,122,.22)` / `#FF7AA2` / `#FF7AA2` |
| red | `#FEE4E2` / `#D92D20` / `#F04438` | `rgba(240,68,56,.22)` / `#FF8A80` / `#F97066` |
| grey | `#EEF1F6` / `#5B6B86` / `#98A2B3` | `#232C3A` / `#98A2B3` / `#475467` |

Sample projects on the canvas: Website redesign (blue), Q4 report (orange), Home renovation (green), Learn Flutter (purple), Japan trip (pink), Freelance (yellow). Inbox and Personal use grey.

### 3.5 Charts

| Series | Colour |
|---|---|
| Tasks completed | bars `raised`, best bar `ink` |
| Focus time | bars purple tile, best bar purple solid |
| Trend line | `ink` 3 px line, `raised` area, 5 px end dot |
| Calendar status | pending `ink`, completed green solid, overdue red solid |
| Timeline blocks | project tile with a 4 px project-solid bar; focus sessions purple |
| "Now" line | red solid, 2 px, with a 10 px dot |

### 3.6 Status pairings

| State | Colour | Required text or mark |
|---|---|---|
| Urgent | red | "Urgent" tag; red checkbox ring |
| High | orange | "High" tag; orange ring |
| Medium | blue | blue ring |
| Low | — | `control` ring |
| Done | `muted` title | Filled `ink` checkbox with a check; strikethrough |
| Overdue | `negative` | "Overdue · {day}" or "was due yesterday" |
| Days left ≤ 7 | red tag | "{n} days left" |
| Backup failed | `errorBox` | "Last night's backup failed" |

---

## 4. Typography

**Poppins** only, in weights 400, 500, 600, 700 and 800, bundled in `assets/fonts/`. All numbers use tabular figures (`FontFeature.tabularFigures()`).

| Style | Size / weight | Letter-spacing | Line height | Example |
|---|---|---|---|---|
| `timer` | 60 / 700 | −2 | 1.0 | 18:42 |
| `heroValue` | 32 / 700 | −0.8 | 1.2 | 2 of 6 done, 78% |
| `onbTitle` | 28 / 700 | −0.4 | 1.2 | What should we call you? |
| `pageTitle` | 26 / 700 | −0.3 | 1.2 | Tasks, Projects, Focus |
| `detailTitle` | 24 / 700 | −0.3 | 1.25 | Review homepage wireframes |
| `stateTitle` | 22 / 700 | 0 | 1.3 | Your day is a blank page |
| `header` | 20 / 700 | 0 | 1.3 | New task, sheet and dialog titles, Home greeting |
| `cardTitle` | 17 / 700 | 0 | 1.3 | Project card names |
| `rowTitle` | 16 / 600 | 0 | 1.35 | Call contractor about bathroom tiles |
| `body` | 15 / 400–500 | 0 | 1.5 | Supporting copy, settings rows, inputs |
| `button` | 17 / 600 | 0 | 1 | Primary button |
| `chip` | 14 / 600 | 0 | 1 | Chips, segments, pills, section links |
| `caption` | 13 / 400 | 0 | 1.45 | 10:00 AM · Website redesign |
| `message` | 13 / 500 | 0 | 1.45 | Message boxes |
| `label` | 13 / 600, uppercase | +0.7 | 1.3 | DUE TODAY |
| `labelSm` | 11–12 / 600, uppercase | +0.7 | 1.3 | Stat tile and sheet labels |
| `tag` | 12 / 600 | 0 | 1 | Priority tags, tag chips, counts |
| `statValue` | 20 / 700 | 0 | 1.25 | 12 days, 1h 15m |

The hero value shows its unit smaller and muted: "2" at 32/700 and " of 6 done" at 18 in `#98A2B3`.

---

## 5. Spacing, radius and elevation

### Spacing
| Token | Value | Use |
|---|---|---|
| `screenX` | 16 | Left/right margin for cards and rows |
| `textX` | 24 | Left/right inset for page titles, section labels and body copy |
| `cardGap` | 10–12 | Between stacked cards |
| `cardPad` | 14–22 | Inside cards |
| `rowPad` | 12–18 | Inside list rows |
| `sectionTop` | 20 | Space above a section label (10 below) |

### Radius
| Token | Value | Use |
|---|---|---|
| `r9` | 9 | 28 px icon tiles |
| `r13` | 13 | 40 px icon tiles |
| `r14` | 14 | Calendar day cells, stepper keys |
| `r16` | 16 | 48 px icon tiles |
| `r18` | 18 | Message boxes, text inputs, segment items, dialog buttons |
| `r20` | 20 | Toast, week-strip cells |
| `r22` | 22 | Primary button, title field card, Kanban cards, theme previews, alert banner |
| `r24` | 24 | Task cards, stat tiles, segmented track, status boxes |
| `r28` | 28 | List groups, project cards, dialogs |
| `r32` | 32 | Hero card, bottom-sheet top corners |
| `r36` | 36 | Onboarding illustration panel |
| `pill` | 999 | Chips, search, bottom bar, progress bars, pill buttons, tags, toggles |

### Elevation
Cards are flat. Shadows appear only on floating elements:

| Element | Light | Dark |
|---|---|---|
| Bottom bar | `0 8 28 rgba(16,24,40,.08)` | `0 8 28 rgba(0,0,0,.5)` |
| Quick-add button | `0 10 24 rgba(16,24,40,.28)` | `0 10 24 rgba(0,0,0,.5)` |
| Toast | `0 10 24 rgba(16,24,40,.25)` | same |
| Dialog | `0 24 48 rgba(16,24,40,.24)` | same, plus a scrim |
| Dragged Kanban card | `0 18 36 rgba(16,24,40,.18)`, rotated −2.5° | same |

---

## 6. Layout patterns

All screens are designed at **390 × 844**. S07 Home (1210), S11 New task (1090), S12 Task detail (1010), S21 Calendar (1000), S34 Insights (1060) and S35 Settings (1150) are drawn taller to show their full scrolled content. Leave the system status bar area alone; the designs show one only as a placeholder.

### Tab screens (Home, Tasks, Projects, Focus)
- **Header row**, 64 px: content on the left (date and greeting, or a page title) and 48 px icon buttons on the right.
- **Content** scrolls under a floating bottom bar, with a 130 px fade to `ground` behind the bar. Keep 120 px of bottom padding so the last item clears it.
- **Bottom bar**: a floating pill, 68 px high and 278 px wide, 16 px from the left and 24 px from the bottom, in `surface` with the bar shadow. Its four items are icon-only (24 px, stroke 1.7), except the active one, which expands into a `navSelected` pill (52 high, padding 0 14) showing icon and label (14/600).
- **Quick-add button**: a separate 64 px `ink` circle, 16 px from the right and 26 px from the bottom, with a 28 px plus and the button shadow. Label: "Quick add task".

### Sub-screens
- Top bar, 60 px: a three-column grid (64 / flexible / 64). Left: a 44 px back button, or **Cancel** in `muted`. Centre: the title (`header`). Right: an optional text action ("Save", "Edit", "Add", "Today") or ••• for more options.
- Page title (`pageTitle`) and supporting copy (`body`, `muted`) inset 24 px.
- Pinned primary button 34 px from the bottom; when a text link sits below it, the button moves to 96 px and the link (52 high) sits at 34 px.

### Onboarding steps
- A top bar with back, a **step indicator** (3 pills of 28 × 6, gap 6, active `ink`, others `raised`) and **Skip**.
- Title (`onbTitle`) and copy inset 24 px; the primary button pinned 34 px from the bottom, or 96 px with a link below it.

### Sheets and dialogs
- **Bottom sheet**: `surface`, top corners 32, full width, with a 40 × 5 handle. A header row (`header` title and a 44 px ✕ or a text action), then content, then a primary button inside the sheet, then 28 px bottom padding. Lists inside sheets sit on a `ground` group. Leave at least ~100 px of the screen visible above the sheet.
- **Dialog**: `surface`, radius 28, 24 px from the screen edges. A 60 px circle icon (`errorBox` colours for destructive), a `header` title, `body` `muted` copy, then actions stacked: destructive or primary first (52 high, radius 18), a neutral `fillSoft` button if there is one, then **Cancel** as a `muted` text link.

### State screens (empty, done, error)
Centred: a 96 px circle icon (`raised`, or the success and error tints), a `stateTitle`, `body` `muted` copy, one pill action, and optional suggestion chips. Inline variant: a `surface` card, radius 28, padding 26 22 22 (S09).

---

## 7. Components

| Component | Spec |
|---|---|
| **Primary button** | 58 high, radius 22, `ink` fill, `onInk` 17/600 label, optional leading 22 px icon, full width minus 32. Pressed: `inkPressed`. **Disabled**: `buttonDisabled` fill, no press, `aria-disabled`. |
| **Pill button** | 48 high (40 small), pill, padding 0 22 (0 16), `ink` fill, 15/600 (14/600). Soft variant: `raised` fill, `ink` text. |
| **Text link** | 52 high touch area, 16/600 `ink` (or `muted` / `negative`), no underline |
| **Destructive button** | 52 high, radius 18, `destructive` fill, white 16/600 |
| **Icon button** | 48 circle (44 small), `raised` fill, 22 px icon with stroke 1.8. Optional 10 px dot (`ink` for "filters on", `negative` for unread) with a 2 px `raised` ring. |
| **Avatar** | 48 circle, `ink` fill, initial 18/700 `onInk`; 56–60 on Settings, 88 on Edit name |
| **Progress hero** | `hero` fill, radius 32, padding 20 22. A 76 px ring (stroke 9, track `heroTrack`, white progress, round cap, value inside in 15/700 white), a `label` in `#D0D5DD`, the `heroValue` in white, a sub line in 14 `#EAECF0`, and an optional ↗ arrow. Tappable. |
| **Stat tile** | `surface`, radius 24, padding 14. A 28 px project-colour icon tile, `labelSm`, then `statValue` with a 12/600 `muted` unit. Three in a row, gap 10. |
| **Alert banner** | `errorBox` background, radius 22, padding 12 14 12 12. A 40 px `surface` tile with a warning icon in red, a title 15/600 and a 13 line, and a chevron. |
| **Task checkbox** | A 26 px circle with a 2 px ring in the priority colour, inside a 44 × 44 tap area. Done: `ink` fill and a 15 px `onInk` check (stroke 3). Subtask size 22. The tag picker uses a rounded-square version (radius 8). |
| **Task card** | `surface`, radius 24, 10 gap below, padding 14 16 14 14. Checkbox, then title (`rowTitle`) and a wrapping meta line (`caption`): priority tag · clock + time · project dot + name · subtask icon + "2/4" · repeat icon. |
| **Task row** | The task card's content inside a list group: no background, `divider` between rows, padding 12 18 12 16, optional trailing priority tag. |
| **Priority tag** | 24 high, pill, padding 0 10, project-colour tile background, icon-colour text (`tag`), 12 px flag |
| **Project dot** | 8 px circle in the project's solid colour |
| **Tag chip** | 24 high, pill, padding 0 10, `raised` fill, `chipText` 12/600, "#name" |
| **List group** | `surface`, radius 28, rows ≥ 56–60 high, padding 12 18, gap 14, `divider` between rows, optional 40 px icon tile, title 16/600 with a 13 `muted` sub line, trailing value (14/600 `muted`) and/or a 20 px chevron. Destructive rows use `negative`. |
| **Key–value row** | 58 high, padding 0 20, label left in `muted`, value right in 600 |
| **Icon tile** | 48 × 48 radius 16, 40 × 40 radius 13, 28 × 28 radius 9; project-colour tile and icon; icon 22/19/15 px, stroke 1.9 |
| **Project card** | `surface`, radius 28, padding 18 20. A 48 px icon tile, name (`cardTitle`), meta (`caption` `muted`), optional days-left tag; a 10 px progress bar on the project tile with the project solid; footer "{pct}% complete" and "{done} of {total} tasks". |
| **Project header** | Project tile background, radius 32, padding 20. A 48 px `surface` icon tile, name 22/700, meta and description in `chipText`, a progress bar on `surface` with the project solid, and the percentage. |
| **Title field card** | `surface`, radius 22, padding 16 18. A `labelSm`, the title input 20/600, then the description 15/1.5. |
| **Text input** | 56 high, radius 18, `surface`, 17/500. Focus: 2 px `ink` outline. Error: 2 px `negative` outline. |
| **Search** | 52 high, pill, `surface` (`ground` in sheets), 20 px search icon in `muted`, input 15/500, trailing 40 px clear button in `raised` |
| **Chip** | 40 high (36 small), pill, padding 0 16 (0 12), `surface` (small: `fillSoft`), `chipText` 14/600 (13/600). Selected: `ink` fill, `onInk` text. Can lead with a project dot or a priority flag; counts follow at 60% opacity. |
| **Segmented control** | Track `surface`, radius 24, padding 6. Segments 44 high, radius 18, 14/600 `muted`, optional 16 px icon. Selected: `ink` fill, `onInk` text. |
| **Toggle** | 52 × 32 pill; off `control`, on `ink`; 26 px thumb with a small shadow (white, or `onInk` when on in dark mode) |
| **Radio** | 24 circle with a 2 px `control` border; on: a 7 px `ink` border |
| **Stepper** | Two 44 px keys (radius 14, `fillSoft`, 20/600 "−" and "+") around the value (16/700, min width 64) |
| **Progress bar** | 10 high (thin: 6), pill, track `raised` (or a project tile), fill `ink` (or a project solid). On the hero: track `heroTrack`, fill white. |
| **Progress ring** | Size, stroke, track and progress colours, round cap, content in the centre |
| **Colour swatch** | 36 px circle in the project solid. Selected: a 3 px `surface` gap and a 2 px `ink` ring. |
| **Theme preview** | 200 high mini-mock (light, dark, half-and-half), radius 22, 1 px `control` ring; selected 3 px `ink` ring; radio and label below |
| **Toast** | Min 56 high, radius 20, `ink` fill, `onInk` 14/500, a 22 px check (`#47CD89`; `#067647` in dark mode), and an optional underlined **Undo** (14/700). Sits 106 px from the bottom, above the bar. Slides up 300 ms. |
| **Empty state** | Centred: a 96 px `raised` circle with a 40 px icon, then `stateTitle`, `body` `muted`, one pill action and optional suggestion chips |
| **Status box** | Radius 24, padding 16. A 40 px `surface` tile with an icon, a title 15/600 and a 13 line. Success, error or working (spinner on `raised`). |
| **Month calendar** | 7 columns, gap 2; weekday initials 12/600 `muted`, starting on the user's week start. Days 46 high, radius 14, number 15/500 and up to three 5 px status dots. Today: 2 px `control` ring. Selected: `ink` fill, 700. Outside the month: `muted` at 55%. Overdue days: number in `negative`. |
| **Quick date tiles** | Four in a row, 76 high, radius 20, `fillSoft`; label 13/600 and day 12/500 `muted`. Selected: `ink`. |
| **Week strip** | Seven cells 72 high, radius 20, `surface`: weekday 11/600 `muted`, day 17/700, optional 5 px dot. Selected: `ink`. |
| **Day timeline** | Hour rails 60 px apart: a 52 px column of 11/600 `muted` labels and a 1 px `divider`. Blocks positioned by time: project tile, radius 16, a 4 px project-solid bar on the left, title 14/600 and a 12 line. The red "now" line has a 10 px dot. |
| **Kanban column** | 276 wide, gap 10. Header: project dot, 15/700 name, a count pill (24 high, `raised`). Cards: `surface`, radius 22, padding 14 16. **Add task**: 48 high, radius 18, dashed 1.5 px `control` outline. |
| **Focus timer** | A 280 px ring, stroke 14, track `raised`, progress `ink` (breaks: green solid), round cap. Centre: a `labelSm` phase, the `timer` and "Session 3 of 4" in 14/500 `muted`. Controls: 56 px `surface` circles either side of an 80 px `ink` play/pause. Session dots 10 px: done `ink`, rest `raised`. |
| **Bar chart** | Equal-width bars (max 30, radius 10), value above in 11/600, day below in 12/600 `muted`. Best bar per §3.5. |
| **Bottom bar and quick-add button** | See §6 |

### Pressed states
Mobile has no hover. Use the canvas's hover colours as **pressed** colours:
- Rows go to `rowPressed`; chips and soft buttons go to `raised`.
- `ink` fills go to `inkPressed`.
- Unticked checkboxes fill with `fillSoft` while pressed.

---

## 8. Iconography

- Line icons on a 24 grid, with round caps and joins. Stroke width depends on where the icon sits:

| Where | Stroke |
|---|---|
| Bottom bar | 1.7 |
| Icon tiles | 1.9 |
| Buttons and fields | 1.8 |
| Small chips and chevrons | 2.1–2.4 |

- Nav icons: Home (house), Tasks (checklist), Projects (folder), Focus (stopwatch).
- Project icon keys: **globe, chart, home, code, plane, briefcase, bag, book, box, gift, palette, heart**.
- Utility icons: search, filter (sliders), calendar, clock, flag, tag, bell, repeat, link, subtask arrow, check, plus, close, chevrons, trash, warning, info, play, pause, reset, skip, download, cloud upload, more (•••), stats, drag handle.
- Store icons as an `AppIcon` enum mapped to bundled Lucide SVGs, so the database stores a key, never a code point from a third-party set.
- Decorative icons are excluded from semantics. Icon-only buttons always have a label: Back, Close, Search tasks, Filter and sort, Quick add task, Settings, Timer settings, Focus statistics, Clear search, Previous month, Next month, Reset timer, Finish session.

---

## 9. Motion

| Moment | Spec |
|---|---|
| Complete a task | The checkbox fills with `ink` and the check fades in; scale 0.7 → 1.18 → 1 over 350 ms (ease-out); the title strikes through; the Home ring animates over 400 ms; a light haptic; the toast slides up (300 ms) and stays 3.5 s |
| Bottom sheet | Slides up 280 ms (ease-out) over the scrim; dismiss by tapping the scrim or dragging down |
| Dialog | Fade and scale 0.96 → 1, 200 ms |
| Toggle | Thumb slides 200 ms |
| Focus ring | Advances linearly each second |
| Chips, segments, radios | Instant |
| Reduced motion | No spring, slide or scale; changes are instant |

---

## 10. Dark mode

- Every screen has a dark design (`<File>Dark`). Layout, sizes and copy are identical; only tokens change.
- `ink` flips to near-white. Primary buttons, selected chips and segments, filled checkboxes, the quick-add button, the avatar and the toast become light with dark text.
- Cards, sheets and dialogs move from white to `surface` `#161D29`. Icon buttons, tracks and pressed rows use `raised` `#232C3A`.
- The hero stays dark but lifts to `#1C2536` so it separates from the ground.
- Project tiles and message boxes become translucent washes (§3.3, §3.4); project solids get lighter where listed.
- Status colours switch to their lighter dark values for contrast.

---

## 11. Accessibility

- Text contrast is ≥ 4.5:1 against its background in both themes; 3:1 is allowed only for text ≥ 24 px. `muted` on `ground` and on `surface` passes in both themes. Don't use `disabled` for text that must be read.
- Touch targets are ≥ 44 × 44, including checkboxes, icon buttons, chips, calendar days and stepper keys.
- Rings, bars and charts expose a text label with their values, e.g. "2 of 6 tasks done today", "Tasks completed: Wednesday 3, Thursday 6, …".
- Checkboxes read "Complete: {title}" or "Mark not done: {title}". Toggles, radios, chips and segments expose their selected state.
- The timer announces phase changes ("Focusing", "Paused", "Session complete"), not every second.
- Disabled buttons expose `aria-disabled` and keep a visible hint explaining why.
- Text scales to 200% without clipping. Rows grow taller and chips wrap rather than truncating.
- Colour is never the only signal (§3.6).

---

## 12. Flutter implementation

```
lib/core/theme/
  app_colors.dart        # AppColors ThemeExtension: every token in §3.1–3.3, light() and dark()
  project_palette.dart   # ProjectColors: tile + icon + solid per colour key, light and dark
  app_typography.dart    # TextStyles in §4, with tabular figures
  app_spacing.dart       # Spacing tokens in §5
  app_radius.dart        # Radius tokens in §5
  app_shadows.dart       # The shadows in §5
  app_motion.dart        # Durations and curves in §9
  app_theme.dart         # buildLightTheme() / buildDarkTheme(): ThemeData + extensions
```

- Map the core tokens onto `ColorScheme`: `surface`, `onSurface` = `ink`, `primary` = `ink`, `onPrimary` = `onInk`, `error` = `negative`. Keep the rest in `AppColors`.
- Widgets read colours with `context.colors.muted`, project colours with `context.projectColors[key]` and text with `context.text.rowTitle`, never `Color(0xFF…)` or a raw font size.
- `ThemeMode` comes from the Theme preference (Light, Dark, System).
- Widget tests render each screen under both `buildLightTheme()` and `buildDarkTheme()`.

### Shared widgets (`lib/core/widgets/`)

| Widget | Used on |
|---|---|
| `AppShell` (bottom bar + quick-add button) | S07–S09, S19–S22, S26, S29, S30, S32, S33 |
| `ProgressHero`, `ProgressRing` | S07–S09, S34, S35 |
| `StatTile` | S07, S34 |
| `AlertBanner` | S07 |
| `TaskCheckbox`, `TaskCard`, `TaskRow`, `PriorityTag`, `ProjectDot`, `TagChip` | S07–S09, S11, S12, S19, S21, S24, S27 |
| `CompleteToast` (with Undo) | S07, S12, S19, S27 |
| `ProjectCard`, `ProjectHeader`, `IconTile` | S26, S27, S45 |
| `ListGroup`, `ListGroupRow`, `KeyValueRow` | S06, S11, S12, S35–S46 |
| `AppProgressBar` | S12, S26, S27 |
| `SegmentedControl` | S19–S21, S26, S30, S34, S41 |
| `AppChip`, `FilterChips`, `SearchField` | S04, S05, S10, S17–S19, S23–S25 |
| `AppToggle`, `AppRadio`, `AppStepper` | S05, S15, S16, S23, S31, S36–S39, S41, S42 |
| `AppTextInput`, `TitleFieldCard` | S03, S04, S11, S28, S40 |
| `StepIndicator`, `OnboardingScaffold` | S03–S05 |
| `AppSheet`, `AppDialog` | S10, S13–S18, S23, S31, S44 |
| `MessageBox`, `StatusBox` | S16, S36–S39, S42, S43, S45, S46 |
| `EmptyState`, `StateCard` | S08, S09, S25, S29 |
| `MonthCalendar`, `QuickDateTiles` | S14, S21 |
| `WeekStrip`, `DayTimeline` | S22 |
| `KanbanColumn` | S20 |
| `FocusTimer`, `SessionDots` | S30, S32, S33 |
| `BarChart`, `TrendLine` | S34 |
| `ColorSwatchRow`, `IconPickerGrid`, `ThemePreviewCard` | S28, S36 |
| `BrandMark`, `Wordmark` | S01, S02, S35 |

---

## 13. Fidelity checklist

Before a screen task is marked done, compare it with both exports and check:

- [ ] Colours, type styles, radii and spacing come from tokens only.
- [ ] Layout matches at 390 × 844 in light and dark.
- [ ] Copy matches the design exactly (strings in ARB).
- [ ] Every priority and status colour has text or a mark beside it.
- [ ] Touch targets ≥ 44 px; icon-only buttons labelled.
- [ ] Rings, charts and progress bars have screen-reader labels with values.
- [ ] Completion motion, toast and Undo match §9.
- [ ] Disabled, empty and error states match their designs (S08, S09, S25, S29, S43).
- [ ] Layout holds at 200% text scale.
