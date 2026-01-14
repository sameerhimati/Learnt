# Learnt Roadmap

## Timeline

- **v1 (MVP):** January 4-18 (2 weeks) → TestFlight to friends/family ✅
- **v2 (Enhanced):** January 19-31 → Broader TestFlight ✅
- **v2.5 (Pre-Launch Polish):** January → Sharing, Favorites, Streaks ✅
- **v3 (AI & Launch):** February → On-device AI + App Store submission
- **Launch:** Mid-February → App Store

---

## v1 - MVP ✅ COMPLETE

**Goal:** Core loop works. You can use it daily.

### Must Have (Ship Blockers)
- [x] Today screen with date display
- [x] Add entry via text input
- [x] Add entry via voice input (Speech framework)
- [x] View today's entry
- [x] Swipe between days (back in time only from today)
- [x] Activity dots showing current week
- [x] Local persistence (SwiftData)
- [x] Multiple entries per day support
- [x] Edit existing entry
- [x] Dark mode support
- [x] Bottom tab bar (3 tabs)
- [x] Basic Insights tab (list of all entries)
- [x] Basic Profile tab (entry count, streak)

### Nice to Have
- [x] Calendar overlay (pull down)
- [x] Tap dots to navigate
- [x] Haptic feedback
- [x] Keyboard avoidance polish
- [ ] App icon (using placeholder)

---

## v2 - Enhanced ✅ COMPLETE

**Goal:** Polish for real users. Richer insights.

### Features
- [x] Categories (4 preset: Personal, Work, Learning, Relationships)
  - [x] Category selector on entry creation
  - [x] Category icon on entry cards
  - [x] Category filtering in Insights
- [x] Guided reflection prompts (Application, Surprise, Simplification, Question)
- [x] Spaced repetition review system
- [x] Notification reminders (configurable capture + review times)
- [x] Calendar overlay with full month view
- [x] Entry search
- [x] Proper onboarding (3 screens max)
- [x] Settings screen
  - [x] Notification time
  - [x] Theme toggle (system default)
- [x] Haptic feedback throughout
- [x] Smooth animations (300ms transitions)
- [x] Empty state illustrations
- [x] Custom tab bar design

### Deferred to Post-Launch
- [ ] iCloud sync (CloudKit)
- [ ] Export to JSON/CSV

---

## v2.5 - Pre-Launch Polish ✅ COMPLETE

**Goal:** Shareable templates, engagement features, transcription polish.

### Shareable Visual Templates
- [x] ShareImageService (SwiftUI → UIImage rendering)
- [x] ShareableCardView base component (monochrome design)
- [x] LearningShareCard (single entry template)
- [x] StreakShareCard (milestone template)
- [x] ShareEntrySheet (share individual entries)
- [x] StreakShareSheet (share streak from profile)

### Monthly Wrapped (Spotify-style)
- [x] WrappedView with 5 swipeable cards
  - Intro with period name
  - Total learnings + days active
  - Top categories breakdown
  - Streak stats (current + longest)
  - Summary with share option
- [x] "Your Month" button in Profile

### Streak System
- [x] StreakService with milestone logic
- [x] Milestones: 3, 7, 14, 30, 60, 90, 180, 365 days
- [x] StreakCelebrationView modal
- [x] Celebration messages per milestone

### Favorites/Bookmarks
- [x] isFavorite field on LearningEntry
- [x] Heart toggle on expanded cards
- [x] Favorite indicator on card preview

### Voice Transcription
- [x] Optional transcription toggle after recording
- [x] Editable transcription text field
- [x] Transcription stored with entry

---

## v3.1 - Review System Overhaul ✅ COMPLETE

**Goal:** Science-backed spaced repetition. Library for browsing learnings.

### Review System Redesign
- [x] Science-backed intervals (1 → 7 → 16 → 35 days)
  - Based on Huberman Lab forgetting curve research
  - Optimal spacing for long-term retention
- [x] Auto-graduation after N reviews (default 4, configurable 3-6)
- [x] Simplified review flow: show learning → "Still with you?" → Got it / Review again
  - Removed quiz phase (no "What do you remember?" prompt)
  - Learnings as gentle reminders, not memorization tests
- [x] 2-button outcome: "Got it" (advance interval) / "Review again" (reset to 1 day)
- [x] Progress ring visualization in Review tab
- [x] Status messages ("3 learnings ready to reinforce", "Next review in 2 days")
- [x] Science note explaining the interval system
- [x] Graduation threshold setting in Profile

### Library Feature
- [x] Library modal accessible from Today header and Profile
- [x] Search learnings by content
- [x] Filter by All / Favorites / Graduated
- [x] Category filtering with counts
- [x] Entry detail view with reflections and review progress
- [x] Proper toolbar title formatting

---

## v3.2 - TestFlight Ready ✅ COMPLETE

**Goal:** Final polish for TestFlight submission.

### App Polish
- [x] Portrait-only mode (no landscape)
- [x] Splash screen with "Learnt" branding
- [x] 3-screen onboarding flow (Welcome, How It Works, Get Started)
- [x] Bold Spotify Wrapped-style share cards (1080x1920)
- [x] Share button in Library entries
- [x] Image/Text toggle for all share sheets
- [x] Dark mode border on share cards

### TestFlight Checklist
- [ ] App icon (1024x1024, light/dark/tinted variants)
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] App Store Connect setup
- [ ] Archive and upload

---

## v4 - Review Types (Planned)

**Goal:** Two types of learnings with different review experiences.

### Learning Types
- [ ] "Quiz me" type - Active recall with text input
  - "What do you remember about..." prompt
  - User types recall attempt
  - Reveal and compare
  - Best for: Facts, concepts, techniques
- [ ] "Remind me" type - Just show the learning
  - Display learning immediately
  - "Still with you?" prompt
  - Best for: Quotes, wisdom, principles
- [ ] Type selector when creating entry
- [ ] Default to "Remind me" for most content

---

## v5 - AI-Contextual Reviews (Planned)

**Goal:** AI generates appropriate review experiences based on content.

### Intelligent Review Prompts
- [ ] AI analyzes learning content type
- [ ] Facts → Quiz questions ("What % boost do walking meetings give?")
- [ ] Wisdom → Reflection prompts ("How have you applied this recently?")
- [ ] Concepts → Explanation requests ("Explain spaced repetition in your own words")
- [ ] Uses Apple Intelligence (on-device, zero API cost)
- [ ] Graceful fallback for non-AI devices

---

## v6 - AI & Launch (Future)

**Goal:** Ship to App Store. On-device AI makes it magical.

### On-Device AI Features (Apple Intelligence - Zero API Cost)
- [ ] AI reflection question generation
  - Contextual prompts based on entry content
  - Uses Apple Foundation Models
- [ ] AI auto-categorization
  - Suggest category based on content
  - User confirms or changes
- [ ] AI monthly summaries for Wrapped
  - Theme detection
  - Pattern insights
  - Standout entries
- [ ] Graceful fallback if device doesn't support AI

### Premium Features (One-Time Purchase $4.99-9.99)
- [ ] Unlock shareable templates (entry, streak, wrapped)
- [ ] Advanced insights/analytics
- [ ] Custom categories beyond 4 presets
- [ ] Widgets

### Launch Checklist
- [ ] App Store screenshots (6.5" and 5.5")
- [ ] App Store description
- [ ] Privacy policy (host on itamih.com)
- [ ] Support URL
- [ ] App review notes
- [ ] Keywords research
- [ ] Category selection (Lifestyle or Productivity)
- [ ] Final app icon design
- [ ] StoreKit IAP implementation

---

## Feature Ideas (Backlog)

Parking lot for future consideration:

- "Talk to your learnings" chat interface
- Widget for home screen
- iPad support
- Mac Catalyst
- Apple Watch quick entry
- Siri shortcuts ("Hey Siri, I learned...")
- Multiple journals (personal, work)
- Entry templates
- Attachments (photos of notes)
- Integration with Apple Notes
- Streak recovery (premium)
- Entry prompts when stuck
- iCloud sync
- Export to JSON/CSV

---

## Technical Debt to Address

Track items to fix but not block shipping:

- [ ] (Add as discovered)

---

## Decisions Log

Record key decisions and rationale:

| Date | Decision | Rationale |
|------|----------|-----------|
| Jan 4 | iOS only, no iPad | Focus. Ship faster. |
| Jan 4 | SwiftData over Core Data | Modern, less boilerplate |
| Jan 4 | New York serif font | Native iOS, no font loading |
| Jan 4 | Multiple entries per day | Flexibility over constraint |
| Jan 4 | Categories in v2 | Organization with minimal friction (4 preset categories) |
| Jan 4 | Voice in v1 | Essential to vision |
| Jan 4 | Local-first | Ship faster, add sync in v2 |
| Jan 9 | On-device AI via Apple Intelligence | Zero API cost, privacy-friendly |
| Jan 9 | Shareables as premium unlock | AI is free (on-device), templates are value |
| Jan 9 | No auth/accounts | StoreKit handles purchases, zero backend |
| Jan 9 | Affiliate marketing over paid ads | Better ROI for self-help apps |
| Jan 9 | Monochrome share templates | Match app aesthetic, stand out on social |
| Jan 9 | Optional voice transcription | User choice, editable after generation |
| Jan 14 | Simplified review (no quiz phase) | Goal is spaced exposure, not memorization testing |
| Jan 14 | Science-backed intervals (1,7,16,35) | Huberman Lab forgetting curve research |
| Jan 14 | Auto-graduation after 4 reviews | Prevents infinite review loops |
| Jan 14 | Portrait-only, iPhone-only | Focus on core experience, no landscape distractions |
| Jan 14 | Spotify Wrapped-style share cards | Design at 1080x1920, preview scaled down for crisp exports |
| Jan 14 | 3-screen onboarding | Minimal introduction, request notifications on final screen |

---

## Marketing Strategy

### Launch Approach
- **Free at launch** with all core features
- Build user base, gather feedback
- Add premium unlock after establishing traction

### Marketing Channels
- **Influencer/Affiliate Marketing** (Primary)
  - Target: Self-improvement, productivity, journaling creators
  - Platforms: TikTok, Instagram, YouTube
  - Offer: Revenue share or flat fee per install
- **Organic Content**
  - Share templates designed for social virality
  - User-generated content from shareable cards
- **App Store Optimization**
  - Keywords: learning journal, daily reflection, voice journal

### Monetization
- **Free Tier:** All core features (capture, review, streaks, AI)
- **Premium ($4.99-9.99 one-time):**
  - Visual share templates (entry, streak, wrapped)
  - Advanced analytics
  - Custom categories
  - Widgets
