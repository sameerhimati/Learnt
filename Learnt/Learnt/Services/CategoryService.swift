//
//  CategoryService.swift
//  Learnt
//

import Foundation
import SwiftData

@Observable
final class CategoryService {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func allCategories() -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    func presetCategories() -> [Category] {
        allCategories().filter { $0.isPreset }
    }

    func customCategories() -> [Category] {
        allCategories().filter { !$0.isPreset }
    }

    // MARK: - Create

    func createCategory(name: String, icon: String) {
        let existing = allCategories()
        let sortOrder = existing.count

        let category = Category(
            name: name,
            icon: icon,
            sortOrder: sortOrder,
            isPreset: false
        )
        modelContext.insert(category)
        save()
    }

    func ensurePresetsExist() {
        let existing = presetCategories()
        if existing.isEmpty {
            for (index, preset) in Category.presets.enumerated() {
                let category = Category(
                    name: preset.name,
                    icon: preset.icon,
                    sortOrder: index,
                    isPreset: true
                )
                modelContext.insert(category)
            }
            save()
        }

        // Sync categories to App Group for share extension
        syncCategoriesToAppGroup()
    }

    // MARK: - Delete

    func deleteCategory(_ category: Category) {
        // Only allow deleting custom categories
        guard !category.isPreset else { return }
        modelContext.delete(category)
        save()
    }

    // MARK: - App Group Sync

    /// Sync categories to App Group so share extension can access them
    func syncCategoriesToAppGroup() {
        let categories = allCategories()
        let sharedCategories = categories.map { category in
            SharedDataService.SharedCategory(
                id: category.id,
                name: category.name,
                icon: category.icon
            )
        }
        SharedDataService.shared.syncCategories(sharedCategories)
    }

    // MARK: - Helpers

    private func save() {
        do {
            try modelContext.save()
            // Sync to App Group after any save
            syncCategoriesToAppGroup()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
