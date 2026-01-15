//
//  OnboardingView.swift
//  Learnt
//

import SwiftUI

/// 4-screen onboarding flow for first-time users
struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void

    private let totalPages = 4

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)

                    privacyPage
                        .tag(1)

                    howItWorksPage
                        .tag(2)

                    getStartedPage
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.primaryTextColor : Color.secondaryTextColor.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button(action: handleButtonTap) {
                    Text(currentPage == totalPages - 1 ? "Get Started" : "Continue")
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.appBackgroundColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Text("Learnt")
                .font(.system(size: 48, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Text("Capture the things you learn,\none moment at a time.")
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 32)
    }

    private var privacyPage: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.primaryTextColor)
                    .padding(.bottom, 8)

                Text("Your Data, Your Device")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Private by design")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            VStack(alignment: .leading, spacing: 20) {
                privacyRow(
                    icon: "iphone",
                    text: "Everything stays on your device"
                )

                privacyRow(
                    icon: "xmark.shield",
                    text: "No accounts, no cloud, no tracking"
                )

                privacyRow(
                    icon: "eye.slash",
                    text: "We never see what you write"
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 32)
    }

    private var howItWorksPage: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("Simple & Intentional")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Distraction-free learning")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            VStack(alignment: .leading, spacing: 24) {
                featureRow(
                    icon: "mic",
                    title: "Voice or Text",
                    description: "Capture learnings your way"
                )

                featureRow(
                    icon: "brain.head.profile",
                    title: "Spaced Repetition",
                    description: "Science-backed review intervals"
                )

                featureRow(
                    icon: "arrow.up.right",
                    title: "Graduate Learnings",
                    description: "Move knowledge to long-term memory"
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 32)
    }

    private var getStartedPage: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.primaryTextColor)

            VStack(spacing: 12) {
                Text("Stay on Track")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Enable notifications to get gentle\nreminders for daily capture and review.")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Components

    private func privacyRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.primaryTextColor)
                .frame(width: 32)

            Text(text)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Spacer()
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color.primaryTextColor)
                .frame(width: 48, height: 48)
                .background(Color.inputBackgroundColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text(description)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private func handleButtonTap() {
        if currentPage < totalPages - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            // Request notification permission on final page
            Task {
                _ = await NotificationService.shared.requestPermission()
            }
            onComplete()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
