# Spikes

## 0.9 Local notifications and a timer that survives the background

**Status:** Timer verified on the iOS simulator. Notification scheduling builds on both platforms, but delivery is **not verified**. Android was not run: there is no emulator on this machine. The throwaway code is on the unmerged branch `spike/notifications-timer` (`flutter run -t lib/spike_main.dart`).

This builds on ctrlSpend's spike (`ctrlspend/docs/spikes.md`, task 0.9 there), which covers the Android manifest, the iOS delegate, the 22.3.3 API and its gotchas. Only what is new or different for ctrlTask is below.

### Versions

| Package | Version | Note |
| --- | --- | --- |
| flutter_local_notifications | 22.3.3 | 23.x needs compileSdk 37, which Flutter 3.47.9 doesn't target (found in 0.1) |
| timezone | 0.11.2 | Import `data/latest_all.dart`, not `latest.dart` (see below) |
| flutter_timezone | 5.1.1 | |

### Verified on the iOS simulator (iPhone 18 Pro, iOS 27, 19 Nov 2026)

The spike stores `startedAt` (UTC) and `plannedSec` in a file and computes the remaining time from the clock on every launch and resume. It never keeps a running count.

| Scenario | Clock | Reported | Result |
| --- | --- | --- | --- |
| Start a 60 s session | 06:19:59 | — | Stored |
| Kill (`simctl terminate`), relaunch ~28 s after start | ~06:20:27 | elapsed 28 s, remaining 31 s | Correct |
| Background (switch to Settings), resume ~52 s after start | ~06:20:51 | elapsed 52 s, remaining 7 s | Correct |
| Kill, relaunch after the session ended | ~06:21:14 | elapsed 75 s, remaining 0 s | Correct, clamped at 0 |

When the app goes to the background and comes back, the lifecycle runs `inactive → hidden → paused`, then `hidden → inactive → resumed`. Recompute on `resumed`.

### Findings

1. **`timezone`'s `latest.dart` crashes on alias zones.** This simulator reports `Asia/Kuala_Lumpur`, which `latest.dart` doesn't contain. `tz.getLocation` throws at startup and the app never draws a frame. `data/latest_all.dart` includes it, and ctrlSpend's production code already uses that file. Use `latest_all.dart`, and fall back to UTC instead of crashing when a zone name is unknown.
2. **Without permission, iOS scheduling silently does nothing.** With permission off, `zonedSchedule` returned without an error, and `pendingNotificationRequests()` was empty. Check `checkPermissions()` before scheduling, and treat "scheduled" as unconfirmed until the request shows as pending.
3. **Reading the time from the clock works.** The timer was right after killing and backgrounding, as PRD §6.6 requires. The end-of-session notification must be scheduled when the session starts, because no Dart code runs while the app is killed.

### Not verified (re-check in 3.1 and 3.7 on real devices)

- The iOS permission prompt and actual delivery of the 10 s test notification and the session-end notification, including with the app killed. The simulator can't grant notification permission without a tap.
- Everything on Android: the Android 13+ prompt, delivery, reboot survival and timing drift with `inexactAllowWhileIdle`. Only the debug APK build with the manifest receivers was checked.
- Whether a session-end notification fires on time when the phone is locked.

### Setup for 3.7

- Android: the manifest receivers and `RECEIVE_BOOT_COMPLETED` from ctrlSpend's spike. No `SCHEDULE_EXACT_ALARM`: inexact timing is fine for reminders and the session end.
- Android: a monochrome `ic_notification` drawable with `res/raw/keep.xml`. The spike used `@mipmap/ic_launcher`, which is fine only for a test.
- iOS: `UNUserNotificationCenter.current().delegate = self` in `AppDelegate.swift`, so notifications show in the foreground.
- Initialise without prompting. S05 and S39 call the permission request.
- At most 14 days of reminders pending (iOS keeps only 64). Reschedule on launch and resume (PRD §12).

### Recommendation for 3.1 (focus timer)

- Store `startedAt` (UTC) and `plannedSec` in the `FocusSession` row when a session starts. Compute the remaining time from the injected `Clock`, and recompute on `AppLifecycleState.resumed`.
- At the same moment, schedule the session-end notification for `startedAt + plannedSec`. Cancel it on pause, reset or finish, and reschedule it on resume from pause.
- On launch, a stored session past its end is complete: save it with `elapsedSec = plannedSec`, applying the 1-minute rule.
