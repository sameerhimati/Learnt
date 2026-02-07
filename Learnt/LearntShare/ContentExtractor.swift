//
//  ContentExtractor.swift
//  LearntShare
//
//  Async content extraction from share extension attachments

import Foundation
import UniformTypeIdentifiers

/// Result of content extraction
struct ExtractedContent {
    var text: String?
    var url: String?

    var isEmpty: Bool {
        (text?.isEmpty ?? true) && (url?.isEmpty ?? true)
    }
}

/// Extracts content from NSExtensionContext attachments
final class ContentExtractor {

    /// Extract all content from extension context
    /// Blocks until all attachments are processed
    static func extract(from context: NSExtensionContext?) async -> ExtractedContent {
        guard let extensionItems = context?.inputItems as? [NSExtensionItem] else {
            return ExtractedContent()
        }

        var result = ExtractedContent()

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                // Try URL first
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    if let url = await loadURL(from: provider) {
                        result.url = url.absoluteString
                    }
                }

                // Try plain text
                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    if let text = await loadText(from: provider) {
                        // Don't overwrite URL with its text representation
                        if result.url == nil || text != result.url {
                            result.text = text
                        }
                    }
                }
            }
        }

        return result
    }

    // MARK: - Private

    private static func loadURL(from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, error in
                if let url = item as? URL {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private static func loadText(from provider: NSItemProvider) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
                if let text = item as? String {
                    continuation.resume(returning: text)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
