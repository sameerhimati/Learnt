//
//  InputChooserOverlay.swift
//  Learnt
//

import SwiftUI

struct InputChooserOverlay: View {
    let onTextSelected: () -> Void
    let onVoiceSelected: () -> Void
    let onDismiss: () -> Void

    @State private var textButtonAppeared = false
    @State private var voiceButtonAppeared = false
    @State private var backgroundOpacity: Double = 0

    private let springAnimation = Animation.spring(
        response: 0.4,
        dampingFraction: 0.7,
        blendDuration: 0
    )

    var body: some View {
        ZStack {
            // Dimmed background - tap to dismiss
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissWithAnimation {
                        onDismiss()
                    }
                }

            // Chooser buttons - positioned at bottom for thumb reach
            VStack {
                Spacer()

                HStack(spacing: 48) {
                    // Text input button
                    InputChooserButton(
                        icon: "text.cursor",
                        label: "Text"
                    ) {
                        dismissWithAnimation {
                            onTextSelected()
                        }
                    }
                    .scaleEffect(textButtonAppeared ? 1.0 : 0.3)
                    .opacity(textButtonAppeared ? 1.0 : 0)

                    // Voice input button
                    InputChooserButton(
                        icon: "mic",
                        label: "Voice"
                    ) {
                        dismissWithAnimation {
                            onVoiceSelected()
                        }
                    }
                    .scaleEffect(voiceButtonAppeared ? 1.0 : 0.3)
                    .opacity(voiceButtonAppeared ? 1.0 : 0)
                }
                .padding(.bottom, 100) // Just above tab bar
            }
        }
        .onAppear {
            // Animate background
            withAnimation(.easeOut(duration: 0.25)) {
                backgroundOpacity = 0.4
            }

            // Staggered button animations
            withAnimation(springAnimation) {
                textButtonAppeared = true
            }
            withAnimation(springAnimation.delay(0.08)) {
                voiceButtonAppeared = true
            }
        }
    }

    private func dismissWithAnimation(completion: @escaping () -> Void) {
        // Animate buttons out
        withAnimation(springAnimation) {
            textButtonAppeared = false
            voiceButtonAppeared = false
        }

        // Fade background
        withAnimation(.easeIn(duration: 0.2)) {
            backgroundOpacity = 0
        }

        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion()
        }
    }
}

#Preview {
    InputChooserOverlay(
        onTextSelected: { print("Text selected") },
        onVoiceSelected: { print("Voice selected") },
        onDismiss: { print("Dismissed") }
    )
}
