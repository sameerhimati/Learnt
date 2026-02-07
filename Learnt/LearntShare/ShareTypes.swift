//
//  ShareTypes.swift
//  LearntShare
//
//  Shared types for the share extension

import Foundation

/// Simplified category for share extension (read from App Group)
struct ShareCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let icon: String
}

/// State for the share extension
enum ShareState: Equatable {
    case loading
    case ready
    case saving
    case error(String)
}
