//
//  CustomTabBar.swift
//  Learnt

import SwiftUI

// MARK: - Notification for jumping to today

extension Notification.Name {
    static let jumpToToday = Notification.Name("jumpToToday")
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            // Review tab
            TabBarItem(
                icon: "arrow.triangle.2.circlepath",
                label: "Review",
                isSelected: selectedTab == 0,
                isCenter: false
            ) {
                selectedTab = 0
            }

            // Today tab (center, larger)
            TabBarItem(
                icon: "scribble.variable",
                label: "Today",
                isSelected: selectedTab == 1,
                isCenter: true
            ) {
                if selectedTab == 1 {
                    // Already on Today tab - notify to jump to today's date
                    NotificationCenter.default.post(name: .jumpToToday, object: nil)
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
        isCenter ? 28 : 22
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

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(1))
    }
    .background(Color.appBackgroundColor)
}
