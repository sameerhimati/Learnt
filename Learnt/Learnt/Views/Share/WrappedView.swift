//
//  WrappedView.swift
//  Learnt
//

import SwiftUI

/// Data model for wrapped summary
struct WrappedData {
    let period: String // e.g., "January 2025" or "2024"
    let totalLearnings: Int
    let totalDays: Int
    let topCategories: [(name: String, icon: String, count: Int)]
    let mostActiveDay: String
    let currentStreak: Int
    let longestStreak: Int
}

/// Spotify Wrapped-style monthly/yearly summary view
struct WrappedView: View {
    @Environment(\.dismiss) private var dismiss
    let data: WrappedData
    let onShare: (Int) -> Void // Pass the card index to share

    @State private var currentPage = 0

    private let totalPages = 5

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentPage ? Color.primaryTextColor : Color.dividerColor)
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Page content
                TabView(selection: $currentPage) {
                    introCard.tag(0)
                    learningsCard.tag(1)
                    categoriesCard.tag(2)
                    streakCard.tag(3)
                    summaryCard.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom controls
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: { onShare(currentPage) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                            Text("Share")
                                .font(.system(.body, design: .serif))
                        }
                        .foregroundStyle(Color.primaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Cards

    private var introCard: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Your")
                .font(.system(size: 20, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Text(data.period)
                .font(.system(size: 36, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Text("in learnings")
                .font(.system(size: 20, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Spacer()

            Text("Tap to continue")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var learningsCard: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("You captured")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Text("\(data.totalLearnings)")
                .font(.system(size: 80, weight: .light, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Text("learnings")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Text("across \(data.totalDays) days")
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    private var categoriesCard: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Your top categories")
                .font(.system(size: 18, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            VStack(spacing: 20) {
                ForEach(Array(data.topCategories.prefix(3).enumerated()), id: \.offset) { index, category in
                    HStack(spacing: 16) {
                        Text("\(index + 1)")
                            .font(.system(size: 24, weight: .light, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .frame(width: 30)

                        Image(systemName: category.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(Color.primaryTextColor)

                        Text(category.name)
                            .font(.system(size: 20, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)

                        Spacer()

                        Text("\(category.count)")
                            .font(.system(size: 16, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }

    private var streakCard: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "flame")
                .font(.system(size: 40))
                .foregroundStyle(Color.primaryTextColor)

            VStack(spacing: 8) {
                Text("\(data.longestStreak)")
                    .font(.system(size: 64, weight: .light, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("day longest streak")
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            if data.currentStreak > 0 {
                Text("Currently at \(data.currentStreak) days")
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    .padding(.top, 16)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var summaryCard: some View {
        VStack(spacing: 40) {
            Spacer()

            Text(data.period)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .textCase(.uppercase)
                .tracking(2)

            VStack(spacing: 24) {
                summaryRow(value: "\(data.totalLearnings)", label: "Learnings")
                summaryRow(value: "\(data.totalDays)", label: "Active Days")
                summaryRow(value: "\(data.longestStreak)", label: "Longest Streak")
            }

            Spacer()

            Text("Keep learning, keep growing")
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .italic()
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    private func summaryRow(value: String, label: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
            Spacer()
            Text(value)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
        }
    }
}

// MARK: - Preview

#Preview {
    WrappedView(
        data: WrappedData(
            period: "January 2025",
            totalLearnings: 47,
            totalDays: 23,
            topCategories: [
                (name: "Learning", icon: "book", count: 18),
                (name: "Work", icon: "briefcase", count: 15),
                (name: "Personal", icon: "person", count: 14)
            ],
            mostActiveDay: "Monday",
            currentStreak: 12,
            longestStreak: 14
        ),
        onShare: { _ in }
    )
}
