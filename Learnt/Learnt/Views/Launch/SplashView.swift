//
//  SplashView.swift
//  Learnt
//

import SwiftUI

/// Animated splash screen where "L" expands to spell "Learnt"
/// Total duration: ~4.5 seconds for a polished, unhurried feel
struct SplashView: View {
    // Animation phases
    @State private var phase = 0

    // Phase 0: Nothing visible
    // Phase 1: L appears (large, centered)
    // Phase 2: L shifts left & shrinks, "earnt" letters fade in
    // Phase 3: Tagline fades in

    // Smooth spring animation for the main transition
    private let smoothSpring = Animation.spring(response: 0.9, dampingFraction: 0.85)

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // The word "Learnt"
                HStack(spacing: 0) {
                    // The "L" - always present after phase 1
                    Text("L")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .scaleEffect(phase >= 2 ? 1.0 : 1.25)
                        .opacity(phase >= 1 ? 1 : 0)

                    // Each letter with staggered timing
                    letterView("e", delay: 0.0)
                    letterView("a", delay: 0.08)
                    letterView("r", delay: 0.16)
                    letterView("n", delay: 0.24)
                    letterView("t", delay: 0.32)
                }
                .offset(x: phase >= 2 ? 0 : 70)
                .animation(smoothSpring, value: phase)

                // Tagline
                Text("Capture what you learn")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .opacity(phase >= 3 ? 1 : 0)
                    .offset(y: phase >= 3 ? 0 : 12)
                    .animation(.easeOut(duration: 0.8), value: phase)
            }
        }
        .onAppear {
            runAnimation()
        }
    }

    private func letterView(_ letter: String, delay: Double) -> some View {
        Text(letter)
            .font(.system(size: 52, weight: .medium, design: .serif))
            .foregroundStyle(Color.primaryTextColor)
            .opacity(phase >= 2 ? 1 : 0)
            .scaleEffect(phase >= 2 ? 1 : 0.3)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.75).delay(delay),
                value: phase
            )
    }

    private func runAnimation() {
        // Phase 1: Show the L (after brief delay for view to settle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                phase = 1
            }
        }

        // Phase 2: Expand to full word (L shifts, letters appear)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            phase = 2
        }

        // Phase 3: Show tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            phase = 3
        }
    }
}

#Preview {
    SplashView()
}
