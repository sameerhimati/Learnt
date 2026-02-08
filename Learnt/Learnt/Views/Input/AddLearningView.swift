//
//  AddLearningView.swift
//  Learnt
//

import SwiftUI
import SwiftData

enum InputMode: String, CaseIterable {
    case text = "Text"
    case voice = "Voice"
}

struct AddLearningView: View {
    let onSave: (String, String?, [Category], String?, String?) -> Void
    let onCancel: () -> Void

    // For editing existing entry
    var initialContent: String = ""
    var initialReflection: String? = nil
    var initialCategories: [Category] = []
    var initialContentAudioFileName: String? = nil
    var initialTranscription: String? = nil

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var allCategories: [Category]

    @State private var inputMode: InputMode = .text
    @State private var content: String = ""
    @State private var reflection: String = ""
    @State private var showReflection = false
    @State private var selectedCategories: [Category] = []
    @State private var contentAudioFileName: String?
    @State private var transcription: String?

    // AI features
    @State private var aiSuggestedCategoryIDs: Set<UUID> = []
    @State private var hasUserModifiedCategories = false

    @FocusState private var focusedField: Field?

    enum Field {
        case content, reflection
    }

    private var isEditing: Bool {
        !initialContent.isEmpty || initialContentAudioFileName != nil
    }

    private var canSave: Bool {
        // Can save if there's text content OR audio recording
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contentAudioFileName != nil
    }

    private var hasReflection: Bool {
        !reflection.isEmpty
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

                        // Category picker with AI suggestions
                        CategoryPicker(
                            selectedCategories: $selectedCategories,
                            aiSuggestedIDs: aiSuggestedCategoryIDs
                        )
                        .onChange(of: selectedCategories) { _, _ in
                            hasUserModifiedCategories = true
                        }

                        // Optional reflection
                        if showReflection {
                            reflectionSection
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
            reflection = initialReflection ?? ""
            selectedCategories = initialCategories
            contentAudioFileName = initialContentAudioFileName
            transcription = initialTranscription
            showReflection = hasReflection

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
        .onChange(of: content) { _, newValue in
            // Trigger AI category suggestions (debounced)
            suggestCategoriesDebounced(for: newValue)
        }
    }

    // MARK: - AI Features

    @State private var suggestionTask: Task<Void, Never>?

    private func suggestCategoriesDebounced(for text: String) {
        // Cancel any pending suggestion
        suggestionTask?.cancel()

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            aiSuggestedCategoryIDs = []
            return
        }

        suggestionTask = Task {
            // Debounce: wait 500ms
            try? await Task.sleep(for: .milliseconds(500))

            // Check if task was cancelled
            guard !Task.isCancelled else { return }

            // Check if text is still the same
            guard content == text else { return }

            // Get AI suggestions (using mock in DEBUG, real AI when available)
            let suggestions: [String]
            #if DEBUG
            suggestions = AIService.mockCategorySuggestions(for: text)
            #else
            suggestions = await AIService.shared.suggestCategories(
                for: text,
                availableCategories: allCategories.map(\.name)
            )
            #endif

            await MainActor.run {
                // Map suggested names to category IDs
                let suggestedIDs = allCategories
                    .filter { suggestions.contains($0.name) }
                    .map(\.id)

                aiSuggestedCategoryIDs = Set(suggestedIDs)

                // Auto-select if user hasn't manually modified categories
                if !hasUserModifiedCategories && selectedCategories.isEmpty {
                    let suggestedCategories = allCategories.filter { suggestions.contains($0.name) }
                    selectedCategories = Array(suggestedCategories.prefix(2))
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
        .padding(.horizontal, 24)
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
                VoiceRecordingView(audioFileName: $contentAudioFileName, title: $content, transcription: $transcription)
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
                showReflection = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                Text("Add a reflection")
                    .font(.system(.body, design: .serif))
            }
            .foregroundStyle(Color.secondaryTextColor)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reflection Section

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reflection")
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(Color.secondaryTextColor)

                Spacer()

                Text("optional")
                    .font(.system(size: 11, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
            }

            TextField("Any thoughts on this?", text: $reflection, axis: .vertical)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .focused($focusedField, equals: .reflection)
                .lineLimit(3...8)
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

        let ref = reflection.isEmpty ? nil : reflection.trimmingCharacters(in: .whitespacesAndNewlines)

        onSave(trimmedContent, ref, selectedCategories, contentAudioFileName, transcription)
    }
}

#Preview("New Learning") {
    AddLearningView(
        onSave: { _, _, _, _, _ in },
        onCancel: {}
    )
    .modelContainer(for: [LearningEntry.self, Category.self], inMemory: true)
}

#Preview("Edit Learning") {
    AddLearningView(
        onSave: { _, _, _, _, _ in },
        onCancel: {},
        initialContent: "SwiftUI animations make interfaces feel responsive",
        initialReflection: "Could use spring animations in my next project"
    )
    .modelContainer(for: [LearningEntry.self, Category.self], inMemory: true)
}
