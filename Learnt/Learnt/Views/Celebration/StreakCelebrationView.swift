//
//  StreakCelebrationView.swift
//  Learnt
//

import SwiftUI

/// Modal view for celebrating streak milestones
struct StreakCelebrationView: View {
    let milestone: Int
    let totalLearnings: Int
    let onDismiss: () -> Void
    let onShare: () -> Void

    private var streakService: StreakService { StreakService.shared }

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Celebration card
            VStack(spacing: 32) {
                // Icon
                Image(systemName: streakService.milestoneIcon(for: milestone))
                    .font(.system(size: 40))
                    .foregroundStyle(Color.primaryTextColor)

                // Streak info
                VStack(spacing: 8) {
                    Text("\(milestone)")
                        .font(.system(size: 56, weight: .light, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)

                    Text("day streak!")
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .textCase(.uppercase)
                        .tracking(1.5)
                }

                // Message
                Text(streakService.celebrationMessage(for: milestone))
                    .font(.system(size: 18, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onShare) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Achievement")
                        }
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.appBackgroundColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button(action: onDismiss) {
                        Text("Continue")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(32)
            .background(Color.appBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    StreakCelebrationView(
        milestone: 7,
        totalLearnings: 21,
        onDismiss: {},
        onShare: {}
    )
}

#Preview("30 Days") {
    StreakCelebrationView(
        milestone: 30,
        totalLearnings: 89,
        onDismiss: {},
        onShare: {}
    )
}
