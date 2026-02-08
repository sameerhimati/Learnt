//
//  MainTabView.swift
//  Learnt

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 1  // Start on Today (center)

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    ReviewView()
                case 1:
                    TodayView()
                case 2:
                    ProfileView()
                default:
                    TodayView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
