# ctrlTask — Product Requirements Document

| | |
|---|---|
| Product | **ctrlTask** (package `ctrl_task`), from ctrlWorks |
| Type | Offline-first personal task and focus app (Flutter, iOS and Android) |
| Purpose | Portfolio project |
| UI source of truth | The "CtrlTask UI" design canvas (https://claude.ai/artifact/VetuLy5Er3H4VsYZLMwURj), which has: 46 light screens, a dark version of each, and a design-system board. Export the screens to `docs/design/`. |
| Related | `CLAUDE.md` (conventions), `docs/PLAN.md` (tasks), `docs/DESIGN.md` (tokens and components) |
| Last updated | 19 Nov 2026: first version, written from the canvas |

This PRD follows the design canvas. Where this file and a screen disagree, the screen wins and this file is updated.

---

## 1. Overview

ctrlTask answers one question first: **what do I need to get done today?** The user captures tasks in seconds, groups them into projects, and the home screen shows today's list, what's overdue and how far through the day they are. A Pomodoro timer keeps them on one task at a time. Everything stays on the phone: there's no account and no sign-in.

**Promise (splash and onboarding):** "Get today done, one tap at a time."

**Problem.** Task apps tend to be either heavy (team tools, dashboards, setup before the first task) or bare lists that don't help decide what matters today. People stop using both within weeks. Most also want an account before you can write anything down.

**Approach.**
- **Today first:** the home screen leads with today's progress and today's list.
- **Five-second capture:** tap +, type a title, send. Date, priority and project are one tap each and all optional.
- **Satisfying completion:** every tick animates, gives a light haptic and can be undone.
- **Focus built in:** start a Pomodoro session from any task.
- **Private by design:** data stays on the device, with export and backup whenever the user likes.

---

## 2. Goals and non-goals

### Product goals
- Add a task in **≤ 5 seconds** from any tab.
- Home answers "what's due today and how am I doing?" **without scrolling** on a 390 × 844 screen.
- Onboarding to a first task in **under 1 minute**.
- Work **fully offline**, with no account.

### Portfolio goals
- Feature-first Flutter architecture with enforced layer boundaries.
- Unit, widget and end-to-end tests, with CI on every push.
- Light and dark themes built from one token set, shared with ctrlSpend.
- A live demo, an APK, and a README explaining key decisions.

### Non-goals (v1)
- Accounts, cloud sync or multi-device use. Export and local backup are the safety net.
- Sharing, assigning or commenting on tasks. ctrlTask is for one person.
- A separate habit tracker. Repeating tasks and the streak cover the need.
- Calendar, email or chat integrations.
- Tablet, web, desktop and watch layouts (a web build is for the demo only).
- Natural-language parsing beyond the simple hints in v1.1.
- The other ctrlWorks apps (ctrlSpend, ctrlGo, ctrlStock).

---

## 3. Target users

| Persona | Context | Needs |
|---|---|---|
| **Alex**, 29, office job plus freelance work | 5–6 projects at once: work, a side gig, a flat renovation, learning Flutter, a trip | One clear list for today, fast capture between meetings, a way to protect focus time |
| **Nadia**, 24, postgraduate student | Coursework deadlines, a part-time job, errands | Deadlines that don't sneak up, reminders, a calendar view |
| **Wei Ming**, 35, freelancer | Client tasks with due dates, invoices, admin | Overdue warnings, priorities, a weekly sense of progress |

The design uses **Alex** as the sample user.

---

## 4. Information architecture

### Navigation
- **Bottom bar:** four tabs (**Home · Tasks · Projects · Focus**) in a floating pill, and a separate round **quick-add button** on the right. The quick-add button opens Quick add (S10) from any tab.
- **Home header:** on the left, the date and "Good morning, {name}". On the right, a **search** button (→ S24) and an **avatar** that opens **Settings** (S35).
- Sub-screens open with a back button. Create and edit screens open as full screens with Cancel / Save, or as sheets with a close (✕) button.
- The Tasks tab has a **List · Calendar · Board** segmented control.

### Screen inventory

| ID | Screen (canvas title) | File | Opened from |
|---|---|---|---|
| **Onboarding** | | | |
| S01 | Splash | `Splash` | App launch |
| S02 | Onboarding 1 · Welcome | `OnbWelcome` | First launch |
| S03 | Onboarding 2 · Your name (step 1 of 3) | `OnbName` | Welcome → Get started |
| S04 | Onboarding 3 · First task (step 2 of 3) | `OnbFirstTask` | Continue |
| S05 | Onboarding 4 · Reminders (step 3 of 3) | `OnbReminders` | Add task / I'll do it later |
| S06 | Onboarding 5 · All set | `OnbDone` | Allow notifications / Not now |
| **Today and tasks** | | | |
| S07 | Home · Today | `Main` | Home tab |
| S08 | Home · First run (empty) | `HomeEmpty` | Home tab with no tasks |
| S09 | Home · All done for today | `HomeAllDone` | Home tab when every task for today is done |
| S10 | Sheet · Quick add | `QuickAdd` | Quick-add button; S08 |
| S11 | New task · Advanced fields | `TaskNew` | More on S10; Edit on S12 |
| S12 | Task detail · Subtasks & notes | `TaskDetail` | Any task row |
| S13 | Dialog · Delete task | `TaskDelete` | Delete task on S12; swipe on S19 |
| S14 | Picker · Date, time & quick reschedule | `Reschedule` | Due fields on S10, S11, S12; Reschedule on S19 |
| S15 | Sheet · Repeat | `PickRepeat` | Repeat on S10, S11, S12 |
| S16 | Sheet · Reminder | `PickReminder` | Reminder on S10, S11, S12 |
| S17 | Sheet · Move to project | `PickProject` | Project on S10, S11, S12 |
| S18 | Sheet · Tags | `PickTags` | Tags on S10, S11 |
| **Tasks tab** | | | |
| S19 | Tasks · List view | `Tasks` | Tasks tab |
| S20 | Tasks · Board (Kanban) | `TasksBoard` | Board segment |
| S21 | Calendar · Month | `Calendar` | Calendar segment |
| S22 | Calendar · Week & day agenda | `CalendarWeek` | Day/Week on S21; Plan tomorrow on S09 |
| S23 | Sheet · Filter & sort | `FilterSort` | Filter button on S19 |
| S24 | Search · Results | `Search` | Search on S07 and S19 |
| S25 | Empty · No search results | `SearchEmpty` | S24 with no matches |
| **Projects** | | | |
| S26 | Projects | `Projects` | Projects tab |
| S27 | Project detail | `ProjectDetail` | A project card |
| S28 | New project | `ProjectNew` | New on S26; New project on S17 |
| S29 | Empty · No projects yet | `ProjectsEmpty` | Projects tab with no projects |
| **Focus** | | | |
| S30 | Focus · Pomodoro | `Focus` | Focus tab; Start a focus session on S12 |
| S31 | Sheet · Focus durations | `FocusSettings` | Settings icon on S30; Default focus length on S35 |
| S32 | Focus · Session complete | `FocusDone` | When a focus session ends |
| S33 | Focus · Short break | `FocusBreak` | Start break on S32 |
| **Insights and settings** | | | |
| S34 | Productivity insights | `Insights` | Insights banner on S35; stats icon on S30 |
| S35 | Settings (full scroll) | `Profile` | Avatar on S07 |
| S36 | Settings · Theme | `SetTheme` | Settings → Theme |
| S37 | Settings · Week starts on | `SetWeekStart` | Settings → Week starts on |
| S38 | Settings · Default priority | `SetPriority` | Settings → Default priority |
| S39 | Settings · Notifications | `SetNotif` | Settings → Notifications |
| S40 | Settings · Edit name | `EditName` | Name card on S35 |
| S41 | Settings · Export data | `Export` | Settings → Export data; Export a copy first on S44 |
| S42 | Settings · Backup & restore | `Backup` | Settings → Backup & restore |
| S43 | Error · Backup failed | `BackupFailed` | S42 when the last backup failed |
| S44 | Dialog · Erase all data | `EraseData` | Settings → Erase all data |
| S45 | Settings · Archived projects | `Archived` | Settings → Archived projects; Archived on S26 |
| S46 | Settings · Tags | `Tags` | Settings → Tags |

Every screen also has a **Dark** variant on the canvas (`<File>Dark`), which shows the same layout with dark tokens. S07 (1210 px), S11 (1090 px), S12 (1010 px), S21 (1000 px), S34 (1060 px) and S35 (1150 px) are taller boards because they show the full scrolled content.

---

## 5. Screen requirements

### 5.1 Onboarding (S01–S06)

**S01 Splash.** Shows:
- the ctrlTask logo (charcoal keycap with an orange check)
- the wordmark and the line "Get today done."
- an orange loading bar
- the footer **"by BrendanLTW"**

Tapping continues.

**S02 Welcome.** Shows:
- an illustration of a day in progress: a done task, a "Focus 25:00" chip, a 4-of-6 progress ring and an urgent task card
- the headline "Get today done, one tap at a time."
- the subtext "Capture tasks in seconds, focus on what matters and watch your day fill up."
- a **Get started** button
- a **Skip setup** link, which goes straight to S07

**S03 What should we call you? (1 of 3).** Shows:
- back button, step indicator and **Skip**
- the subtext "It's only used for your greeting and stays on this phone."
- a name field with the keyboard open
- the help text "You can change this any time in Settings."
- **Continue**

Rules:
- The name is used in the Home greeting and the Settings name card.
- Continue is disabled until the field has at least one non-space character. The value is trimmed and limited to 30 characters.
- Skipping leaves the name empty; the greeting then reads "Good morning" with no name.

**S04 What's one thing to get done today? (2 of 3).** Shows:
- a task title field
- **Or pick one** suggestion chips: Plan my week, Clear my inbox, 30-minute walk, Call mum (tapping one fills the field)
- **When** chips: Today (default), Tomorrow, No date
- **Add task** and **I'll do it later**

The task is created with the user's default priority (Medium) and no project.

**S05 Want a nudge? (3 of 3).** Shows three toggles:
- **Task reminders:** at the time set on each task
- **Daily plan:** a short list of what's due today
- **Overdue nudges:** once a day, if something slips

and **Daily plan at** time chips (7:00, 8:00 default, 9:00, 10:00). **Allow notifications** requests OS permission. **Not now** continues without it. The choices are saved either way, and S39 shows how to turn notifications on if permission is denied.

**S06 You're all set.** "Your first task is on today's list. Tick it off to start your streak." A setup summary: name, first task, daily plan time, week start. **Go to Today** goes to S07 and **Create a project first** goes to S28.

Acceptance:
- [ ] Onboarding runs once. Afterwards the app opens on S07.
- [ ] Every value chosen in onboarding appears in Settings and can be changed later: name (S40), notifications (S39), week start (S37).
- [ ] Back works on every step without losing entered values.

### 5.2 Home (S07–S09)

From top to bottom:
- **Header:** date ("Tue, 17 November"), greeting by time of day ("Good morning / afternoon / evening, Alex"), search button, avatar → Settings.
- **Progress hero** (dark navy card): a ring with the percentage, "Today's progress", "{done} of {total} done" and a line with what's left ("4 left · next: Review wireframes, 10:00"). Tapping opens S19.
- **Stat tiles:** **Streak** ("12 days"), **Focused** today ("1h 15m"), **This week** ("18 done").
- **Overdue banner** (only when something is overdue): "{n} overdue task(s)" and the most urgent one ("Send invoice to Lumen Studio · was due yesterday"). Tapping opens that task (or S19 filtered to overdue when there are several).
- **Due today:** task cards (§6.1) with checkbox, title and meta. **All tasks** → S19.
- **Upcoming deadlines:** the next three dated tasks or project deadlines after today, with a priority tag or "{n} days". **Calendar** → S22.

**S08 First run:** the hero reads "Nothing planned" with "Your ring fills as you tick things off", then the empty state "Your day is a blank page — Add the first thing you want to get done today. A title is all you need.", **Add a task** (→ S10), and suggestion chips (Plan my week, Clear my inbox, 30-minute walk, Create a project).

**S09 All done:** the ring is full with a check, the hero reads "{n} of {n} done · All clear. Enjoy your evening.", and a celebration card shows "Day done. Nice work.", the day's tasks and focus totals, the new streak, and **Plan tomorrow** (→ S22). Below it, **Tomorrow · {date}** lists tomorrow's tasks.

Acceptance:
- [ ] Completing a task updates the ring, the counts and the streak immediately (§6.1).
- [ ] The overdue banner hides when nothing is overdue.
- [ ] S09 shows when every task due today is done and at least one exists; S08 shows when there are no tasks at all.
- [ ] The ring's screen-reader label reads "{done} of {total} tasks done today".

### 5.3 Quick add (S10)

A bottom sheet, top to bottom:
1. **New task** title and ✕ close.
2. A title field (keyboard open) and a round **send** button.
3. A hint line showing anything detected in the title (v1.1, §6.8).
4. **When** chips: No date, Today, Tomorrow · 9 AM, the coming Saturday, and a calendar button (→ S14).
5. **Priority** chips: Urgent, High, Medium, Low, each with its flag colour. Default: the user's default priority.
6. A row with the **project** chip (dot, name and chevron → S17; default Inbox), and **tag** (→ S18), **reminder** (→ S16) and **repeat** (→ S15) buttons. **More ›** opens S11 with everything typed so far.

Rules:
- Only the title is required. Send is disabled while it's empty. The title is trimmed and limited to 120 characters.
- Sending creates the task, closes the sheet and shows it in the right list immediately.
- Opened from a project (S27), the project chip starts on that project. Opened from a calendar day (S21, S22), the date starts on that day.

Acceptance:
- [ ] From tapping + to the task appearing takes under 5 seconds for a title-only task.
- [ ] The sheet opens with the keyboard up and focus in the title field.

### 5.4 Task form, detail and delete (S11–S13)

**S11 New task / Edit task.** Cancel, title ("New task" or "Edit task") and **Save**.
- **Title and description** card. Title up to 120 characters; description up to 1,000.
- **Essentials:** Due (→ S14), Priority (four chips inline), Project (→ S17).
- **More details · optional:** Tags (chips and **+ Tag** → S18), Reminder (→ S16), Repeat (→ S15).
- **Subtasks · {done}/{total}:** each with its own checkbox, and **Add subtask**. Up to 50 per task.
- **Notes & links:** saved links (title and URL) and **Add a note or link**.

**S12 Task detail.**
- a large checkbox and the title
- chips: priority tag, project (→ S17), tags
- the description
- **Due {date · time}** with quick chips: **Today**, **Tomorrow**, **Next week**, **Pick** (→ S14)
- details: Reminder (→ S16), Repeat (→ S15), links (open in the browser)
- **Subtasks · {done}/{total}** with a thin progress bar and the percentage
- **Start a focus session** (→ S30 with this task linked) and **Delete task** (→ S13)
- **Edit** in the header (→ S11)

Completing the task here shows the toast "Task completed. Moved to Done." with **Undo**.

**S13 Delete task dialog:** "Delete this task? “{title}” and its {n} subtasks will be removed from {project}. This can't be undone." **Delete task** (destructive), **Mark as done instead**, **Cancel**.

Acceptance:
- [ ] Edit opens S11 with every field prefilled.
- [ ] Quick chips on S12 change the due date in one tap and keep the time.
- [ ] Deleting removes the task's subtasks, tags links and links, cancels its reminder and returns to the previous screen.

### 5.5 Pickers (S14–S18)

**S14 Due date (sheet):**
- quick tiles: **Today**, **Tomorrow**, **Weekend** (Saturday), **Next week** (Monday, or the user's week start)
- a month calendar (week starts on the user's setting; today ringed; past days allowed but muted)
- time chips: 9:00 AM, 12:00 PM, 3:00 PM, 6:00 PM, and **no time**
- a button that reads back the choice: "Set Thu, 19 Nov · 3:00 PM"

**S15 Repeat (sheet):** Never, Every day, Weekdays (Mon–Fri), Every week (shows seven day toggles), Every month on the {day}, Custom (every N days, weeks or months, N 1–12). An **Ends** row (never, or a date via S14). The button reads back the rule ("Repeat every Mon, Thu"). Every week needs at least one day.

**S16 Reminder (sheet):** a note "Due {date · time}. You'll be reminded {when}." and options: No reminder, At due time, 10 minutes before, 30 minutes before, 1 hour before, Morning of (9:00 AM), Day before. Each shows the resulting time. Options that need a time are disabled when the task has no due time, except Morning of and Day before.

**S17 Move to project (sheet):** a search field, **Inbox** (no project), every active project with its colour tile and open count, a check on the current one, and **New project** (→ S28). Choosing closes the sheet.

**S18 Tags (sheet):** a search-or-create field, the selected tags as chips (tap to remove), a checklist of tags with usage counts, **Create tag “#{text}”** when the text matches nothing, and **Save {n} tags**. Tag names are lowercase, without "#", up to 24 characters, unique.

Acceptance:
- [ ] Every picker returns its value to the screen that opened it without losing other unsaved fields.
- [ ] Changing the due date or time moves the reminder with it.

### 5.6 Tasks tab (S19–S25)

**S19 List.**
- title **Tasks**, search (→ S24), filter (→ S23; a dot shows when filters are on)
- **List · Calendar · Board** segmented control
- filter chips with counts: **All**, **Today**, **Upcoming**, **High priority**, **Done**
- sections: **Overdue** (red label), **Today · {date}** ("4 of 6 left"), **Tomorrow**, **This week**, **Later**, **No date**
- flat task rows (§6.1), with a priority tag for Urgent and High
- swipe right completes; swipe left reveals **Reschedule** (→ S14) and **Delete** (→ S13)

**S20 Board.** A project selector chip and "Grouped by status". Three columns: **To do**, **In progress**, **Done**, each with a count. Cards show title, priority tag, due date, tags and a subtask bar. Long-press drags a card to another column. **Add task** at the bottom of each column. Moving a card to Done completes the task; moving it out of Done reopens it.

**S21 Calendar · Month.**
- **Day · Week · Month** chips (Day and Week → S22)
- month name with previous and next
- the month grid (§6.2) with up to three dots per day: **Pending**, **Completed**, **Overdue**; overdue days show their number in red
- the legend and the hint "Hold & drag to move"
- the selected day's agenda below ("Tue, 17 Nov · Today", "{n} tasks", or "Nothing due. Tap + to plan this day")

**S22 Calendar · Week.** Header "16 – 22 Nov" with back and **Today**, the Day/Week/Month chips, counts ("5 due · 1 overdue"), a week strip with dots, **Anytime** chips for tasks without a time, and a day timeline with hour rails, task blocks in their project colour, focus sessions as purple blocks, and a red "now" line.

**S23 Filter & sort (sheet):** **Sort by** Due date (default), Priority, Project, Date added. **Priority** chips (multi-select). **Projects** chips (multi-select). **Show completed tasks** toggle. **Reset** and **Show {n} tasks**.

**S24 Search:** a pill field with **Cancel**, type chips (**All**, **Tasks**, **Projects**, **Done**) with counts, **Tasks** results with the match highlighted, **Projects** results (name, description or notes), and **Recent searches** with **Clear**.

**S25 No results:** "No matches for “{query}” — Nothing in your tasks, projects or tags. Check the spelling or try a shorter word." A **Did you mean {word}?** chip when a close match exists, and **Create task “{query}”** (→ S10 prefilled).

Acceptance:
- [ ] Chip counts and sections update live as tasks change.
- [ ] Filters from S23 and the chips combine; Reset clears S23 only.
- [ ] Search is case-insensitive over task titles, descriptions, subtask titles, tags and project names.
- [ ] Swipe-complete shows the same toast and Undo as the checkbox.
- [ ] Dropping a task on a calendar day (S21) changes its date and keeps its time (v1.1).

### 5.7 Projects (S26–S29, S45)

**S26 Projects:** title, **New** (→ S28), **Active · {n}** / **Archived · {n}** segments, and project cards (§DESIGN 7): colour tile, name, deadline ("Due Mon, 30 Nov" / "No deadline"), a days-left tag (red when 7 days or fewer), a progress bar, "{pct}% complete" and "{done} of {total} tasks". The Archived segment shows S45's list.

**S27 Project detail:**
- a header card in the project's colour: icon, name, deadline and days left, description, progress bar with %, "{done} of {total} tasks done · {focus} focused"
- **Open · {n}** with flat task rows and **Add task to {project}** (→ S10 with the project set)
- **Board view** link (→ S20 filtered to the project)
- **Completed** row with the count
- ••• → S28 in edit mode, which also has **Archive project** and **Delete project**

**S28 New project / Edit project:** a live preview tile, **Name** (required, up to 40 characters, unique among active projects) and description (up to 300), **Colour** (8 swatches), **Icon** (bag, globe, home, code, plane, book, plus chart, briefcase, box, gift, palette, heart in the full set), **Deadline** (optional, → S14), and **Create project** / **Save**.

**S29 Empty:** "Group tasks into projects — A project keeps related tasks together, tracks progress and holds a deadline. Your {n} inbox tasks stay where they are." **Create a project**, and starter chips Work, Home, Learning, Travel (prefill S28).

**S45 Archived projects:** archived project cards with "{n} tasks · finished {date}" and **Restore**; the toast "{project} is active again"; the note "Archived projects keep their tasks and stats. Restore one to move it back to Projects."

Rules:
- Archiving hides a project and its open tasks from lists, pickers and Home. Its tasks and focus time still count in Insights.
- Deleting a project asks whether to **move its tasks to Inbox** (default) or **delete them too**.

Acceptance:
- [ ] Progress and counts update live.
- [ ] Restoring brings back the project and its open tasks exactly as they were.

### 5.8 Focus (S30–S33)

**S30 Focus:**
- title **Focus**, stats (→ S34) and timer settings (→ S31)
- mode segments: **Focus · {n}**, **Short · {n}**, **Long · {n}**
- **Working on** card with the linked task and **Change** (opens a task picker; "No task" allowed)
- the timer ring with the phase ("Focusing", "Paused", "On a break"), the time and "Session {k} of {n}"
- controls: **Reset**, **Play/Pause** (labelled Start, Pause or Resume), **Finish session** (→ S32)
- session dots and "Today {time} focused · long break after session {n}"

**S31 Timer settings (sheet):** steppers for **Focus** (10–90 min, step 5, default 25), **Short break** (1–15, default 5), **Long break** (10–45, step 5, default 15), **Sessions per round** (2–8, default 4); toggles **Start breaks automatically**, **Start next session automatically**, **Silence notifications while focusing**; **Save as default**.

**S32 Session complete:** a full ring with a check, "Session complete", "{minutes} min on {task}", session dots, "Today {time} focused", and actions **Start {n}-min break** (→ S33), **Skip break**, **Mark task done**.

**S33 Short break:** the Short segment selected, a tip card ("Stand up, refill your water and look at something far away."), a green ring counting down with "Next: session {k} of {n}", and controls to pause, restart, or end the break and start focusing.

Acceptance:
- [ ] The timer keeps the right time when the app is in the background or killed (§6.6).
- [ ] When a session ends, the phone gets a notification if the app isn't open.
- [ ] A session counts toward focus time only if it ran at least 1 minute.
- [ ] The timer's screen reader announces phase changes, not every second.

### 5.9 Insights (S34)

- back, title **Insights**, **Last 7 days · This month** segments
- a hero with the **completion rate** ring and the change against the previous equal range ("+6 pts vs previous 7 days")
- stat tiles: **Completed**, **Streak**, **Focus**
- **Tasks completed** bar chart with the best day highlighted and "Best: Thu, 6"
- **Focus time** bar chart in purple with the daily average
- **6-week trend** of the completion rate with the change in points
- a **power day** card: "{Weekday} is your power day — You finish {avg} tasks on average, mostly before noon."

Acceptance:
- [ ] All values are computed from data (§8 Derived values).
- [ ] Every chart has a text alternative listing its values.
- [ ] With fewer than 3 days of history, charts show "Not enough data yet" and the stat tiles still show.

### 5.10 Settings (S35–S46)

**S35 Settings:**
- **Name card** ("Alex · Data stored on this phone · Edit name") → S40
- **Productivity insights** banner ("12-day streak · 342 tasks done") → S34
- **Preferences:** Theme (→ S36), Week starts on (→ S37), Default priority (→ S38), Default focus length (→ S31), Notifications ("3 on" → S39)
- **Manage:** Archived projects (count → S45), Tags (count → S46), Export data (→ S41), Backup & restore ("Last backup today, 2:14 AM" → S42)
- **Data:** **Erase all data** (→ S44), in red
- Footer: "ctrlTask {version} · by BrendanLTW"

**S36 Theme:** three preview cards **Light · Dark · System** with radios. "System follows your phone's setting and switches automatically at night."

**S37 Week starts on:** Monday (default; "Common in Malaysia and Europe"), Sunday ("Common in the US"), Saturday. Note: "Changes the calendar grid, “This week” in Tasks and your weekly insights."

**S38 Default priority:** Urgent, High, Medium (default), Low, each with its flag and description. Note: "New tasks start at this priority. You can change it in quick add with one tap."

**S39 Notifications:**
- toggles: **Task reminders**, **Daily plan**, **Overdue nudges** (6:00 PM), **Focus session end** (soft bell), **Weekly review** (Sunday 8:00 PM)
- **Timing:** Daily plan at (default 8:00 AM), Default task reminder (default 30 min before), Quiet hours (default 11 PM – 7 AM)
- when OS permission is denied, a warning box reads "Notifications are off for ctrlTask" with **Open phone settings**; the toggles still save the user's choices

**S40 Edit name:** Cancel, **Edit name**, Save; a large avatar, the name field (same rules as S03), and "Shown in your greeting on Home. It stays on this phone and is never uploaded."

**S41 Export data:**
- **Format:** **CSV · JSON**
- **Range:** **All time** (default), **This year**, **Custom range** (From and To via S14)
- **Include** toggles: Completed tasks (on), Archived projects (off), Focus sessions (on)
- a totals line ("342 tasks · 8 projects · 96 focus sessions")
- **Export {format} · {size}** saves `ctrltask-YYYY-MM-DD.{csv|json}` through the share sheet; formats in §6.7

**S42 Backup & restore:**
- a status box: "Backed up today, 2:14 AM · 342 tasks · 8 projects · 1.2 MB"
- **Automatic backup** ("Every night while charging"), **Save backups to** (a folder the user picks), **Keep** (last 7 backups)
- the note "Backups stay on your phone or in the folder you choose. ctrlTask has no account and no server."
- **Back up now** and **Restore from a backup**

**S43 Backup failed:** an error box ("Last night's backup failed — Not enough space in Files. Free up 1.2 MB or choose another folder. Last good backup: Sun, 15 Nov."), **Try again** (spinner, then success) and **Choose another folder**.

**S44 Erase all data:** a dialog: "This deletes {n} tasks, {m} projects and all focus history from this phone. It can't be undone." **Erase everything** (destructive), **Export a copy first** (→ S41), **Cancel**. Erasing also cancels every scheduled notification and restarts at S01.

**S46 Tags:** **Add** in the header, a search field ("Search {n} tags"), **Most used** with task counts (each opens S24 filtered to the tag), and the note "Type # in quick add to tag a task. Tap a tag here to rename, merge or delete it." Renaming to an existing name merges the two.

Acceptance:
- [ ] Every setting takes effect immediately and survives a restart.
- [ ] Changing the week start updates the calendar, "This week" and weekly insights at once.
- [ ] Restore validates the whole file before replacing anything, and asks for confirmation first ("Replace everything on this phone with the backup from {date}?").
- [ ] Backups are written to a temporary file and renamed when complete, so a failed backup never leaves a half-written file.

---

## 6. Shared behaviour

### 6.1 Task rows and completion
- **Task card** (Home) and **task row** (lists) show: checkbox, title, and a meta line with priority tag (Urgent and High only, hidden when done), time, project dot and name, subtask count ("2/4") and a repeat icon. Overdue dates read "Overdue · {day}" in red.
- The checkbox ring takes the priority colour (§6.3). Its tap area is 44 × 44.
- Completing a task:
  - fills the checkbox with a short spring (350 ms) and a light haptic
  - strikes through the title and moves the task to the bottom of today's list
  - updates the ring, counts and streak
  - shows the toast "Nice. “{title}” is done" with **Undo** for **3.5 seconds**
- Undo restores the task exactly, including the streak and any repeat occurrence it created.
- Completing a parent doesn't tick its subtasks; ticking every subtask doesn't complete the parent.

### 6.2 Days and weeks
- "Today" is the device's local calendar day. Due dates are stored as local dates, with an optional local time (minutes after midnight).
- The week starts on the user's setting (Monday by default). One pure function, `weekOf(date, weekStart)`, is used everywhere.
- **Sections** (S19): Overdue, Today, Tomorrow, This week (rest of the current week), Later, No date.
- Dates read "Tue, 17 Nov"; times "10:00 AM"; relative labels where they help: "Today, 10:00", "Yesterday", "13 days left".

### 6.3 Priority and status
| Priority | Colour | Checkbox ring | Text tag on rows |
|---|---|---|---|
| Urgent | red | red | "Urgent" |
| High | orange | orange | "High" |
| Medium | blue | blue | none |
| Low | grey | grey | none |

- **Overdue:** an open task whose due date (and time, if set) is before now.
- Colour is always paired with text: a tag, "Overdue · Mon", a strikethrough, or a label in the legend.

### 6.4 Repeat
- Rules: daily, weekdays (Mon–Fri), weekly on chosen days, monthly on a day (29–31 fall back to the month's last day), custom every N days, weeks or months (N 1–12); optional end date.
- Completing a repeating task keeps it as done and creates the next occurrence from its **due date**, not the completion date. The next occurrence keeps the title, description, priority, project, tags, reminder and subtasks (unticked).
- If the next occurrence would be after the end date, none is created.
- A repeating task with no due date uses today as its first due date.

### 6.5 Reminders
- A reminder fires at the due date and time minus the offset. **Morning of** = 9:00 AM on the due date; **Day before** = the due time on the previous day (9:00 AM if there's no time).
- Reminders inside quiet hours are delayed to the end of quiet hours.
- Reminders are rescheduled whenever the task changes and cancelled when it's completed, archived or deleted.
- **Daily plan**, **Overdue nudges** and **Weekly review** are scheduled notifications with their own toggles (S39).
- All notifications are generated and scheduled on the device. Nothing is sent to a server.

### 6.6 Focus timer
- A session stores its start time and planned length; the remaining time is always computed from the clock, so it survives backgrounding, locking and app restarts.
- When a session ends, a local notification fires (with the soft bell if "Focus session end" is on), and the session is saved.
- After **Sessions per round** focus sessions, the next break is a long break.
- **Start breaks automatically** and **Start next session automatically** chain the phases without a tap.
- **Silence notifications while focusing** delays task reminders until the session ends.

### 6.7 Export and backup formats
- **CSV** (tasks only): UTF-8, comma-separated, header row. Columns in order: `title`, `status` (`open` / `done`), `priority`, `due_date` (YYYY-MM-DD), `due_time` (HH:MM), `project`, `tags` (separated by `;`), `repeat` (readable rule), `created_at`, `completed_at`, `description`.
- **JSON** (and backups): every table, with a `schemaVersion` and an `exportedAt`, so a backup restores exactly.
- Backups are named `ctrltask-backup-YYYY-MM-DD-HHmm.json`. Only the newest **Keep** backups are kept.

### 6.8 Quick-add hints (v1.1)
Detected in the title and shown under it before sending: `today`, `tomorrow`, weekday names, times like `9am` or `14:30`, `!urgent` / `!high` / `!low`, `#tag`, `@project`. Detected text is removed from the title when the task is saved.

---

## 7. Requirements and priorities

Priorities:
- **P0** = core app
- **P1** = complete experience
- **P2** = extended features, shipped in a later update (**v1.1**), not in v1.0

| ID | Requirement | Screens | Priority |
|---|---|---|---|
| FR-01 | Onboarding: name, first task, reminder choices | S01–S06 | P0 |
| FR-02 | Home with progress ring, stat tiles, overdue banner, due today, upcoming | S07–S09 | P0 |
| FR-03 | Quick add with when, priority and project | S10 | P0 |
| FR-04 | Create, edit, complete, undo and delete tasks with subtasks | S11–S13 | P0 |
| FR-05 | Due date and time picker with quick reschedule | S12, S14 | P0 |
| FR-06 | Projects: create, edit, detail, progress, move tasks, archive and restore | S17, S26–S29, S45 | P0 |
| FR-07 | Tasks list with sections, filter chips and swipe actions | S19 | P0 |
| FR-08 | Focus timer with modes, linked task, durations, session complete and breaks | S30–S33 | P1 |
| FR-09 | Calendar month and week views | S21, S22 | P1 |
| FR-10 | Filter and sort sheet; search with no-results state | S23–S25 | P1 |
| FR-11 | Repeating tasks | S15 | P1 |
| FR-12 | Reminders and local notifications (task reminders, daily plan, overdue, focus end, weekly review, quiet hours) | S05, S16, S39 | P1 |
| FR-13 | Tags: picker and manager | S18, S46 | P1 |
| FR-14 | Insights: completion rate, streak, charts, trend, power day | S34 | P1 |
| FR-15 | Settings: name, theme, week start, default priority | S35–S38, S40 | P1 |
| FR-16 | Dark mode for every screen | all | P1 |
| FR-17 | Export CSV and JSON; erase all data | S41, S44 | P1 |
| FR-18 | Board (Kanban) view with drag between columns | S20 | P2 |
| FR-19 | Backup and restore, automatic nightly backup, failure state | S42, S43 | P2 |
| FR-20 | Quick-add hints and drag-to-reschedule in the calendar | S10, S21 | P2 |

---

## 8. Data model

| Entity | Fields | Rules |
|---|---|---|
| **Task** | `id`, `title`, `description?`, `dueDate?` (local date), `dueMinute?` (0–1439), `priority` (urgent / high / medium / low), `projectId?`, `status` (open / done), `completedAt?` (UTC), `createdAt`, `updatedAt`, `boardColumn` (todo / doing / done), `sortOrder`, `repeatRuleId?`, `reminder` (none / atTime / min10 / min30 / hour1 / morningOf / dayBefore) | Title 1–120 characters, trimmed. Description ≤ 1,000. `dueMinute` needs `dueDate`. `boardColumn` is `done` exactly when `status` is done. |
| **Subtask** | `id`, `taskId`, `title`, `done`, `sortOrder` | Title 1–120 characters. ≤ 50 per task. Deleted with the task. |
| **Tag** | `id`, `name` | Lowercase, no "#", 1–24 characters, unique. |
| **TaskTag** | `taskId`, `tagId` | Removed with either side. |
| **Link** | `id`, `taskId`, `title`, `url` | URL must be http or https. Deleted with the task. |
| **Project** | `id`, `name`, `description?`, `colorKey`, `iconKey`, `deadline?`, `archivedAt?`, `createdAt`, `sortOrder` | Name 1–40 characters, unique among active projects. |
| **RepeatRule** | `id`, `kind` (daily / weekdays / weekly / monthly / custom), `weekdays` (bitmask), `dayOfMonth?`, `interval?` (1–12), `unit?` (day / week / month), `endsOn?` | Weekly needs at least one weekday. |
| **FocusSession** | `id`, `taskId?`, `kind` (focus / short / long), `plannedSec`, `startedAt` (UTC), `endedAt?`, `elapsedSec`, `completed` | Counts toward focus time only when `elapsedSec` ≥ 60. Kept when its task is deleted (`taskId` set to null). |

**Preferences** (key-value):
- `userName`, `theme` (light / dark / system), `weekStart` (mon / sun / sat), `defaultPriority`
- focus: `focusMin` (25), `shortMin` (5), `longMin` (15), `sessionsPerRound` (4), `autoStartBreaks`, `autoStartNext`, `silenceWhileFocusing`
- notifications: `remindersOn`, `dailyPlanOn` and `dailyPlanMinute` (480), `overdueOn`, `focusEndOn`, `weeklyReviewOn`, `defaultReminder` (min30), `quietStartMinute` (1380), `quietEndMinute` (420)
- backup (v1.1): `autoBackup`, `backupFolder`, `keepBackups` (7), `lastBackupAt`, `lastBackupError?`
- `onboardingComplete`

### Derived values
- **Today's list** = open tasks due today + tasks completed today. Order: done last, then by time (untimed after timed), then priority, then `sortOrder`.
- **Today's progress** = completed today ÷ today's list.
- **Overdue** = open tasks due before today, or due today with a time already passed.
- **Streak** = consecutive local days, ending today or yesterday, with at least one task completed.
- **Focus today** = sum of `elapsedSec` of today's counted focus sessions.
- **Done this week** = tasks completed in the current week (`weekOf`).
- **Project progress** = done ÷ all tasks in the project.
- **Days left** = project deadline − today, in days.
- **Completion rate** = tasks completed in the range ÷ tasks due in the range. **Change** = rate − previous equal range's rate, in points.
- **Power day** = the weekday with the highest average completions over the last 4 full weeks.

---

## 9. Design system

From the canvas's design-system board. The full spec is in `docs/DESIGN.md`.

### Brand
- The name is written **ctrlTask**: lowercase "ctrl". In the wordmark, "ctrl" is weight 400 in grey and "Task" is 700. It comes from **ctrlWorks**.
- Logo: an **orange check** on a charcoal keycap.
- Endorsed lockup "ctrlTask by ctrlWorks" for the App Store page and website.
- The splash footer and the Settings footer credit the maker: **"by BrendanLTW"**.
- In sentences: "ctrlTask, from ctrlWorks". Never "ctrlWorks Task".

### Colour tokens
Shared with ctrlSpend: `ground` `#F7F8FA` / `#0B1018`, `surface` `#FFFFFF` / `#161D29`, `ink` (text and primary accent) `#101828` / `#F2F4F7`, `muted` `#5B6B86` / `#98A2B3`, `positive`, `negative`, `warning`. ctrlTask adds eight **project colours** (orange, yellow, green, blue, purple, pink, red, grey) used for projects, priority and charts. Navy `ink` is the accent; the brief's purple is a project colour.

### Typography
Poppins, tabular figures. Timer 60/700, hero value 32/700, page title 26–28/700, header 20/700, row title 16/600, body 15/400–500, caption 13/400, label 13/600 caps.

### Components
Buttons, segmented control, chips, toggles, radios, steppers, task card and row, priority tag, project card, list groups, progress ring and bar, stat tile, bottom sheet, dialog, toast, empty state, message boxes, month calendar, week strip, day timeline, Kanban column, focus timer, bar chart, trend line, the bottom bar with the quick-add button.

### Accessibility
- Text contrast ≥ 4.5:1 in both themes.
- Every ring, bar and chart has a screen-reader label with its values.
- Icon-only buttons are labelled (Back, Close, Search tasks, Filter and sort, Quick add task, Settings, Timer settings, Focus statistics).
- Priority and status are never shown by colour alone.

---

## 10. Non-functional requirements

| Area | Requirement |
|---|---|
| Performance | Cold start to an interactive Home in < 1.5 s on a mid-range Android device; 60 fps lists with 2,000 tasks; any change on screen in < 100 ms |
| Offline | Every feature works without a network |
| Correctness | Dates stored as local dates plus optional minutes; timestamps in UTC; one `weekOf` and one `nextOccurrence` function used everywhere |
| Privacy | No accounts, analytics, ads or network calls; data leaves only through export and backups the user chooses; Erase all data removes everything |
| Reliability | No data loss if the app is killed mid-write; backups are atomic; restore validates before replacing |
| Platforms | iOS 15+ and Android 8+; a web build for the demo with notifications and backup hidden |
| Quality | `flutter analyze` clean; unit tests for derived values, `weekOf`, `nextOccurrence`, reminder times and the focus timer; widget tests per screen in both themes; one end-to-end test (onboarding → quick add → complete → undo → focus session); CI on every push |
| Design fidelity | Each screen is compared with its light and dark design before its task is done |

---

## 11. Milestones

| Phase | Scope | Exit criteria |
|---|---|---|
| 0 Foundation | Project, tokens (light and dark), Poppins, routing shell with 4 tabs and quick-add button, date formatting, CI | Shell matches the design in both themes |
| 1 Data | Drift schema, `weekOf`, `nextOccurrence`, repositories, derived values | Unit tests pass |
| 2 Core | Onboarding, Home (3 states), quick add, task form and detail, delete, due-date picker, projects, tasks list | **All P0 done** |
| 3 Complete | Focus, calendar, filter and search, repeat, reminders and notifications, tags, insights, settings, export, erase | **All P1 done** |
| 4 Ship | Accessibility and fidelity pass, end-to-end test, demo, APK, README | **v1.0 released** with all P0 + P1 |
| 5 Update | Board view, backup and restore, quick-add hints, drag to reschedule | P2 tests pass; **v1.1 released** |

---

## 12. Risks and open questions

| Risk | Mitigation |
|---|---|
| The background timer is killed by the OS | Compute remaining time from the stored start; schedule the end notification when the session starts |
| iOS keeps at most 64 pending notifications | Schedule only the next 14 days of reminders; reschedule on launch and resume |
| Repeat rules on short months | Monthly on the 29th–31st falls back to the last day; exhaustive tests for `nextOccurrence` |
| Streaks across time zones and travel | Use the device's local date at completion time; tests for day boundaries |
| Backup folder access on iOS | Use the Files picker; fall back to the share sheet |
| The brief asked for purple as the primary colour | Decided 17 Nov 2026: navy `ink`, as in ctrlSpend; purple is a project colour |

### Open questions
- Should **Inbox** (tasks with no project) appear as a row on S26? Today it only appears in S17.
- The Custom repeat options (S15) and the custom export range (S41) don't have their own designs yet; they use the patterns from ctrlSpend's S44 and S50.
- The task picker behind **Change** on S30 isn't designed yet; it should reuse S17's sheet layout with today's tasks.
