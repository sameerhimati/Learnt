//
//  AIService.swift
//  Learnt
//
//  On-device AI using Apple Foundation Models framework
//  Requires iOS 26+ and A17 Pro / M1 or newer
//

import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - AI Service

@Observable
final class AIService {
    static let shared = AIService()

    /// Check if Foundation Models is available on this device
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability {
                return true
            }
        }
        #endif
        return false
    }

    private init() {}

    // MARK: - Category Suggestions

    func suggestCategories(for content: String, availableCategories: [String]) async -> [String] {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await suggestCategoriesWithAI(for: content, availableCategories: availableCategories)
        }
        #endif
        return []
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func suggestCategoriesWithAI(for content: String, availableCategories: [String]) async -> [String] {
        guard case .available = SystemLanguageModel.default.availability else { return [] }

        let categoryList = availableCategories.joined(separator: ", ")
        let prompt = """
        Analyze this learning entry and suggest the 1-2 most relevant categories.
        Available categories: \(categoryList)

        Learning entry: "\(content)"

        Return only the category names, comma-separated.
        """

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            // Parse response and match to available categories
            let suggested = response.content
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { availableCategories.contains($0) }
            return Array(suggested.prefix(2))
        } catch {
            print("AI category suggestion failed: \(error)")
            return []
        }
    }
    #endif
}

// MARK: - Preview/Mock Support

#if DEBUG
extension AIService {
    static func mockCategorySuggestions(for content: String) -> [String] {
        let lowercased = content.lowercased()
        var suggestions: [String] = []

        if lowercased.contains("work") || lowercased.contains("meeting") ||
           lowercased.contains("project") || lowercased.contains("team") {
            suggestions.append("Work")
        }

        if lowercased.contains("learn") || lowercased.contains("read") ||
           lowercased.contains("study") || lowercased.contains("course") {
            suggestions.append("Learning")
        }

        if lowercased.contains("friend") || lowercased.contains("family") ||
           lowercased.contains("relationship") || lowercased.contains("talk") {
            suggestions.append("Relationships")
        }

        if suggestions.isEmpty || lowercased.contains("life") ||
           lowercased.contains("personal") || lowercased.contains("self") {
            suggestions.append("Personal")
        }

        return Array(suggestions.prefix(2))
    }

}
#endif
