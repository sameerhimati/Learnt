//
//  LearningEntry.swift
//  Learnt
//

import Foundation
import SwiftData

@Model
final class LearningEntry {
    var id: UUID
    var content: String
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var sortOrder: Int

    // Reflection prompts (all optional)
    var application: String?      // "How could you apply this?"
    var surprise: String?         // "What surprised you?"
    var simplification: String?   // "Explain it simply"
    var question: String?         // "What question does this raise?"

    // Spaced repetition
    var nextReviewDate: Date?
    var reviewInterval: Int       // days until next review (starts at 1)
    var reviewCount: Int          // times successfully reviewed

    init(
        content: String,
        date: Date = Date(),
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.content = content
        self.date = date.startOfDay
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = sortOrder

        // Reflection fields default to nil
        self.application = nil
        self.surprise = nil
        self.simplification = nil
        self.question = nil

        // Spaced repetition defaults
        self.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        self.reviewInterval = 1
        self.reviewCount = 0
    }
}

extension LearningEntry {
    var previewText: String {
        let maxLength = 50
        if content.count <= maxLength {
            return content
        }
        let index = content.index(content.startIndex, offsetBy: maxLength)
        return String(content[..<index]) + "..."
    }

    // MARK: - Reflection Helpers

    var hasReflections: Bool {
        application != nil || surprise != nil || simplification != nil || question != nil
    }

    var reflectionCount: Int {
        [application, surprise, simplification, question].compactMap { $0 }.count
    }

    // MARK: - Review Helpers

    var isDueForReview: Bool {
        guard let nextReview = nextReviewDate else { return false }
        return nextReview <= Date()
    }

    var daysUntilReview: Int? {
        guard let nextReview = nextReviewDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date().startOfDay, to: nextReview.startOfDay)
        return components.day
    }
}
