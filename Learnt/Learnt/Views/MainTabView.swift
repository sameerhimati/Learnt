//
//  MainTabView.swift
//  Learnt

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 1  // Start on Today (center)
    @State private var showWrappedPrompt = false
    @State private var showWrapped = false
    @Query private var entries: [LearningEntry]

    private var settings: SettingsService { SettingsService.shared }
    private var notifications: NotificationService { NotificationService.shared }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    ReviewView()
                case 1:
                    TodayView()
                case 2:
                    ProfileView()
                default:
                    TodayView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            checkWrappedPrompt()
        }
        .alert("Your Month in Learning", isPresented: $showWrappedPrompt) {
            Button("View My Wrapped") {
                settings.markWrappedPromptShown()
                showWrapped = true
            }
            Button("Later", role: .cancel) {
                settings.markWrappedPromptShown()
            }
        } message: {
            Text("Your monthly learning summary is ready! See your progress, insights, and celebrate your growth.")
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
    }

    // MARK: - AI Summary Generation

    private func generateAISummary(for monthDate: Date, completion: @escaping (String) -> Void) {
        let monthEntries = entriesForMonth(monthDate)

        // Don't generate if no entries - let the UI show the placeholder
        guard !monthEntries.isEmpty else {
            return
        }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let period = monthFormatter.string(from: monthDate)

        // Build top categories
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
            // Check if AI is available on this device
            if AIService.shared.isAvailable {
                // Use real AI
                let result = await AIService.shared.generateMonthlySummary(
                    entries: monthEntries,
                    period: period,
                    topCategories: topCats
                )
                await MainActor.run {
                    completion(result?.summary ?? AIService.shared.fallbackSummary(count: monthEntries.count, period: period).summary)
                }
            } else {
                // Use fallback when AI is unavailable
                let fallback = AIService.shared.fallbackSummary(count: monthEntries.count, period: period)
                await MainActor.run {
                    completion(fallback.summary)
                }
            }
        }
    }

    // MARK: - Wrapped Prompt

    private func checkWrappedPrompt() {
        // Only show if:
        // 1. We haven't shown this month
        // 2. User has at least 1 learning
        // 3. Notifications are not authorized (so they wouldn't get the notification)
        guard settings.shouldShowWrappedPrompt,
              !entries.isEmpty else { return }

        Task {
            await notifications.updateAuthorizationStatus()

            // Only show in-app if notifications are not authorized
            if notifications.authorizationStatus != .authorized {
                await MainActor.run {
                    // Small delay for better UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showWrappedPrompt = true
                    }
                }
            } else {
                // If notifications are on, they'll get the notification
                // Still mark as shown so we don't double-prompt
                settings.markWrappedPromptShown()
            }
        }
    }

    // MARK: - Wrapped Data

    private var currentMonthData: WrappedData {
        wrappedDataForMonth(Date())
    }

    private var pastMonthsData: [WrappedData] {
        // Get up to 6 past months with entries
        var pastMonths: [WrappedData] = []
        let calendar = Calendar.current

        for monthOffset in 1...6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) else { continue }

            let monthEntries = entriesForMonth(monthDate)
            if !monthEntries.isEmpty {
                pastMonths.append(wrappedDataForMonth(monthDate))
            }
        }

        return pastMonths
    }

    private func wrappedDataForMonth(_ date: Date) -> WrappedData {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"

        let monthEntries = entriesForMonth(date)
        let totalDays = Set(monthEntries.map { $0.date.startOfDay }).count
        let longestStreak = calculateLongestStreak(for: monthEntries)
        let topCategories = calculateTopCategories(for: monthEntries)

        return WrappedData(
            period: monthFormatter.string(from: date),
            monthDate: date,
            totalLearnings: monthEntries.count,
            totalDays: totalDays,
            topCategories: topCategories,
            longestStreak: longestStreak
        )
    }

    private func entriesForMonth(_ date: Date) -> [LearningEntry] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        return entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == month && entryYear == year
        }
    }

    private func calculateLongestStreak(for monthEntries: [LearningEntry]) -> Int {
        guard !monthEntries.isEmpty else { return 0 }

        let datesWithEntries = Set(monthEntries.map { $0.date.startOfDay }).sorted()
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

    private func calculateTopCategories(for monthEntries: [LearningEntry]) -> [(name: String, icon: String, count: Int)] {
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

        return categoryCount
            .map { (name: $0.key, icon: $0.value.icon, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
