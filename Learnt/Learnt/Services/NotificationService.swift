//
//  NotificationService.swift
//  Learnt
//

import Foundation
import UserNotifications

@Observable
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let settings = SettingsService.shared

    // MARK: - Notification Identifiers

    private enum Identifiers {
        static let captureReminder = "learnt.capture.reminder"
        static let reviewReminder = "learnt.review.reminder"
        static let monthlyWrapped = "learnt.monthly.wrapped"
    }

    // MARK: - Authorization Status

    var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            settings.notificationPermissionRequested = true
            await updateAuthorizationStatus()

            if granted {
                settings.captureReminderEnabled = true
                settings.reviewReminderEnabled = true
            }

            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func updateAuthorizationStatus() async {
        let notificationSettings = await center.notificationSettings()
        authorizationStatus = notificationSettings.authorizationStatus
    }

    // MARK: - Scheduling

    func rescheduleNotifications() {
        Task {
            await cancelAllNotifications()

            if settings.captureReminderEnabled {
                await scheduleCaptureReminder()
            }

            if settings.reviewReminderEnabled {
                await scheduleReviewReminder()
            }

            if settings.monthlyWrappedEnabled {
                await scheduleMonthlyWrapped()
            }
        }
    }

    private func scheduleCaptureReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Time to reflect"
        content.body = "What did you learn today?"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: settings.captureReminderTime
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifiers.captureReminder,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule capture reminder: \(error)")
        }
    }

    private func scheduleReviewReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "Review time"
        content.body = "Strengthen your learnings with a quick review"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: settings.reviewReminderTime
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifiers.reviewReminder,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule review reminder: \(error)")
        }
    }

    private func scheduleMonthlyWrapped() async {
        let content = UNMutableNotificationContent()
        content.title = "Your Month in Learning"
        content.body = "Your monthly learning wrapped is ready! See your progress and insights."
        content.sound = .default

        // Schedule for the 1st of each month at 10:00 AM
        var components = DateComponents()
        components.day = 1
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifiers.monthlyWrapped,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule monthly wrapped reminder: \(error)")
        }
    }

    private func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }

    private init() {
        Task {
            await updateAuthorizationStatus()
        }
    }
}
