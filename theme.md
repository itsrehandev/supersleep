# Super Sleep — Final UI/UX Specification

**Product:** Super Sleep  
**Platform:** Android  
**Framework:** Flutter  
**Design direction:** Google-inspired simplicity using Material Design 3  
**Tagline:** *Wake up. Show up. Build your streak.*

This document is the final UI/UX reference for the approved Super Sleep implementation. It covers the full feature list, screen structure, interaction details, light and dark themes, and colour specifications.

---

## 1. Product design direction

Super Sleep should feel like a familiar, trustworthy Android app: clean, calm, simple and easy to understand.

### Design principles

- Use a clean layout with generous spacing.
- Keep the next alarm and main actions easy to find.
- Use familiar Material Design patterns.
- Avoid clutter, excessive gradients, decorative illustrations and heavy shadows.
- Use consistent icons, labels, corner radii and spacing.
- Keep the normal app calm and friendly; make the active alarm screen high-contrast and urgent.
- Prioritise clarity and reliability over visual effects.

### Main product areas

1. **Alarms:** Create and manage alarms and their settings.
2. **Missions:** Maths Problem, QR Code and Correct Typing.
3. **Streak:** Daily wake-up streak, calendar, milestones and longest streak.
4. **History:** Completed and missed alarm records.
5. **Settings:** Sound, volume, vibration, appearance, permissions and safety options.

---

## 2. Visual identity

| Property | Specification |
|---|---|
| Design system | Material Design 3 |
| Flutter setting | `useMaterial3: true` |
| Font | Roboto |
| Icons | Material Icons / Material Symbols |
| Primary colour family | Blue |
| Streak / achievement accent | Amber |
| Shapes | Soft rounded corners |
| Elevation | Minimal; prefer tonal surfaces |
| Motion | Subtle transitions, generally 150–250 ms |
| Layout | Responsive, Android-friendly |

---

## 3. Colour system

Use centralised theme tokens and Flutter `ColorScheme` values. Do not scatter individual hex values throughout the widget code.

### 3.1 Light theme

| Token | HEX | Usage |
|---|---|---|
| Primary | `#2563EB` | Main actions, selected navigation, active controls |
| On Primary | `#FFFFFF` | Text/icons on primary controls |
| Primary Container | `#DBEAFE` | Selected cards and soft highlights |
| On Primary Container | `#1E40AF` | Text/icons on primary containers |
| Background | `#F8FAFC` | Main app background |
| On Background | `#0F172A` | Main text |
| Surface | `#FFFFFF` | Cards, dialogs and bottom sheets |
| On Surface | `#0F172A` | Text on surfaces |
| Surface Variant | `#F1F5F9` | Secondary surfaces and input backgrounds |
| On Surface Variant | `#64748B` | Supporting text and inactive icons |
| Outline | `#CBD5E1` | Borders and dividers |
| Success | `#16A34A` | Successful missions and completed alarms |
| Streak / Warning | `#F59E0B` | Streaks, milestones and warnings |
| Error | `#DC2626` | Errors, invalid input and missed alarms |

### 3.2 Dark theme

| Token | HEX | Usage |
|---|---|---|
| Primary | `#8AB4F8` | Main actions, selected navigation, active controls |
| On Primary | `#172554` | Text/icons on primary controls |
| Primary Container | `#1E3A5F` | Selected cards and soft highlights |
| On Primary Container | `#DBEAFE` | Text/icons on primary containers |
| Background | `#121212` | Main app background |
| On Background | `#F8FAFC` | Main text |
| Surface | `#1E1E1E` | Cards, dialogs and bottom sheets |
| On Surface | `#F8FAFC` | Text on surfaces |
| Surface Variant | `#2A2A2A` | Secondary surfaces and input backgrounds |
| On Surface Variant | `#B0B0B0` | Supporting text and inactive icons |
| Outline | `#424242` | Borders and dividers |
| Success | `#4ADE80` | Successful missions and completed alarms |
| Streak / Warning | `#FBBF24` | Streaks, milestones and warnings |
| Error | `#F87171` | Errors, invalid input and missed alarms |

### 3.3 Colour rules

- Blue is the primary action and selection colour.
- Amber is reserved for streaks, achievements and caution.
- Green indicates success.
- Red indicates errors and missed states.
- Use neutral surfaces for most of the interface.
- Never rely on colour alone; pair status colours with text or icons.
- Maintain readable contrast in both themes.
- Avoid using gradients as the default visual treatment.

---

## 4. Typography

Use Roboto consistently.

| Text role | Size | Weight |
|---|---:|---|
| Screen title | 24–26 px | Bold / 700 |
| Section heading | 18–20 px | Semi-bold / 600 |
| Alarm time | 48–56 px | Medium / 500 |
| Card title | 16 px | Semi-bold / 600 |
| Body text | 14–16 px | Regular / 400 |
| Supporting text | 12–14 px | Regular / 400 |
| Button label | 14–16 px | Medium / 500 |
| Small label | 12 px | Medium / 500 |

Use tabular numerals for alarm times, durations and scores where available. Avoid long all-caps labels.

---

## 5. Spacing, shapes and components

### Spacing scale

Use an 8 px base spacing system:

| Value | Usage |
|---:|---|
| 4 px | Small icon/text gap |
| 8 px | Compact spacing |
| 16 px | Standard component spacing |
| 24 px | Section spacing |
| 32 px | Major section spacing |

### Corner radii

| Component | Radius |
|---|---:|
| Cards | 16–20 px |
| Buttons | 12–16 px |
| Input fields | 12–16 px |
| Dialogs / bottom sheets | 20–24 px |
| Chips | Fully rounded |

### Component rules

- Primary action: filled primary-colour button.
- Secondary action: outlined or tonal button.
- Destructive action: clearly labelled red text/button with confirmation when appropriate.
- Inputs: clear labels, readable values and visible validation.
- Switches: Material 3 switches.
- Cards: subtle tonal separation; avoid heavy shadows.
- Tap targets: at least 48 × 48 dp.
- Use consistent Material icons.
- Respect Android system insets and navigation areas.

---

