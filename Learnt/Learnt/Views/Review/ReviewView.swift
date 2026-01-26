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

    private var settings: SettingsService { SettingsService.shared }

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var dueForReview: [LearningEntry] {
        allEntries.filter { $0.isDueForReview }
    }

    private var totalReviewed: Int {
        allEntries.filter { $0.reviewCount > 0 }.count
    }

    private var graduatedCount: Int {
        allEntries.filter { $0.isGraduated }.count
    }

    private var nextReviewDate: Date? {
        allEntries
            .compactMap { $0.nextReviewDate }
            .filter { $0 > Date() }
            .min()
    }


    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackgroundColor
                    .ignoresSafeArea()

                if allEntries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Streak badge (if active)
                            if settings.reviewStreak > 0 {
                                streakBadge
                            }

                            // Ready for review section
                            reviewReadySection

                            // Stats section
                            statsSection

                            // Science-backed explanation
                            scienceNote
                        }
                        .padding(16)
                        .padding(.bottom, 80)
                    }
                }
            }
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
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.4))

            VStack(spacing: 8) {
                Text("No learnings yet")
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                Text("Add your first learning in the Today tab.\nThey'll appear here for spaced review.")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame")
                .font(.system(size: 16))
            Text("\(settings.reviewStreak)-day streak")
                .font(.system(.subheadline, design: .serif, weight: .medium))
        }
        .foregroundStyle(Color.primaryTextColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.inputBackgroundColor)
        .clipShape(Capsule())
    }

    // MARK: - Review Ready Section

    private var reviewReadySection: some View {
        VStack(spacing: 16) {
            // Hero card with count and status
            VStack(spacing: 12) {
                // Main count display
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready for review")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text("\(dueForReview.count)")
                        .font(.system(size: 56, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Status message
                HStack(spacing: 8) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 12))
                    Text(statusMessage)
                        .font(.system(size: 13, design: .serif))
                }
                .foregroundStyle(Color.secondaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .coachMark(
                .reviewDue,
                title: "Spaced Repetition",
                message: "Review learnings at optimal intervals to move them into long-term memory.",
                arrowDirection: .up
            )

            // Start button
            Button(action: { showReviewSession = true }) {
                HStack(spacing: 8) {
                    if dueForReview.count > 0 {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                    }
                    Text(dueForReview.isEmpty ? "No Reviews Due" : "Start Review Session")
                }
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

    private var statusIcon: String {
        if dueForReview.count > 0 {
            return "sparkles"
        } else if let next = nextReviewDate {
            return Calendar.current.isDateInToday(next) ? "clock" : "calendar"
        } else {
            return "checkmark.circle"
        }
    }

    private var statusMessage: String {
        if dueForReview.count > 0 {
            let plural = dueForReview.count == 1 ? "learning is" : "learnings are"
            return "\(dueForReview.count) \(plural) ready to reinforce"
        } else if let next = nextReviewDate {
            if Calendar.current.isDateInToday(next) {
                return "Next review later today"
            } else if Calendar.current.isDateInTomorrow(next) {
                return "Next review tomorrow"
            } else if let days = Calendar.current.dateComponents([.day], from: Date(), to: next).day {
                return "Next review in \(days) days"
            }
        }
        return "All caught up!"
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            // 3 stats in a row
            HStack(spacing: 12) {
                statCard(value: "\(allEntries.count)", label: "Total")
                statCard(value: "\(totalReviewed)", label: "Reviewed")
                statCard(value: "\(graduatedCount)", label: "Graduated")
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

    // MARK: - Science Note

    private var scienceNote: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 12))
                Text("Based on neuroscience")
                    .font(.system(size: 12, weight: .medium, design: .serif))
            }
            .foregroundStyle(Color.secondaryTextColor)

            Text("Spaced reviews optimize long-term retention. After \(SettingsService.shared.graduationThreshold) successful reviews, learnings graduate.")
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.8))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ReviewView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
