//
//  EntryStore.swift
//  Learnt
//

import Foundation
import SwiftData

@Observable
final class EntryStore {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func entries(for date: Date) -> [LearningEntry] {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        let predicate = #Predicate<LearningEntry> { entry in
            entry.date >= startOfDay && entry.date <= endOfDay
        }
        let descriptor = FetchDescriptor<LearningEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }

    func hasEntries(for date: Date) -> Bool {
        !entries(for: date).isEmpty
    }

    func datesWithEntries(in range: ClosedRange<Date>) -> Set<Date> {
        let predicate = #Predicate<LearningEntry> { entry in
            entry.date >= range.lowerBound && entry.date <= range.upperBound
        }
        let descriptor = FetchDescriptor<LearningEntry>(predicate: predicate)

        do {
            let entries = try modelContext.fetch(descriptor)
            return Set(entries.map { $0.date.startOfDay })
        } catch {
            print("Failed to fetch dates: \(error)")
            return []
        }
    }

    func datesWithEntries(forWeekOf date: Date) -> Set<Date> {
        let start = date.startOfWeek
        let end = date.endOfWeek
        return datesWithEntries(in: start...end)
    }

    func datesWithEntries(forMonthOf date: Date) -> Set<Date> {
        let start = date.startOfMonth
        let end = date.endOfMonth
        return datesWithEntries(in: start...end)
    }

    // MARK: - Create

    func createEntry(content: String, for date: Date, isVoiceEntry: Bool = false, audioData: Data? = nil) {
        let existingEntries = entries(for: date)
        let sortOrder = existingEntries.count

        let entry = LearningEntry(
            content: content,
            date: date,
            isVoiceEntry: isVoiceEntry,
            sortOrder: sortOrder,
            audioData: audioData
        )
        modelContext.insert(entry)
        save()
    }

    // MARK: - Update

    func updateEntry(_ entry: LearningEntry, content: String) {
        entry.content = content
        entry.updatedAt = Date()
        save()
    }

    // MARK: - Delete

    func deleteEntry(_ entry: LearningEntry) {
        modelContext.delete(entry)
        save()
    }

    // MARK: - Helpers

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
