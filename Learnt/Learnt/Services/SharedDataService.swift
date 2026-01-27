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

    /// UserDefaults key for pending shared content
    private let pendingShareKey = "PendingSharedContent"

    /// Shared UserDefaults for the App Group
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: SharedDataService.appGroupIdentifier)
    }

    private init() {}

    // MARK: - Pending Share

    /// Structure representing content shared from the extension
    struct PendingShare {
        let text: String
        let url: String?
        let timestamp: Date
    }

    /// Check if there's a pending share from the extension
    func hasPendingShare() -> Bool {
        return sharedDefaults?.data(forKey: pendingShareKey) != nil
    }

    /// Retrieve and clear the pending share
    /// Note: Must match the JSON format used by ShareViewController in the extension
    func consumePendingShare() -> PendingShare? {
        guard let data = sharedDefaults?.data(forKey: pendingShareKey),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let text = json["text"] as? String else {
            return nil
        }

        let url = json["url"] as? String
        let timestamp: Date
        if let ts = json["timestamp"] as? Double {
            timestamp = Date(timeIntervalSince1970: ts)
        } else {
            timestamp = Date()
        }

        // Clear the pending share
        sharedDefaults?.removeObject(forKey: pendingShareKey)
        return PendingShare(text: text, url: url, timestamp: timestamp)
    }
}
