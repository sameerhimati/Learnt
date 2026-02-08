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
                return "Learnings where you've added a personal reflection. Reflecting deepens understanding and retention."
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

    private var reviewedCount: Int {
        entries.filter { $0.reviewCount > 0 }.count
    }

    private var dueForReview: Int {
        entries.filter { $0.isDueForReview }.count
    }

    private var reflectionCount: Int {
        entries.filter { $0.hasReflection }.count
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main stats
                    mainStatsSection
                        .padding(.top, 16)

                    // Review stats (always show, even when zero)
                    reviewStatsSection

                    // Library link
                    librarySection

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

    // MARK: - Library Section

    private var librarySection: some View {
        Button(action: { showLibrary = true }) {
            HStack(spacing: 12) {
                Image(systemName: "books.vertical")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.secondaryTextColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Library")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                    Text("Browse all your learnings")
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
    }

    // MARK: - Main Stats

    private var mainStatsSection: some View {
        HStack(spacing: 12) {
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
