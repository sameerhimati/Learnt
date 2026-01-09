//
//  Category.swift
//  Learnt
//

import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String  // SF Symbol name
    var sortOrder: Int
    var isPreset: Bool
    var createdAt: Date

    init(name: String, icon: String, sortOrder: Int, isPreset: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.isPreset = isPreset
        self.createdAt = Date()
    }

    // Preset categories
    static let presets: [(name: String, icon: String)] = [
        ("Personal", "person"),
        ("Work", "briefcase"),
        ("Learning", "book"),
        ("Relationships", "heart")
    ]
}
