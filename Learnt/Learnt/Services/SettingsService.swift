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
        static let graduationThreshold = "graduationThreshold"
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

    /// Whether daily quotes are shown on the Today screen (default: true)
    var dailyQuotesEnabled: Bool {
        get {
            // Default to true if not set
            if UserDefaults.standard.object(forKey: Keys.dailyQuotesEnabled) == nil {
                return true
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
