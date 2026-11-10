# Alarm App: Engineering Principles & Required Systems

Final engineering guide for a Flutter, Android-only alarm app built for heavy sleepers. It combines general architecture principles with alarm-specific reliability rules and the systems the app needs.

> Verify package versions, Android API behavior, and Google Play policy against current official docs before release. Platform rules for exact alarms, full-screen intents, and foreground services change between Android versions.

---

## 1. Final Decisions

| # | Area | Decision |
|---|------|----------|
| D1 | Platform | Android only |
| D2 | Local database | `sqflite` (plain SQLite) |
| D3 | Scheduling engine | `android_alarm_manager_plus` (exact trigger, reboot reschedule) + `flutter_local_notifications` (ringing notification, full-screen UI, reboot-time notification support) |
| D4 | Permissions | Request all alarm-relevant permissions; app guides the user to grant each one |
| D5 | State management | Riverpod |
| D6 | Time policy | Fixed clock time stored as a `DateTime` / epoch; the next fire epoch is computed from it |
| D7 | Audio | Alarm-grade sound via notification channel (alarm audio usage, looping) |
| D8 | Backend | None. Fully local, offline |
| D9 | v1 features | Defaults assumed (see section 15) |
| D10 | Testing | Defaults assumed (see section 14) |

---

## 2. Core Alarm Principles

1. **Reliability over everything.** A missed alarm is a failed product. Every design choice is judged by: will it ring on time if the app is killed, the phone rebooted, or the battery low?
2. **The OS owns the trigger, never Dart.** No `Timer`, `Future.delayed`, or in-app countdown fires an alarm. Use AlarmManager through `android_alarm_manager_plus`.
3. **Database is the source of truth; the OS schedule is derived state.** A single `AlarmScheduler` reconciles the OS schedule from the DB. On any drift, the DB wins and the schedule is rebuilt.
4. **Idempotent scheduling.** Scheduling the same alarm twice must never create duplicates. Use stable, deterministic integer IDs.
5. **Reschedule on every event that can clear alarms:** reboot, app update, time change, timezone change, and app launch.
6. **Pure domain logic.** "Compute next fire time" is a pure function with no I/O and heavy unit tests.
7. **Platform code behind interfaces.** `AlarmScheduler`, `NotificationService`, `PermissionService`, and `Clock` are abstract classes so they can be faked in tests.
8. **Explicit alarm state machine.** `scheduled → ringing → snoozed | dismissed | missed`. No ad-hoc boolean flags.
9. **Minimal work at ring time.** When an alarm fires, start sound and show UI. No network, no heavy queries, no migrations.
10. **Fail loudly to the user.** If an alarm cannot be guaranteed (missing permission, battery restriction), show a visible warning on the main screen.
11. **Local-first.** Everything works offline. There is no backend dependency anywhere in the critical path.
12. **Observability.** Log every schedule, fire, snooze, dismiss, and reschedule to a local table. This is the only way to debug "my alarm didn't ring".
13. **Test on real devices from several manufacturers.** Emulators do not reproduce Doze or OEM task killers.

---

## 3. Layered Architecture (MVVM + Dependency Injection with Riverpod)

Each feature (e.g. `lib/features/alarms/`) is split into three layers. Dependencies flow downward only.

```
Widgets  →  ViewModel (Notifier)  →  Repository  →  sqflite / OS plugins
```

### 3.1 Repository layer
- Talks directly to sqflite and platform plugins.
- Has no knowledge of widgets or UI state.
- Exposes plain async operations: `Future<List<Alarm>>`, `Future<int> insert(Alarm)`, `Future<void> delete(int id)`.
- Maps rows to models and back; no SQL leaks outside this layer.

### 3.2 ViewModel layer
- Extends a Riverpod `Notifier` / `AsyncNotifier` (or `StateNotifier` if matching older code).
- Receives dependencies through providers (constructor injection for testability).
- Owns state transitions: loading, data, error.
- Calls the repository to persist, then the scheduler to reconcile. It never touches AlarmManager directly.
- State classes are immutable and updated with `copyWith`.

### 3.3 Provider layer
- One file per feature, e.g. `alarm_providers.dart`.
- Provider for each repository and service (DI root).
- Provider for each ViewModel.
- Granular selectors (`alarmListProvider`, `nextAlarmProvider`, `permissionHealthProvider`) so widgets rebuild only when their slice changes.

### Rules of thumb
- If it cannot be unit-tested without a UI, it is in the wrong layer.
- Data flows up through state; dependencies flow down through providers.
- Override providers in tests instead of using global singletons.

---

## 4. Navigation: Shell Routing (GoRouter)

- Define all routes in `core/app_router.dart` with named constants.
- Use `ShellRoute` to wrap main routes in one shell scaffold; only child content changes on navigation.
- Handle responsive navigation at the shell level (bottom bar or drawer on phones, rail on tablets).
- The **ringing screen** is a dedicated route that must be reachable directly from a notification tap or full-screen intent (deep link into the router), independent of the shell.
- Keep redirects (e.g. send user to the permission setup flow) in the router, not in screens.

---

## 5. Centralized Design System

- `app_theme.dart` holds all colors, named `TextStyle`s, and the full `ThemeData` (light and dark).
- No hard-coded colors, font sizes, or magic spacing in feature code.
- Clamp text scaling at the app root so the UI stays usable under large accessibility font settings.
- Provide a shared `ResponsiveLayout` primitive for spacing and column counts.
- The ringing screen uses very large, high-contrast controls: a sleepy user must be able to dismiss or snooze in one obvious action.

---

## 6. Single Responsibility Principle

| Unit | Responsibility | Must not |
|------|----------------|----------|
| Widgets | Render one reusable UI piece | Call APIs or hold business logic |
| ViewModels | Orchestrate state and rules | Build widgets or call AlarmManager directly |
| Repositories | Pure database operations | Import UI packages or schedule alarms |
| Scheduler service | Sync DB to OS schedule | Persist business data |
| Notification service | Show and cancel notifications | Decide when alarms fire |
| Models | Immutable data with `fromMap` / `toMap` | Contain I/O |

---

## 7. Data Layer (sqflite)

### 7.1 Principles
- One `DatabaseProvider` opens the database once and exposes it; never open it ad hoc.
- Enable foreign keys and use transactions for multi-row writes.
- Schema versioning with explicit, ordered migrations in `onUpgrade`. Never edit a released migration; add a new one.
- Store times as integer epoch milliseconds and booleans as 0/1.
- Because the DB is also read from the background isolate when an alarm fires, keep the DB access class free of Flutter UI dependencies and safe to construct in a background isolate.
- Keep simple app settings (theme, 24-hour format, default snooze) in the same database `settings` table, so there is one storage system to reason about.

### 7.2 Suggested schema

```sql
CREATE TABLE alarms (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  label            TEXT    NOT NULL DEFAULT '',
  hour             INTEGER NOT NULL,        -- 0-23, user's clock time
  minute           INTEGER NOT NULL,        -- 0-59
  repeat_days_mask INTEGER NOT NULL DEFAULT 0, -- bit 0 = Mon ... bit 6 = Sun; 0 = one-time
  is_enabled       INTEGER NOT NULL DEFAULT 1,
  next_fire_epoch  INTEGER,                 -- cached next trigger (UTC epoch ms)
  sound_uri        TEXT,                    -- null = bundled default
  vibrate          INTEGER NOT NULL DEFAULT 1,
  snooze_minutes   INTEGER NOT NULL DEFAULT 5,
  max_snoozes      INTEGER NOT NULL DEFAULT 3,
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL
);

CREATE TABLE alarm_events (          -- ring/snooze/dismiss history and logs
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  alarm_id   INTEGER,
  type       TEXT NOT NULL,          -- scheduled|fired|snoozed|dismissed|missed|rescheduled|error
  at_epoch   INTEGER NOT NULL,
  detail     TEXT
);

CREATE TABLE settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE INDEX idx_alarms_enabled_next ON alarms(is_enabled, next_fire_epoch);
```

### 7.3 Repository rules
- Return domain models, never raw maps.
- Prune `alarm_events` periodically (e.g. keep the last 30 days) to keep the DB small.
- Wrap "save alarm + recompute `next_fire_epoch`" in one transaction.

---

## 8. Time Policy

**Decision:** fixed clock time with epoch-based triggers.

- The user's chosen time (`hour`, `minute`) and repeat days are stored as the alarm definition.
- The scheduler converts that into an absolute `next_fire_epoch` (UTC epoch ms) and hands that fixed instant to AlarmManager.
- `next_fire_epoch` is **recomputed** (never assumed) after every fire, every reboot, every time or timezone change, and every app launch.
- If the device timezone or clock changes, the already-scheduled epoch keeps pointing at the original instant until recomputed, so listen for the time-change and timezone-change broadcasts and trigger a full reconcile.
- `Clock` is an injectable abstraction (`DateTime Function() now`) so time logic is deterministic in tests.

> Note: with fixed epoch scheduling, a user who changes timezone will have alarms fire at the wrong local wall time until the reconcile runs. The reconcile-on-change rule above is what keeps this safe. If you later want strict wall-clock behavior, only the recompute step changes; the rest of the architecture stays the same.

### 8.1 Next-occurrence function (pure)

```dart
/// Pure: no I/O, no globals. Fully unit-testable.
DateTime? computeNextFire({
  required DateTime now,
  required int hour,
  required int minute,
  required int repeatDaysMask, // 0 = one-time
});
```

Test cases to cover: time already passed today, one-time alarm in the past, each weekday combination, wrap across week and month boundaries, leap day, and snooze interaction.

---

## 9. Scheduling System

### 9.1 Responsibilities
`AlarmScheduler` (interface) with an Android implementation using `android_alarm_manager_plus`:

- `scheduleAlarm(Alarm)`: compute next fire, persist it, register the exact alarm.
- `cancelAlarm(int id)`
- `rescheduleAll()`: read enabled alarms from DB, cancel stale registrations, register each one.
- `snooze(int id)`: schedule a one-shot at now + snooze duration without altering the repeat definition.

### 9.2 Registration settings
Use exact, wake-up, Doze-bypassing registrations and reboot persistence:

```dart
await AndroidAlarmManager.oneShotAt(
  fireAt,                 // DateTime from next_fire_epoch
  alarmId,                // stable int ID
  alarmCallback,          // top-level function
  exact: true,
  wakeup: true,
  allowWhileIdle: true,
  alarmClock: true,       // uses the alarm-clock API: most reliable, shows system alarm icon
  rescheduleOnReboot: true,
);
```

Requirements:
- `alarmCallback` must be a **top-level or static** function annotated with `@pragma('vm:entry-point')`.
- Initialize the plugin during app startup before scheduling.
- Verify current plugin documentation for the exact parameter names and manifest entries, since they must match the installed version.

### 9.3 Stable IDs
- Alarm ID = database row ID.
- Snooze registrations use a derived, deterministic ID (e.g. `alarmId + 1_000_000`) so they can be cancelled precisely.

### 9.4 Reconcile triggers
Call `rescheduleAll()` on:
- App launch
- Device reboot (boot receiver, plus plugin's `rescheduleOnReboot`)
- App update (package replaced)
- Time changed and timezone changed
- After any alarm create, edit, delete, enable, or disable
- After each alarm fires (to schedule the next repeat occurrence)

### 9.5 Reboot handling
Two layers of defense, because reboots are the most common silent failure:
1. `android_alarm_manager_plus` with `rescheduleOnReboot: true`.
2. A boot-completed receiver path that runs `rescheduleAll()` and (via `flutter_local_notifications`) restores any scheduled notifications, with the DB as the source of truth.

If a reboot happened while an alarm should have rung, record a `missed` event and notify the user on next launch.

### 9.6 Fire-time flow (background isolate)

```
AlarmManager fires exact alarm
  → alarmCallback (background isolate)
      1. Load alarm by id from sqflite (single read)
      2. Log 'fired' event
      3. Show ringing notification (alarm channel, full-screen intent, looping sound)
      4. Compute and schedule next occurrence (if repeating) or disable (if one-time)
```

Keep this path short and free of network or heavy work.

---

## 10. Ringing System (Audio, Notification, UI)

### 10.1 Approach
`flutter_local_notifications` provides the ringing surface, configured as an alarm, not an ordinary notification.

Notification configuration principles:
- Dedicated high-importance **alarm channel**, created at startup.
- Category set to alarm; audio attributes usage set to alarm so sound plays through the alarm stream.
- Full-screen intent enabled, so the ringing screen appears over the lock screen.
- Ongoing and non-dismissible by swipe while ringing.
- Insistent flag (repeat the sound until handled) so the sound loops.
- Visible actions: **Dismiss** and **Snooze** directly on the notification.
- Sound resource bundled with the app as the guaranteed default; custom sound is optional and must fall back to the bundled sound if the file is missing or unreadable.

### 10.2 Ringing screen
- Opens via full-screen intent or notification tap through the router.
- Keep screen on and show over lock screen while ringing.
- Large Dismiss and Snooze buttons; show label and current time.
- Dismissing cancels the notification, stops sound, and logs `dismissed`.
- Snooze cancels the notification, schedules the snooze one-shot, and logs `snoozed`, respecting `max_snoozes`.

### 10.3 Known risk to design around
`flutter_local_notifications` plus a Dart callback is not a true native alarm service. Ringing sound depends on notification channel behavior, and some manufacturers aggressively limit background Dart isolates. Mitigations:
- Test the sound loop duration on real devices; if it stops early on some devices, escalate to a small native foreground service for audio (Kotlin) behind the same `NotificationService` interface. No other layer should need to change.
- Provide a configurable auto-stop timeout (e.g. 10 minutes) that logs `missed` so a stuck alarm doesn't ring forever.

---

## 11. Permissions & "Alarm Health" System

Because users are heavy sleepers, the app should require full permission setup and make gaps impossible to miss.

### 11.1 Permissions to handle

| Permission / setting | Purpose | Notes |
|---|---|---|
| Exact alarms | Exact trigger time | Use the exact-alarm permission appropriate to the Android version. Alarm apps can qualify for the auto-granted variant on newer versions; confirm Play declaration requirements. |
| Post notifications | Show ringing notification | Runtime permission on Android 13+ |
| Full-screen intent | Ringing screen over lock screen | May require a user-granted special access on newer Android |
| Boot completed | Reschedule after reboot | Manifest receiver |
| Wake lock | Wake device to ring | Manifest |
| Foreground service (if native audio service is added) | Reliable long-running audio | Requires declared service type on newer Android |
| Battery optimization exemption | Avoid Doze restrictions | Google Play restricts when apps may request this; provide an in-app explanation and a link to settings as a fallback |
| OEM auto-start / background restrictions | Prevent manufacturer task killers | Cannot be granted programmatically; show device-specific instructions |

### 11.2 Permission flow
- First-run **setup wizard** walks through each permission one at a time, explaining why it is needed in one sentence.
- Each step checks the actual granted state (not just "I asked").
- A persistent **Alarm Health** card on the main screen shows green/red status for every item with a one-tap link to the relevant system setting.
- Block creating alarms (or show a prominent warning banner) while critical permissions (exact alarms, notifications, full-screen intent) are missing.
- Re-check health on every app resume, since users can revoke permissions in settings.

### 11.3 `PermissionService`
- Abstract interface with one method per permission: `check()` and `request()` or `openSettings()`.
- Exposes an aggregate `AlarmHealth` model consumed by a Riverpod provider.

---

## 12. Riverpod Conventions

- Providers are declared in each feature's `providers/` file, never inline in widgets.
- Repositories and services: `Provider`. ViewModels: `NotifierProvider` / `AsyncNotifierProvider`.
- Use `select` and small derived providers to limit rebuilds.
- Side effects (schedule, cancel, notify) happen in ViewModels, not in widgets.
- Alarm list screen listens to a provider backed by the repository; after each mutation, reload from the DB rather than hand-patching state.
- Background isolate cannot use the app's `ProviderContainer`; construct the needed repository and services directly there from the same classes.

---

## 13. Project Structure

```
lib/
├── core/
│   ├── app_router.dart
│   ├── app_theme.dart
│   ├── responsive_layout.dart
│   ├── clock.dart                    # injectable time source
│   └── database/
│       ├── database_provider.dart    # opens DB once, migrations
│       └── migrations.dart
├── shared/
│   └── widgets/                      # CustomCard, buttons, etc.
├── features/
│   ├── alarms/
│   │   ├── data/                     # AlarmRepository (sqflite)
│   │   ├── domain/                   # Alarm model, computeNextFire, state machine
│   │   ├── providers/                # alarm_providers.dart
│   │   ├── viewmodels/               # AlarmListViewModel, AlarmEditViewModel
│   │   └── views/                    # list, editor, widgets
│   ├── ringing/
│   │   ├── views/                    # ringing screen
│   │   └── viewmodels/
│   ├── scheduling/
│   │   ├── alarm_scheduler.dart      # interface
│   │   ├── android_alarm_scheduler.dart
│   │   ├── alarm_callback.dart       # top-level @pragma entry points
│   │   └── notification_service.dart
│   ├── permissions/
│   │   ├── permission_service.dart
│   │   ├── alarm_health.dart
│   │   └── views/                    # setup wizard, health card
│   └── settings/
└── main.dart                         # init plugins, timezone/clock, scaling, router
```

---

## 14. Testing Strategy

| Level | Covers | Tools |
|---|---|---|
| Unit | `computeNextFire`, state machine, ViewModels, permission aggregation | `flutter_test`, `mocktail` |
| Database | Migrations from every previous version, queries | sqflite FFI (`sqflite_common_ffi`) with in-memory DB |
| Widget | Alarm list, editor, ringing screen, health card | `flutter_test` with provider overrides |
| Integration | Create → schedule → ring → dismiss/snooze | `integration_test` |
| Manual device matrix | Reboot, Doze, battery saver, app swiped from recents, timezone change, OEM killers | Real devices from multiple manufacturers |

Mandatory manual checklist before every release:
- [ ] Alarm rings with app swiped away from recents
- [ ] Alarm rings after reboot
- [ ] Alarm rings in battery saver and after hours of idle (Doze)
- [ ] Alarm rings on lock screen with full-screen UI
- [ ] Snooze and dismiss work from both the notification and the screen
- [ ] Repeating alarm schedules the next occurrence after firing
- [ ] Time change and timezone change trigger a reconcile
- [ ] Revoking each permission produces a visible health warning

---

## 15. Assumed v1 Scope (not specified, so defaults were used)

Included:
- One-time and weekday-repeat alarms
- Label, vibration toggle, bundled default sound, optional custom sound with fallback
- Snooze with configurable duration and max count
- Alarm Health screen and permission setup wizard
- Local event log

Deferred:
- Dismiss challenges (math, QR, shake)
- Home screen widget, timers, stopwatch
- Cloud sync, accounts, export/import

---

## 16. Known Risks & Open Items

1. **Notification-based ringing vs. a native alarm service.** The chosen stack is the lightest, but may be less reliable than a native foreground service on aggressive OEMs. The `NotificationService` interface keeps the upgrade path contained.
2. **Fixed epoch time policy.** Alarms may fire at the wrong local time after a timezone change until the reconcile runs. Reconcile-on-change is mandatory.
3. **Battery exemption policy.** Google Play may restrict requesting the battery optimization exemption directly; the fallback is guiding users to settings.
4. **Plugin maintenance.** Check pub.dev for recent releases, open issues, and Android version compatibility of `android_alarm_manager_plus` and `flutter_local_notifications` before starting, and again before each release.
5. **Background isolate DB access.** sqflite must be usable in the alarm callback isolate; verify early with a prototype on a real device.

---

## 17. Master Checklist

- [ ] OS (AlarmManager) triggers alarms; Dart timers are never used
- [ ] DB is the source of truth; scheduler reconciles from it
- [ ] Stable IDs; scheduling is idempotent
- [ ] Reschedule on launch, reboot, update, time change, timezone change
- [ ] Next-fire logic is pure and thoroughly unit-tested
- [ ] Explicit alarm state machine
- [ ] Repository has no UI imports; ViewModels get dependencies via providers
- [ ] Platform services sit behind interfaces
- [ ] Alarm channel, full-screen intent, looping sound configured
- [ ] All permissions checked; Alarm Health visible and re-checked on resume
- [ ] Migrations tested from every prior schema version
- [ ] No hard-coded colors, styles, or breakpoints in feature code
- [ ] Event log and auto-stop timeout in place
- [ ] Real-device manual test matrix passed