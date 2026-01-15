//
//  SplashView.swift
//  Learnt
//

import SwiftUI

/// Animated splash screen where "L" expands to spell "Learnt"
struct SplashView: View {
    // Animation states
    @State private var showL = false
    @State private var showE = false
    @State private var showA = false
    @State private var showR = false
    @State private var showN = false
    @State private var showT = false
    @State private var showTagline = false
    @State private var lScale: CGFloat = 1.2

    private let letterDelay: Double = 0.15
    private let letterDuration: Double = 0.3

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Animated "Learnt" text
                HStack(spacing: 0) {
                    // The iconic "L" - starts larger, scales down as other letters appear
                    Text("L")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .scaleEffect(lScale)
                        .opacity(showL ? 1 : 0)

                    // "earnt" letters appear one by one
                    Text("e")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .opacity(showE ? 1 : 0)
                        .offset(x: showE ? 0 : -10)

                    Text("a")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .opacity(showA ? 1 : 0)
                        .offset(x: showA ? 0 : -10)

                    Text("r")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .opacity(showR ? 1 : 0)
                        .offset(x: showR ? 0 : -10)

                    Text("n")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .opacity(showN ? 1 : 0)
                        .offset(x: showN ? 0 : -10)

                    Text("t")
                        .font(.system(size: 52, weight: .medium, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .opacity(showT ? 1 : 0)
                        .offset(x: showT ? 0 : -10)
                }

                // Tagline fades in last
                Text("Capture what you learn")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline ? 0 : 8)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Phase 1: Show the L prominently (0.0s)
        withAnimation(.easeOut(duration: 0.4)) {
            showL = true
        }

        // Phase 2: Scale down L and reveal letters (0.6s - 1.8s)
        let startDelay = 0.6

        // Scale down L as other letters appear
        withAnimation(.easeInOut(duration: 0.8).delay(startDelay)) {
            lScale = 1.0
        }

        // Reveal each letter with staggered timing
        withAnimation(.easeOut(duration: letterDuration).delay(startDelay)) {
            showE = true
        }

        withAnimation(.easeOut(duration: letterDuration).delay(startDelay + letterDelay)) {
            showA = true
        }

        withAnimation(.easeOut(duration: letterDuration).delay(startDelay + letterDelay * 2)) {
            showR = true
        }

        withAnimation(.easeOut(duration: letterDuration).delay(startDelay + letterDelay * 3)) {
            showN = true
        }

        withAnimation(.easeOut(duration: letterDuration).delay(startDelay + letterDelay * 4)) {
            showT = true
        }

        // Phase 3: Show tagline (2.0s)
        withAnimation(.easeOut(duration: 0.5).delay(2.0)) {
            showTagline = true
        }
    }
}

#Preview {
    SplashView()
}
