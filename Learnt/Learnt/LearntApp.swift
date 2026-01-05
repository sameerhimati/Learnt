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
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
