//
//  InputChooserButton.swift
//  Learnt
//

import SwiftUI

struct InputChooserButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(Color.inputBackgroundColor)
                        .frame(width: 80, height: 80)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .regular))
                        .foregroundStyle(Color.primaryTextColor)
                }

                // Label
                Text(label)
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)
            }
        }
        .buttonStyle(ChooserButtonStyle())
    }
}

// Custom button style for press feedback
private struct ChooserButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: 48) {
        InputChooserButton(icon: "text.cursor", label: "Text") {}
        InputChooserButton(icon: "mic", label: "Voice") {}
    }
    .padding(40)
    .background(Color.black.opacity(0.4))
}
