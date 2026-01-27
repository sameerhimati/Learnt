//
//  SplashView.swift
//  Learnt
//

import SwiftUI

/// Simple splash screen - "Learnt" appears immediately, tagline fades in
struct SplashView: View {
    @State private var showTagline = false

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Learnt")
                    .font(.system(size: 52, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Capture what you learn")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                    .opacity(showTagline ? 1 : 0)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.7)) {
                    showTagline = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
