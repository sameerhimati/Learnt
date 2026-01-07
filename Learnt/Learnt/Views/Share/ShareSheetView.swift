//
//  ShareSheetView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [LearningEntry]

    @State private var selectedEntryIDs: Set<UUID> = []
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showShareSheet = false

    private let initialDate: Date

    init(initialDate: Date) {
        self.initialDate = initialDate
        _startDate = State(initialValue: initialDate.startOfDay)
        _endDate = State(initialValue: initialDate.endOfDay)
    }

    private var filteredEntries: [LearningEntry] {
        allEntries
            .filter { $0.date >= startDate.startOfDay && $0.date <= endDate.endOfDay }
            .sorted { $0.date > $1.date }
    }

    private var entriesByDate: [(Date, [LearningEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { $0.date.startOfDay }
        return grouped.sorted { $0.key > $1.key }
    }

    private var selectedEntries: [LearningEntry] {
        filteredEntries.filter { selectedEntryIDs.contains($0.id) }
    }

    private var shareText: String {
        guard !selectedEntries.isEmpty else { return "" }

        let entriesByDay = Dictionary(grouping: selectedEntries) { $0.date.startOfDay }
        let sortedDays = entriesByDay.keys.sorted(by: >)

        var text = ""
        for day in sortedDays {
            let dayEntries = entriesByDay[day] ?? []
            text += "What I learned on \(day.formattedFull):\n"
            for entry in dayEntries.sorted(by: { $0.createdAt < $1.createdAt }) {
                text += "• \(entry.content)\n"
            }
            text += "\n"
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date range selector
                dateRangeSelector

                Divider()
                    .background(Color.dividerColor)

                // Entries list
                entriesList

                Divider()
                    .background(Color.dividerColor)

                // Preview and share
                bottomBar
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("Share Learnings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareActivityView(text: shareText)
            }
            .onAppear {
                // Select all entries from initial date by default
                let todayEntries = filteredEntries.filter { $0.date.isSameDay(as: initialDate) }
                selectedEntryIDs = Set(todayEntries.map { $0.id })
            }
        }
    }

    // MARK: - Date Range Selector

    private var dateRangeSelector: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Date Range")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                Spacer()
            }

            HStack(spacing: 12) {
                DatePicker("From", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(Color.primaryTextColor)

                Text("to")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                DatePicker("To", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(Color.primaryTextColor)
            }
        }
        .padding(16)
    }

    // MARK: - Entries List

    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Select/Deselect all
                HStack {
                    Button(action: selectAll) {
                        Text("Select All")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                    .buttonStyle(.plain)

                    Text("•")
                        .foregroundStyle(Color.secondaryTextColor)

                    Button(action: deselectAll) {
                        Text("Deselect All")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("\(selectedEntryIDs.count) selected")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Entries grouped by date
                ForEach(entriesByDate, id: \.0) { date, entries in
                    Section {
                        ForEach(entries) { entry in
                            entryRow(entry)
                        }
                    } header: {
                        HStack {
                            Text(date.formattedFull)
                                .font(.system(.caption, design: .serif, weight: .medium))
                                .foregroundStyle(Color.secondaryTextColor)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appBackgroundColor)
                    }
                }
            }
        }
    }

    private func entryRow(_ entry: LearningEntry) -> some View {
        let isSelected = selectedEntryIDs.contains(entry.id)

        return Button(action: { toggleSelection(entry) }) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)

                // Content
                Text(entry.previewText)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.inputBackgroundColor : Color.clear)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 12) {
            // Preview
            if !selectedEntries.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(shareText)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .lineLimit(3)
                        .padding(.horizontal, 16)
                }
                .frame(height: 50)
            }

            // Share button
            Button(action: { showShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share \(selectedEntries.count) Learning\(selectedEntries.count == 1 ? "" : "s")")
                }
                .font(.system(.body, design: .serif, weight: .medium))
                .foregroundStyle(selectedEntries.isEmpty ? Color.secondaryTextColor : Color.appBackgroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(selectedEntries.isEmpty ? Color.inputBackgroundColor : Color.primaryTextColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(selectedEntries.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .padding(.top, 12)
    }

    // MARK: - Actions

    private func toggleSelection(_ entry: LearningEntry) {
        if selectedEntryIDs.contains(entry.id) {
            selectedEntryIDs.remove(entry.id)
        } else {
            selectedEntryIDs.insert(entry.id)
        }
    }

    private func selectAll() {
        selectedEntryIDs = Set(filteredEntries.map { $0.id })
    }

    private func deselectAll() {
        selectedEntryIDs.removeAll()
    }
}

// MARK: - Share Activity View

struct ShareActivityView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ShareSheetView(initialDate: Date())
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
