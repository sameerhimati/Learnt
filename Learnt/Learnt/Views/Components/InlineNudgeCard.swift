//
//  InlineNudgeCard.swift
//  Learnt
//

import SwiftUI

/// A subtle inline card that teaches the user something at the moment of relevance.
/// Used for milestone-based progressive coaching (not a dark overlay coach mark).
struct InlineNudgeCard: View {
    let title: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Text(message)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 16) {
        InlineNudgeCard(
            title: "Reflect to remember",
            message: "Tap \"Reflect on this\" below your learning to deepen your understanding.",
            onDismiss: {}
        )

        InlineNudgeCard(
            title: "Review started",
            message: "This learning will come back for review tomorrow. Check the Review tab when it's ready.",
            onDismiss: {}
        )
    }
    .padding()
    .background(Color.appBackgroundColor)
}
