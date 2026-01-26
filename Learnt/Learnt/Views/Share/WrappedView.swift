//
//  WrappedView.swift
//  Learnt
//

import SwiftUI
import UIKit

/// Data model for wrapped summary
struct WrappedData: Identifiable {
    let id = UUID()
    let period: String // e.g., "January 2025"
    let monthDate: Date // The actual month this represents
    let totalLearnings: Int
    let totalDays: Int
    let topCategories: [(name: String, icon: String, count: Int)]
    let longestStreak: Int

    // AI-generated summary (optional)
    var aiSummary: String? = nil
}

/// Wrapper for share preview data
struct SharePreviewData: Identifiable {
    let id = UUID()
    let data: WrappedData
    let summary: String?
}

/// Monthly reflection view - single page with current + past months
struct WrappedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    let currentMonth: WrappedData
    let pastMonths: [WrappedData]
    let onShare: () -> Void
    let onGenerateSummary: (Date, @escaping (String) -> Void) -> Void

    private var settings: SettingsService { SettingsService.shared }

    @State private var selectedPastMonth: WrappedData?
    @State private var isLoadingSummary = false
    @State private var currentSummary: String?
    @State private var sharePreviewData: SharePreviewData?

    private var displaySummary: String? {
        // Don't show any summary if we don't meet minimum requirements
        guard canGenerateAISummary else { return nil }
        return currentSummary ?? currentMonth.aiSummary
    }

    /// Check if AI summary generation is allowed based on learning count
    /// - Requires at least 5 learnings, OR
    /// - It's the 1st of the month with at least 1 learning
    private var canGenerateAISummary: Bool {
        let count = currentMonth.totalLearnings
        if count >= 5 { return true }

        // Allow on 1st of month with at least 1 learning
        let calendar = Calendar.current
        let isFirstOfMonth = calendar.component(.day, from: Date()) == 1
        return isFirstOfMonth && count >= 1
    }

    private var insufficientLearningsMessage: String {
        let needed = 5 - currentMonth.totalLearnings
        return "Add \(needed) more learning\(needed == 1 ? "" : "s") to unlock AI insights"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Current month summary
                    monthCard(data: currentMonth, isCurrent: true, summary: displaySummary, isLoading: isLoadingSummary)

                    // Past months section
                    if !pastMonths.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Past Months")
                                .font(.system(.subheadline, design: .serif, weight: .medium))
                                .foregroundStyle(Color.secondaryTextColor)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                ForEach(pastMonths) { month in
                                    pastMonthRow(data: month)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Month")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        sharePreviewData = SharePreviewData(data: currentMonth, summary: displaySummary)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 28, height: 28)
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
        }
        .sheet(item: $selectedPastMonth) { month in
            PastMonthDetailView(
                data: month,
                onGenerateSummary: onGenerateSummary,
                onShare: { data in
                    selectedPastMonth = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let summary = settings.getAISummary(for: settings.monthKey(from: data.monthDate))
                        sharePreviewData = SharePreviewData(data: data, summary: summary)
                    }
                },
                onDismiss: { selectedPastMonth = nil }
            )
        }
        .sheet(item: $sharePreviewData) { previewData in
            WrappedSharePreview(
                data: previewData.data,
                summary: previewData.summary,
                onDismiss: { sharePreviewData = nil }
            )
        }
        .onAppear {
            loadOrGenerateSummary()
        }
    }

    // MARK: - Summary Loading

    private func loadOrGenerateSummary() {
        let monthKey = settings.monthKey(from: currentMonth.monthDate)

        // Don't load or generate if insufficient learnings
        guard canGenerateAISummary else {
            // Clear any invalid stored summary
            currentSummary = nil
            return
        }

        // For current month, always regenerate to reflect latest learnings
        // (Summary will be locked when the month ends)

        // Check if we have a stored summary AND the stored learning count matches
        // This allows regeneration when user adds more learnings
        if let stored = settings.getAISummary(for: monthKey),
           let storedCount = settings.getAISummaryLearningCount(for: monthKey),
           storedCount == currentMonth.totalLearnings {
            currentSummary = stored
            return
        }

        // Check if passed in data has summary and we have enough learnings
        if currentMonth.aiSummary != nil {
            return
        }

        // Generate new summary
        isLoadingSummary = true
        onGenerateSummary(currentMonth.monthDate) { summary in
            // Only store if we actually got a summary (not empty)
            guard !summary.isEmpty else {
                isLoadingSummary = false
                return
            }
            // Store it with learning count so we know when to regenerate
            settings.setAISummary(summary, for: monthKey)
            settings.setAISummaryLearningCount(currentMonth.totalLearnings, for: monthKey)
            currentSummary = summary
            isLoadingSummary = false
        }
    }

    // MARK: - Current Month Card

    private func monthCard(data: WrappedData, isCurrent: Bool, summary: String? = nil, isLoading: Bool = false) -> some View {
        let displayedSummary = summary ?? data.aiSummary

        return VStack(spacing: 24) {
            // Period header
            Text(data.period)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            // Stats row
            HStack(spacing: 32) {
                statItem(value: "\(data.totalLearnings)", label: "Learnings")
                statItem(value: "\(data.totalDays)", label: "Days")
                statItem(value: "\(data.longestStreak)", label: "Streak")
            }

            // Top 3 categories
            if !data.topCategories.isEmpty {
                VStack(spacing: 12) {
                    Text("Top Categories")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    HStack(spacing: 16) {
                        ForEach(Array(data.topCategories.prefix(3).enumerated()), id: \.offset) { _, category in
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                Text(category.name)
                                    .font(.system(size: 13, design: .serif))
                            }
                            .foregroundStyle(Color.primaryTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.inputBackgroundColor)
                            .clipShape(Capsule())
                        }
                    }
                }
            }

            // AI Summary section
            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("AI Insights")
                        .font(.system(size: 11, design: .serif))
                }
                .foregroundStyle(Color.secondaryTextColor)

                if isLoading {
                    // Loading indicator
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating insights...")
                            .font(.system(size: 14, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                    .padding(.vertical, 8)
                } else if let summary = displayedSummary {
                    Text(summary)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                } else if isCurrent && !canGenerateAISummary {
                    // Not enough learnings message
                    Text(insufficientLearningsMessage)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .multilineTextAlignment(.center)
                } else if !AIService.shared.isAvailable {
                    // AI not available on this device/iOS version
                    Text("AI insights require iOS 26+")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .multilineTextAlignment(.center)
                } else {
                    // Fallback - should rarely appear
                    Text("Your month in reflection")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .italic()
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.inputBackgroundColor.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
            Text(label)
                .font(.system(size: 11, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
    }

    // MARK: - Past Month Row

    private func pastMonthRow(data: WrappedData) -> some View {
        Button(action: { selectedPastMonth = data }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.period)
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)

                    Text("\(data.totalLearnings) learnings · \(data.totalDays) days")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }

                Spacer()

                // Top category badge
                if let top = data.topCategories.first {
                    HStack(spacing: 4) {
                        Image(systemName: top.icon)
                            .font(.system(size: 10))
                        Text(top.name)
                            .font(.system(size: 11, design: .serif))
                    }
                    .foregroundStyle(Color.secondaryTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.inputBackgroundColor)
                    .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondaryTextColor)
            }
            .padding(16)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}

// MARK: - Past Month Detail View

struct PastMonthDetailView: View {
    let data: WrappedData
    let onGenerateSummary: (Date, @escaping (String) -> Void) -> Void
    let onShare: (WrappedData) -> Void
    let onDismiss: () -> Void

    private var settings: SettingsService { SettingsService.shared }

    @State private var summary: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                monthCard
                    .padding(.vertical, 24)
            }
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { onShare(data) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(data.period)
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            loadOrGenerateSummary()
        }
    }

    private var monthCard: some View {
        VStack(spacing: 24) {
            // Period header
            Text(data.period)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            // Stats row
            HStack(spacing: 32) {
                statItem(value: "\(data.totalLearnings)", label: "Learnings")
                statItem(value: "\(data.totalDays)", label: "Days")
                statItem(value: "\(data.longestStreak)", label: "Streak")
            }

            // Top 3 categories
            if !data.topCategories.isEmpty {
                VStack(spacing: 12) {
                    Text("Top Categories")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    HStack(spacing: 16) {
                        ForEach(Array(data.topCategories.prefix(3).enumerated()), id: \.offset) { _, category in
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                Text(category.name)
                                    .font(.system(size: 13, design: .serif))
                            }
                            .foregroundStyle(Color.primaryTextColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.inputBackgroundColor)
                            .clipShape(Capsule())
                        }
                    }
                }
            }

            // AI Summary section
            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("AI Insights")
                        .font(.system(size: 11, design: .serif))
                }
                .foregroundStyle(Color.secondaryTextColor)

                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating insights...")
                            .font(.system(size: 14, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                    .padding(.vertical, 8)
                } else if let summary = summary {
                    Text(summary)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                } else if !AIService.shared.isAvailable {
                    Text("AI insights require iOS 26+")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Your month in reflection")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .italic()
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.inputBackgroundColor.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
            Text(label)
                .font(.system(size: 11, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
    }

    /// Check if AI summary generation is allowed based on learning count
    /// Past months: require at least 1 learning (since they're locked, we only generate once)
    private var canGenerateAISummary: Bool {
        data.totalLearnings >= 1
    }

    private func loadOrGenerateSummary() {
        let monthKey = settings.monthKey(from: data.monthDate)

        // Don't load or generate if no learnings
        guard canGenerateAISummary else {
            summary = nil
            return
        }

        // Past months are locked - use stored summary if exists
        if let stored = settings.getAISummary(for: monthKey) {
            summary = stored
            return
        }

        // Generate new summary for past month (will be locked permanently)
        isLoading = true
        onGenerateSummary(data.monthDate) { newSummary in
            // Only store if we actually got a summary (not empty)
            guard !newSummary.isEmpty else {
                isLoading = false
                return
            }
            // Store it permanently (past months are locked)
            settings.setAISummary(newSummary, for: monthKey)
            summary = newSummary
            isLoading = false
        }
    }
}

// MARK: - Share Preview View

struct WrappedSharePreview: View {
    let data: WrappedData
    let summary: String?
    let onDismiss: () -> Void

    @State private var useDarkMode = true
    @State private var isSharing = false
    @State private var shareAsText = false

    // Card is designed at full export size, preview is scaled down
    private let cardSize = CGSize(width: 1080, height: 1920)
    private var previewScale: CGFloat { 200.0 / 1080.0 }  // Scale to fit ~200pt width

    private var textToShare: String {
        var text = "\(data.period)\n\n"
        text += "\(data.totalLearnings) Learnings · \(data.totalDays) Days · \(data.longestStreak) Day Streak\n\n"

        if !data.topCategories.isEmpty {
            text += "Top Categories: \(data.topCategories.prefix(3).map { $0.name }.joined(separator: ", "))\n\n"
        }

        if let summary = summary, !summary.isEmpty {
            text += "AI Insights:\n\(summary)\n\n"
        }

        text += "— Learnt"
        return text
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode toggle (Image / Text)
                HStack(spacing: 0) {
                    modeButton(label: "Image", isSelected: !shareAsText) {
                        shareAsText = false
                    }
                    modeButton(label: "Text", isSelected: shareAsText) {
                        shareAsText = true
                    }
                }
                .padding(.top, 16)

                Spacer()

                if shareAsText {
                    // Text preview
                    ScrollView {
                        Text(textToShare)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.inputBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                } else {
                    // Card preview (scaled down from full size)
                    shareableCard(darkMode: useDarkMode)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .scaleEffect(previewScale)
                        .frame(width: cardSize.width * previewScale, height: cardSize.height * previewScale)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                }

                Spacer()

                // Share button
                Button {
                    if shareAsText {
                        shareText()
                    } else {
                        shareCard()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSharing {
                            ProgressView()
                                .tint(Color.appBackgroundColor)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text("Share")
                    }
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(Color.appBackgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isSharing)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !shareAsText {
                        Button(action: { useDarkMode.toggle() }) {
                            Image(systemName: useDarkMode ? "sun.max" : "moon")
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 28, height: 28)
                                .foregroundStyle(Color.primaryTextColor)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Share")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 28, height: 28)
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
        }
    }

    private func modeButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular, design: .serif))
                .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? Color.inputBackgroundColor : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shareable Card (designed at 1080x1920)

    @ViewBuilder
    private func shareableCard(darkMode: Bool) -> some View {
        let bgColor = darkMode ? Color(red: 0.08, green: 0.08, blue: 0.08) : Color(red: 0.98, green: 0.98, blue: 0.98)
        let primaryColor = darkMode ? Color.white : Color(red: 0.1, green: 0.1, blue: 0.1)
        let secondaryColor = darkMode ? Color(red: 0.5, green: 0.5, blue: 0.5) : Color(red: 0.5, green: 0.5, blue: 0.5)
        let borderColor = darkMode ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.85, green: 0.85, blue: 0.85)
        let cardBgColor = darkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.95, green: 0.95, blue: 0.95)

        ZStack {
            // Background
            bgColor

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Month/Period - Large bold header
                Text(data.period.uppercased())
                    .font(.system(size: 42, weight: .medium, design: .serif))
                    .foregroundColor(secondaryColor)
                    .tracking(4)

                Spacer().frame(height: 60)

                // Main stat - HUGE number
                Text("\(data.totalLearnings)")
                    .font(.system(size: 220, weight: .bold, design: .serif))
                    .foregroundColor(primaryColor)

                Text(data.totalLearnings == 1 ? "Learning" : "Learnings")
                    .font(.system(size: 48, weight: .regular, design: .serif))
                    .foregroundColor(secondaryColor)

                Spacer().frame(height: 80)

                // Secondary stats
                HStack(spacing: 80) {
                    statColumn(value: "\(data.totalDays)", label: "Days", primary: primaryColor, secondary: secondaryColor)
                    statColumn(value: "\(data.longestStreak)", label: "Day Streak", primary: primaryColor, secondary: secondaryColor)
                }

                Spacer().frame(height: 80)

                // Categories (if any)
                if !data.topCategories.isEmpty {
                    HStack(spacing: 24) {
                        ForEach(Array(data.topCategories.prefix(3).enumerated()), id: \.offset) { _, category in
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 28))
                                Text(category.name)
                                    .font(.system(size: 32, weight: .medium, design: .serif))
                            }
                            .foregroundColor(primaryColor)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 20)
                            .background(cardBgColor)
                            .clipShape(Capsule())
                        }
                    }

                    Spacer().frame(height: 60)
                }

                // AI Summary box
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                        Text("AI Insights")
                            .font(.system(size: 28, weight: .medium, design: .serif))
                    }
                    .foregroundColor(secondaryColor)

                    if let summary = summary, !summary.isEmpty {
                        Text(summary)
                            .font(.system(size: 36, weight: .regular, design: .serif))
                            .foregroundColor(primaryColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("Your month in reflection")
                            .font(.system(size: 36, weight: .regular, design: .serif))
                            .foregroundColor(secondaryColor)
                            .italic()
                    }
                }
                .padding(48)
                .frame(maxWidth: .infinity)
                .background(cardBgColor)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(.horizontal, 60)

                Spacer()

                // Footer
                Text("Learnt")
                    .font(.system(size: 36, weight: .medium, design: .serif))
                    .foregroundColor(secondaryColor)
                    .padding(.bottom, 60)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 48))
        .overlay(
            RoundedRectangle(cornerRadius: 48)
                .stroke(borderColor, lineWidth: 2)
        )
    }

    private func statColumn(value: String, label: String, primary: Color, secondary: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 72, weight: .bold, design: .serif))
                .foregroundColor(primary)
            Text(label)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundColor(secondary)
        }
    }

    // MARK: - Share

    private func shareCard() {
        isSharing = true

        // Render the card at full size
        let cardView = shareableCard(darkMode: useDarkMode)
            .frame(width: cardSize.width, height: cardSize.height)

        Task { @MainActor in
            if let image = ShareImageService.shared.renderToImage(cardView, size: cardSize) {
                ShareImageService.shared.shareImage(image)
            }
            isSharing = false
        }
    }

    private func shareText() {
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    WrappedView(
        currentMonth: WrappedData(
            period: "January 2025",
            monthDate: Date(),
            totalLearnings: 47,
            totalDays: 23,
            topCategories: [
                (name: "Learning", icon: "book", count: 18),
                (name: "Work", icon: "briefcase", count: 15),
                (name: "Personal", icon: "person", count: 14)
            ],
            longestStreak: 14,
            aiSummary: "You've been focused on expanding your technical knowledge this month, with a particular emphasis on learning new frameworks and tools."
        ),
        pastMonths: [
            WrappedData(
                period: "December 2024",
                monthDate: Date().adding(months: -1),
                totalLearnings: 32,
                totalDays: 18,
                topCategories: [(name: "Work", icon: "briefcase", count: 12)],
                longestStreak: 8
            ),
            WrappedData(
                period: "November 2024",
                monthDate: Date().adding(months: -2),
                totalLearnings: 28,
                totalDays: 15,
                topCategories: [(name: "Personal", icon: "person", count: 10)],
                longestStreak: 5
            )
        ],
        onShare: {},
        onGenerateSummary: { _, completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion("Preview summary generated.")
            }
        }
    )
}
