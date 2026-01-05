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
