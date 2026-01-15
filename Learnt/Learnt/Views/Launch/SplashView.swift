//
//  SplashView.swift
//  Learnt
//

import SwiftUI

/// Animated splash screen where "L" expands to spell "Learnt"
struct SplashView: View {
    // Simplified animation state - single progress value
    @State private var showL = false
    @State private var expandLetters = false
    @State private var showTagline = false

    // Computed values based on animation progress
    private var lScale: CGFloat { expandLetters ? 1.0 : 1.3 }
    private var xOffset: CGFloat { expandLetters ? 0 : 75 }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // The word "Learnt" - use drawingGroup for smoother rendering
                HStack(spacing: 0) {
                    Text("L")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .scaleEffect(lScale)
                        .opacity(showL ? 1 : 0)

                    ForEach(Array("earnt".enumerated()), id: \.offset) { index, letter in
                        Text(String(letter))
                            .font(.system(size: 52, weight: .medium, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                            .opacity(expandLetters ? 1 : 0)
                            .scaleEffect(expandLetters ? 1 : 0.5)
                            .animation(
                                .easeOut(duration: 0.35).delay(Double(index) * 0.08),
                                value: expandLetters
                            )
                    }
                }
                .offset(x: xOffset)
                .animation(.easeInOut(duration: 0.6), value: expandLetters)
                .drawingGroup() // Flatten to single layer for smoother animation

                // Tagline
                Text("Capture what you learn")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline ? 0 : 8)
                    .animation(.easeOut(duration: 0.4), value: showTagline)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Phase 1: Show the L
        withAnimation(.easeOut(duration: 0.3)) {
            showL = true
        }

        // Phase 2: Expand letters (after brief pause)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expandLetters = true
        }

        // Phase 3: Show tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showTagline = true
        }
    }
}

#Preview {
    SplashView()
}
