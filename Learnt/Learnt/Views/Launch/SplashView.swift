//
//  SplashView.swift
//  Learnt
//

import SwiftUI

/// Animated splash screen where "L" expands to spell "Learnt"
struct SplashView: View {
    // Animation states
    @State private var phase: AnimationPhase = .initial

    enum AnimationPhase {
        case initial      // Nothing visible
        case showL        // L appears large and centered
        case expanding    // Letters appear, L shifts left
        case complete     // Full word "Learnt" centered, tagline appears
    }

    // Letter visibility
    @State private var showE = false
    @State private var showA = false
    @State private var showR = false
    @State private var showN = false
    @State private var showT = false
    @State private var showTagline = false

    // L scale (starts big, shrinks to normal)
    @State private var lScale: CGFloat = 1.3

    // Horizontal offset to keep centered (positive = shift right)
    // When only L shows, we shift right to center it
    // As more letters appear, we shift back to 0
    @State private var xOffset: CGFloat = 75

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // The word "Learnt"
                HStack(spacing: 0) {
                    Text("L")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .scaleEffect(lScale)
                        .opacity(phase == .initial ? 0 : 1)

                    Group {
                        letterView("e", show: showE)
                        letterView("a", show: showA)
                        letterView("r", show: showR)
                        letterView("n", show: showN)
                        letterView("t", show: showT)
                    }
                }
                .offset(x: xOffset)

                // Tagline
                Text("Capture what you learn")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline ? 0 : 10)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func letterView(_ letter: String, show: Bool) -> some View {
        Text(letter)
            .font(.system(size: 52, weight: .medium, design: .serif))
            .foregroundStyle(Color.primaryTextColor)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.5)
    }

    private func startAnimation() {
        // Phase 1: Show the L (0.0s - 0.4s)
        withAnimation(.easeOut(duration: 0.4)) {
            phase = .showL
        }

        // Phase 2: Start expanding (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            phase = .expanding

            // Animate L scale down and shift left together
            withAnimation(.easeInOut(duration: 1.0)) {
                lScale = 1.0
                xOffset = 0
            }

            // Stagger letter reveals
            let letterDelay = 0.12
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
                showE = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1 + letterDelay)) {
                showA = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1 + letterDelay * 2)) {
                showR = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1 + letterDelay * 3)) {
                showN = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1 + letterDelay * 4)) {
                showT = true
            }
        }

        // Phase 3: Show tagline (2.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                phase = .complete
                showTagline = true
            }
        }
    }
}

#Preview {
    SplashView()
}
