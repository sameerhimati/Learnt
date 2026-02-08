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

    // Free-text reflection (optional)
    var reflection: String?

    // Spaced repetition
    var nextReviewDate: Date?
    var reviewInterval: Int       // days until next review
    var reviewCount: Int          // times successfully reviewed
    var firstReflectionDate: Date?  // When user first reflected (starts the review timer)

    // Categories (can have multiple)
    @Relationship var categories: [Category] = []

    // Voice memo audio file paths (stored as file names in Documents)
    var contentAudioFileName: String?
    var reflectionAudioFileName: String?

    // Optional transcription of voice content
    var transcription: String?

    // Favorites
    var isFavorite: Bool = false

    // Graduation (after completing review cycle)
    var isGraduated: Bool = false

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

        // Reflection defaults to nil
        self.reflection = nil

        // Spaced repetition defaults - timer starts on first reflection, not creation
        self.nextReviewDate = nil
        self.reviewInterval = 0
        self.reviewCount = 0
        self.firstReflectionDate = nil

        // Transcription, favorites, and graduation defaults
        self.transcription = nil
        self.isFavorite = false
        self.isGraduated = false
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

    var hasReflection: Bool {
        reflection != nil
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

    // MARK: - Audio Helpers

    var hasAnyAudio: Bool {
        contentAudioFileName != nil ||
        reflectionAudioFileName != nil
    }

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func audioURL(for fileName: String?) -> URL? {
        guard let fileName = fileName else { return nil }
        return Self.documentsDirectory.appendingPathComponent(fileName)
    }

    var contentAudioURL: URL? { audioURL(for: contentAudioFileName) }
    var reflectionAudioURL: URL? { audioURL(for: reflectionAudioFileName) }
}
