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
    @Environment(\.scenePhase) private var scenePhase
    @State private var appearanceMode = SettingsService.shared.appearanceMode
    @State private var showSplash = true
    @State private var hasSeenOnboarding = SettingsService.shared.hasSeenOnboarding

    // App-level pending share handling - auto-imports without prompting
    @State private var importedShareCount = 0
    @State private var showImportToast = false

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
                        .withCoachMarks()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(colorScheme)
            .onAppear {
                // Initialize data
                let context = sharedModelContainer.mainContext
                // MockDataService.populateMockData(modelContext: context)  // Disabled for testing

                let categoryService = CategoryService(modelContext: context)
                categoryService.ensurePresetsExist()

                Task {
                    await NotificationService.shared.updateAuthorizationStatus()
                }

                // Dismiss splash after animation completes (~1.7 seconds)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                appearanceMode = SettingsService.shared.appearanceMode
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    importPendingShares()
                }
            }
            .overlay(alignment: .top) {
                if showImportToast {
                    importToast
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showImportToast = false }
                            }
                        }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Pending Share Handling

    /// Auto-import all pending shares without prompting user
    private func importPendingShares() {
        let shares = SharedDataService.shared.consumeAllPendingShares()
        guard !shares.isEmpty else { return }

        let context = sharedModelContainer.mainContext

        // Fetch all categories to match IDs
        let fetchDescriptor = FetchDescriptor<Category>()
        let allCategories = (try? context.fetch(fetchDescriptor)) ?? []

        for share in shares {
            // Match category IDs to actual categories
            let matchedCategories = allCategories.filter { share.categoryIds.contains($0.id) }

            // Create learning entry
            let entry = LearningEntry(content: share.text, date: share.timestamp)
            entry.categories = matchedCategories

            context.insert(entry)
        }

        try? context.save()

        // Show toast
        importedShareCount = shares.count
        withAnimation {
            showImportToast = true
        }
    }

    /// Toast shown after importing shares
    private var importToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(importedShareCount == 1 ? "Learning saved" : "\(importedShareCount) learnings saved")
                .font(.system(.subheadline, design: .serif))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.top, 60)
    }
}
