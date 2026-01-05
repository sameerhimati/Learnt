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
    var isVoiceEntry: Bool
    var sortOrder: Int

    init(
        content: String,
        date: Date = Date(),
        isVoiceEntry: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.content = content
        self.date = date.startOfDay
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isVoiceEntry = isVoiceEntry
        self.sortOrder = sortOrder
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
}
