//
//  LearntApp.swift
//  Learnt
//
//  Created by Sameer Himati on 1/4/26.
//

import SwiftUI
import SwiftData

@main
struct LearntApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LearningEntry.self,
            Category.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // Populate mock data for testing
                    let context = sharedModelContainer.mainContext
                    MockDataService.populateMockData(modelContext: context)

                    // Ensure category presets exist
                    let categoryService = CategoryService(modelContext: context)
                    categoryService.ensurePresetsExist()

                    // Initialize notification service
                    Task {
                        await NotificationService.shared.updateAuthorizationStatus()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
