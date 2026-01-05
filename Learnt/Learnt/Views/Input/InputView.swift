//
//  InputView.swift
//  Learnt
//

import SwiftUI

struct InputView: View {
    var initialContent: String = ""
    var showVoiceOption: Bool = true
    let onSave: (String) -> Void
    let onCancel: () -> Void
    var onStartVoice: (() -> Void)? = nil

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
            }
        }
        .toolbar {
            if showVoiceOption, let onStartVoice = onStartVoice {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    // Mic button in keyboard toolbar
                    Button(action: onStartVoice) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color.primaryTextColor)
                    }

                    Spacer()
                }
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
