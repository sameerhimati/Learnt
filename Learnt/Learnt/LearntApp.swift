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
    @State private var appearanceMode = SettingsService.shared.appearanceMode
    @State private var showSplash = true
    @State private var hasSeenOnboarding = SettingsService.shared.hasSeenOnboarding

    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

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
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else if !hasSeenOnboarding {
                    OnboardingView {
                        SettingsService.shared.hasSeenOnboarding = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hasSeenOnboarding = true
                        }
                    }
                    .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(colorScheme)
            .onAppear {
                // Initialize data
                let context = sharedModelContainer.mainContext
                MockDataService.populateMockData(modelContext: context)

                let categoryService = CategoryService(modelContext: context)
                categoryService.ensurePresetsExist()

                Task {
                    await NotificationService.shared.updateAuthorizationStatus()
                }

                // Dismiss splash after animation completes (~3 seconds)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSplash = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                appearanceMode = SettingsService.shared.appearanceMode
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
