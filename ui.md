## 6. Navigation

Use a four-item bottom navigation bar:

| Tab | Purpose |
|---|---|
| Alarms | Home dashboard and alarm management |
| Streak | Streak calendar, score and achievements |
| Timer 
| Stopwatch
| Settings | Preferences, permissions and safety |

Keep labels visible and highlight the selected destination with the primary theme colour.

---

## 7. Screen specifications

## 7.1 Home dashboard / Alarms

**Purpose:** Show the next alarm and make alarm management quick.

Include:

- App name: **Super Sleep**
- A short greeting or simple welcome message.
- A prominent **Next Alarm** card.
- Next alarm time, date/day and custom label.
- Edit action for the next alarm.
- List of all saved alarms.
- Each alarm row shows time, label, repeat days and enabled/disabled switch.
- Add Alarm floating action button.
- Compact current streak and wake-up score summaries.
- Bottom navigation.

### Alarm row actions

Each alarm row should provide access to:

- Edit
- Duplicate
- Enable / Disable
- Delete

Use a three-dot overflow menu for secondary actions such as Duplicate and Delete, rather than crowding the alarm row with buttons.

### Empty state

When no alarms exist, show a simple message and a prominent **Create your first alarm** action.

---

## 7.2 Create / Edit Alarm screen

**Purpose:** Configure all settings for an individual alarm.

Organise the screen into clear sections.

### A. Time and schedule

- Large Material time picker.
- Follow the device's 12-hour or 24-hour preference.
- One-time alarm or repeat alarm.
- Weekday selector for repeat alarms.
- Custom alarm label.
- Default label: **Alarm** when the user leaves the label empty.

### B. Missions

Allow users to select one or more missions for this alarm:

- Maths Problem
- QR Code
- Correct Typing

Only show the relevant settings for a selected mission.

#### Maths Problem difficulty

When Maths Problem is selected, show a difficulty selector:

- **Easy:** Simple arithmetic and small numbers.
- **Medium:** Larger numbers and/or multiple operations.
- **Hard:** More challenging calculations and combinations of operations.

The generated maths question must match the selected level.

#### Correct Typing difficulty

When Correct Typing is selected, show a separate difficulty selector:

- **Easy:** Short phrase, familiar words and simple punctuation.
- **Medium:** Longer sentence with mixed case and punctuation.
- **Hard:** Longer or more complex text with varied punctuation and character patterns.

The displayed text must match the selected level. Validate the user's entry consistently against the displayed text.

#### Independent difficulty selection

Maths and Typing difficulty are independent settings for each alarm.

Example:
- Maths: Hard
- Correct Typing: Easy

Do not use one shared difficulty selector for both missions. Difficulty must be selected while creating or editing the alarm, and saved with that alarm.

#### QR Code mission

- Show QR mission selection.
- Explain that the user must scan their registered QR code.
- Provide a route to QR registration if no code has been registered.
- Do not accept an arbitrary QR code.

### C. Sound and vibration

#### Alarm sound

- Show the currently selected ringtone.
- Provide a preview/play control.
- Provide a ringtone selection screen.
- Include built-in/default ringtones.
- Include an **Add from device** option so the user can select an audio file stored on their phone.
- Display the selected custom ringtone's name.
- Handle a missing or unavailable audio file gracefully.

#### Vibration

- Material 3 toggle.
- Clearly show enabled/disabled state.

### D. Volume

Provide two separate controls:

**Fixed alarm volume**
- Slider from 0% to 100%.
- Display the selected percentage (for example, 50% or 70%).
- Explain that this is the requested alarm playback volume.

**Increasing alarm volume**
- Toggle to enable/disable gradual volume increase.
- When enabled, show a dropdown for ramp-up duration:
    - 15 seconds (default)
    - 30 seconds
    - 45 seconds

Show a short explanation: “Start quieter and gradually reach your selected alarm volume.”

The UI should make it clear that the selected volume and the ramp-up duration are separate settings.

### E. Snooze

- Snooze enable/disable control.
- Snooze interval dropdown or selector (how many minutes before ringing again).
- Snooze limit fixed at **3 times**.
- Show the remaining snoozes on the active alarm screen.

### F. Save

Use a clear primary **Save alarm** button. Validate required fields and show concise error messages near the relevant field.

### Suggested form order

1. Time and repeat schedule
2. Label
3. Mission selection and mission-specific difficulty
4. Sound and vibration
5. Alarm volume and gradual increase
6. Snooze interval and limit
7. Save alarm

Use progressive disclosure so advanced controls do not overcrowd the screen.

---

## 7.3 Active Alarm screen

**Purpose:** Make it immediately obvious that the alarm is ringing and guide the user through the selected mission.

Design:

- Full-screen, high-contrast dark presentation.
- Large readable time.
- Alarm label.
- Clear mission name and instructions.
- Show one mission at a time.
- Show mission progress if multiple missions are required.
- Snooze button with remaining snoozes (for example, “Snooze · 2 left”).
- Visible recovery option.
- No accidental dismiss button.

The active alarm screen should remain high-contrast regardless of the app's selected Light or Dark theme. Never obstruct emergency calling or Android safety functions.

---

## 7.4 Maths Mission screen

Include:

- “Solve to dismiss” instruction.
- Selected difficulty label: Easy, Medium or Hard.
- Large maths question.
- Answer input or answer choices.
- Submit button.
- Clear incorrect-answer feedback.
- Clear success feedback.

The question complexity must match the difficulty selected for this alarm.

---

## 7.5 QR Mission screen

Include:

- Camera preview.
- Clear scanning frame.
- Instruction: “Scan your registered QR code.”
- Camera permission explanation and recovery if permission is denied.
- Success state for the correct registered code.
- Error state for an invalid or unregistered code.
- Route to recovery if scanning cannot be completed.

Only the user's registered, app-generated QR code should pass verification.

---

## 7.6 Correct Typing Mission screen

Include:

- “Type exactly to dismiss” instruction.
- Selected difficulty label.
- Displayed phrase or sentence.
- Text input field.
- Submit button.
- Clear mismatch feedback.
- Success feedback when the text matches.

Text length and complexity must match the difficulty selected for this alarm. Make the input large enough for comfortable typing.

---

## 7.7 QR Registration screen

Include:

- Short explanation of what the QR code is used for.
- Generate/register QR code action.
- Display of the user's generated QR code.
- Save/print/share guidance so the user can place it away from their bed.
- Replace/regenerate action with a clear confirmation.
- Registered status.

The registered code must be associated with the user's app data. Replacing it should invalidate the previous code.

---

## 7.8 Streak dashboard

**Purpose:** Encourage consistent, on-time wake-ups.

Include:

- Large current streak number with flame icon.
- Streak calendar.
- Longest streak.
- Wake-up score.
- Achievement milestones: 3, 7, 14 and 30 days.
- Progress indicator toward the next milestone.

### Streak calendar states

Use distinct, labelled states for:
- Successful on-time wake-up.
- Missed wake-up.
- Future day.
- Today / pending.

### Streak rules reflected in the UI

- A streak increases only after a successful on-time alarm completion.
- Snoozing alone does not count as a successful wake-up.
- Multiple alarms on the same local calendar day must not award duplicate daily streak credit.
- Missed-day and reset behaviour should be communicated clearly.
- Do not claim the app treats sleep disorders or guarantees behaviour change.

---

## 7.9 History screen

Include:

- Completed alarms.
- Missed alarms.
- Alarm date and scheduled time.
- Completion time where available.
- Mission(s) completed.
- Snooze count.
- Clear visual distinction between completed and missed entries.
- Empty state when there is no history.

---

## 7.10 Settings screen

Group settings into clear sections.

### Alarm preferences
- Default ringtone.
- Add ringtone from device / manage selected custom ringtone.
- Vibration preference.
- Default snooze interval.
- Snooze limit information (3 times).
- Default alarm volume.
- Gradual volume increase preference and duration.
- Automatic alarm stop duration.

### Missions and recovery
- QR registration / replacement.
- Recovery code information.

### Android reliability
- Exact alarm permission status.
- Full-screen alarm permission status.
- Battery optimisation guidance.
- Notification permission status where relevant.
- Camera permission status where relevant.
- Clear instructions for missing permissions.

### Appearance
- Light
- Dark
- System default

---

## 8. Light and dark mode behaviour

Support three appearance choices:

1. **Light:** Always use the Light theme.
2. **Dark:** Always use the Dark theme.
3. **System default:** Follow the Android system appearance.

Requirements:

- Use the colour tokens in Section 3.
- Keep layout and hierarchy consistent across themes.
- Check cards, inputs, dialogs, bottom sheets, icons, borders, disabled states and error states in both themes.
- Do not create dark mode by simply inverting the light palette.
- Maintain readable contrast.
- The active alarm screen may use its own high-contrast dark presentation for visibility.

---

## 9. Interaction, accessibility and feedback

- Use clear text labels for important actions; do not rely on icons alone.
- Keep touch targets at least 48 × 48 dp.
- Support Android font scaling without clipping essential content.
- Provide clear validation messages near invalid fields.
- Provide loading, success, error and disabled states.
- Use haptic feedback sparingly.
- Keep animations short and non-blocking.
- Ensure the recovery option remains discoverable.
- Do not obstruct emergency calls.
- Confirm destructive actions such as deleting an alarm or replacing a registered QR code.
- Make alarm sound preview and custom ringtone selection understandable.

---

## 10. Flutter implementation guidance

| Area | Recommendation |
|---|---|
| Framework | Flutter |
| Design system | Material 3 |
| Theme | Separate Light and Dark `ThemeData` |
| Colour management | Centralised colour tokens / `ColorScheme` |
| Font | Roboto |
| Icons | Material Icons / Material Symbols |
| Time picker | Material time picker |
| Weekday selection | Material choice chips or compact selector |
| Difficulty selection | Segmented control or radio selector |
| Volume | Slider with numeric percentage |
| Volume ramp duration | Dropdown: 15 / 30 / 45 seconds |
| Snooze interval | Dropdown or compact selector |
| Navigation | Four-item bottom navigation |
| Layout | Responsive Flutter widgets |

### Reusable widgets

Create reusable components for:

- Next alarm card
- Alarm list tile/card
- Alarm time display
- Weekday selector
- Mission selector
- Difficulty selector
- Ringtone selector row
- Volume slider
- Gradual volume dropdown
- Snooze settings row
- Streak summary card
- Achievement item
- Permission status row
- Primary / secondary buttons
- Empty states and confirmation dialogs

Keep alarm scheduling and Android reliability logic separate from presentation widgets.

---

## 11. Final implementation checklist

### Traditional alarm

- [ ] Create alarm
- [ ] Edit alarm
- [ ] Delete alarm
- [ ] Enable / Disable alarm
- [ ] One-time alarm
- [ ] Repeat on selected weekdays
- [ ] Custom alarm label
- [ ] Default label: “Alarm”
- [ ] Select alarm sound
- [ ] Add custom ringtone from phone storage
- [ ] Vibration
- [ ] Snooze
- [ ] Select snooze interval
- [ ] Snooze limit: 3 times
- [ ] Next alarm display
- [ ] Duplicate alarm
- [ ] Fixed alarm volume slider (0–100%)
- [ ] Gradual volume increase toggle
- [ ] Gradual increase duration: 15 seconds by default, 30 or 45 seconds selectable

### Wake-up missions

- [ ] Maths Problem — Easy / Medium / Hard
- [ ] QR Code — registered code only
- [ ] Correct Typing — Easy / Medium / Hard
- [ ] Maths and Typing difficulty configured independently for each alarm

### Streak and gamification

- [ ] Daily wake-up streak
- [ ] Streak calendar
- [ ] Achievement milestones: 3, 7, 14 and 30 days
- [ ] Longest streak
- [ ] Wake-up score

### Android reliability and safety

- [ ] Exact alarm permission
- [ ] Full-screen alarm permission
- [ ] Alarm works when app is closed
- [ ] Alarm works when phone is locked
- [ ] Restore alarms after phone restart
- [ ] Battery optimisation guidance
- [ ] Do Not Disturb handling
- [ ] Recovery code
- [ ] Automatic alarm stop after configured duration
- [ ] Emergency calls remain accessible
- [ ] Prevent duplicate alarms

### Essential UI

- [ ] Home dashboard
- [ ] Alarm creation / editing screen
- [ ] Active alarm screen
- [ ] Maths mission screen
- [ ] Typing mission screen
- [ ] QR mission screen
- [ ] QR registration screen
- [ ] Streak dashboard
- [ ] History screen
- [ ] Settings screen
- [ ] Light theme
- [ ] Dark theme
- [ ] System default theme option

---

## 12. Final design identity

**Super Sleep should look like a simple, trustworthy Google-style Android app.**

- Blue communicates action, clarity and selection.
- Amber highlights streaks and achievements.
- Neutral surfaces keep the interface calm.
- Mission difficulty is selected independently for Maths and Typing on each alarm.
- Traditional alarm settings are organised into clear sections.
- Light and Dark themes share the same layout and interaction patterns.
- The active alarm screen is high-contrast and focused on helping the user complete the selected mission safely.

**Design priority:** Make the app immediately understandable, comfortable to use and consistent across every screen. Functional alarm reliability takes priority over decorative polish.
