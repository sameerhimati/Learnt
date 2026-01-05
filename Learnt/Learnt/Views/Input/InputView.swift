//
//  InputView.swift
//  Learnt
//

import SwiftUI

struct InputView: View {
    var initialContent: String = ""
    let onSave: (String) -> Void
    let onCancel: () -> Void
    let onStartVoice: () -> Void

    @State private var content: String = ""
    @FocusState private var isFocused: Bool

    private var isEditing: Bool {
        !initialContent.isEmpty
    }

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Text input area
                textArea

                // Bottom bar with mic button
                bottomBar
            }
        }
        .onAppear {
            content = initialContent
            // Auto-focus after a brief delay for smooth animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.secondaryTextColor)
                    .frame(width: 32, height: 32)
                    .background(Color.inputBackgroundColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { onSave(content) }) {
                Text("Save")
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(canSave ? Color.primaryTextColor : Color.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Text Area

    private var textArea: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Placeholder
                if content.isEmpty {
                    Text("What did you learn today?")
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .allowsHitTesting(false)
                }

                // Text editor overlay
                TextEditor(text: $content)
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($isFocused)
                    .padding(.horizontal, 12)
                    .padding(.top, content.isEmpty ? -48 : 24)
                    .frame(minHeight: 200)
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Spacer()

            // Mic button
            Button(action: onStartVoice) {
                ZStack {
                    Circle()
                        .fill(Color.inputBackgroundColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)

                    Image(systemName: "mic")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color.primaryTextColor)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.bottom, 8)
    }
}

#Preview("New Entry") {
    InputView(
        onSave: { _ in },
        onCancel: {},
        onStartVoice: {}
    )
}

#Preview("Edit Entry") {
    InputView(
        initialContent: "Today I learned about the importance of simplicity in design.",
        onSave: { _ in },
        onCancel: {},
        onStartVoice: {}
    )
}
