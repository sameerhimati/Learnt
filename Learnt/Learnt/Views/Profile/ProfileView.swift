//
//  ProfileView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var entries: [LearningEntry]

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

        // Check if today has an entry
        if datesWithEntries.contains(checkDate) {
            streak = 1
            checkDate = checkDate.yesterday.startOfDay
        } else {
            // Check yesterday (allow one day grace)
            checkDate = checkDate.yesterday.startOfDay
            if !datesWithEntries.contains(checkDate) {
                return 0
            }
            streak = 1
            checkDate = checkDate.yesterday.startOfDay
        }

        // Count consecutive days going back
        while datesWithEntries.contains(checkDate) {
            streak += 1
            checkDate = checkDate.yesterday.startOfDay
        }

        return streak
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Stats
                    HStack(spacing: 24) {
                        statCard(value: "\(currentStreak)", label: "Day Streak")
                        statCard(value: "\(totalEntries)", label: "Learnings")
                        statCard(value: "\(totalDays)", label: "Days")
                    }
                    .padding(.top, 24)

                    Divider()
                        .background(Color.dividerColor)

                    // Settings section (stub for now)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)

                        settingsRow(icon: "bell", title: "Reminders", subtitle: "Coming in v2")
                        settingsRow(icon: "moon", title: "Appearance", subtitle: "System")
                        settingsRow(icon: "square.and.arrow.up", title: "Export Data", subtitle: "Coming in v2")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("You")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(.largeTitle, design: .serif))
                .fontWeight(.medium)
                .foregroundStyle(Color.primaryTextColor)

            Text(label)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func settingsRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.secondaryTextColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                Text(subtitle)
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
}

#Preview {
    ProfileView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
