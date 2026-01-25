# Learnt Roadmap

## Current Status

**TestFlight Live** - 12 testers
**Development Resumed** - January 25, 2026

---

## Vision

**From:** Daily learning journal (text/voice entries)
**To:** Personal knowledge bank with zero-friction capture and active recall

**Core Differentiators:**
- Mobile-first (not a web app ported to mobile)
- Zero-friction capture (share sheet, quick entry)
- Forces reflection moment ("what did you learn from this?")
- Active recall prompts (spaced repetition that actually works)
- AI-powered categorization and insights

---

## Completed Versions

### v1 - MVP ✅

Core capture and review loop.

- Today screen with date display and navigation
- Text and voice input with transcription
- Swipe between days (back in time only)
- Activity dots showing current week
- Multiple entries per day
- Edit existing entries
- Dark mode support
- 3-tab navigation (Insights | Today | You)
- Calendar overlay (pull down)
- Local persistence (SwiftData)
- Haptic feedback

### v2 - Enhanced ✅

Polish for real users.

- Categories (4 preset: Personal, Work, Learning, Relationships)
- Guided reflection prompts
- Spaced repetition review system
- Notification reminders (capture + review times)
- Full calendar with month view
- Entry search
- 3-screen onboarding
- Settings (notifications, theme, appearance)
- Custom tab bar design
- Empty states

### v2.5 - Pre-Launch Polish ✅

Sharing and engagement.

- ShareImageService (SwiftUI → UIImage at 1080x1920)
- LearningShareCard (single entry template)
- StreakShareCard (milestone template)
- Image/Text toggle on all share sheets
- Monthly Wrapped ("Your Month" view)
  - Stats (learnings, days, streak)
  - Top categories
  - Past months browser
- Streak system with milestones (3, 7, 14, 30, 60, 90, 180, 365)
- Streak celebration modal
- Favorites/bookmarks with heart toggle
- Voice transcription (optional, editable)

### v3.1 - Review System Overhaul ✅

Science-backed spaced repetition.

- Intervals: 1 → 7 → 16 → 30 → 45 → 60 days (Huberman Lab research)
- Auto-graduation after N reviews (configurable 3-6, default 4)
- Simplified flow: show learning → "Still with you?" → Got it / Review again
- Progress ring visualization
- Status messages ("3 learnings ready to reinforce")
- Graduation threshold setting

### v3.2 - TestFlight Ready ✅

Final polish for external testing.

- Portrait-only mode
- Splash screen ("L" → "Learnt" animation, 4.5s)
- App icons (light, dark, tinted variants)
- Coach marks system for first-time users
- Library modal (search, filter by All/Favorites/Graduated/Category)
- Bold Spotify Wrapped-style share cards
- Dark mode border on share cards

### v3.3 - AI Foundation ✅

On-device AI infrastructure (ready for iOS 26).

- AIService using Apple Foundation Models
- Category auto-suggestion (iOS 26+)
- Reflection prompt generation (iOS 26+)
- Monthly AI summaries for Wrapped (iOS 26+)
- Graceful fallback for iOS 18-25
- Mock implementations for testing

---

## What's Built

### 49 Swift Files

**Models (2)**
- LearningEntry (content, reflections, spaced repetition, categories, audio, favorites, graduation)
- Category (name, icon, preset flag)

**Services (11)**
- AIService - On-device AI via Foundation Models
- CategoryService - Category CRUD and presets
- CoachMarkService - First-time user guidance
- EntryStore - SwiftData operations
- MockDataService - Test data generation
- NotificationService - Capture/review reminders
- QuoteService - Daily inspirational quotes
- SettingsService - UserDefaults wrapper
- ShareImageService - SwiftUI → UIImage rendering
- StreakService - Milestone tracking
- VoiceRecorderService - Audio recording/playback

**Views (35)**
- Today: TodayView, LearningCard, WeekActivityRow, AddButton, QuoteCard, EmptyStateView
- Input: AddLearningView, VoiceRecordingView, CategoryPicker, AddCategoryView
- Review: ReviewView, ReviewSessionView
- Calendar: CalendarOverlay
- Library: LibraryView
- Profile: ProfileView, ReminderSettingsView
- Share: WrappedView, ShareEntrySheet, ShareSheetView, ShareableCardView, LearningShareCard, StreakShareCard, StreakShareSheet
- Celebration: StreakCelebrationView
- Onboarding: OnboardingView
- Launch: SplashView
- Components: CustomTabBar, CoachMarkView, AudioPlaybackButton
- Main: LearntApp, MainTabView

**Utilities (2)**
- Date+Extensions
- Color+Theme

### Data Model

```swift
LearningEntry {
    id, content, date, createdAt, updatedAt, sortOrder
    application, surprise, simplification, question  // Reflections
    nextReviewDate, reviewInterval, reviewCount      // Spaced repetition
    categories: [Category]                           // Many-to-many
    contentAudioFileName, transcription              // Voice
    isFavorite, isGraduated                          // Status
}
```

### Features Summary

| Feature | Status |
|---------|--------|
| Text entry | ✅ |
| Voice entry with transcription | ✅ |
| Multiple entries per day | ✅ |
| Categories (4 preset) | ✅ |
| Reflection prompts | ✅ |
| Spaced repetition (35-day cap, see v2) | ⏳ Updating |
| Auto-graduation | ✅ |
| Favorites | ✅ |
| Search | ✅ |
| Calendar navigation | ✅ |
| Notifications | ✅ |
| Streaks + milestones | ✅ |
| Monthly Wrapped | ✅ |
| Share cards (entry, streak, wrapped) | ✅ |
| AI summaries | ✅ (iOS 26+) |
| Dark mode | ✅ |
| Onboarding | ✅ |
| Coach marks | ✅ |
| App icons (light/dark/tinted) | ✅ |

---

## Future Versions

### TestFlight v2 - Bug Fixes & Core Improvements

**Goal:** Address user feedback, improve core experience. Cost: $0

**Bugs (from TestFlight feedback)**
- [ ] Fix splash animation (smooth the "L" → "Learnt" transition, currently choppy)
- [ ] Reset to today on app launch (currently stays on last viewed day)
- [ ] Fix edit button overlap with + button (3+ entries)
- [ ] Rethink date/navigation UX (arrows + date more prominent, swipe not intuitive)
- [ ] Fix AI summary or graceful fallback for iOS <26 (shows "keep learning, keep growing")

**Capture Friction**
- [ ] Share sheet extension (share links/text from anywhere → creates new learning)

**Spaced Repetition Overhaul**
- [ ] Timer starts on first reflection, not entry creation
- [ ] Cap all intervals at 35 days max
- [ ] Adjust intervals for graduation threshold:
  - 3 reviews: 7 → 21 → 35 days
  - 4 reviews: 7 → 14 → 28 → 35 days
  - 5 reviews: 5 → 12 → 21 → 28 → 35 days
  - 6 reviews: 4 → 9 → 16 → 23 → 30 → 35 days

**Library & Organization**
- [ ] Filter by category/date
- [ ] Bulk review functionality
- [ ] Bulk summarize functionality

**Polish**
- [ ] Keep quotes from previous days (persist, not just today)
- [ ] Review by label / re-review graduated learnings

---

### TestFlight v3 / App Store Launch

**Goal:** Cloud infrastructure and public release. Cost: ~$0-20/month

**Infrastructure**
- [ ] User authentication (Firebase Auth or Supabase - free tier)
- [ ] Cloud sync (CloudKit for iOS-only, or Supabase for future flexibility)
- [ ] Offline-first with sync when connected
- [ ] Data migration path from local-only to cloud

**Media Support**
- [ ] Photo attachments on learnings
- [ ] Image storage (Firebase Storage / S3 / CloudKit)

**App Store Requirements**
- [ ] Privacy policy URL (host on itamih.com)
- [ ] Support URL
- [ ] App Store screenshots (6.5" and 5.5")
- [ ] App Store description and keywords
- [ ] App review notes
- [ ] Category selection (Lifestyle or Productivity)

---

### Post-Launch

**Goal:** AI-powered knowledge bank. Cost: ~$0.10-0.30/user/month

**Media Interpretation**
- [ ] AI vision to understand photos (Claude/GPT-4o Vision API)
- [ ] OCR for handwritten notes, whiteboards
- [ ] Smart extraction from screenshots

**Advanced Review**
- [ ] Quizzing functionality (not just "still with you?")
- [ ] AI-generated questions based on learning content
- [ ] Spaced repetition for image-based learnings

**Premium Features**
- [ ] StoreKit subscription implementation
- [ ] Paywall UI
- [ ] Custom categories beyond 4 presets
- [ ] Widgets (home screen, lock screen)
- [ ] Export to JSON/CSV

---

### Future Vision (Later)

- "Talk to your learnings" chat interface (RAG)
- Personal SLM trained on user's knowledge
- iPad support
- Mac Catalyst
- Apple Watch quick entry
- Siri shortcuts ("Hey Siri, I learned...")

---

## Cost Projections

| Stage | Infrastructure | AI Costs | Total/month |
|-------|---------------|----------|-------------|
| TestFlight v2 | $0 | $0 (on-device) | $0 |
| App Store Launch | ~$5-20 | $0 | ~$5-20 |
| Post-Launch (1k users) | ~$20 | ~$50-100 | ~$70-120 |
| Scale (10k users) | ~$100 | ~$300-500 | ~$400-600 |

---

## Technical Notes

### iOS Version Support

| iOS Version | AI Features |
|-------------|-------------|
| 18-25 | Core app works, AI summaries disabled |
| 26+ | Full AI via Foundation Models (on-device) |

No API keys required. AI runs locally on A17 Pro / M1+ devices.

### Known Issues (from TestFlight)

**Bugs:**
1. Splash animation choppy
2. App doesn't reset to today on launch
3. Edit button hidden by + button (3+ entries)
4. AI summary not generating (iOS 26 only)

**UX Issues:**
- Date tap → today not discoverable
- Swipe navigation not intuitive
- Calendar/share icons could move to make room for date + arrows

---

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| Jan 4 | iOS only, no iPad | Focus. Ship faster. |
| Jan 4 | SwiftData over Core Data | Modern, less boilerplate |
| Jan 4 | New York serif font | Native iOS, no font loading |
| Jan 4 | Multiple entries per day | Flexibility over constraint |
| Jan 4 | Categories in v2 | Organization with minimal friction |
| Jan 4 | Voice in v1 | Essential to vision |
| Jan 4 | Local-first | Ship faster, add sync later |
| Jan 9 | On-device AI via Apple Intelligence | Zero API cost, privacy-friendly |
| Jan 9 | Shareables as premium unlock | AI is free (on-device), templates are value |
| Jan 9 | No auth/accounts | StoreKit handles purchases, zero backend |
| Jan 9 | Monochrome share templates | Match app aesthetic, stand out on social |
| Jan 9 | Optional voice transcription | User choice, editable after generation |
| Jan 14 | Simplified review (no quiz phase) | Goal is spaced exposure, not memorization |
| Jan 14 | Science-backed intervals | Huberman Lab forgetting curve research |
| Jan 14 | Auto-graduation after 4 reviews | Prevents infinite review loops |
| Jan 14 | Portrait-only, iPhone-only | Focus on core experience |
| Jan 14 | Spotify Wrapped-style cards | 1080x1920, preview scaled for crisp exports |
| Jan 14 | 3-screen onboarding | Minimal introduction |
| Jan 16 | Development pause | TestFlight live, gathering feedback |
| Jan 25 | Vision pivot | From journal → personal knowledge bank with active recall |
| Jan 25 | Spaced rep overhaul | Timer from first reflection, 35-day cap, higher frequency |
| Jan 25 | 3-month free trial | Hook users before conversion, subscription model |
| Jan 25 | Share sheet priority | Zero-friction capture is core to new vision |
| Jan 25 | Cloud sync in v3 | Required for cross-device and future AI features |

---

## Marketing Strategy

### Launch Approach
- 3-month free trial with all features
- Users build habit and data moat
- Convert to subscription after trial

### Marketing Channels
- **Influencer/Affiliate** (Primary) - Self-improvement creators
- **Organic** - Shareable cards designed for social virality
- **ASO** - Keywords: learning journal, knowledge bank, daily reflection, voice journal, active recall

### Monetization
- **Trial (3 months):** All features free
- **Subscription (TBD pricing):** Required after trial for continued access
- **Open questions:**
  - What happens after trial? Read-only or locked?
  - Monthly vs yearly pricing?
  - Family sharing?
