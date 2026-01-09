//
//  ReminderSettingsView.swift
//  Learnt
//

import SwiftUI

struct ReminderSettingsView: View {
    @State private var showPermissionAlert = false
    @State private var captureEnabled = SettingsService.shared.captureReminderEnabled
    @State private var captureTime = SettingsService.shared.captureReminderTime
    @State private var reviewEnabled = SettingsService.shared.reviewReminderEnabled
    @State private var reviewTime = SettingsService.shared.reviewReminderTime

    private var notifications: NotificationService { NotificationService.shared }
    private var settings: SettingsService { SettingsService.shared }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Capture reminder section
                VStack(alignment: .leading, spacing: 20) {
                    Toggle(isOn: $captureEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Capture Reminder")
                                .font(.system(.body, design: .serif, weight: .medium))
                                .foregroundStyle(Color.primaryTextColor)
                            Text("Daily reminder to record learnings")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)
                        }
                    }
                    .tint(Color.primaryTextColor)

                    if captureEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)

                            DatePicker(
                                "",
                                selection: $captureTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 150)
                        }
                    }
                }
                .padding(20)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Review reminder section
                VStack(alignment: .leading, spacing: 20) {
                    Toggle(isOn: $reviewEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Review Reminder")
                                .font(.system(.body, design: .serif, weight: .medium))
                                .foregroundStyle(Color.primaryTextColor)
                            Text("Morning reminder for spaced repetition")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)
                        }
                    }
                    .tint(Color.primaryTextColor)

                    if reviewEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)

                            DatePicker(
                                "",
                                selection: $reviewTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 150)
                        }
                    }
                }
                .padding(20)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(16)
            .padding(.bottom, 80)
        }
        .background(Color.appBackgroundColor)
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Sync state with settings
            captureEnabled = settings.captureReminderEnabled
            captureTime = settings.captureReminderTime
            reviewEnabled = settings.reviewReminderEnabled
            reviewTime = settings.reviewReminderTime
        }
        .onChange(of: captureEnabled) { _, newValue in
            settings.captureReminderEnabled = newValue
            if newValue { checkPermission() }
        }
        .onChange(of: captureTime) { _, newValue in
            settings.captureReminderTime = newValue
        }
        .onChange(of: reviewEnabled) { _, newValue in
            settings.reviewReminderEnabled = newValue
            if newValue { checkPermission() }
        }
        .onChange(of: reviewTime) { _, newValue in
            settings.reviewReminderTime = newValue
        }
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive reminders.")
        }
    }

    // MARK: - Helpers

    private func checkPermission() {
        Task {
            await notifications.updateAuthorizationStatus()
            if notifications.authorizationStatus == .notDetermined {
                _ = await notifications.requestPermission()
            } else if notifications.authorizationStatus == .denied {
                showPermissionAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
}
