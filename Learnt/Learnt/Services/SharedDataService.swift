//
//  SharedDataService.swift
//  Learnt
//
//  Manages shared data between the main app and share extension via App Groups

import Foundation

/// Service for sharing data between the main app and extensions via App Groups
final class SharedDataService {
    static let shared = SharedDataService()

    /// The App Group identifier - must match the one configured in Xcode
    static let appGroupIdentifier = "group.com.sameer.Learnt"

    /// UserDefaults key for pending shared content (array)
    private let pendingSharesKey = "PendingShares"

    /// Legacy key for single pending share (migration)
    private let legacyPendingShareKey = "PendingSharedContent"

    /// UserDefaults key for shared categories
    static let categoriesKey = "SharedCategories"

    /// Shared UserDefaults for the App Group
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: SharedDataService.appGroupIdentifier)
    }

    private init() {}

    // MARK: - Pending Share

    /// Structure representing content shared from the extension (V2 format)
    struct PendingShare: Identifiable {
        let id: UUID
        let text: String
        let url: String?
        let categoryIds: [UUID]
        let timestamp: Date

        init(id: UUID = UUID(), text: String, url: String? = nil, categoryIds: [UUID] = [], timestamp: Date = Date()) {
            self.id = id
            self.text = text
            self.url = url
            self.categoryIds = categoryIds
            self.timestamp = timestamp
        }
    }

    /// Check if there are pending shares from the extension
    func hasPendingShares() -> Bool {
        guard let defaults = sharedDefaults else { return false }
        // Check new array key or legacy single key
        if let data = defaults.data(forKey: pendingSharesKey),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           !array.isEmpty {
            return true
        }
        // Check legacy single share key
        return defaults.data(forKey: legacyPendingShareKey) != nil
    }

    /// Retrieve and clear ALL pending shares
    /// Supports both V1 (legacy) and V2 (with categories) formats
    func consumeAllPendingShares() -> [PendingShare] {
        var shares: [PendingShare] = []

        // First, check for new array format
        if let data = sharedDefaults?.data(forKey: pendingSharesKey),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            for json in jsonArray {
                if let share = parsePendingShare(from: json) {
                    shares.append(share)
                }
            }
            // Clear the array
            sharedDefaults?.removeObject(forKey: pendingSharesKey)
        }

        // Also check legacy single share key for migration
        if let data = sharedDefaults?.data(forKey: legacyPendingShareKey),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let share = parsePendingShare(from: json) {
            shares.append(share)
            sharedDefaults?.removeObject(forKey: legacyPendingShareKey)
        }

        return shares
    }

    /// Parse a single pending share from JSON dictionary
    private func parsePendingShare(from json: [String: Any]) -> PendingShare? {
        guard let text = json["text"] as? String else { return nil }

        let timestamp: Date
        if let ts = json["timestamp"] as? Double {
            timestamp = Date(timeIntervalSince1970: ts)
        } else {
            timestamp = Date()
        }

        let version = json["version"] as? Int ?? 1

        if version == 1 {
            let url = json["url"] as? String
            return PendingShare(text: text, url: url, categoryIds: [], timestamp: timestamp)
        }

        // V2 format
        let categoryIdStrings = json["categoryIds"] as? [String] ?? []
        let categoryIds = categoryIdStrings.compactMap { UUID(uuidString: $0) }
        return PendingShare(text: text, url: nil, categoryIds: categoryIds, timestamp: timestamp)
    }

    /// Add a pending share (called by share extension)
    func addPendingShare(_ share: [String: Any]) {
        guard let defaults = sharedDefaults else { return }

        // Load existing shares array
        var existingShares: [[String: Any]] = []
        if let data = defaults.data(forKey: pendingSharesKey),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            existingShares = array
        }

        // Append new share
        existingShares.append(share)

        // Save back
        if let data = try? JSONSerialization.data(withJSONObject: existingShares) {
            defaults.set(data, forKey: pendingSharesKey)
        }
    }

    // MARK: - Categories Sync

    /// Simplified category struct for sharing via App Group
    struct SharedCategory: Codable {
        let id: UUID
        let name: String
        let icon: String
    }

    /// Write categories to App Group for share extension to read
    func syncCategories(_ categories: [SharedCategory]) {
        guard let defaults = sharedDefaults else { return }

        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: SharedDataService.categoriesKey)
        }
    }

    /// Read categories from App Group (used by share extension)
    func loadCategories() -> [SharedCategory] {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: SharedDataService.categoriesKey),
              let categories = try? JSONDecoder().decode([SharedCategory].self, from: data) else {
            return []
        }
        return categories
    }
}
