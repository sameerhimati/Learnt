//
//  MainTabView.swift
//  Learnt

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1  // Start on Today (center)
    @State private var tabBarActions = TabBarActions()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    InsightsView()
                case 1:
                    TodayView(tabBarActions: tabBarActions)
                case 2:
                    ProfileView()
                default:
                    TodayView(tabBarActions: tabBarActions)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, tabBarActions: tabBarActions)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
