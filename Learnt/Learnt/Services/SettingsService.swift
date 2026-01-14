//
//  SettingsService.swift
//  Learnt
//

import Foundation

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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonth = formatter.string(from: Date())

        // Only show if it's a new month and we haven't shown yet
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
