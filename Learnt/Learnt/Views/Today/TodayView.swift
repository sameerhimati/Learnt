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

    // Use SceneStorage to persist selected date across tab switches
    @SceneStorage("selectedDate") private var selectedDateTimestamp: Double = Date().timeIntervalSince1970
    @State private var hasAppearedOnce = false

    private var selectedDate: Date {
        get { Date(timeIntervalSince1970: selectedDateTimestamp) }
    }

    private func setSelectedDate(_ date: Date) {
        selectedDateTimestamp = date.timeIntervalSince1970
    }
    @State private var showCalendar = false
    @State private var showAddLearning = false
    @State private var showShareSheet = false
    @State private var editingEntry: LearningEntry?
    @State private var reflectingEntry: LearningEntry?
    @State private var entryToDelete: LearningEntry?
    @State private var isQuoteHidden = QuoteService.shared.isQuoteHidden
    @State private var entryToShare: LearningEntry?
    @State private var showLibrary = false
    @State private var dailyQuotesEnabled = SettingsService.shared.dailyQuotesEnabled
    @State private var expandedCardId: UUID? = nil

    private let quoteService = QuoteService.shared
    private var settings: SettingsService { SettingsService.shared }

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var entriesForSelectedDate: [LearningEntry] {
        allEntries.filter { $0.date.isSameDay(as: selectedDate) }
            .sorted { ($0.sortOrder, $0.createdAt) < ($1.sortOrder, $1.createdAt) }
    }

    private var canGoForward: Bool {
        !selectedDate.isSameDay(as: Date()) && selectedDate < Date()
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with arrow navigation
                headerView

                Divider()
                    .background(Color.dividerColor)

                // Content
                if entriesForSelectedDate.isEmpty {
                    VStack(spacing: 0) {
                        // Quote of the day (only on today, when enabled and not hidden)
                        if selectedDate.isToday && dailyQuotesEnabled && !isQuoteHidden {
                            QuoteCard(
                                quote: quoteService.quoteOfTheDay,
                                onAddToEntry: { quoteText in
                                    entryStore.createEntry(content: quoteText, for: selectedDate)
                                },
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
                            onAdd: { showAddLearning = true }
                        )
                    }
                } else {
                    entriesListView
                }
            }
            .coachMark(
                .navigateDays,
                title: "Browse Your History",
                message: "Swipe left or right to see previous days, or tap the calendar icon.",
                arrowDirection: .none
            )

            // Floating buttons (bottom) - hide when card is expanded
            if expandedCardId == nil {
                VStack {
                    Spacer()
                    HStack {
                        // Library button (bottom-left)
                        Button(action: { showLibrary = true }) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.primaryTextColor)
                                .frame(width: 56, height: 56)
                                .background(Color.appBackgroundColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 24)

                        Spacer()

                        // Add button (bottom-right)
                        Button(action: { showAddLearning = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color.primaryTextColor)
                                .frame(width: 56, height: 56)
                                .background(Color.appBackgroundColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 80) // Above tab bar
                }
            }
        }
        .gesture(swipeGesture)
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
                onSave: { content, app, sur, sim, que, categories, audioFileName, transcription in
                    entryStore.createEntry(content: content, for: selectedDate)
                    if let entry = entryStore.entries(for: selectedDate).last {
                        entry.categories = categories
                        entry.contentAudioFileName = audioFileName
                        entry.transcription = transcription
                        if app != nil || sur != nil || sim != nil || que != nil {
                            entryStore.updateReflections(entry, application: app, surprise: sur, simplification: sim, question: que)
                        }
                    }
                    showAddLearning = false
                },
                onCancel: { showAddLearning = false }
            )
        }
        .sheet(item: $editingEntry) { entry in
            AddLearningView(
                onSave: { content, app, sur, sim, que, categories, audioFileName, transcription in
                    entryStore.updateEntry(entry, content: content)
                    entry.categories = categories
                    entry.contentAudioFileName = audioFileName
                    entry.transcription = transcription
                    entryStore.updateReflections(entry, application: app, surprise: sur, simplification: sim, question: que)
                    editingEntry = nil
                },
                onCancel: { editingEntry = nil },
                initialContent: entry.content,
                initialApplication: entry.application,
                initialSurprise: entry.surprise,
                initialSimplification: entry.simplification,
                initialQuestion: entry.question,
                initialCategories: entry.categories,
                initialContentAudioFileName: entry.contentAudioFileName,
                initialTranscription: entry.transcription
            )
        }
        .sheet(item: $reflectingEntry) { entry in
            AddLearningView(
                onSave: { content, app, sur, sim, que, categories, audioFileName, transcription in
                    entryStore.updateEntry(entry, content: content)
                    entry.categories = categories
                    entry.contentAudioFileName = audioFileName
                    entry.transcription = transcription
                    entryStore.updateReflections(entry, application: app, surprise: sur, simplification: sim, question: que)
                    reflectingEntry = nil
                },
                onCancel: { reflectingEntry = nil },
                initialContent: entry.content,
                initialApplication: entry.application,
                initialSurprise: entry.surprise,
                initialSimplification: entry.simplification,
                initialQuestion: entry.question,
                initialCategories: entry.categories,
                initialContentAudioFileName: entry.contentAudioFileName,
                initialTranscription: entry.transcription
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(initialDate: selectedDate)
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
        .sheet(item: $entryToShare) { entry in
            ShareEntrySheet(entry: entry)
        }
        .sheet(isPresented: $showLibrary) {
            LibraryView()
        }
        .onAppear {
            // Always sync with settings in case they changed while on another tab
            dailyQuotesEnabled = SettingsService.shared.dailyQuotesEnabled
            isQuoteHidden = quoteService.isQuoteHidden

            // On first appear (cold launch), always reset to today
            if !hasAppearedOnce {
                hasAppearedOnce = true
                setSelectedDate(Date().startOfDay)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .jumpToToday)) { _ in
            // When user taps Today tab while already on Today, jump to today's date
            navigateTo(Date())
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Reset to today if app has been inactive for 1+ hour or on cold launch
                if settings.shouldResetToToday {
                    setSelectedDate(Date().startOfDay)
                }
            }
            if newPhase == .background {
                // Track when app goes to background
                settings.lastActiveTime = Date()
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            // Navigation arrows + date (tap date to return to today)
            HStack(spacing: 8) {
                Button(action: { navigateTo(selectedDate.yesterday) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)

                // Tap date to return to today
                Button(action: { navigateTo(Date()) }) {
                    Text(selectedDate.formattedFull)
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                }
                .buttonStyle(.plain)

                Button(action: { navigateTo(selectedDate.tomorrow) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(canGoForward ? Color.secondaryTextColor : Color.secondaryTextColor.opacity(0.3))
                }
                .buttonStyle(.plain)
                .disabled(!canGoForward)
            }

            Spacer()

            // "Today" button when viewing a past date
            if !selectedDate.isToday {
                Button(action: { navigateTo(Date()) }) {
                    Text("Today")
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.inputBackgroundColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // Calendar only
            Button(action: { showCalendar = true }) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primaryTextColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Entries List

    private var entriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Quote of the day (only on today, when enabled and not hidden)
                if selectedDate.isToday && settings.dailyQuotesEnabled && !isQuoteHidden {
                    QuoteCard(
                        quote: quoteService.quoteOfTheDay,
                        onAddToEntry: { quoteText in
                            entryStore.createEntry(content: quoteText, for: selectedDate)
                        },
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
                        onShare: { entryToShare = entry },
                        onToggleFavorite: {
                            entry.isFavorite.toggle()
                            entry.updatedAt = Date()
                        },
                        onExpansionChanged: { isExpanded in
                            expandedCardId = isExpanded ? entry.id : nil
                        }
                    )
                    .modifier(FirstCardCoachMark(isFirstCard: index == 0))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 80) // Space for tab bar
        }
    }

    // MARK: - Navigation

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                let horizontal = value.translation.width

                if horizontal > 0 {
                    // Swipe right = go back in time
                    navigateTo(selectedDate.yesterday)
                } else if horizontal < 0 && canGoForward {
                    // Swipe left = go forward (only if not at today)
                    navigateTo(selectedDate.tomorrow)
                }
            }
    }

    private func navigateTo(_ date: Date) {
        // Don't allow navigating to future
        guard !date.isFuture else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            setSelectedDate(date.startOfDay)
        }
    }

}

// MARK: - First Card Coach Mark

private struct FirstCardCoachMark: ViewModifier {
    let isFirstCard: Bool

    func body(content: Content) -> some View {
        if isFirstCard {
            content
                .coachMark(
                    .expandCard,
                    title: "Tap to Expand",
                    message: "Tap any card to see details, edit, add reflections, or share.",
                    arrowDirection: .down
                )
        } else {
            content
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
