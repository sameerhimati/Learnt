//
//  ProfileView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [LearningEntry]
    @State private var showClearDataAlert = false
    @State private var showWrapped = false
    @State private var showStreakShare = false
    @State private var showLibrary = false
    @State private var showGraduationPicker = false
    @State private var showAppearancePicker = false
    @State private var selectedStatExplanation: StatType?
    @State private var showTutorialResetAlert = false
    @State private var dailyQuotesEnabled: Bool = SettingsService.shared.dailyQuotesEnabled

    // Settings observation for reminder subtitle updates
    private var settings: SettingsService { SettingsService.shared }

    // Stat explanation types
    enum StatType: Identifiable {
        case reviewed, graduated, reflected

        var id: Self { self }

        var title: String {
            switch self {
            case .reviewed: return "Reviewed"
            case .graduated: return "Graduated"
            case .reflected: return "Reflected"
            }
        }

        var icon: String {
            switch self {
            case .reviewed: return "arrow.triangle.2.circlepath"
            case .graduated: return "checkmark.seal"
            case .reflected: return "text.bubble"
            }
        }

        var explanation: String {
            switch self {
            case .reviewed:
                return "Learnings you've reviewed at least once through spaced repetition. Each review strengthens the memory at optimal intervals (1, 7, 16, 35 days)."
            case .graduated:
                return "Learnings that have completed the full review cycle. These are now stored in long-term memory and won't appear in your review queue."
            case .reflected:
                return "Learnings where you've added reflection prompts (how to apply, what surprised you, simplified explanation, or questions raised)."
            }
        }
    }

    // Force refresh for reminders subtitle
    @State private var reminderRefreshTrigger = false

    // MARK: - Computed Stats

    private var totalEntries: Int {
        entries.count
    }

    private var totalDays: Int {
        Set(entries.map { $0.date.startOfDay }).count
    }

    private var currentStreak: Int {
        guard !entries.isEmpty else { return 0 }

        let datesWithEntries = Set(entries.map { $0.date.startOfDay })
        var streak = 0
        var checkDate = Date().startOfDay

        if datesWithEntries.contains(checkDate) {
            streak = 1
            checkDate = checkDate.yesterday.startOfDay
        } else {
            checkDate = checkDate.yesterday.startOfDay
            if !datesWithEntries.contains(checkDate) {
                return 0
            }
            streak = 1
            checkDate = checkDate.yesterday.startOfDay
        }

        while datesWithEntries.contains(checkDate) {
            streak += 1
            checkDate = checkDate.yesterday.startOfDay
        }

        return streak
    }

    private var reviewedCount: Int {
        entries.filter { $0.reviewCount > 0 }.count
    }

    private var dueForReview: Int {
        entries.filter { $0.isDueForReview }.count
    }

    private var reflectionCount: Int {
        entries.filter { $0.hasReflections }.count
    }

    private var graduatedCount: Int {
        entries.filter { $0.isGraduated }.count
    }

    private var reminderSubtitle: String {
        // Use reminderRefreshTrigger to force recalculation when returning from settings
        _ = reminderRefreshTrigger
        let enabled = [settings.captureReminderEnabled, settings.reviewReminderEnabled].filter { $0 }.count
        switch enabled {
        case 0: return "Off"
        case 1: return "1 reminder"
        case 2: return "2 reminders"
        default: return "On"
        }
    }

    private var longestStreak: Int {
        guard !entries.isEmpty else { return 0 }

        let datesWithEntries = Set(entries.map { $0.date.startOfDay }).sorted()
        guard let firstDate = datesWithEntries.first else { return 0 }

        var longest = 1
        var current = 1
        var previousDate = firstDate

        for date in datesWithEntries.dropFirst() {
            if Calendar.current.isDate(date, inSameDayAs: previousDate.tomorrow) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
            previousDate = date
        }

        return longest
    }

    private var topCategories: [(name: String, icon: String, count: Int)] {
        var categoryCount: [String: (icon: String, count: Int)] = [:]

        for entry in entries {
            for category in entry.categories {
                if let existing = categoryCount[category.name] {
                    categoryCount[category.name] = (category.icon, existing.count + 1)
                } else {
                    categoryCount[category.name] = (category.icon, 1)
                }
            }
        }

        return categoryCount
            .map { (name: $0.key, icon: $0.value.icon, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var mostActiveDay: String {
        guard !entries.isEmpty else { return "Monday" }

        let calendar = Calendar.current
        var dayCount: [Int: Int] = [:]  // weekday: count

        for entry in entries {
            let weekday = calendar.component(.weekday, from: entry.date)
            dayCount[weekday, default: 0] += 1
        }

        // Find the day with the most entries
        let mostActive = dayCount.max(by: { $0.value < $1.value })?.key ?? 1

        // Convert weekday number to name (1=Sunday, 2=Monday, etc.)
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[mostActive - 1]
    }

    private var currentMonthData: WrappedData {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"

        // Load stored summary if available
        let monthKey = settings.monthKey(from: Date())
        let storedSummary = settings.getAISummary(for: monthKey)

        return WrappedData(
            period: monthFormatter.string(from: Date()),
            monthDate: Date(),
            totalLearnings: currentMonthEntries.count,
            totalDays: Set(currentMonthEntries.map { $0.date.startOfDay }).count,
            topCategories: topCategories,
            longestStreak: longestStreak,
            aiSummary: storedSummary
        )
    }

    private var currentMonthEntries: [LearningEntry] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())

        return entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == month && entryYear == year
        }
    }

    private var pastMonthsData: [WrappedData] {
        var pastMonths: [WrappedData] = []
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"

        for monthOffset in 1...6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) else { continue }

            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)

            let monthEntries = entries.filter { entry in
                let entryMonth = calendar.component(.month, from: entry.date)
                let entryYear = calendar.component(.year, from: entry.date)
                return entryMonth == month && entryYear == year
            }

            if !monthEntries.isEmpty {
                let datesWithEntries = Set(monthEntries.map { $0.date.startOfDay }).sorted()
                var longest = 1
                var current = 1
                if let firstDate = datesWithEntries.first {
                    var previousDate = firstDate
                    for date in datesWithEntries.dropFirst() {
                        if calendar.isDate(date, inSameDayAs: previousDate.tomorrow) {
                            current += 1
                            longest = max(longest, current)
                        } else {
                            current = 1
                        }
                        previousDate = date
                    }
                }

                var categoryCount: [String: (icon: String, count: Int)] = [:]
                for entry in monthEntries {
                    for category in entry.categories {
                        if let existing = categoryCount[category.name] {
                            categoryCount[category.name] = (category.icon, existing.count + 1)
                        } else {
                            categoryCount[category.name] = (category.icon, 1)
                        }
                    }
                }
                let topCats = categoryCount
                    .map { (name: $0.key, icon: $0.value.icon, count: $0.value.count) }
                    .sorted { $0.count > $1.count }

                pastMonths.append(WrappedData(
                    period: monthFormatter.string(from: monthDate),
                    monthDate: monthDate,
                    totalLearnings: monthEntries.count,
                    totalDays: datesWithEntries.count,
                    topCategories: topCats,
                    longestStreak: longest
                ))
            }
        }

        return pastMonths
    }

    // MARK: - AI Summary

    private func generateAISummary(for monthDate: Date, completion: @escaping (String) -> Void) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: monthDate)
        let year = calendar.component(.year, from: monthDate)

        let monthEntries = entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == month && entryYear == year
        }

        // Don't generate if no entries - let the UI show the placeholder
        guard !monthEntries.isEmpty else {
            return
        }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let period = monthFormatter.string(from: monthDate)

        // Build top categories for this month
        var categoryCount: [String: Int] = [:]
        for entry in monthEntries {
            for category in entry.categories {
                categoryCount[category.name, default: 0] += 1
            }
        }
        let topCats = categoryCount
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }

        Task {
            #if DEBUG
            // Use mock data in DEBUG
            let result = AIService.mockMonthlySummary(count: monthEntries.count, period: period, topCategories: topCats)
            await MainActor.run {
                completion(result.summary)
            }
            #else
            // Use real AI when available
            let result = await AIService.shared.generateMonthlySummary(
                entries: monthEntries,
                period: period,
                topCategories: topCats
            )
            await MainActor.run {
                completion(result?.summary ?? "Keep learning, keep growing")
            }
            #endif
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main stats
                    mainStatsSection
                        .padding(.top, 16)

                    // Review stats (always show, even when zero)
                    reviewStatsSection

                    // Share section (always show)
                    shareSection

                    Divider()
                        .background(Color.dividerColor)

                    // Settings section
                    settingsSection

                    Spacer()
                        .frame(height: 60)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("You")
            .navigationBarTitleDisplayMode(.large)
            .alert("Clear All Data?", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all \(entries.count) learnings. This cannot be undone.")
            }
            .alert("Tutorial Reset", isPresented: $showTutorialResetAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Feature tips have been reset. You'll see them again as you navigate the app.")
            }
            .fullScreenCover(isPresented: $showWrapped) {
                WrappedView(
                    currentMonth: currentMonthData,
                    pastMonths: pastMonthsData,
                    onShare: {},
                    onGenerateSummary: { monthDate, completion in
                        generateAISummary(for: monthDate, completion: completion)
                    }
                )
            }
            .sheet(isPresented: $showStreakShare) {
                StreakShareSheet(streakDays: currentStreak, totalLearnings: totalEntries)
            }
            .sheet(isPresented: $showLibrary) {
                LibraryView()
            }
            .sheet(isPresented: $showGraduationPicker) {
                GraduationSettingsSheet()
            }
            .sheet(isPresented: $showAppearancePicker) {
                AppearanceSettingsSheet()
            }
            .sheet(item: $selectedStatExplanation) { stat in
                StatExplanationSheet(stat: stat)
            }
            .onAppear {
                // Refresh reminders subtitle when returning from settings
                reminderRefreshTrigger.toggle()
            }
        }
    }

    // MARK: - Share Section

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share & Browse")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            HStack(spacing: 12) {
                // Library button
                Button(action: { showLibrary = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.primaryTextColor)

                        Text("Library")
                            .font(.system(size: 12, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // Your Month button
                Button(action: { showWrapped = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.primaryTextColor)

                        Text("Your Month")
                            .font(.system(size: 12, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // Share Streak button
                Button(action: { showStreakShare = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "flame")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.primaryTextColor)

                        Text("Streak")
                            .font(.system(size: 12, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(currentStreak == 0)
                .opacity(currentStreak == 0 ? 0.5 : 1)
            }
            .coachMark(
                .yourMonth,
                title: "Your Month",
                message: "View your monthly learning summary with stats and insights.",
                arrowDirection: .up
            )
        }
    }

    // MARK: - Main Stats

    private var mainStatsSection: some View {
        HStack(spacing: 12) {
            statCard(value: "\(currentStreak)", label: "Day Streak", icon: "flame")
            statCard(value: "\(totalEntries)", label: "Learnings", icon: "lightbulb")
            statCard(value: "\(totalDays)", label: "Days", icon: "calendar")
        }
    }

    // MARK: - Review Stats

    private var reviewStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review Progress")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            HStack(spacing: 12) {
                tappableStatCard(value: "\(reviewedCount)", label: "Reviewed", type: .reviewed)
                tappableStatCard(value: "\(graduatedCount)", label: "Graduated", type: .graduated)
                tappableStatCard(value: "\(reflectionCount)", label: "Reflected", type: .reflected)
            }

            if dueForReview > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text("\(dueForReview) learning\(dueForReview == 1 ? "" : "s") ready for review")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            NavigationLink {
                ReminderSettingsView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminders")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                        Text(reminderSubtitle)
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Graduation threshold
            Button(action: { showGraduationPicker = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Graduation")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                        Text("\(settings.graduationThreshold) reviews to graduate")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Appearance
            Button(action: { showAppearancePicker = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "moon")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Appearance")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                        Text(settings.appearanceMode.rawValue)
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Daily Quotes toggle
            HStack(spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.secondaryTextColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Quotes")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                    Text("Show inspirational quotes on Today")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }

                Spacer()

                Toggle("", isOn: $dailyQuotesEnabled)
                    .labelsHidden()
                    .toggleStyle(MonochromeToggleStyle())
            }
            .padding(16)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onChange(of: dailyQuotesEnabled) { _, newValue in
                settings.dailyQuotesEnabled = newValue
                if newValue {
                    // When re-enabling quotes, also clear "hidden for today" flag
                    QuoteService.shared.showQuote()
                }
            }

            // Replay Tutorial button
            Button(action: {
                CoachMarkService.shared.resetAllMarks()
                showTutorialResetAlert = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Replay Tutorial")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                        Text("Show feature tips again")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Clear data button
            Button(action: { showClearDataAlert = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear All Data")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                        Text("Delete all learnings")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            // Legal & Support links
            HStack(spacing: 24) {
                Link(destination: URL(string: "https://sameerhimati.github.io/Learnt/privacy.html")!) {
                    Text("Privacy Policy")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }

                Link(destination: URL(string: "https://sameerhimati.github.io/Learnt/support.html")!) {
                    Text("Support")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func clearAllData() {
        for entry in entries {
            modelContext.delete(entry)
        }
        try? modelContext.save()
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.6))

            Text(value)
                .font(.system(.title, design: .serif, weight: .medium))
                .foregroundStyle(Color.primaryTextColor)

            Text(label)
                .font(.system(size: 11, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func tappableStatCard(value: String, label: String, type: StatType) -> some View {
        Button(action: { selectedStatExplanation = type }) {
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(.title3, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)

                Text(label)
                    .font(.system(size: 10, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

}

// MARK: - Graduation Settings Sheet

struct GraduationSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedThreshold: Int = SettingsService.shared.graduationThreshold

    private let options = [3, 4, 5, 6]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Explanation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When do learnings graduate?")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)

                        Text("Graduated learnings have completed the review cycle and are stored in long-term memory. They won't appear in your review queue anymore.")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .lineSpacing(2)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Options
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                selectedThreshold = option
                                SettingsService.shared.graduationThreshold = option
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(option) reviews")
                                            .font(.system(.body, design: .serif, weight: selectedThreshold == option ? .medium : .regular))
                                            .foregroundStyle(Color.primaryTextColor)

                                        Text(intervalsFor(option))
                                            .font(.system(size: 12, design: .serif))
                                            .foregroundStyle(Color.secondaryTextColor)
                                    }

                                    Spacer()

                                    if selectedThreshold == option {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color.primaryTextColor)
                                    }
                                }
                                .padding(16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if option != options.last {
                                Divider()
                                    .background(Color.dividerColor)
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Science note
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 12))
                        Text("Default is 4 reviews based on neuroscience research on memory consolidation.")
                            .font(.system(size: 12, design: .serif))
                    }
                    .foregroundStyle(Color.secondaryTextColor)
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("Graduation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func intervalsFor(_ count: Int) -> String {
        switch count {
        case 3: return "Days 1, 7, 16"
        case 4: return "Days 1, 7, 16, 30 (recommended)"
        case 5: return "Days 1, 7, 16, 30, 45"
        case 6: return "Days 1, 7, 16, 30, 45, 60"
        default: return ""
        }
    }
}

// MARK: - Appearance Settings Sheet

struct AppearanceSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: SettingsService.AppearanceMode = SettingsService.shared.appearanceMode
    @State private var selectedIcon: SettingsService.AppIcon = SettingsService.shared.currentAppIcon

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.secondaryTextColor)

                        VStack(spacing: 0) {
                            ForEach(SettingsService.AppearanceMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedMode = mode
                                    SettingsService.shared.appearanceMode = mode
                                }) {
                                    HStack {
                                        HStack(spacing: 12) {
                                            Image(systemName: iconFor(mode))
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.secondaryTextColor)
                                                .frame(width: 24)

                                            Text(mode.rawValue)
                                                .font(.system(.body, design: .serif, weight: selectedMode == mode ? .medium : .regular))
                                                .foregroundStyle(Color.primaryTextColor)
                                        }

                                        Spacer()

                                        if selectedMode == mode {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Color.primaryTextColor)
                                        }
                                    }
                                    .padding(16)
                                }
                                .buttonStyle(.plain)

                                if mode != SettingsService.AppearanceMode.allCases.last {
                                    Divider()
                                        .background(Color.dividerColor)
                                        .padding(.leading, 52)
                                }
                            }
                        }
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // App Icon options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App Icon")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.secondaryTextColor)

                        HStack(spacing: 16) {
                            ForEach(SettingsService.AppIcon.allCases, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                    SettingsService.shared.setAppIcon(icon)
                                }) {
                                    VStack(spacing: 8) {
                                        // Icon preview
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(icon == .light ? Color(hex: "FAFAFA") : Color(hex: "1A1A1A"))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Text("L")
                                                    .font(.system(size: 28, weight: .medium, design: .serif))
                                                    .foregroundStyle(icon == .light ? Color(hex: "1A1A1A") : Color(hex: "FAFAFA"))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(selectedIcon == icon ? Color.primaryTextColor : Color.clear, lineWidth: 2)
                                            )
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                                        Text(icon.rawValue)
                                            .font(.system(size: 12, design: .serif))
                                            .foregroundStyle(Color.primaryTextColor)

                                        if selectedIcon == icon {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color.primaryTextColor)
                                        } else {
                                            Circle()
                                                .stroke(Color.secondaryTextColor, lineWidth: 1)
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func iconFor(_ mode: SettingsService.AppearanceMode) -> String {
        switch mode {
        case .system: return "iphone"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

// MARK: - Stat Explanation Sheet

struct StatExplanationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let stat: ProfileView.StatType

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: stat.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.primaryTextColor)
                    .padding(.top, 24)

                // Title
                Text(stat.title)
                    .font(.system(.title2, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)

                // Explanation
                Text(stat.explanation)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.appBackgroundColor)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.secondaryTextColor)
                            .frame(width: 28, height: 28)
                            .background(Color.inputBackgroundColor)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
