//
//  LibraryView.swift
//  Learnt
//

import SwiftUI
import SwiftData
import AVFoundation

struct LibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [LearningEntry]
    @Query private var allCategories: [Category]

    @State private var searchText = ""
    @State private var filter: LibraryFilter = .all
    @State private var dateFilter: DateFilter = .allTime
    @State private var selectedCategory: Category?
    @State private var selectedEntry: LearningEntry?

    // Bulk selection state
    @State private var isSelectionMode = false
    @State private var selectedEntries: Set<UUID> = []
    @State private var showBulkReviewSheet = false

    enum LibraryFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case graduated = "Graduated"
    }

    enum DateFilter: String, CaseIterable {
        case allTime = "All Time"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case last30Days = "Last 30 Days"
    }

    private var filteredEntries: [LearningEntry] {
        var entries = allEntries

        // Apply status filter
        switch filter {
        case .all:
            break
        case .favorites:
            entries = entries.filter { $0.isFavorite }
        case .graduated:
            entries = entries.filter { $0.isGraduated }
        }

        // Apply date filter
        switch dateFilter {
        case .allTime:
            break
        case .thisWeek:
            entries = entries.filter { $0.date >= Date().startOfWeek }
        case .thisMonth:
            entries = entries.filter { $0.date >= Date().startOfMonth }
        case .last30Days:
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            entries = entries.filter { $0.date >= cutoff }
        }

        // Apply category filter
        if let category = selectedCategory {
            entries = entries.filter { $0.categories.contains(category) }
        }

        // Apply search
        if !searchText.isEmpty {
            entries = entries.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort by date (newest first)
        return entries.sorted { $0.date > $1.date }
    }

    private var categoriesWithCounts: [(category: Category, count: Int)] {
        allCategories.map { category in
            let count = allEntries.filter { $0.categories.contains(category) }.count
            return (category, count)
        }.filter { $0.count > 0 }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Search bar
                        searchBar

                        // Filter chips
                        filterChips

                        // Date filter chips
                        dateFilterChips

                        // Category chips (if any)
                        if !categoriesWithCounts.isEmpty {
                            categoryChips
                        }

                        // Entries list
                        if filteredEntries.isEmpty {
                            emptyState
                        } else {
                            entriesList
                        }
                    }
                    .padding(16)
                    .padding(.bottom, isSelectionMode && !selectedEntries.isEmpty ? 80 : 0)
                }
                .background(Color.appBackgroundColor)

                // Bulk action bar
                if isSelectionMode && !selectedEntries.isEmpty {
                    bulkActionBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { toggleSelectionMode() }) {
                        Text(isSelectionMode ? "Done" : "Select")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
                ToolbarItem(placement: .principal) {
                    if isSelectionMode && !selectedEntries.isEmpty {
                        Text("\(selectedEntries.count) selected")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.primaryTextColor)
                    } else {
                        Text("Library")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
            .sheet(item: $selectedEntry) { entry in
                LibraryEntryDetailView(entry: entry)
            }
            .fullScreenCover(isPresented: $showBulkReviewSheet) {
                ReviewSessionView(
                    entries: selectedEntriesForReview,
                    onComplete: {
                        showBulkReviewSheet = false
                        selectedEntries.removeAll()
                        isSelectionMode = false
                    }
                )
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondaryTextColor)

            TextField("Search learnings...", text: $searchText)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
        }
        .padding(12)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(LibraryFilter.allCases, id: \.self) { filterOption in
                Button(action: { filter = filterOption }) {
                    Text(filterOption.rawValue)
                        .font(.system(.subheadline, design: .serif, weight: filter == filterOption ? .medium : .regular))
                        .foregroundStyle(filter == filterOption ? Color.appBackgroundColor : Color.primaryTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(filter == filterOption ? Color.primaryTextColor : Color.inputBackgroundColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    // MARK: - Date Filter Chips

    private var dateFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DateFilter.allCases, id: \.self) { dateOption in
                    Button(action: { dateFilter = dateOption }) {
                        Text(dateOption.rawValue)
                            .font(.system(.subheadline, design: .serif, weight: dateFilter == dateOption ? .medium : .regular))
                            .foregroundStyle(dateFilter == dateOption ? Color.appBackgroundColor : Color.primaryTextColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(dateFilter == dateOption ? Color.primaryTextColor : Color.inputBackgroundColor)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All" chip to clear category filter
                    if selectedCategory != nil {
                        Button(action: { selectedCategory = nil }) {
                            Text("All")
                                .font(.system(size: 13, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.inputBackgroundColor)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(categoriesWithCounts, id: \.category.id) { item in
                        Button(action: { selectedCategory = item.category }) {
                            HStack(spacing: 4) {
                                Text(item.category.name)
                                Text("(\(item.count))")
                                    .foregroundStyle(Color.secondaryTextColor)
                            }
                            .font(.system(size: 13, design: .serif))
                            .foregroundStyle(selectedCategory == item.category ? Color.appBackgroundColor : Color.primaryTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == item.category ? Color.primaryTextColor : Color.inputBackgroundColor)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "books.vertical")
                .font(.system(size: 40))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.5))

            Text(emptyStateMessage)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "No learnings match your search"
        }
        if dateFilter != .allTime {
            switch dateFilter {
            case .allTime:
                break
            case .thisWeek:
                return "No learnings this week"
            case .thisMonth:
                return "No learnings this month"
            case .last30Days:
                return "No learnings in the last 30 days"
            }
        }
        switch filter {
        case .all:
            return "No learnings yet"
        case .favorites:
            return "No favorite learnings yet"
        case .graduated:
            return "No graduated learnings yet"
        }
    }

    // MARK: - Entries List

    private var entriesList: some View {
        VStack(spacing: 0) {
            ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                Button(action: {
                    if isSelectionMode {
                        toggleSelection(entry)
                    } else {
                        selectedEntry = entry
                    }
                }) {
                    LibraryEntryRow(
                        entry: entry,
                        isSelectionMode: isSelectionMode,
                        isSelected: selectedEntries.contains(entry.id)
                    )
                }
                .buttonStyle(.plain)

                if index < filteredEntries.count - 1 {
                    Divider()
                        .background(Color.dividerColor)
                        .padding(.leading, 16)
                }
            }
        }
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Bulk Action Bar

    private var bulkActionBar: some View {
        HStack(spacing: 16) {
            // Review button
            Button(action: { showBulkReviewSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                    Text("Review")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                }
                .foregroundStyle(Color.appBackgroundColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.primaryTextColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Favorite toggle button
            Button(action: { bulkToggleFavorite() }) {
                HStack(spacing: 6) {
                    Image(systemName: allSelectedAreFavorited ? "heart.slash" : "heart")
                        .font(.system(size: 14))
                    Text(allSelectedAreFavorited ? "Unfavorite" : "Favorite")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                }
                .foregroundStyle(Color.primaryTextColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.inputBackgroundColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.appBackgroundColor)
    }

    // MARK: - Helper Methods

    private var allSelectedAreFavorited: Bool {
        let selectedItems = filteredEntries.filter { selectedEntries.contains($0.id) }
        return !selectedItems.isEmpty && selectedItems.allSatisfy { $0.isFavorite }
    }

    private var selectedEntriesForReview: [LearningEntry] {
        filteredEntries.filter { selectedEntries.contains($0.id) }
    }

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedEntries.removeAll()
        }
    }

    private func toggleSelection(_ entry: LearningEntry) {
        if selectedEntries.contains(entry.id) {
            selectedEntries.remove(entry.id)
        } else {
            selectedEntries.insert(entry.id)
        }
    }

    private func bulkToggleFavorite() {
        let targetValue = !allSelectedAreFavorited
        for entry in filteredEntries where selectedEntries.contains(entry.id) {
            entry.isFavorite = targetValue
        }
        try? modelContext.save()
    }
}

// MARK: - Entry Row

struct LibraryEntryRow: View {
    let entry: LearningEntry
    var isSelectionMode: Bool = false
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.previewText)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Text(entry.date.formattedShort)
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    if !entry.categories.isEmpty {
                        Text(entry.categories.first?.name ?? "")
                            .font(.system(size: 11, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    }
                }
            }

            Spacer()

            if !isSelectionMode {
                if entry.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.primaryTextColor)
                }

                if entry.isGraduated {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondaryTextColor)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Entry Detail View

struct LibraryEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let entry: LearningEntry

    @StateObject private var audioPlayer = LibraryAudioPlayer()

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false

    private var audioURL: URL? {
        guard let fileName = entry.contentAudioFileName else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(fileName)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    viewModeContent

                    // Delete button
                    Button(action: { showDeleteAlert = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text("Delete Learning")
                                .font(.system(.body, design: .serif))
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: { showEditSheet = true }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 28, height: 28)
                                .foregroundStyle(Color.primaryTextColor)
                        }
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 28, height: 28)
                                .foregroundStyle(Color.primaryTextColor)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onDisappear {
            audioPlayer.stop()
        }
        .sheet(isPresented: $showEditSheet) {
            AddLearningView(
                onSave: { content, reflection, categories, audioFileName, transcription in
                    updateEntry(
                        content: content,
                        reflection: reflection,
                        categories: categories,
                        audioFileName: audioFileName,
                        transcription: transcription
                    )
                    showEditSheet = false
                },
                onCancel: { showEditSheet = false },
                initialContent: entry.content,
                initialReflection: entry.reflection,
                initialCategories: entry.categories,
                initialContentAudioFileName: entry.contentAudioFileName,
                initialTranscription: entry.transcription
            )
        }
        .alert("Delete Learning?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteLearning()
            }
        } message: {
            Text("This will permanently delete this learning. This cannot be undone.")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareEntrySheet(entry: entry)
        }
    }

    // MARK: - View Mode

    private var viewModeContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Main content card
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.content)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineSpacing(6)

                // Audio playback if available
                if let url = audioURL {
                    Button(action: { audioPlayer.toggle(url: url) }) {
                        HStack(spacing: 8) {
                            Image(systemName: audioPlayer.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 12))
                            Text(audioPlayer.isPlaying ? "Stop" : "Play audio")
                                .font(.system(size: 13, design: .serif))
                        }
                        .foregroundStyle(Color.primaryTextColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.appBackgroundColor)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Metadata row
            HStack(spacing: 12) {
                Label(entry.date.formattedFull, systemImage: "calendar")

                if entry.isFavorite {
                    Label("Favorite", systemImage: "heart.fill")
                }

                if entry.isGraduated {
                    Label("Graduated", systemImage: "checkmark.seal")
                }
            }
            .font(.system(size: 12, design: .serif))
            .foregroundStyle(Color.secondaryTextColor)

            // Categories
            if !entry.categories.isEmpty {
                HStack(spacing: 8) {
                    ForEach(entry.categories) { category in
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 10))
                            Text(category.name)
                                .font(.system(size: 12, design: .serif))
                        }
                        .foregroundStyle(Color.secondaryTextColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.inputBackgroundColor)
                        .clipShape(Capsule())
                    }
                }
            }

            // Reflection
            if let reflection = entry.reflection {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reflection")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text(reflection)
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .lineSpacing(2)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Review progress
            if entry.reviewCount > 0 || entry.isGraduated {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Review Progress")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)

                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(entry.reviewCount)")
                                .font(.system(.title3, design: .serif, weight: .medium))
                                .foregroundStyle(Color.primaryTextColor)
                            Text("Reviews")
                                .font(.system(size: 11, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)
                        }

                        if entry.isGraduated {
                            VStack(alignment: .leading, spacing: 2) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.primaryTextColor)
                                Text("Graduated")
                                    .font(.system(size: 11, design: .serif))
                                    .foregroundStyle(Color.secondaryTextColor)
                            }
                        } else if let nextReview = entry.nextReviewDate {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(nextReview.formattedShort)
                                    .font(.system(.title3, design: .serif, weight: .medium))
                                    .foregroundStyle(Color.primaryTextColor)
                                Text("Next review")
                                    .font(.system(size: 11, design: .serif))
                                    .foregroundStyle(Color.secondaryTextColor)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Actions

    private func updateEntry(
        content: String,
        reflection: String?,
        categories: [Category],
        audioFileName: String?,
        transcription: String?
    ) {
        entry.content = content
        entry.reflection = reflection
        entry.categories = categories
        entry.contentAudioFileName = audioFileName
        entry.transcription = transcription
        entry.updatedAt = Date()
        try? modelContext.save()
    }

    private func deleteLearning() {
        // Delete associated audio file if exists
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
        }

        modelContext.delete(entry)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Library Audio Player

private class LibraryAudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?

    func toggle(url: URL) {
        if isPlaying {
            stop()
        } else {
            play(url: url)
        }
    }

    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [LearningEntry.self, Category.self], inMemory: true)
}
