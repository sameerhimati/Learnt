//
//  CustomTabBar.swift
//  Learnt
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            // Insights tab
            TabBarItem(
                icon: "sparkles",
                label: "Insights",
                isSelected: selectedTab == 0,
                isCenter: false
            ) {
                selectedTab = 0
            }

            // Today tab (center, larger)
            TabBarItem(
                icon: "waveform",
                label: "Today",
                isSelected: selectedTab == 1,
                isCenter: true
            ) {
                selectedTab = 1
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
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color.appBackgroundColor
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
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
            VStack(spacing: 4) {
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
