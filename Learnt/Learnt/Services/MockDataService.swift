//
//  MockDataService.swift
//  Learnt
//

import Foundation
import SwiftData

struct MockDataService {

    static let mockLearnings = [
        "The best way to learn is to teach others what you know.",
        "Compound interest works for knowledge too - small daily learnings add up.",
        "Taking breaks actually improves focus and retention.",
        "Writing things down by hand helps memory more than typing.",
        "Sleep is when your brain consolidates what you learned during the day.",
        "Asking 'why' five times gets you to the root cause of any problem.",
        "The Feynman technique: explain it simply to truly understand it.",
        "Spaced repetition beats cramming every time.",
        "Your environment shapes your habits more than willpower.",
        "Reading fiction improves empathy and emotional intelligence.",
        "Walking meetings boost creativity by 60%.",
        "The 2-minute rule: if it takes less than 2 minutes, do it now.",
        "Gratitude journaling measurably improves mental health.",
        "Deep work requires at least 90 minutes of uninterrupted focus.",
        "Learning a new skill is harder at first but gets easier - the J-curve.",
        "Saying no to good opportunities makes room for great ones.",
        "Your brain can't actually multitask - it just switches rapidly.",
        "Cold showers increase alertness and may boost immunity.",
        "Meditation physically changes brain structure in 8 weeks.",
        "The best time to learn something new is right after exercise.",
        "Failure is data, not defeat.",
        "Constraints breed creativity.",
        "Done is better than perfect.",
        "Small consistent actions beat sporadic big efforts.",
        "Your network is your net worth - relationships compound too.",
        "Boredom is the birthplace of creativity.",
        "Questions are more valuable than answers.",
        "The map is not the territory - models are always simplifications.",
        "Inversion: think about what you want to avoid, not just what you want.",
        "First principles thinking: break problems down to fundamental truths."
    ]

    static func populateMockData(modelContext: ModelContext) {
        // Check if we already have mock data
        let descriptor = FetchDescriptor<LearningEntry>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0

        // Only add mock data if we have fewer than 10 entries
        guard existingCount < 10 else { return }

        let calendar = Calendar.current
        let today = Date()

        // Past week - one entry per day
        for daysAgo in 1...7 {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                let learning = mockLearnings.randomElement() ?? "Something interesting"
                let entry = LearningEntry(
                    content: learning,
                    date: date,
                    sortOrder: 0
                )
                modelContext.insert(entry)
            }
        }

        // Add some entries from 2 weeks ago
        for daysAgo in [10, 12, 14] {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                let learning = mockLearnings.randomElement() ?? "Something interesting"
                let entry = LearningEntry(
                    content: learning,
                    date: date,
                    sortOrder: 0
                )
                modelContext.insert(entry)
            }
        }

        // Random days in the past 2-3 months
        let randomDaysAgo = [21, 28, 35, 42, 50, 60, 75, 90]
        for daysAgo in randomDaysAgo {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) {
                let learning = mockLearnings.randomElement() ?? "Something interesting"
                let entry = LearningEntry(
                    content: learning,
                    date: date,
                    sortOrder: 0
                )
                modelContext.insert(entry)

                // Sometimes add a second entry for the same day
                if Bool.random() {
                    let learning2 = mockLearnings.randomElement() ?? "Another insight"
                    let entry2 = LearningEntry(
                        content: learning2,
                        date: date,
                        sortOrder: 1
                    )
                    modelContext.insert(entry2)
                }
            }
        }

        try? modelContext.save()
    }
}
