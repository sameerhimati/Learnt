//
//  SettingsService.swift
//  Learnt
//

import Foundation
import UIKit

@Observable
final class SettingsService {
    static let shared = SettingsService()

    // MARK: - Keys

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let captureReminderEnabled = "captureReminderEnabled"
        static let captureReminderTime = "captureReminderTime"
        static let reviewReminderEnabled = "reviewReminderEnabled"
        static let reviewReminderTime = "reviewReminderTime"
        static let notificationPermissionRequested = "notificationPermissionRequested"
        static let reviewStreak = "reviewStreak"
        static let lastReviewDate = "lastReviewDate"
        static let longestReviewStreak = "longestReviewStreak"
        static let graduationThreshold = "graduationThreshold"
        static let monthlyWrappedEnabled = "monthlyWrappedEnabled"
        static let lastWrappedPromptMonth = "lastWrappedPromptMonth"
        static let appearanceMode = "appearanceMode"
        static let dailyQuotesEnabled = "dailyQuotesEnabled"
        static let lastActiveTime = "lastActiveTime"
    }

    // MARK: - Onboarding

    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasSeenOnboarding) }
    }

    // MARK: - Appearance

    enum AppearanceMode: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }

    enum AppIcon: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"

        var iconName: String? {
            switch self {
            case .light: return nil  // Primary icon (no name needed)
            case .dark: return "AppIconDark"
            }
        }

        var previewImageName: String {
            switch self {
            case .light: return "icon-1024"
            case .dark: return "icon-1024-dark"
            }
        }
    }

    var currentAppIcon: AppIcon {
        get {
            if let alternateIconName = UIApplication.shared.alternateIconName {
                return AppIcon.allCases.first { $0.iconName == alternateIconName } ?? .light
            }
            return .light
        }
    }

    func setAppIcon(_ icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else { return }

        UIApplication.shared.setAlternateIconName(icon.iconName) { error in
            if let error = error {
                print("Failed to set app icon: \(error.localizedDescription)")
            }
        }
    }

    var appearanceMode: AppearanceMode {
        get {
            guard let raw = UserDefaults.standard.string(forKey: Keys.appearanceMode),
                  let mode = AppearanceMode(rawValue: raw) else {
                return .system
            }
            return mode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.appearanceMode)
        }
    }

    // MARK: - Daily Quotes

    /// Whether daily quotes are shown on the Today screen (default: false)
    var dailyQuotesEnabled: Bool {
        get {
            // Default to false if not set (users can enable in Settings)
            if UserDefaults.standard.object(forKey: Keys.dailyQuotesEnabled) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: Keys.dailyQuotesEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.dailyQuotesEnabled)
        }
    }

    // MARK: - App Activity Tracking

    /// Last time the app was active (for reset-to-today logic)
    var lastActiveTime: Date? {
        get { UserDefaults.standard.object(forKey: Keys.lastActiveTime) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastActiveTime) }
    }

    /// Check if app has been inactive for more than 1 hour
    var shouldResetToToday: Bool {
        guard let lastActive = lastActiveTime else {
            return true  // First launch or no previous activity
        }
        let hourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        return lastActive < hourAgo
    }

    // MARK: - Capture Reminder

    var captureReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.captureReminderEnabled) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.captureReminderEnabled)
            NotificationService.shared.rescheduleNotifications()
        }
    }

    var captureReminderTime: Date {
        get {
            let seconds = UserDefaults.standard.integer(forKey: Keys.captureReminderTime)
            if seconds == 0 { return defaultCaptureTime }
            return Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(seconds))
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            let seconds = (components.hour ?? 18) * 3600 + (components.minute ?? 0) * 60
            UserDefaults.standard.set(seconds, forKey: Keys.captureReminderTime)
            NotificationService.shared.rescheduleNotifications()
        }
    }

    // MARK: - Review Reminder

    var reviewReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.reviewReminderEnabled) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.reviewReminderEnabled)
            NotificationService.shared.rescheduleNotifications()
        }
    }

    var reviewReminderTime: Date {
        get {
            let seconds = UserDefaults.standard.integer(forKey: Keys.reviewReminderTime)
            if seconds == 0 { return defaultReviewTime }
            return Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(seconds))
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            let seconds = (components.hour ?? 9) * 3600 + (components.minute ?? 0) * 60
            UserDefaults.standard.set(seconds, forKey: Keys.reviewReminderTime)
            NotificationService.shared.rescheduleNotifications()
        }
    }

    // MARK: - Permission State

    var notificationPermissionRequested: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.notificationPermissionRequested) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.notificationPermissionRequested) }
    }

    // MARK: - Review Streak

    var reviewStreak: Int {
        get { UserDefaults.standard.integer(forKey: Keys.reviewStreak) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.reviewStreak) }
    }

    var lastReviewDate: Date? {
        get { UserDefaults.standard.object(forKey: Keys.lastReviewDate) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastReviewDate) }
    }

    var longestReviewStreak: Int {
        get { UserDefaults.standard.integer(forKey: Keys.longestReviewStreak) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.longestReviewStreak) }
    }

    // MARK: - Review Graduation

    /// Number of successful reviews before a learning graduates (default: 4)
    /// Based on neuroscience research: intervals at 1, 7, 16, 35 days optimize retention
    var graduationThreshold: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.graduationThreshold)
            return value == 0 ? 4 : value  // Default to 4 if not set
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.graduationThreshold) }
    }

    // MARK: - Monthly Wrapped

    /// Whether monthly wrapped notification is enabled (default: true)
    var monthlyWrappedEnabled: Bool {
        get {
            // Default to true if not set
            if UserDefaults.standard.object(forKey: Keys.monthlyWrappedEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Keys.monthlyWrappedEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.monthlyWrappedEnabled)
            NotificationService.shared.rescheduleNotifications()
        }
    }

    /// The last month (as "YYYY-MM") the user was prompted to view their wrapped
    var lastWrappedPromptMonth: String? {
        get { UserDefaults.standard.string(forKey: Keys.lastWrappedPromptMonth) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastWrappedPromptMonth) }
    }

    /// Check if we should show the wrapped prompt this month
    var shouldShowWrappedPrompt: Bool {
        let calendar = Calendar.current
        let today = Date()
        let dayOfMonth = calendar.component(.day, from: today)

        // Only show in first 7 days of the month
        guard dayOfMonth <= 7 else { return false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: today)

        // Only show if we haven't shown this month yet
        return lastWrappedPromptMonth != currentMonth
    }

    /// Mark that we've shown the wrapped prompt for the current month
    func markWrappedPromptShown() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        lastWrappedPromptMonth = formatter.string(from: Date())
    }

    // MARK: - Monthly AI Summaries Storage

    private var monthlySummariesKey: String { "monthlySummaries" }

    /// Get stored AI summary for a specific month (format: "yyyy-MM")
    func getAISummary(for monthKey: String) -> String? {
        let summaries = UserDefaults.standard.dictionary(forKey: monthlySummariesKey) as? [String: String] ?? [:]
        return summaries[monthKey]
    }

    /// Store AI summary for a specific month (format: "yyyy-MM")
    func setAISummary(_ summary: String, for monthKey: String) {
        var summaries = UserDefaults.standard.dictionary(forKey: monthlySummariesKey) as? [String: String] ?? [:]
        summaries[monthKey] = summary
        UserDefaults.standard.set(summaries, forKey: monthlySummariesKey)
    }

    /// Check if AI summary exists for a month
    func hasAISummary(for monthKey: String) -> Bool {
        getAISummary(for: monthKey) != nil
    }

    /// Get month key from a date (format: "yyyy-MM")
    func monthKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }

    // MARK: - AI Summary Learning Count (for current month regeneration)

    private var monthlySummaryCountsKey: String { "monthlySummaryCounts" }

    /// Get stored learning count for when AI summary was generated
    func getAISummaryLearningCount(for monthKey: String) -> Int? {
        let counts = UserDefaults.standard.dictionary(forKey: monthlySummaryCountsKey) as? [String: Int] ?? [:]
        return counts[monthKey]
    }

    /// Store learning count when AI summary was generated
    func setAISummaryLearningCount(_ count: Int, for monthKey: String) {
        var counts = UserDefaults.standard.dictionary(forKey: monthlySummaryCountsKey) as? [String: Int] ?? [:]
        counts[monthKey] = count
        UserDefaults.standard.set(counts, forKey: monthlySummaryCountsKey)
    }

    /// Check if a month is in the past (not current month)
    func isMonthPast(_ monthKey: String) -> Bool {
        let currentKey = self.monthKey(from: Date())
        return monthKey < currentKey
    }

    // MARK: - AI Summary Regeneration Tracking

    private var monthlyRegenerationCountsKey: String { "monthlyRegenerationCounts" }

    /// Maximum allowed regenerations per month
    static let maxRegenerationsPerMonth = 2

    /// Get regeneration count for a specific month
    func getRegenerationCount(for monthKey: String) -> Int {
        let counts = UserDefaults.standard.dictionary(forKey: monthlyRegenerationCountsKey) as? [String: Int] ?? [:]
        return counts[monthKey] ?? 0
    }

    /// Increment regeneration count for a month
    func incrementRegenerationCount(for monthKey: String) {
        var counts = UserDefaults.standard.dictionary(forKey: monthlyRegenerationCountsKey) as? [String: Int] ?? [:]
        counts[monthKey] = (counts[monthKey] ?? 0) + 1
        UserDefaults.standard.set(counts, forKey: monthlyRegenerationCountsKey)
    }

    /// Check if regeneration is allowed for a month
    func canRegenerate(for monthKey: String) -> Bool {
        // Can't regenerate past months (they're locked)
        guard !isMonthPast(monthKey) else { return false }

        // Check regeneration count
        return getRegenerationCount(for: monthKey) < Self.maxRegenerationsPerMonth
    }

    /// Get remaining regenerations for a month
    func remainingRegenerations(for monthKey: String) -> Int {
        return max(0, Self.maxRegenerationsPerMonth - getRegenerationCount(for: monthKey))
    }

    /// Clear AI summary to force regeneration
    func clearAISummary(for monthKey: String) {
        var summaries = UserDefaults.standard.dictionary(forKey: monthlySummariesKey) as? [String: String] ?? [:]
        summaries.removeValue(forKey: monthKey)
        UserDefaults.standard.set(summaries, forKey: monthlySummariesKey)

        // Also clear the learning count so it will regenerate
        var counts = UserDefaults.standard.dictionary(forKey: monthlySummaryCountsKey) as? [String: Int] ?? [:]
        counts.removeValue(forKey: monthKey)
        UserDefaults.standard.set(counts, forKey: monthlySummaryCountsKey)
    }

    // MARK: - Defaults

    private var defaultCaptureTime: Date {
        var components = DateComponents()
        components.hour = 18  // 6:00 PM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private var defaultReviewTime: Date {
        var components = DateComponents()
        components.hour = 9  // 9:00 AM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private init() {}
}
