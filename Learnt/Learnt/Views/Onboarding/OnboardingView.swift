//
//  OnboardingView.swift
//  Learnt
//

import SwiftUI

/// Multi-step guided walkthrough that explains the entire core loop.
/// Skip button always visible in the corner for users who want to jump ahead.
struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let totalPages = 7

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            // Page content
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                capturePage.tag(1)
                reflectPage.tag(2)
                reviewPage.tag(3)
                graduatePage.tag(4)
                explorePage.tag(5)
                getStartedPage.tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Skip button — on top of TabView so it's tappable
            VStack {
                HStack {
                    Spacer()
                    Button(action: onComplete) {
                        Text("Skip")
                            .font(.system(size: 14, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                Spacer()
            }

            // Bottom: progress dots + button
            VStack {
                Spacer()

                VStack(spacing: 24) {
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.primaryTextColor : Color.secondaryTextColor.opacity(0.3))
                                .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }

                    // Action button
                    Button(action: {
                        if currentPage < totalPages - 1 {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            currentPage += 1
                        } else {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            onComplete()
                        }
                    }) {
                        Text(currentPage == totalPages - 1 ? "Start Learning" : "Continue")
                            .font(.system(.body, design: .serif, weight: .medium))
                            .foregroundStyle(Color.appBackgroundColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryTextColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        OnboardingPageView(
            icon: nil,
            title: "Learnt",
            titleSize: 48,
            message: "Capture what you learn,\none small thing at a time.",
            detail: nil
        )
    }

    // MARK: - Page 2: Capture

    private var capturePage: some View {
        OnboardingPageView(
            icon: "pencil.line",
            title: "Capture",
            message: "Jot down anything you learned today. A conversation insight. A podcast takeaway. A mistake you won't repeat.",
            detail: "Just type in the bar at the bottom and hit send. Quick and effortless."
        )
    }

    // MARK: - Page 3: Reflect

    private var reflectPage: some View {
        OnboardingPageView(
            icon: "text.bubble",
            title: "Reflect",
            message: "After capturing a learning, add a reflection. Connect it to what you already know.",
            detail: "Reflecting deepens understanding and activates spaced review — so you'll be reminded at the right time."
        )
    }

    // MARK: - Page 4: Review

    private var reviewPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.primaryTextColor)

                VStack(spacing: 12) {
                    Text("Review")
                        .font(.system(size: 32, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)

                    Text("Learnt uses spaced repetition — a proven technique for long-term memory. You'll review each learning at increasing intervals.")
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                // Visual timeline
                reviewTimeline
            }

            Spacer()
            Spacer()
                .frame(height: 120)
        }
    }

    private var reviewTimeline: some View {
        VStack(spacing: 0) {
            ForEach(Array(reviewIntervals.enumerated()), id: \.offset) { index, interval in
                HStack(spacing: 16) {
                    // Day label
                    Text(interval.label)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .frame(width: 70, alignment: .trailing)

                    // Dot on timeline
                    ZStack {
                        Circle()
                            .fill(Color.primaryTextColor)
                            .frame(width: 10, height: 10)
                    }

                    // Description
                    Text(interval.description)
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 8)

                // Connector line
                if index < reviewIntervals.count - 1 {
                    HStack(spacing: 16) {
                        Spacer()
                            .frame(width: 70)

                        Rectangle()
                            .fill(Color.secondaryTextColor.opacity(0.3))
                            .frame(width: 1, height: 16)

                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
    }

    private var reviewIntervals: [(label: String, description: String)] {
        [
            ("Day 1", "First review"),
            ("Day 7", "One week later"),
            ("Day 16", "Two weeks later"),
            ("Day 35", "One month later"),
        ]
    }

    // MARK: - Page 5: Graduate

    private var graduatePage: some View {
        OnboardingPageView(
            icon: "checkmark.seal",
            title: "Graduate",
            message: "After 4 successful reviews, a learning graduates. It's now part of your long-term memory.",
            detail: "Graduated learnings leave the review queue — you've proven you know them."
        )
    }

    // MARK: - Page 6: Explore

    private var explorePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Image(systemName: "rectangle.3.group")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.primaryTextColor)

                VStack(spacing: 12) {
                    Text("Your Tabs")
                        .font(.system(size: 32, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)

                    Text("Everything you need, organized simply.")
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                // Tab descriptions
                VStack(spacing: 16) {
                    tabRow(
                        icon: "rectangle.stack",
                        name: "Review",
                        description: "See what's due and start a review session"
                    )
                    tabRow(
                        icon: "pencil.line",
                        name: "Today",
                        description: "Capture and browse your daily learnings"
                    )
                    tabRow(
                        icon: "line.3.horizontal",
                        name: "More",
                        description: "Library, stats, settings, and more"
                    )
                }
                .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
                .frame(height: 120)
        }
    }

    private func tabRow(icon: String, name: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.primaryTextColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text(description)
                    .font(.system(size: 13, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Page 7: Get Started

    private var getStartedPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.primaryTextColor)

                Text("You're ready")
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Start by capturing one thing\nyou learned today.")
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
                .frame(height: 120)
        }
    }
}

// MARK: - Reusable Page Layout

private struct OnboardingPageView: View {
    let icon: String?
    let title: String
    var titleSize: CGFloat = 32
    let message: String
    let detail: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(Color.primaryTextColor)
                }

                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: titleSize, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)

                    Text(message)
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)

                    if let detail {
                        Text(detail)
                            .font(.system(size: 14, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 40)
                            .padding(.top, 4)
                    }
                }
            }

            Spacer()
            // Bottom spacer to account for the button area
            Spacer()
                .frame(height: 120)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
