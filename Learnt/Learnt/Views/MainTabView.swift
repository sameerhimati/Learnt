//
//  MainTabView.swift
//  Learnt
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1  // Start on Today (center)

    var body: some View {
        TabView(selection: $selectedTab) {
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("You", systemImage: "person")
                }
                .tag(2)
        }
        .tint(Color.primaryTextColor)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
