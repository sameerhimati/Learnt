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

    /// User-facing message explaining AI availability
    var availabilityMessage: String {
        if isAvailable {
            return "AI insights powered by on-device Apple Intelligence"
        } else {
            return "AI insights require iOS 26+ with Apple Intelligence"
        }
    }

    /// Generate a fallback summary when AI is unavailable
    func fallbackSummary(count: Int, period: String) -> MonthlySummaryResult {
        // Provide a simple, encouraging fallback
        let message: String
        if count == 1 {
            message = "You captured 1 learning in \(period). Keep reflecting on what matters to you."
        } else if count < 5 {
            message = "You captured \(count) learnings in \(period). Each reflection builds understanding."
        } else if count < 15 {
            message = "You captured \(count) learnings in \(period). Your consistent reflection is building a valuable record."
        } else {
            message = "You captured \(count) learnings in \(period). Your dedication to reflection is remarkable."
        }
        return MonthlySummaryResult(summary: message, standoutInsight: "")
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

    // MARK: - Monthly Summary

    func generateMonthlySummary(
        entries: [Any],
        period: String,
        topCategories: [(name: String, count: Int)] = []
    ) async -> MonthlySummaryResult? {
        guard !entries.isEmpty else { return nil }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return await generateMonthlySummaryWithAI(entries: entries, period: period, topCategories: topCategories)
        }
        #endif
        return nil
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateMonthlySummaryWithAI(
        entries: [Any],
        period: String,
        topCategories: [(name: String, count: Int)]
    ) async -> MonthlySummaryResult? {
        guard case .available = SystemLanguageModel.default.availability else { return nil }

        let entriesText = entries.prefix(50).compactMap { entry -> String? in
            let mirror = Mirror(reflecting: entry)
            var content: String?
            var transcription: String?

            for child in mirror.children {
                if child.label == "content", let value = child.value as? String {
                    content = value.trimmingCharacters(in: .whitespacesAndNewlines)
                } else if child.label == "transcription", let value = child.value as? String? {
                    transcription = value?.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }

            // Use content if available, otherwise use existing transcription for voice entries
            if let text = content, !text.isEmpty {
                return "- \(text)"
            } else if let text = transcription, !text.isEmpty {
                return "- \(text)"
            }
            return nil
        }.joined(separator: "\n")

        guard !entriesText.isEmpty else { return nil }

        // Build category context
        let categoryContext = topCategories.isEmpty ? "" : """

        Top categories this month: \(topCategories.map { "\($0.name) (\($0.count))" }.joined(separator: ", "))
        """

        // Vary the prompt slightly based on entry count
        let focusInstruction: String
        if entries.count < 10 {
            focusInstruction = "Focus on the quality and depth of reflection shown."
        } else if entries.count < 25 {
            focusInstruction = "Highlight any evolution or growth in thinking over the month."
        } else {
            focusInstruction = "Identify the strongest recurring themes and any surprising connections."
        }

        let prompt = """
        You are analyzing \(entries.count) personal learning entries from \(period).
        \(categoryContext)

        Entries:
        \(entriesText)

        \(focusInstruction)

        Write a personalized 2-3 sentence reflection that:
        - Speaks directly to the person (use "you")
        - Highlights specific themes or topics from their actual entries
        - Avoids generic phrases like "personal growth" or "continuous learning"
        - Feels like insight from a thoughtful friend, not a template

        Return ONLY the reflection text, nothing else.
        """

        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            let summary = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return MonthlySummaryResult(summary: summary, standoutInsight: "")
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

    static func mockMonthlySummary(count: Int, period: String, topCategories: [(name: String, count: Int)] = []) -> MonthlySummaryResult {
        // Vary mock responses based on count and categories
        let summaries = [
            "You've been exploring how small daily habits compound into meaningful change. Your reflections show a curiosity about the intersection of productivity and well-being.",
            "This month you've been drawn to understanding systems and processes. Your entries reveal a mind that enjoys breaking down complexity into actionable pieces.",
            "Your learnings this month circle around communication and connection. You seem particularly interested in how we build understanding with others.",
            "You've spent this month questioning assumptions and testing new approaches. There's a thread of experimentation running through your reflections.",
            "Your entries reveal a focus on clarity—both in thinking and in action. You've been working through how to simplify without losing what matters."
        ]

        // Use count to pick different mock response
        let index = count % summaries.count
        return MonthlySummaryResult(
            summary: summaries[index],
            standoutInsight: ""
        )
    }
}
#endif
