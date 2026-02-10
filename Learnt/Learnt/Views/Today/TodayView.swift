//
//  TodayView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var allEntries: [LearningEntry]

    @SceneStorage("selectedDate") private var selectedDateTimestamp: Double = Date().timeIntervalSince1970
    @State private var hasAppearedOnce = false
    @State private var showCalendar = false
    @State private var showAddLearning = false
    @State private var editingEntry: LearningEntry?
    @State private var reflectingEntry: LearningEntry?
    @State private var entryToDelete: LearningEntry?
    @State private var isQuoteHidden = QuoteService.shared.isQuoteHidden
    @State private var dailyQuotesEnabled = SettingsService.shared.dailyQuotesEnabled
    @State private var expandedCardId: UUID? = nil
    @State private var inlineEntryText = ""
    @State private var keyboardHeight: CGFloat = 0

    // Onboarding nudge state
    @State private var showReflectNudge = false
    @State private var showReviewStartedNudge = false

    private let quoteService = QuoteService.shared
    private var settings: SettingsService { SettingsService.shared }
    private var onboarding: OnboardingProgressService { OnboardingProgressService.shared }

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var selectedDate: Date {
        Date(timeIntervalSince1970: selectedDateTimestamp)
    }

    private func setSelectedDate(_ date: Date) {
        selectedDateTimestamp = date.timeIntervalSince1970
    }

    private var entriesForSelectedDate: [LearningEntry] {
        allEntries.filter { $0.date.isSameDay(as: selectedDate) }
            .sorted { ($0.sortOrder, $0.createdAt) < ($1.sortOrder, $1.createdAt) }
    }

    private var canGoForward: Bool {
        !selectedDate.isSameDay(as: Date()) && selectedDate < Date()
    }

    private var entryBarPlaceholder: String {
        selectedDate.isToday ? "What did you learn?" : "What did you learn on \(selectedDate.formattedShort)?"
    }

    private var isKeyboardVisible: Bool {
        keyboardHeight > 0
    }

    // No auto-focus — keyboard on launch is jarring

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()
                .onTapGesture { dismissKeyboard() }

            VStack(spacing: 0) {
                headerView

                Divider()
                    .background(Color.dividerColor)

                // Content area
                if entriesForSelectedDate.isEmpty {
                    emptyContent
                        .onTapGesture { dismissKeyboard() }
                } else {
                    entriesListView
                }
            }

            // Floating entry bar overlay — ignores bottom safe area
            // so keyboardHeight (measured from screen bottom) maps correctly
            VStack {
                Spacer()
                InlineEntryBar(
                    text: $inlineEntryText,
                    placeholder: entryBarPlaceholder,
                    onSend: {
                        let trimmed = inlineEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        entryStore.createEntry(content: trimmed, for: selectedDate)
                        inlineEntryText = ""

                        // Track first entry milestone
                        if !onboarding.hasCreatedFirstEntry {
                            onboarding.reach(.firstEntry)
                            // Show reflect nudge after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showReflectNudge = true
                                }
                            }
                        }

                        // Clear first session flag after first entry
                        if onboarding.isFirstSession {
                            onboarding.isFirstSession = false
                        }
                    },
                    onMicTap: { showAddLearning = true },
                    onExpand: { showAddLearning = true }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, isKeyboardVisible ? keyboardHeight + 8 : 110)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showCalendar) {
            CalendarOverlay(
                selectedDate: selectedDate,
                datesWithEntries: Set(allEntries.map { $0.date.startOfDay }),
                onDateSelected: { date in
                    navigateTo(date)
                    showCalendar = false
                },
                onDismiss: { showCalendar = false }
            )
        }
        .sheet(isPresented: $showAddLearning) {
            AddLearningView(
                onSave: { content, reflection, categories, audioFileName, transcription in
                    entryStore.createEntry(content: content, for: selectedDate)
                    if let entry = entryStore.entries(for: selectedDate).last {
                        entry.categories = categories
                        entry.contentAudioFileName = audioFileName
                        entry.transcription = transcription
                        if reflection != nil {
                            entryStore.updateReflection(entry, reflection: reflection)
                            trackFirstReflection()
                        }
                    }
                    showAddLearning = false

                    // Track first entry milestone
                    if !onboarding.hasCreatedFirstEntry {
                        onboarding.reach(.firstEntry)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showReflectNudge = true
                            }
                        }
                    }
                },
                onCancel: { showAddLearning = false }
            )
        }
        .sheet(item: $editingEntry) { entry in
            AddLearningView(
                onSave: { content, reflection, categories, audioFileName, transcription in
                    entryStore.updateEntry(entry, content: content)
                    entry.categories = categories
                    entry.contentAudioFileName = audioFileName
                    entry.transcription = transcription
                    entryStore.updateReflection(entry, reflection: reflection)
                    if reflection != nil { trackFirstReflection() }
                    editingEntry = nil
                },
                onCancel: { editingEntry = nil },
                initialContent: entry.content,
                initialReflection: entry.reflection,
                initialCategories: entry.categories,
                initialContentAudioFileName: entry.contentAudioFileName,
                initialTranscription: entry.transcription
            )
        }
        .sheet(item: $reflectingEntry) { entry in
            AddLearningView(
                onSave: { content, reflection, categories, audioFileName, transcription in
                    entryStore.updateEntry(entry, content: content)
                    entry.categories = categories
                    entry.contentAudioFileName = audioFileName
                    entry.transcription = transcription
                    entryStore.updateReflection(entry, reflection: reflection)
                    if reflection != nil { trackFirstReflection() }
                    reflectingEntry = nil
                },
                onCancel: { reflectingEntry = nil },
                initialContent: entry.content,
                initialReflection: entry.reflection,
                initialCategories: entry.categories,
                initialContentAudioFileName: entry.contentAudioFileName,
                initialTranscription: entry.transcription
            )
        }
        .alert("Delete Learning?", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    entryStore.deleteEntry(entry)
                }
                entryToDelete = nil
            }
        } message: {
            Text("This learning will be permanently deleted.")
        }
        .onAppear {
            dailyQuotesEnabled = SettingsService.shared.dailyQuotesEnabled
            isQuoteHidden = quoteService.isQuoteHidden

            if !hasAppearedOnce {
                hasAppearedOnce = true
                setSelectedDate(Date().startOfDay)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .jumpToToday)) { _ in
            navigateTo(Date())
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let screenHeight = UIScreen.main.bounds.height
            let newHeight = max(0, screenHeight - frame.origin.y)

            // Use the keyboard's own animation duration for proper tracking
            if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double, duration > 0 {
                withAnimation(.easeOut(duration: duration)) {
                    keyboardHeight = newHeight
                }
            } else {
                // Interactive dismiss — no animation, track instantly
                keyboardHeight = newHeight
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                if settings.shouldResetToToday {
                    setSelectedDate(Date().startOfDay)
                }
            }
            if newPhase == .background {
                settings.lastActiveTime = Date()
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 0) {
            // Back arrow
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                navigateTo(selectedDate.yesterday)
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primaryTextColor)
                    .frame(width: 40, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Date
            Button(action: { showCalendar = true }) {
                Text(selectedDate.formattedFull)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(1)
            }
            .buttonStyle(.plain)

            // Forward arrow
            Button(action: {
                if canGoForward {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    navigateTo(selectedDate.tomorrow)
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(canGoForward ? Color.primaryTextColor : Color.secondaryTextColor.opacity(0.3))
                    .frame(width: 40, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!canGoForward)

            Spacer()

            // "← Today" button when viewing a past date
            if !selectedDate.isToday {
                Button(action: { navigateTo(Date()) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 11, weight: .medium))
                        Text("Today")
                            .font(.system(size: 13, weight: .medium, design: .serif))
                    }
                    .foregroundStyle(Color.primaryTextColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.inputBackgroundColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // Calendar
            Button(action: { showCalendar = true }) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryTextColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 8)
        .padding(.trailing, 4)
        .padding(.vertical, 4)
    }

    // MARK: - Empty Content

    private var emptyContent: some View {
        VStack(spacing: 0) {
            if selectedDate.isToday && dailyQuotesEnabled && !isQuoteHidden {
                QuoteCard(
                    quote: quoteService.quoteOfTheDay,
                    onHide: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            quoteService.hideQuoteForToday()
                            isQuoteHidden = true
                        }
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            EmptyStateView(
                isToday: selectedDate.isToday,
                date: selectedDate,
                totalEntryCount: allEntries.count,
                onAdd: { showAddLearning = true }
            )
        }
        // Keep empty state above the floating entry bar
        .padding(.bottom, isKeyboardVisible ? keyboardHeight + 40 : 130)
    }

    // MARK: - Entries List

    private var entriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Review started nudge (shown after first reflection)
                if showReviewStartedNudge {
                    InlineNudgeCard(
                        title: "Review started",
                        message: "This learning will come back for review tomorrow. Check the Review tab when it's ready.",
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showReviewStartedNudge = false
                            }
                        }
                    )
                }

                if selectedDate.isToday && settings.dailyQuotesEnabled && !isQuoteHidden {
                    QuoteCard(
                        quote: quoteService.quoteOfTheDay,
                        onHide: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                quoteService.hideQuoteForToday()
                                isQuoteHidden = true
                            }
                        }
                    )
                }

                ForEach(Array(entriesForSelectedDate.enumerated()), id: \.element.id) { index, entry in
                    LearningCard(
                        entry: entry,
                        onEdit: { editingEntry = entry },
                        onAddReflection: { reflectingEntry = entry },
                        onDelete: { entryToDelete = entry },
                        onToggleFavorite: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            entry.isFavorite.toggle()
                            entry.updatedAt = Date()
                        },
                        onExpansionChanged: { isExpanded in
                            expandedCardId = isExpanded ? entry.id : nil
                        }
                    )
                }

                // Reflect nudge (shown after first entry, before first reflection)
                if showReflectNudge {
                    InlineNudgeCard(
                        title: "Reflect to remember",
                        message: "Tap \"Reflect on this\" on your learning to deepen understanding and start spaced review.",
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showReflectNudge = false
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, isKeyboardVisible ? keyboardHeight + 80 : 160)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Helpers

    private func navigateTo(_ date: Date) {
        guard !date.isFuture else { return }
        dismissKeyboard()
        withAnimation(.easeInOut(duration: 0.2)) {
            setSelectedDate(date.startOfDay)
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func trackFirstReflection() {
        if !onboarding.hasAddedFirstReflection {
            onboarding.reach(.firstReflection)
            // Hide reflect nudge and show review started nudge
            withAnimation(.easeOut(duration: 0.3)) {
                showReflectNudge = false
                showReviewStartedNudge = true
            }
            // Auto-dismiss review started nudge after 8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showReviewStartedNudge = false
                }
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
