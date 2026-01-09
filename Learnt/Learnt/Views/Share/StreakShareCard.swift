//
//  StreakShareCard.swift
//  Learnt
//

import SwiftUI

/// Shareable card for streak milestones
struct StreakShareCard: View {
    let streakDays: Int
    let totalLearnings: Int

    private var streakService: StreakService { StreakService.shared }

    var body: some View {
        ShareableCardView {
            VStack(spacing: 40) {
                // Milestone icon
                Image(systemName: streakService.milestoneIcon(for: streakDays))
                    .font(.system(size: 48))
                    .foregroundStyle(Color.primaryTextColor)

                // Streak number
                VStack(spacing: 8) {
                    Text("\(streakDays)")
                        .font(.system(size: 72, weight: .light, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)

                    Text("day streak")
                        .font(.system(size: 18, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .textCase(.uppercase)
                        .tracking(2)
                }

                // Celebration message
                Text(streakService.celebrationMessage(for: streakDays))
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .multilineTextAlignment(.center)

                // Stats row
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("\(totalLearnings)")
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                        Text("learnings")
                            .font(.system(size: 12, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("7 Day Streak") {
    StreakShareCard(streakDays: 7, totalLearnings: 21)
        .frame(width: 375, height: 667)
}

#Preview("30 Day Streak") {
    StreakShareCard(streakDays: 30, totalLearnings: 89)
        .frame(width: 375, height: 667)
}

#Preview("365 Day Streak") {
    StreakShareCard(streakDays: 365, totalLearnings: 1200)
        .frame(width: 375, height: 667)
}
