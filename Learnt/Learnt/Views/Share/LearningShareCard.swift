//
//  LearningShareCard.swift
//  Learnt
//

import SwiftUI

/// Shareable card for a single learning entry
struct LearningShareCard: View {
    let content: String
    let date: Date
    let categories: [Category]

    var body: some View {
        ShareableCardView {
            VStack(spacing: 32) {
                // Date
                Text(date.formattedFull)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .textCase(.uppercase)
                    .tracking(1.5)

                // Learning content
                Text(content)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                // Categories
                if !categories.isEmpty {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.id) { category in
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                Text(category.name)
                                    .font(.system(size: 12, design: .serif))
                            }
                            .foregroundStyle(Color.secondaryTextColor)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Convenience initializer from LearningEntry

extension LearningShareCard {
    init(entry: LearningEntry) {
        self.content = entry.content
        self.date = entry.date
        self.categories = entry.categories
    }
}

// MARK: - Preview

#Preview("Learning Card") {
    LearningShareCard(
        content: "The best way to learn something is to teach it to someone else.",
        date: Date(),
        categories: []
    )
    .frame(width: 375, height: 500)
}

#Preview("Long Content") {
    LearningShareCard(
        content: "I learned that consistency beats intensity. Small daily efforts compound over time into remarkable results. The key is showing up every single day, even when you don't feel like it.",
        date: Date(),
        categories: []
    )
    .frame(width: 375, height: 600)
}
