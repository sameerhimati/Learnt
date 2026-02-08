//
//  EmptyStateView.swift
//  Learnt
//

import SwiftUI

struct EmptyStateView: View {
    let isToday: Bool
    var date: Date = Date()
    var totalEntryCount: Int = 0
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            if isToday {
                todayContent
            } else {
                pastDateContent
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Today Variants

    @ViewBuilder
    private var todayContent: some View {
        if totalEntryCount == 0 {
            // First time ever — educate with examples
            Text("What did you learn today?")
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)

            Text("A conversation. A podcast. A mistake.\nAnything worth remembering.")
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        } else {
            // Returning user, nothing today
            Text("Nothing captured today yet.")
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Past Date

    private var pastDateContent: some View {
        VStack(spacing: 16) {
            Text("No learnings on \(date.formattedShort).")
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)

            Button(action: onAdd) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                    Text("Remember something?")
                        .font(.system(.subheadline, design: .serif))
                }
                .foregroundStyle(Color.primaryTextColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.inputBackgroundColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    VStack {
        EmptyStateView(isToday: true, totalEntryCount: 0, onAdd: {})
            .frame(height: 300)

        Divider()

        EmptyStateView(isToday: true, totalEntryCount: 5, onAdd: {})
            .frame(height: 200)

        Divider()

        EmptyStateView(isToday: false, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, onAdd: {})
            .frame(height: 200)
    }
    .background(Color.appBackgroundColor)
}
