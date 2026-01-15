//
//  EmptyStateView.swift
//  Learnt
//

import SwiftUI

struct EmptyStateView: View {
    let isToday: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(isToday ? "What did you learn today?" : "Nothing recorded")
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)

            if isToday {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color.primaryTextColor)
                        .frame(width: 64, height: 64)
                        .background(Color.inputBackgroundColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .coachMark(
                    .addLearning,
                    title: "Add a Learning",
                    message: "Tap here to capture something you learned today. Use voice or text.",
                    arrowDirection: .up
                )
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack {
        EmptyStateView(isToday: true, onAdd: {})
            .frame(height: 300)

        Divider()

        EmptyStateView(isToday: false, onAdd: {})
            .frame(height: 200)
    }
    .background(Color.appBackgroundColor)
}
