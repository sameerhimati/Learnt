//
//  SplashView.swift
//  Learnt
//

import SwiftUI

/// Elegant branded splash screen shown while app initializes
struct SplashView: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.95

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Learnt")
                    .font(.system(size: 48, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)

                Text("Capture what you learn")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                scale = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
