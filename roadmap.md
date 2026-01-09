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

## v3 - AI & Launch (Current)

**Goal:** Ship to App Store. On-device AI makes it magical.

### On-Device AI Features (Apple Intelligence - Zero API Cost)
- [ ] AI reflection question generation
  - Contextual prompts based on entry content
  - Uses Apple Foundation Models (iOS 17.4+)
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
