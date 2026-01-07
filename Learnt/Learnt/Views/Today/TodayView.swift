//
//  TodayView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [LearningEntry]

    @State private var selectedDate = Date()
    @State private var showCalendar = false
    @State private var showAddLearning = false
    @State private var showShareSheet = false
    @State private var editingEntry: LearningEntry?
    @State private var reflectingEntry: LearningEntry?
    @State private var isQuoteHidden = QuoteService.shared.isQuoteHidden

    private let quoteService = QuoteService.shared

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var entriesForSelectedDate: [LearningEntry] {
        allEntries.filter { $0.date.isSameDay(as: selectedDate) }
            .sorted { ($0.sortOrder, $0.createdAt) < ($1.sortOrder, $1.createdAt) }
    }

    private var datesWithEntries: Set<Date> {
        Set(allEntries.filter { date in
            let weekStart = selectedDate.startOfWeek
            let weekEnd = selectedDate.endOfWeek
            return date.date >= weekStart && date.date <= weekEnd
        }.map { $0.date.startOfDay })
    }

    private var canGoForward: Bool {
        !selectedDate.isSameDay(as: Date()) && selectedDate < Date()
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Week Activity Row
                WeekActivityRow(
                    selectedDate: selectedDate,
                    datesWithEntries: datesWithEntries,
                    onDateSelected: navigateTo,
                    onWeekChange: { weeks in
                        let newDate = selectedDate.adding(days: weeks * 7)
                        navigateTo(newDate)
                    }
                )

                Divider()
                    .background(Color.dividerColor)

                // Content
                if entriesForSelectedDate.isEmpty {
                    VStack(spacing: 0) {
                        // Quote of the day (only on today, when not hidden)
                        if selectedDate.isToday && !isQuoteHidden {
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

            // Floating + button (bottom right) - only when there are entries
            if !entriesForSelectedDate.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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
                        .padding(.bottom, 80) // Above tab bar
                    }
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
                onSave: { content, app, sur, sim, que in
                    entryStore.createEntry(content: content, for: selectedDate)
                    // Update reflections if any were provided
                    if let entry = entryStore.entries(for: selectedDate).last {
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
                onSave: { content, app, sur, sim, que in
                    entryStore.updateEntry(entry, content: content)
                    entryStore.updateReflections(entry, application: app, surprise: sur, simplification: sim, question: que)
                    editingEntry = nil
                },
                onCancel: { editingEntry = nil },
                initialContent: entry.content,
                initialApplication: entry.application,
                initialSurprise: entry.surprise,
                initialSimplification: entry.simplification,
                initialQuestion: entry.question
            )
        }
        .sheet(item: $reflectingEntry) { entry in
            AddLearningView(
                onSave: { content, app, sur, sim, que in
                    entryStore.updateEntry(entry, content: content)
                    entryStore.updateReflections(entry, application: app, surprise: sur, simplification: sim, question: que)
                    reflectingEntry = nil
                },
                onCancel: { reflectingEntry = nil },
                initialContent: entry.content,
                initialApplication: entry.application,
                initialSurprise: entry.surprise,
                initialSimplification: entry.simplification,
                initialQuestion: entry.question
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(initialDate: selectedDate)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text(selectedDate.formattedFull)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Spacer()

            HStack(spacing: 16) {
                Button(action: { showCalendar = true }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.primaryTextColor)
                }
                .buttonStyle(.plain)

                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundStyle(entriesForSelectedDate.isEmpty
                            ? Color.secondaryTextColor
                            : Color.primaryTextColor)
                }
                .buttonStyle(.plain)
                .disabled(entriesForSelectedDate.isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Entries List

    private var entriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Quote of the day (only on today, when not hidden)
                if selectedDate.isToday && !isQuoteHidden {
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

                ForEach(entriesForSelectedDate) { entry in
                    LearningCard(
                        entry: entry,
                        onEdit: { editingEntry = entry },
                        onAddReflection: { reflectingEntry = entry }
                    )
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
            selectedDate = date.startOfDay
        }
    }

}

#Preview {
    TodayView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
