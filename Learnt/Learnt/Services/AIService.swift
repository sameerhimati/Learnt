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

    // MARK: - Reflection Prompts

    func generateReflectionPrompts(for content: String) async -> ReflectionPromptsResult? {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generateReflectionPromptsWithAI(for: content)
        }
        #endif
        return nil
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateReflectionPromptsWithAI(for content: String) async -> ReflectionPromptsResult? {
        guard case .available = SystemLanguageModel.default.availability else { return nil }

        let prompt = """
        Generate 4 personalized reflection prompts for this learning entry.
        Keep each prompt concise (under 15 words).

        Learning: "\(content)"

        Format as:
        Application: [prompt about applying this]
        Surprise: [prompt about what was unexpected]
        Simplify: [prompt about explaining simply]
        Question: [prompt about exploring further]
        """

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return parseReflectionPrompts(from: response.content)
        } catch {
            print("AI reflection prompts failed: \(error)")
            return nil
        }
    }

    @available(iOS 26.0, *)
    private func parseReflectionPrompts(from text: String) -> ReflectionPromptsResult {
        var application = "How might you use this insight tomorrow?"
        var surprise = "What aspect of this challenged your assumptions?"
        var simplify = "How would you explain this to a friend?"
        var question = "What would you like to explore further?"

        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.lowercased().hasPrefix("application:") {
                application = String(line.dropFirst(12)).trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().hasPrefix("surprise:") {
                surprise = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().hasPrefix("simplify:") {
                simplify = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().hasPrefix("question:") {
                question = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            }
        }

        return ReflectionPromptsResult(
            applicationPrompt: application,
            surprisePrompt: surprise,
            simplificationPrompt: simplify,
            questionPrompt: question
        )
    }
    #endif

    // MARK: - Monthly Summary

    func generateMonthlySummary(
        entries: [Any],
        period: String
    ) async -> MonthlySummaryResult? {
        guard !entries.isEmpty else { return nil }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generateMonthlySummaryWithAI(entries: entries, period: period)
        }
        #endif
        return nil
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateMonthlySummaryWithAI(entries: [Any], period: String) async -> MonthlySummaryResult? {
        guard case .available = SystemLanguageModel.default.availability else { return nil }

        let entriesText = entries.prefix(50).compactMap { entry -> String? in
            let mirror = Mirror(reflecting: entry)
            for child in mirror.children {
                if child.label == "content", let content = child.value as? String {
                    return "- \(content)"
                }
            }
            return nil
        }.joined(separator: "\n")

        guard !entriesText.isEmpty else { return nil }

        let prompt = """
        Analyze these \(entries.count) learning entries from \(period).

        Entries:
        \(entriesText)

        Generate:
        1. A brief 2-sentence summary of the main themes
        2. One standout insight or pattern you noticed

        Format as:
        Summary: [your summary]
        Insight: [your insight]
        """

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return parseMonthlySummary(from: response.content)
        } catch {
            print("AI monthly summary failed: \(error)")
            return nil
        }
    }

    @available(iOS 26.0, *)
    private func parseMonthlySummary(from text: String) -> MonthlySummaryResult {
        var summary = "You captured meaningful learnings this month."
        var insight = "Keep reflecting on what matters most to you."

        let lines = text.components(separatedBy: "\n")
        for line in lines {
            if line.lowercased().hasPrefix("summary:") {
                summary = String(line.dropFirst(8)).trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().hasPrefix("insight:") {
                insight = String(line.dropFirst(8)).trimmingCharacters(in: .whitespaces)
            }
        }

        return MonthlySummaryResult(summary: summary, standoutInsight: insight)
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

    static func mockReflectionPrompts(for content: String) -> ReflectionPromptsResult {
        ReflectionPromptsResult(
            applicationPrompt: "How might you use this insight tomorrow?",
            surprisePrompt: "What aspect of this challenged your assumptions?",
            simplificationPrompt: "How would you explain this to a friend?",
            questionPrompt: "What would you like to explore further?"
        )
    }

    static func mockMonthlySummary(count: Int, period: String) -> MonthlySummaryResult {
        MonthlySummaryResult(
            summary: "This month you focused on personal growth and professional development. Your entries show a pattern of thoughtful reflection and continuous learning.",
            standoutInsight: "Your most impactful learning was about the importance of consistency over intensity."
        )
    }
}
#endif
