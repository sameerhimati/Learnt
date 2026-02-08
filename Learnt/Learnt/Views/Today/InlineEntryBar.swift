//
//  InlineEntryBar.swift
//  Learnt
//

import SwiftUI

struct InlineEntryBar: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void
    let onMicTap: () -> Void
    let onExpand: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Mic button
            Button(action: onMicTap) {
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.secondaryTextColor)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Text field
            TextField(placeholder, text: $text, axis: .vertical)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .focused($isFocused)
                .lineLimit(1...4)
                .submitLabel(.send)
                .onSubmit {
                    if canSend {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onSend()
                    }
                }

            // Send or expand button
            if canSend {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onSend()
                }) {
                    Image(systemName: "arrow.up.circle")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.primaryTextColor)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button(action: onExpand) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.15), value: canSend)
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    VStack {
        Spacer()
        InlineEntryBar(
            text: .constant(""),
            placeholder: "What did you learn?",
            onSend: {},
            onMicTap: {},
            onExpand: {}
        )
        .padding(.horizontal, 16)
    }
    .background(Color.appBackgroundColor)
}
