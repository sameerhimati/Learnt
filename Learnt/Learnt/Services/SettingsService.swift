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
        static let captureReminderEnabled = "captureReminderEnabled"
        static let captureReminderTime = "captureReminderTime"
        static let reviewReminderEnabled = "reviewReminderEnabled"
        static let reviewReminderTime = "reviewReminderTime"
        static let notificationPermissionRequested = "notificationPermissionRequested"
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
