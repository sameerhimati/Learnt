//
//  EntryStore.swift
//  Learnt
//

import Foundation
import SwiftData

/// Result of a spaced repetition review (simplified to 2 options)
enum ReviewResult {
    case gotIt       // Advance to next interval in the schedule
    case reviewAgain // Reset to 1-day interval
}

@Observable
final class EntryStore {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func entries(for date: Date) -> [LearningEntry] {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        let predicate = #Predicate<LearningEntry> { entry in
            entry.date >= startOfDay && entry.date <= endOfDay
        }
        let descriptor = FetchDescriptor<LearningEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }

    func hasEntries(for date: Date) -> Bool {
        !entries(for: date).isEmpty
    }

    func datesWithEntries(in range: ClosedRange<Date>) -> Set<Date> {
        let predicate = #Predicate<LearningEntry> { entry in
            entry.date >= range.lowerBound && entry.date <= range.upperBound
        }
        let descriptor = FetchDescriptor<LearningEntry>(predicate: predicate)

        do {
            let entries = try modelContext.fetch(descriptor)
            return Set(entries.map { $0.date.startOfDay })
        } catch {
            print("Failed to fetch dates: \(error)")
            return []
        }
    }

    func datesWithEntries(forWeekOf date: Date) -> Set<Date> {
        let start = date.startOfWeek
        let end = date.endOfWeek
        return datesWithEntries(in: start...end)
    }

    func datesWithEntries(forMonthOf date: Date) -> Set<Date> {
        let start = date.startOfMonth
        let end = date.endOfMonth
        return datesWithEntries(in: start...end)
    }

    // MARK: - Create

    func createEntry(content: String, for date: Date) {
        let existingEntries = entries(for: date)
        let sortOrder = existingEntries.count

        let entry = LearningEntry(
            content: content,
            date: date,
            sortOrder: sortOrder
        )
        modelContext.insert(entry)
        save()
    }

    // MARK: - Update

    func updateEntry(_ entry: LearningEntry, content: String) {
        entry.content = content
        entry.updatedAt = Date()
        save()
    }

    func updateReflections(
        _ entry: LearningEntry,
        application: String? = nil,
        surprise: String? = nil,
        simplification: String? = nil,
        question: String? = nil
    ) {
        entry.application = application
        entry.surprise = surprise
        entry.simplification = simplification
        entry.question = question

        // Start the spaced repetition timer on first reflection
        let hasNewReflections = application != nil || surprise != nil || simplification != nil || question != nil
        if entry.firstReflectionDate == nil && hasNewReflections {
            entry.firstReflectionDate = Date()
            // Schedule first review for tomorrow
            entry.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
            entry.reviewInterval = 1
        }

        entry.updatedAt = Date()
        save()
    }

    // MARK: - Review (Spaced Repetition)

    func entriesDueForReview() -> [LearningEntry] {
        let now = Date()
        let predicate = #Predicate<LearningEntry> { entry in
            entry.nextReviewDate != nil && entry.nextReviewDate! <= now
        }
        let descriptor = FetchDescriptor<LearningEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.nextReviewDate)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch review entries: \(error)")
            return []
        }
    }

    func upcomingReviews(limit: Int = 10) -> [LearningEntry] {
        let now = Date()
        let predicate = #Predicate<LearningEntry> { entry in
            entry.nextReviewDate != nil && entry.nextReviewDate! > now
        }
        var descriptor = FetchDescriptor<LearningEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.nextReviewDate)]
        )
        descriptor.fetchLimit = limit

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch upcoming reviews: \(error)")
            return []
        }
    }

    /// Record a review result and update spaced repetition schedule
    /// Intervals are threshold-based and capped at 35 days max
    /// - Parameters:
    ///   - entry: The entry being reviewed
    ///   - result: Whether user recalled it (.gotIt) or needs another review (.reviewAgain)
    func recordReview(_ entry: LearningEntry, result: ReviewResult) {
        let calendar = Calendar.current
        let threshold = SettingsService.shared.graduationThreshold

        switch result {
        case .gotIt:
            entry.reviewCount += 1

            // Check for graduation
            if entry.reviewCount >= threshold {
                entry.isGraduated = true
                entry.nextReviewDate = nil  // No more reviews needed
            } else {
                // Threshold-based intervals, all capped at 35 days
                let intervals: [Int]
                switch threshold {
                case 3:  intervals = [7, 21, 35]
                case 4:  intervals = [7, 14, 28, 35]
                case 5:  intervals = [5, 12, 21, 28, 35]
                case 6:  intervals = [4, 9, 16, 23, 30, 35]
                default: intervals = [7, 14, 28, 35]
                }

                let nextInterval = intervals[min(entry.reviewCount - 1, intervals.count - 1)]
                entry.reviewInterval = nextInterval
                entry.nextReviewDate = calendar.date(byAdding: .day, value: nextInterval, to: Date())
            }

        case .reviewAgain:
            // Reset interval to 1 day but keep review count
            entry.reviewInterval = 1
            entry.nextReviewDate = calendar.date(byAdding: .day, value: 1, to: Date())
        }

        entry.updatedAt = Date()
        save()

        // Update review streak
        updateReviewStreak()
    }

    /// Update review streak based on review activity
    private func updateReviewStreak() {
        let settings = SettingsService.shared
        let today = Date().startOfDay

        if let lastReview = settings.lastReviewDate?.startOfDay {
            if lastReview == today {
                // Already reviewed today, no change to streak
            } else if lastReview == today.yesterday.startOfDay {
                // Consecutive day, increment streak
                settings.reviewStreak += 1
            } else {
                // Missed days, reset streak
                settings.reviewStreak = 1
            }
        } else {
            // First review ever
            settings.reviewStreak = 1
        }

        settings.lastReviewDate = today

        // Update longest streak if current is higher
        if settings.reviewStreak > settings.longestReviewStreak {
            settings.longestReviewStreak = settings.reviewStreak
        }
    }

    // MARK: - Delete

    func deleteEntry(_ entry: LearningEntry) {
        modelContext.delete(entry)
        save()
    }

    // MARK: - Helpers

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
