//
//  ReviewView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [LearningEntry]
    @Query private var allCategories: [Category]

    @State private var showReviewSession = false
    @State private var selectedCategoryFilter: Category?
    @State private var includeGraduated = false
    @State private var showFilterSheet = false

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var dueForReview: [LearningEntry] {
        allEntries.filter { $0.isDueForReview }
    }

    private var reviewableEntries: [LearningEntry] {
        var entries: [LearningEntry]

        if includeGraduated {
            entries = allEntries.filter { $0.isDueForReview || $0.isGraduated }
        } else {
            entries = dueForReview
        }

        if let category = selectedCategoryFilter {
            entries = entries.filter { $0.categories.contains(category) }
        }

        return entries
    }

    private var isFilterActive: Bool {
        selectedCategoryFilter != nil || includeGraduated
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
                        VStack(spacing: 0) {
                            if !reviewableEntries.isEmpty {
                                // Due entries with start button
                                dueSection
                            } else {
                                // All caught up
                                caughtUpSection
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showFilterSheet = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.primaryTextColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())

                            if isFilterActive {
                                Circle()
                                    .fill(Color.primaryTextColor)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 4, y: 6)
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showReviewSession) {
                ReviewSessionView(
                    entries: reviewableEntries,
                    onComplete: { showReviewSession = false }
                )
            }
            .sheet(isPresented: $showFilterSheet) {
                ReviewFilterSheet(
                    categories: Array(allCategories),
                    selectedCategory: $selectedCategoryFilter,
                    includeGraduated: $includeGraduated
                )
            }
        }
    }

    // MARK: - Empty State

    /// Whether any entry has a reflection (meaning something is in the review pipeline)
    private var hasAnyReflections: Bool {
        allEntries.contains { $0.hasReflection }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            if allEntries.isEmpty {
                // No entries at all
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.4))

                VStack(spacing: 8) {
                    Text("Review starts after you reflect")
                        .font(.system(.title3, design: .serif, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text("Capture a learning in Today, then add\na reflection. That starts the review timer.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            } else if !hasAnyReflections {
                // Has entries but no reflections yet
                Image(systemName: "text.bubble")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.4))

                VStack(spacing: 8) {
                    Text("Add a reflection to start review")
                        .font(.system(.title3, design: .serif, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text("Tap any learning in Today and add a reflection.\nYou'll be prompted to review it at the right time.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            } else {
                // Has reflections but nothing due (shouldn't normally reach here, but fallback)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.4))

                VStack(spacing: 8) {
                    Text("Nothing due yet")
                        .font(.system(.title3, design: .serif, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text("Your learnings will appear here\nwhen it's time to review them.")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    // MARK: - Due Section

    private var dueSection: some View {
        VStack(spacing: 0) {
            // Header with start button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(reviewableEntries.count) ready")
                        .font(.system(.title3, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)

                    if isFilterActive {
                        Text("filtered")
                            .font(.system(size: 11, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                    }
                }

                Spacer()

                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showReviewSession = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                        Text("Start")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                    }
                    .foregroundStyle(Color.appBackgroundColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.primaryTextColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Entry preview list
            VStack(spacing: 1) {
                ForEach(Array(reviewableEntries.enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: 12) {
                        // Index number
                        Text("\(index + 1)")
                            .font(.system(size: 13, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                            .frame(width: 20, alignment: .trailing)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.content)
                                .font(.system(size: 15, design: .serif))
                                .foregroundStyle(Color.primaryTextColor)
                                .lineLimit(1)

                            Text(entry.date.relativeDay)
                                .font(.system(size: 12, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.inputBackgroundColor)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .onAppear {
                // Track first time seeing review with due items
                if !OnboardingProgressService.shared.hasSeenFirstReview {
                    OnboardingProgressService.shared.reach(.firstReviewSeen)
                }
            }
            .coachMark(
                .reviewDue,
                title: "Time to review",
                message: "Read each learning and rate how well you know it. The app spaces out reviews so you remember long-term.",
                arrowDirection: .up
            )
        }
    }

    // MARK: - Caught Up Section

    private var caughtUpSection: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 60)

            if hasAnyReflections {
                // Legitimately caught up — has entries in the pipeline but none due
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.3))

                Text("All caught up")
                    .font(.system(.title3, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)

                if let next = nextReviewDate {
                    Text("Next review \(next.relativeDay)")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }
            } else {
                // Nothing in the review pipeline yet
                Image(systemName: "text.bubble")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.3))

                Text("No learnings in review")
                    .font(.system(.title3, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Add a reflection to any learning\nto start spaced review.")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

// MARK: - Date Relative Day

private extension Date {
    var relativeDay: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(self) {
            return "today"
        } else if calendar.isDateInYesterday(self) {
            return "yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "tomorrow"
        }

        let components = calendar.dateComponents([.day], from: self.startOfDay, to: now.startOfDay)
        if let days = components.day, days > 0 {
            return "\(days) days ago"
        }

        let futureComponents = calendar.dateComponents([.day], from: now.startOfDay, to: self.startOfDay)
        if let days = futureComponents.day, days > 0 {
            return "in \(days) days"
        }

        return self.formattedShort
    }
}

#Preview {
    ReviewView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
