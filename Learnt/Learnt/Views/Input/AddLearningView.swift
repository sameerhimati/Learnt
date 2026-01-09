//
//  AddLearningView.swift
//  Learnt
//

import SwiftUI

enum InputMode: String, CaseIterable {
    case text = "Text"
    case voice = "Voice"
}

struct AddLearningView: View {
    let onSave: (String, String?, String?, String?, String?, [Category], String?) -> Void
    let onCancel: () -> Void

    // For editing existing entry
    var initialContent: String = ""
    var initialApplication: String? = nil
    var initialSurprise: String? = nil
    var initialSimplification: String? = nil
    var initialQuestion: String? = nil
    var initialCategories: [Category] = []
    var initialContentAudioFileName: String? = nil

    @State private var inputMode: InputMode = .text
    @State private var content: String = ""
    @State private var application: String = ""
    @State private var surprise: String = ""
    @State private var simplification: String = ""
    @State private var question: String = ""
    @State private var showReflections = false
    @State private var selectedCategories: [Category] = []
    @State private var contentAudioFileName: String?

    @FocusState private var focusedField: Field?

    enum Field {
        case content, application, surprise, simplification, question
    }

    private var isEditing: Bool {
        !initialContent.isEmpty || initialContentAudioFileName != nil
    }

    private var canSave: Bool {
        // Can save if there's text content OR audio recording
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contentAudioFileName != nil
    }

    private var hasReflections: Bool {
        !application.isEmpty || !surprise.isEmpty || !simplification.isEmpty || !question.isEmpty
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Main learning input with mode toggle
                        mainLearningSection

                        // Category picker
                        CategoryPicker(selectedCategories: $selectedCategories)

                        // Reflection prompts (expandable) - text only
                        if showReflections {
                            reflectionPromptsSection
                        } else {
                            addReflectionButton
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    focusedField = nil
                }
            }
        }
        .onAppear {
            content = initialContent
            application = initialApplication ?? ""
            surprise = initialSurprise ?? ""
            simplification = initialSimplification ?? ""
            question = initialQuestion ?? ""
            selectedCategories = initialCategories
            contentAudioFileName = initialContentAudioFileName
            showReflections = hasReflections

            // Set initial input mode based on existing content
            if initialContentAudioFileName != nil && initialContent.isEmpty {
                inputMode = .voice
            }

            // Only auto-focus for text mode
            if inputMode == .text {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    focusedField = .content
                }
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

            Button(action: saveEntry) {
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

    // MARK: - Main Learning Section

    private var mainLearningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What did you learn?")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            // Input mode toggle
            inputModeToggle

            // Content based on mode
            if inputMode == .text {
                textInputView
            } else {
                VoiceRecordingView(audioFileName: $contentAudioFileName, title: $content)
            }
        }
    }

    private var inputModeToggle: some View {
        HStack(spacing: 0) {
            ForEach(InputMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        inputMode = mode
                        if mode == .text {
                            focusedField = .content
                        } else {
                            focusedField = nil
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode == .text ? "character.cursor.ibeam" : "mic.fill")
                            .font(.system(size: 12))
                        Text(mode.rawValue)
                            .font(.system(size: 13, design: .serif))
                    }
                    .foregroundStyle(inputMode == mode ? Color.appBackgroundColor : Color.secondaryTextColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(inputMode == mode ? Color.primaryTextColor : Color.clear)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.inputBackgroundColor)
        .clipShape(Capsule())
    }

    private var textInputView: some View {
        TextField("", text: $content, axis: .vertical)
            .font(.system(.title3, design: .serif))
            .foregroundStyle(Color.primaryTextColor)
            .focused($focusedField, equals: .content)
            .lineLimit(5...10)
            .padding(16)
            .background(Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Add Reflection Button

    private var addReflectionButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showReflections = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                Text("Add reflections")
                    .font(.system(.body, design: .serif))
            }
            .foregroundStyle(Color.secondaryTextColor)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reflection Prompts Section (Text Only)

    private var reflectionPromptsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Reflections")
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(Color.secondaryTextColor)

                Spacer()

                Text("optional")
                    .font(.system(size: 11, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
            }

            reflectionPrompt(
                icon: "lightbulb",
                label: "How could you apply this?",
                text: $application,
                field: .application
            )

            reflectionPrompt(
                icon: "exclamationmark.circle",
                label: "What surprised you?",
                text: $surprise,
                field: .surprise
            )

            reflectionPrompt(
                icon: "text.quote",
                label: "Explain it simply",
                text: $simplification,
                field: .simplification
            )

            reflectionPrompt(
                icon: "questionmark.circle",
                label: "What question does this raise?",
                text: $question,
                field: .question
            )
        }
    }

    private func reflectionPrompt(
        icon: String,
        label: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondaryTextColor)

                Text(label)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            TextField("", text: text, axis: .vertical)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .focused($focusedField, equals: field)
                .lineLimit(2...5)
                .padding(12)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Actions

    private func saveEntry() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        // Allow saving with audio only (no text required)
        guard !trimmedContent.isEmpty || contentAudioFileName != nil else { return }

        let app = application.isEmpty ? nil : application.trimmingCharacters(in: .whitespacesAndNewlines)
        let sur = surprise.isEmpty ? nil : surprise.trimmingCharacters(in: .whitespacesAndNewlines)
        let sim = simplification.isEmpty ? nil : simplification.trimmingCharacters(in: .whitespacesAndNewlines)
        let que = question.isEmpty ? nil : question.trimmingCharacters(in: .whitespacesAndNewlines)

        onSave(trimmedContent, app, sur, sim, que, selectedCategories, contentAudioFileName)
    }
}

#Preview("New Learning") {
    AddLearningView(
        onSave: { _, _, _, _, _, _, _ in },
        onCancel: {}
    )
    .modelContainer(for: [LearningEntry.self, Category.self], inMemory: true)
}

#Preview("Edit Learning") {
    AddLearningView(
        onSave: { _, _, _, _, _, _, _ in },
        onCancel: {},
        initialContent: "SwiftUI animations make interfaces feel responsive",
        initialApplication: "Use in my next project",
        initialQuestion: "What about performance?"
    )
    .modelContainer(for: [LearningEntry.self, Category.self], inMemory: true)
}
