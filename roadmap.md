# Learnt Roadmap

## Timeline

- **v1 (MVP):** January 4-18 (2 weeks) → TestFlight to friends/family
- **v2 (Enhanced):** January 19-31 → Broader TestFlight
- **Launch:** Early February → App Store submission

---

## v1 - MVP (Current)

**Goal:** Core loop works. You can use it daily.

### Must Have (Ship Blockers)
- [ ] Today screen with date display
- [ ] Add entry via text input
- [ ] Add entry via voice input (Speech framework)
- [ ] View today's entry
- [ ] Swipe between days (back in time only from today)
- [ ] Activity dots showing current week
- [ ] Local persistence (SwiftData)
- [x] Multiple entries per day support
- [ ] Edit existing entry
- [ ] Dark mode support
- [ ] Bottom tab bar (3 tabs)
- [ ] Basic Insights tab (list of all entries)
- [ ] Basic Profile tab (entry count, streak)

### Nice to Have (Don't Block Ship)
- [ ] Calendar overlay (pull down)
- [ ] Tap dots to navigate
- [ ] Haptic feedback
- [ ] Keyboard avoidance polish
- [ ] App icon

### Explicitly NOT in v1
- Cloud sync
- AI summaries
- Notifications
- Onboarding flow
- Settings beyond theme
- Export functionality
- Share functionality

### v1 Success Criteria
1. You use it every day for a week
2. Entry flow takes <10 seconds
3. Voice transcription works reliably
4. No crashes

---

## v2 - Enhanced

**Goal:** Polish for real users. Cloud backup. Richer insights.

### Features
- [ ] Categories (4 preset: Personal, Work, Learning, Relationships)
  - [ ] Category selector on entry creation
  - [ ] Category icon on entry cards
  - [ ] Category filtering in Insights
- [ ] iCloud sync (CloudKit)
- [ ] Notification reminders (configurable time)
- [ ] Calendar overlay with full month view
- [ ] Entry search
- [ ] Export to JSON/CSV
- [ ] Proper onboarding (3 screens max)
- [ ] Settings screen
  - [ ] Notification time
  - [ ] Theme toggle
  - [ ] Export data
- [ ] Haptic feedback throughout
- [ ] Smooth animations (300ms transitions)
- [ ] Empty state illustrations
- [ ] App icon (final design)

### v2 Success Criteria
1. 5+ friends/family using it
2. No sync issues
3. Someone asks "how do I get this?"

---

## v3 - AI & Launch

**Goal:** Ship to App Store. AI makes it magical.

### Features
- [ ] AI auto-categorization
  - Suggest category based on content
  - User confirms or changes
  - Suggest new categories (max 6-8 total)
- [ ] AI monthly summaries (Claude API)
  - Top 3 themes
  - Pattern insights
  - Standout entry
- [ ] AI yearly recap
- [ ] Shareable summary cards
- [ ] "Talk to your learnings" chat (stretch)
- [ ] Widget for home screen
- [ ] Premium tier
  - Monthly/yearly summaries
  - Unlimited history search
  - Priority AI processing

### Launch Checklist
- [ ] App Store screenshots (6.5" and 5.5")
- [ ] App Store description
- [ ] Privacy policy (host on itamih.com)
- [ ] Support URL
- [ ] App review notes
- [ ] Keywords research
- [ ] Category selection (Lifestyle or Productivity)

---

## Feature Ideas (Backlog)

Parking lot for future consideration:

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
