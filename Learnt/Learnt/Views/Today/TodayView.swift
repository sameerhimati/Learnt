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
    @State private var showInput = false
    @State private var showVoiceInput = false
    @State private var editingEntry: LearningEntry?

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
                        onAdd: { showInput = true }
                    )
                } else {
                    entriesListView
                }
            }

            // Floating Add Button (only when entries exist)
            if !entriesForSelectedDate.isEmpty && selectedDate.isToday {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AddButton(onTap: { showInput = true })
                            .padding(24)
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
        .sheet(isPresented: $showInput) {
            InputView(
                onSave: { content in
                    entryStore.createEntry(content: content, for: selectedDate)
                    showInput = false
                },
                onCancel: { showInput = false },
                onStartVoice: {
                    showInput = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showVoiceInput = true
                    }
                }
            )
        }
        .sheet(item: $editingEntry) { entry in
            InputView(
                initialContent: entry.content,
                onSave: { content in
                    entryStore.updateEntry(entry, content: content)
                    editingEntry = nil
                },
                onCancel: { editingEntry = nil },
                onStartVoice: {
                    // Voice input not available in edit mode for now
                }
            )
        }
        .sheet(isPresented: $showVoiceInput) {
            VoiceInputView(
                onSave: { content in
                    entryStore.createEntry(content: content, for: selectedDate)
                    showVoiceInput = false
                },
                onCancel: { showVoiceInput = false }
            )
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

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundStyle(entriesForSelectedDate.isEmpty
                            ? Color.secondaryTextColor
                            : Color.primaryTextColor)
                }
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
            .padding(.bottom, 100) // Space for floating button
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

    // MARK: - Share

    private var shareText: String {
        guard !entriesForSelectedDate.isEmpty else { return "" }

        let header = "What I learned on \(selectedDate.formattedFull):"
        let bullets = entriesForSelectedDate
            .map { "• \($0.content)" }
            .joined(separator: "\n")

        return "\(header)\n\n\(bullets)"
    }
}

#Preview {
    TodayView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
