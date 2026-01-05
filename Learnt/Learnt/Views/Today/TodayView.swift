//
//  TodayView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [LearningEntry]

    var tabBarActions: TabBarActions?

    @State private var selectedDate = Date()
    @State private var showCalendar = false
    @State private var showInputChooser = false
    @State private var showTextInput = false
    @State private var showVoiceInput = false
    @State private var showShareSheet = false
    @State private var editingEntry: LearningEntry?
    @State private var lastTapCount = 0

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
                    EmptyStateView(
                        isToday: selectedDate.isToday,
                        onAdd: { showInputChooser = true }
                    )
                } else {
                    entriesListView
                }
            }

            // Input chooser overlay
            if showInputChooser {
                InputChooserOverlay(
                    onTextSelected: {
                        showInputChooser = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showTextInput = true
                        }
                    },
                    onVoiceSelected: {
                        showInputChooser = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showVoiceInput = true
                        }
                    },
                    onDismiss: {
                        showInputChooser = false
                    }
                )
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
        .sheet(isPresented: $showTextInput) {
            InputView(
                showVoiceOption: false,
                onSave: { content in
                    entryStore.createEntry(content: content, for: selectedDate)
                    showTextInput = false
                },
                onCancel: { showTextInput = false }
            )
        }
        .sheet(item: $editingEntry) { entry in
            InputView(
                initialContent: entry.content,
                showVoiceOption: false,
                onSave: { content in
                    entryStore.updateEntry(entry, content: content)
                    editingEntry = nil
                },
                onCancel: { editingEntry = nil }
            )
        }
        .sheet(isPresented: $showVoiceInput) {
            VoiceInputView(
                onSave: { content, audioData in
                    entryStore.createEntry(
                        content: content,
                        for: selectedDate,
                        isVoiceEntry: true,
                        audioData: audioData
                    )
                    showVoiceInput = false
                },
                onCancel: { showVoiceInput = false }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(initialDate: selectedDate)
        }
        .onChange(of: tabBarActions?.todayTabTapCount) { oldValue, newValue in
            guard let newValue = newValue, newValue > lastTapCount else { return }
            lastTapCount = newValue

            if selectedDate.isToday {
                // Already viewing today - toggle input chooser
                showInputChooser.toggle()
            } else {
                // Viewing past date - jump to today
                navigateTo(Date())
            }
        }
        .onChange(of: showInputChooser) { _, isShowing in
            // Sync chooser state to tab bar for X rotation
            tabBarActions?.isChooserShowing = isShowing
        }
        .onChange(of: selectedDate) { _, newDate in
            // Update tab bar icon state
            tabBarActions?.isViewingToday = newDate.isToday
        }
        .onAppear {
            // Set initial state
            tabBarActions?.isViewingToday = selectedDate.isToday
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
                ForEach(entriesForSelectedDate) { entry in
                    EntryCard(entry: entry) {
                        editingEntry = entry
                    }
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
