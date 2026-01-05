//
//  CustomTabBar.swift
//  Learnt

import SwiftUI

// MARK: - Tab Bar Action Handler

@Observable
class TabBarActions {
    var todayTabTapCount = 0
    var isViewingToday = true  // Whether TodayView is showing today's date
    var isChooserShowing = false  // Whether input chooser is visible

    func todayTabTapped() {
        todayTabTapCount += 1
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var tabBarActions: TabBarActions?

    var body: some View {
        HStack(spacing: 0) {
            // Insights tab
            TabBarItem(
                icon: "books.vertical.fill",
                label: "Insights",
                isSelected: selectedTab == 0,
                isCenter: false
            ) {
                selectedTab = 0
            }

            // Today tab (center, larger)
            // Icon changes to + when on Today tab AND viewing today's date
            // Rotates to X when chooser is showing
            TodayTabItem(
                isSelected: selectedTab == 1,
                isViewingToday: tabBarActions?.isViewingToday == true,
                isChooserShowing: tabBarActions?.isChooserShowing == true
            ) {
                if selectedTab == 1 {
                    // Already on Today tab - trigger action
                    tabBarActions?.todayTabTapped()
                } else {
                    selectedTab = 1
                }
            }

            // You tab
            TabBarItem(
                icon: "person",
                label: "You",
                isSelected: selectedTab == 2,
                isCenter: false
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Color.appBackgroundColor
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Item

private struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let isCenter: Bool
    let action: () -> Void

    private var iconSize: CGFloat {
        isCenter ? 38 : 22
    }

    private var fontWeight: Font.Weight {
        isSelected ? .medium : .regular
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: fontWeight))
                    .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)

                Text(label)
                    .font(.system(size: 10, weight: fontWeight, design: .serif))
                    .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Today Tab Item (with rotation animation)

private struct TodayTabItem: View {
    let isSelected: Bool
    let isViewingToday: Bool
    let isChooserShowing: Bool
    let action: () -> Void

    private var showPlus: Bool {
        isSelected && isViewingToday
    }

    private var fontWeight: Font.Weight {
        isSelected ? .medium : .regular
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: showPlus ? "plus" : "scribble.variable")
                    .font(.system(size: 32, weight: fontWeight))
                    .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)
                    .rotationEffect(.degrees(isChooserShowing ? 45 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isChooserShowing)

                Text("Today")
                    .font(.system(size: 10, weight: fontWeight, design: .serif))
                    .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(1))
    }
    .background(Color.appBackgroundColor)
}
