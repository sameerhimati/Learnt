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

    // MARK: - Computed Stats

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

        if datesWithEntries.contains(checkDate) {
            streak = 1
            checkDate = checkDate.yesterday.startOfDay
        } else {
            checkDate = checkDate.yesterday.startOfDay
            if !datesWithEntries.contains(checkDate) {
                return 0
            }
            streak = 1
            checkDate = checkDate.yesterday.startOfDay
        }

        while datesWithEntries.contains(checkDate) {
            streak += 1
            checkDate = checkDate.yesterday.startOfDay
        }

        return streak
    }

    private var reviewedCount: Int {
        entries.filter { $0.reviewCount > 0 }.count
    }

    private var dueForReview: Int {
        entries.filter { $0.isDueForReview }.count
    }

    private var reflectionCount: Int {
        entries.filter { $0.hasReflections }.count
    }

    private var retentionRate: String {
        let reviewed = entries.filter { $0.reviewCount > 0 }
        guard !reviewed.isEmpty else { return "—" }
        let avgInterval = reviewed.map { Double($0.reviewInterval) }.reduce(0, +) / Double(reviewed.count)
        let rate = min(Int((avgInterval / 90.0) * 100), 100)
        return "\(rate)%"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main stats
                    mainStatsSection
                        .padding(.top, 16)

                    // Review stats
                    if totalEntries > 0 {
                        reviewStatsSection
                    }

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
        }
    }

    // MARK: - Main Stats

    private var mainStatsSection: some View {
        HStack(spacing: 12) {
            statCard(value: "\(currentStreak)", label: "Day Streak", icon: "flame")
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
                miniStatCard(value: "\(reviewedCount)", label: "Reviewed")
                miniStatCard(value: retentionRate, label: "Retention")
                miniStatCard(value: "\(reflectionCount)", label: "Reflected")
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

            settingsRow(icon: "bell", title: "Reminders", subtitle: "Coming soon")
            settingsRow(icon: "moon", title: "Appearance", subtitle: "System")
            settingsRow(icon: "square.and.arrow.up", title: "Export Data", subtitle: "Coming soon")

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

    private func miniStatCard(value: String, label: String) -> some View {
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
