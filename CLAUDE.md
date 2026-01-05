# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Learnt is a minimal iOS app for tracking daily learnings. Multiple entries per day, voice or text. AI-generated summaries in v2+.

**Philosophy:** Every element must earn its place. If removing something makes the app clearer, cut it.

## Tech Stack

- Swift 5.9+ / SwiftUI / iOS 17+
- SwiftData (local storage, no cloud in v1)
- Speech framework for voice transcription
- iPhone only (no iPad for v1)

## Build Commands

```bash
# Build and run on simulator (preferred - use the slash command)
/build-run

# Manual build
xcodebuild -project Learnt/Learnt.xcodeproj -scheme Learnt -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Open in Xcode
open Learnt.xcodeproj
```

## Slash Commands

- `/build-run` - Build and launch in iOS Simulator
- `/commit` - Stage, commit with good message, and push
- `/screenshot` - Capture and analyze current simulator UI
- `/new-screen [Name]` - Create a new SwiftUI view following project structure
- `/feature [description]` - Full feature development workflow (plan, confirm, build, test)

## Design System (Critical)

**Invoke `/learnt-design` skill for any UI work.**

### Monochrome Only - No Accent Colors

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Background | `#FAFAFA` | `#1A1A1A` |
| Primary text | `#1A1A1A` | `#FAFAFA` |
| Secondary text | `#6B6B6B` | `#9B9B9B` |
| Dividers | `#E8E8E8` | `#2A2A2A` |
| Input fields | `#F5F5F5` | `#252525` |

### Typography
- **All fonts:** New York serif via `.system(.size, design: .serif)`
- **Hierarchy:** Size and weight only, never color for emphasis
- **Icons:** SF Symbols only, regular weight, never filled except to show completion on the calendar view. (clarify if required)

### Spacing
- 8pt grid: 8, 16, 24, 32, 40, 48
- Card padding: 16pt, screen margins: 16pt, section spacing: 24pt
- Corner radius: 12-16pt for cards, 50% for circular buttons

## Code Style

- Use `@Observable` (not `ObservableObject`) for iOS 17+
- SwiftUI previews for ALL views
- Max ~100 lines per view file
- Name files after their primary type

## Architecture

### Data Model
```swift
@Model
class LearningEntry {
    var id: UUID
    var content: String
    var date: Date  // Normalized to start of day
    var createdAt: Date
    var updatedAt: Date
    var isVoiceEntry: Bool
    var sortOrder: Int  // For ordering within a day
    // Multiple entries per day allowed
}
```

### Navigation
- 3-tab bar: Insights | Today | You
- Today screen: swipe RIGHT = back in time, LEFT = forward (can't pass today)
- Pull down on Today = calendar overlay

### Key Constraints
- Multiple entries per day (collapsed preview, tap to expand, edit button when expanded)
- Voice transcription starts immediately on mic tap
- Local-first, no sync in v1

## Anti-patterns (DO NOT)

- Bright colors or gradients
- Gamification (points, levels, achievements)
- Hamburger menus
- Skeleton loading states (app is local, instant)
- SF Symbols with fill (use regular weight, except selected states)
- Animations longer than 300ms

## v2 Features (Planned)

- **Categories:** 4 preset (Personal, Work, Learning, Relationships) with SF Symbol icons
- AI auto-categorization in v3

## Current Focus

See `roadmap.md` for version planning. Currently building v1 MVP.
