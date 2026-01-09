//
//  ShareableCardView.swift
//  Learnt
//

import SwiftUI

/// Base container for all shareable cards with consistent branding
struct ShareableCardView<Content: View>: View {
    let content: Content
    let showBranding: Bool

    init(showBranding: Bool = true, @ViewBuilder content: () -> Content) {
        self.showBranding = showBranding
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background
            Color.appBackgroundColor

            VStack(spacing: 0) {
                Spacer()

                // Main content
                content
                    .padding(.horizontal, 48)

                Spacer()

                // Branding footer
                if showBranding {
                    brandingFooter
                        .padding(.bottom, 48)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var brandingFooter: some View {
        VStack(spacing: 8) {
            Text("Learnt")
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Text("Track what you learn, every day")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
    }
}

// MARK: - Preview

#Preview("Base Card") {
    ShareableCardView {
        VStack(spacing: 16) {
            Text("Sample Content")
                .font(.system(.title, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Text("This is where the shareable content goes")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
    }
    .frame(width: 375, height: 667)
}
