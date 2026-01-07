//
//  ReviewView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [LearningEntry]

    @State private var showReviewSession = false

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var dueForReview: [LearningEntry] {
        allEntries.filter { $0.isDueForReview }
    }

    private var upcomingReviews: [LearningEntry] {
        allEntries
            .filter { $0.nextReviewDate != nil && !$0.isDueForReview }
            .sorted { ($0.nextReviewDate ?? .distantFuture) < ($1.nextReviewDate ?? .distantFuture) }
            .prefix(5)
            .map { $0 }
    }

    private var totalReviewed: Int {
        allEntries.filter { $0.reviewCount > 0 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if allEntries.isEmpty {
                        emptyState
                    } else {
                        // Ready for review section
                        reviewReadySection

                        // Stats section
                        statsSection

                        // Upcoming reviews
                        if !upcomingReviews.isEmpty {
                            upcomingSection
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 80)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showReviewSession) {
                ReviewSessionView(
                    entries: dueForReview,
                    onComplete: { showReviewSession = false }
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 100)

            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.5))

            Text("No learnings to review")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Text("Add learnings in the Today tab\nand they'll appear here for review")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Review Ready Section

    private var reviewReadySection: some View {
        VStack(spacing: 16) {
            // Count badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready for review")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text("\(dueForReview.count)")
                        .font(.system(size: 48, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                }

                Spacer()

                if dueForReview.count > 0 {
                    // Decorative icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.3))
                }
            }
            .padding(20)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Start button
            Button(action: { showReviewSession = true }) {
                Text("Start Review Session")
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(dueForReview.isEmpty ? Color.secondaryTextColor : Color.appBackgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(dueForReview.isEmpty ? Color.dividerColor : Color.primaryTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(dueForReview.isEmpty)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            HStack(spacing: 12) {
                statCard(value: "\(allEntries.count)", label: "Learnings")
                statCard(value: "\(totalReviewed)", label: "Reviewed")
                statCard(value: retentionRate, label: "Retention")
            }
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .serif, weight: .medium))
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

    private var retentionRate: String {
        let reviewed = allEntries.filter { $0.reviewCount > 0 }
        guard !reviewed.isEmpty else { return "—" }

        // Calculate based on current intervals (higher interval = better retention)
        let avgInterval = reviewed.map { Double($0.reviewInterval) }.reduce(0, +) / Double(reviewed.count)
        let rate = min(Int((avgInterval / 90.0) * 100), 100)
        return "\(rate)%"
    }

    // MARK: - Upcoming Section

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coming up")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            VStack(spacing: 8) {
                ForEach(upcomingReviews) { entry in
                    upcomingRow(entry)
                }
            }
        }
    }

    private func upcomingRow(_ entry: LearningEntry) -> some View {
        HStack(spacing: 12) {
            Text(entry.previewText)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .lineLimit(1)

            Spacer()

            if let days = entry.daysUntilReview {
                Text(days == 0 ? "Today" : days == 1 ? "Tomorrow" : "In \(days) days")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }
        }
        .padding(12)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ReviewView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
