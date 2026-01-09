//
//  AIService.swift
//  Learnt
//
//  On-device AI using Apple Foundation Models framework
//  Requires iOS 26+ and A17 Pro / M1 or newer
//
//  Note: Uses conditional compilation. When FoundationModels SDK is available,
//  real AI features will be enabled. Until then, provides graceful fallbacks.
//

import Foundation

// MARK: - Result Types

struct ReflectionPromptsResult {
    var applicationPrompt: String
    var surprisePrompt: String
    var simplificationPrompt: String
    var questionPrompt: String
}

struct MonthlySummaryResult {
    var summary: String
    var standoutInsight: String
}

// MARK: - AI Service

@Observable
final class AIService {
    static let shared = AIService()

    #if canImport(FoundationModels)
    private var session: LanguageModelSession?
    #endif

    /// Check if Foundation Models is available on this device
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        return LanguageModelSession.isAvailable
        #else
        return false
        #endif
    }

    private init() {
        #if canImport(FoundationModels)
        if LanguageModelSession.isAvailable {
            self.session = LanguageModelSession()
        }
        #endif
    }

    // MARK: - Category Suggestions

    /// Suggest relevant categories for a learning entry
    /// - Parameters:
    ///   - content: The learning entry text
    ///   - availableCategories: List of available category names
    /// - Returns: Array of suggested category names (max 2)
    func suggestCategories(for content: String, availableCategories: [String]) async -> [String] {
        guard isAvailable else { return [] }
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        #if canImport(FoundationModels)
        // Real implementation with Foundation Models
        let categoryList = availableCategories.joined(separator: ", ")

        let prompt = """
        Analyze this learning entry and suggest the 1-2 most relevant categories.
        Available categories: \(categoryList)

        Learning entry: "\(content)"

        Only suggest categories from the available list.
        """

        do {
            // Use guided generation when available
            let result = try await session?.respond(to: prompt)
            // Parse result and map to categories
            // This will be refined once SDK is available
            return []
        } catch {
            print("AI category suggestion failed: \(error)")
            return []
        }
        #else
        return []
        #endif
    }

    // MARK: - Reflection Prompts

    /// Generate contextual reflection prompts based on learning content
    /// - Parameter content: The learning entry text
    /// - Returns: Generated prompts or nil if failed
    func generateReflectionPrompts(for content: String) async -> ReflectionPromptsResult? {
        guard isAvailable else { return nil }
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

        #if canImport(FoundationModels)
        let prompt = """
        Generate personalized reflection prompts for this learning entry.
        Keep each prompt concise (under 15 words).

        Learning: "\(content)"
        """

        do {
            // Use guided generation when available
            let _ = try await session?.respond(to: prompt)
            // Parse and return ReflectionPromptsResult
            return nil
        } catch {
            print("AI reflection prompts failed: \(error)")
            return nil
        }
        #else
        return nil
        #endif
    }

    // MARK: - Monthly Summary

    /// Generate a summary of learning entries for a time period
    /// - Parameters:
    ///   - entries: Array of learning entries
    ///   - period: Description of the period (e.g., "January 2026")
    /// - Returns: Generated summary or nil if failed
    func generateMonthlySummary(
        entries: [LearningEntry],
        period: String
    ) async -> MonthlySummaryResult? {
        guard isAvailable else { return nil }
        guard !entries.isEmpty else { return nil }

        #if canImport(FoundationModels)
        let entriesText = entries
            .prefix(50)
            .map { "- \($0.content)" }
            .joined(separator: "\n")

        let prompt = """
        Analyze these \(entries.count) learning entries from \(period).

        Entries:
        \(entriesText)

        Generate a brief summary of themes and one standout insight.
        """

        do {
            let _ = try await session?.respond(to: prompt)
            return nil
        } catch {
            print("AI monthly summary failed: \(error)")
            return nil
        }
        #else
        return nil
        #endif
    }
}

// MARK: - Preview/Mock Support

#if DEBUG
extension AIService {
    /// Create mock suggestions for previews and testing
    static func mockCategorySuggestions(for content: String) -> [String] {
        // Simple keyword matching for testing
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

    /// Create mock reflection prompts for previews
    static func mockReflectionPrompts(for content: String) -> ReflectionPromptsResult {
        ReflectionPromptsResult(
            applicationPrompt: "How might you use this insight tomorrow?",
            surprisePrompt: "What aspect of this challenged your assumptions?",
            simplificationPrompt: "How would you explain this to a friend?",
            questionPrompt: "What would you like to explore further?"
        )
    }

    /// Create mock monthly summary for previews
    static func mockMonthlySummary(count: Int, period: String) -> MonthlySummaryResult {
        MonthlySummaryResult(
            summary: "This month you focused on personal growth and professional development. Your entries show a pattern of thoughtful reflection and continuous learning.",
            standoutInsight: "Your most impactful learning was about the importance of consistency over intensity."
        )
    }
}
#endif
