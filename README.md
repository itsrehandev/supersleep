# Super Sleep

> AI-Powered SE-MAX · CUI Tech Fest FA'26 · Team: Load Balancers

## What it does

Super Sleep is a heavy-sleeper Android alarm and wake-up companion built with Flutter and Material Design 3. It combines exact Android OS alarm scheduling, local SQLite database storage (`sqflite`), custom device ringtone selection, audio testing previews, and interactive wake-up missions (such as Maths Problem puzzles at Easy, Medium, and Hard difficulty levels) to ensure users wake up on time without sleeping through their alarms.

## Problem and user

Heavy sleepers frequently turn off traditional alarms in their sleep or miss alarms when an app process is terminated or backgrounded by device battery optimizers. Super Sleep solves this for students, professionals, and heavy sleepers by pairing exact Android AlarmManager scheduling (`alarmClock: true`, Doze-bypassing alarms, full-screen intent lock-screen overlays) with mandatory wake-up math challenges that guarantee mental alertness before an alarm can be dismissed.

## Live deployment

- **URL / install link:** `https://pern-my.sharepoint.com/:u:/g/personal/fa25-bse-065_isbstudent_comsats_edu_pk/IQAfDI84JIceQIawE4K_CWSWATdSqz_iiszf7wIo16UXK2o?e=7iUIBF`
- **Platform:** Android

## Judge quick start (under 5 minutes)

1. Connect an Android physical device or start an Android Emulator (API 21+).
2. Open terminal in project root and run `flutter pub get`.
3. Launch the app using `flutter run`.
4. Tap the **+ Add Alarm** floating action button on the Home Dashboard.
5. Set time to 1 minute ahead, toggle **Maths Problem** mission (select Easy, Medium, or Hard), pick your preferred built-in or custom ringtone, and tap **Save**.
6. When the alarm triggers, test the math puzzle entry: enter the answer and tap **Submit & Stop Alarm** to stop playback and update the next alarm schedule.

## Test accounts

| Role | Username / email | Password |
|------|------------------|----------|
| Offline Local User | N/A (Fully offline app) | N/A |

## Run locally

### Prerequisites

- Flutter SDK (3.10.0 or higher) with Dart 3.10+
- Android Studio or Android SDK command line tools
- Connected Android device or Android Emulator running API 21+

### Setup

```bash
git clone <repository-url>
cd supersleep
flutter pub get
```

### Environment variables

No external environment variables are required. Super Sleep is local-first, offline, and relies on SQLite (`sqflite`) for data storage.

### Run

```bash
flutter run
```

To target a specific connected Android device:
```bash
flutter devices
flutter run -d <device-id>
```

### Run tests

```bash
flutter analyze
```

## Known limitations

- Android platform only (`android_alarm_manager_plus` and exact alarm clock intents are Android-native surfaces).
- On aggressive OEM Android devices (e.g. Xiaomi MIUI, Huawei EMUI), background autostart permissions must be granted manually in device Settings for killed-state execution.

## Documentation

- [Requirements](docs/requirements.md)
- [Design](docs/design.md)
- [Testing](docs/testing.md)
- [AI usage log](docs/ai-usage-log.md)
- [Judge checks](docs/judge-checks.md)

## Team

| Name | Role |
|------|------|
| Muhammad Rehan | Coder and debugger |
| Syed Muhammad Mujahid | Requirements gatherer and prompt engineer |
