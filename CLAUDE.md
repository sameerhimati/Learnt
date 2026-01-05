# Learnt

A minimal iOS app for tracking daily learnings. One entry per day, voice or text. AI-generated summaries in v2.

## Philosophy

**Every element must earn its place.** If removing something makes the app clearer, cut it.

This is a stoic aesthetic - not Roman columns and Latin quotes, but restraint, intention, and truth. The app should feel like:
- A well-made journal
- A meditation room
- Morning coffee alone

NOT like:
- A productivity tool
- A game with streaks and badges
- A social network

## Tech Stack

- **Language:** Swift 5.9+
- **UI:** SwiftUI (iOS 17+)
- **Storage:** SwiftData (local only for v1)
- **Voice:** Speech framework for transcription
- **Target:** iPhone only (no iPad for v1)
- **Minimum iOS:** 17.0

## Design System

### Typography
- **Primary font:** New York (iOS system serif) - use `.serif` design
- **Fallback concept:** EB Garamond aesthetic - classic, readable, refined
- **Hierarchy:** Size and weight only, never color for emphasis

### Colors (NO accent colors - monochrome only)

**Light Mode:**
- Background: `#FAFAFA`
- Primary text: `#1A1A1A`
- Secondary text: `#6B6B6B`
- Dividers/borders: `#E8E8E8`
- Input fields: `#F5F5F5`

**Dark Mode:**
- Background: `#1A1A1A`
- Primary text: `#FAFAFA`
- Secondary text: `#9B9B9B`
- Dividers/borders: `#2A2A2A`
- Input fields: `#252525`

### Spacing
- All spacing in 8pt increments (8, 16, 24, 32, 40, 48)
- Generous whitespace - when in doubt, add more space
- Corner radius: 12-16pt for cards, 50% for circular buttons

### Icons
- SF Symbols only
- Line weight: regular or light
- Never filled icons except for selected states

## App Structure

### Screens

1. **Today (Main)** - Center tab
   - Date display (e.g., "Monday, January 6")
   - Today's entry (or empty state)
   - Activity dots for current week (filled = has entry)
   - Floating + button at bottom

2. **Input (Modal/Expansion)**
   - Mic button for voice
   - Text button for keyboard
   - Expandable text field
   - Save/cancel actions

3. **Calendar (Overlay)**
   - Pull down from top to reveal
   - Month grid view
   - Dots on dates with entries
   - Tap date to navigate

4. **Insights (Left tab)**
   - Monthly summary cards (v2)
   - Yearly recap (v2)
   - For v1: placeholder or simple list of all entries

5. **You (Right tab)**
   - Current streak count
   - Total entries
   - Settings (notification time, theme)
   - Export data
   - Premium upsell (future)

### Navigation

- Bottom tab bar with 3 tabs: Insights | Today | You
- Swipe gestures on Today screen:
  - Swipe RIGHT = go back in time (yesterday, etc.)
  - Swipe LEFT = go forward toward today (only when viewing past)
  - Cannot swipe past today
- Pull down on Today = reveal calendar overlay

### Core Data Model

```swift
@Model
class LearningEntry {
    var id: UUID
    var content: String
    var date: Date  // Normalized to start of day
    var createdAt: Date
    var updatedAt: Date
    var isVoiceEntry: Bool
    
    // One entry per calendar day enforced at save time
}
```

## Key Interactions

### Adding an Entry
1. User taps + button
2. Button expands to show mic and text options
3. User chooses input method
4. For voice: start recording immediately, transcribe on stop
5. For text: show text field with keyboard
6. Save stores entry for current date
7. If entry exists for today, this edits it (not creates new)

### Viewing History
1. Swipe right on main screen to go back in time
2. Each day shows that day's entry
3. Activity dots update to show current week context
4. Tap any dot to jump to that day
5. Pull down for calendar to jump to any date

### Empty States
- No entry today: "What did you learn today?" with prominent + button
- No entries ever: Gentle onboarding, same CTA

## Commands

Common tasks I do repeatedly:
- `swift build` - Build the project
- `open Learnt.xcodeproj` - Open in Xcode
- Run on simulator: Cmd+R in Xcode or `xcodebuild` commands

## Code Style

- Use SwiftUI previews for ALL views
- Prefer `@Observable` over `ObservableObject` (iOS 17+)
- Keep views small and composable (max ~100 lines per view file)
- Use extensions to organize View code
- Name files after the primary type they contain
- Group related views in folders

## Anti-patterns (DO NOT DO)

- ❌ Bright colors or gradients
- ❌ Gamification (points, levels, achievements)
- ❌ Social features (sharing to feed, following)
- ❌ Categories or tags for entries
- ❌ Multiple entries per day
- ❌ Complex onboarding flows
- ❌ Settings on the main screen
- ❌ Hamburger menus
- ❌ Pull-to-refresh (not needed)
- ❌ Skeleton loading states (app is local, instant)

## File Organization

```
Learnt/
├── LearntApp.swift              # App entry point
├── Models/
│   └── LearningEntry.swift      # SwiftData model
├── Views/
│   ├── MainTabView.swift        # Tab container
│   ├── Today/
│   │   ├── TodayView.swift      # Main today screen
│   │   ├── EntryCard.swift      # Entry display component
│   │   ├── ActivityDots.swift   # Week activity indicator
│   │   └── AddButton.swift      # Expandable + button
│   ├── Input/
│   │   ├── InputView.swift      # Input modal
│   │   ├── VoiceInput.swift     # Voice recording component
│   │   └── TextInput.swift      # Text entry component
│   ├── Calendar/
│   │   └── CalendarOverlay.swift
│   ├── Insights/
│   │   └── InsightsView.swift   # Monthly/yearly summaries
│   └── Profile/
│       ├── ProfileView.swift    # You tab
│       └── SettingsView.swift
├── Services/
│   ├── EntryStore.swift         # SwiftData operations
│   └── SpeechService.swift      # Voice transcription
├── Utilities/
│   ├── Date+Extensions.swift
│   └── Color+Theme.swift        # Color definitions
└── Resources/
    └── Assets.xcassets
```

## Current Focus

See roadmap.md for version planning. Currently building v1.
