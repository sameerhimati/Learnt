//
//  ReviewSessionView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct ReviewSessionView: View {
    @Environment(\.modelContext) private var modelContext
    let entries: [LearningEntry]
    let onComplete: () -> Void

    @State private var currentIndex = 0
    @State private var showAddReflection = false
    @State private var reflectionApplication = ""
    @State private var reflectionSurprise = ""
    @State private var reflectionSimplification = ""
    @State private var reflectionQuestion = ""
    @FocusState private var focusedField: ReflectionField?

    enum ReflectionField {
        case application, surprise, simplification, question
    }

    private var entryStore: EntryStore {
        EntryStore(modelContext: modelContext)
    }

    private var currentEntry: LearningEntry? {
        guard currentIndex < entries.count else { return nil }
        return entries[currentIndex]
    }

    private var progress: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(currentIndex) / Double(entries.count)
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header

                if let entry = currentEntry {
                    // Learning card
                    ScrollView {
                        learningCard(entry: entry)
                            .padding(16)
                            .padding(.bottom, 100)
                    }
                } else {
                    // Session complete
                    completionView
                }
            }
        }
        .sheet(isPresented: $showAddReflection) {
            ReflectionInputSheet(
                application: $reflectionApplication,
                surprise: $reflectionSurprise,
                simplification: $reflectionSimplification,
                question: $reflectionQuestion
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onComplete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 32, height: 32)
                        .background(Color.inputBackgroundColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(currentIndex + 1) of \(entries.count)")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.dividerColor)
                        .frame(height: 3)

                    Rectangle()
                        .fill(Color.primaryTextColor)
                        .frame(width: geo.size.width * progress, height: 3)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Learning Card

    private func learningCard(entry: LearningEntry) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Date header
            Text(entry.date.formattedFull)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            // Main content
            Text(entry.content)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .lineSpacing(4)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            // Reflections (if any)
            if entry.hasReflections {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your reflections")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    VStack(alignment: .leading, spacing: 10) {
                        if let app = entry.application {
                            reflectionRow(icon: "lightbulb", label: "Apply", content: app)
                        }
                        if let sur = entry.surprise {
                            reflectionRow(icon: "exclamationmark.circle", label: "Surprised", content: sur)
                        }
                        if let sim = entry.simplification {
                            reflectionRow(icon: "text.quote", label: "Simply", content: sim)
                        }
                        if let que = entry.question {
                            reflectionRow(icon: "questionmark.circle", label: "Question", content: que)
                        }
                    }
                    .padding(16)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Option to add reflections
                if showAddReflection {
                    addReflectionSection
                } else {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAddReflection = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 14))
                            Text("Add a reflection")
                                .font(.system(.subheadline, design: .serif))
                        }
                        .foregroundStyle(Color.secondaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
                .frame(height: 24)

            // Action prompt
            VStack(alignment: .leading, spacing: 12) {
                Text("Still with you?")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                HStack(spacing: 12) {
                    ratingButton(
                        title: "Got it",
                        subtitle: "Next interval",
                        isPrimary: true,
                        result: .gotIt
                    )

                    ratingButton(
                        title: "Review again",
                        subtitle: "See it sooner",
                        isPrimary: false,
                        result: .reviewAgain
                    )
                }
            }
        }
    }

    // MARK: - Add Reflection Section

    private var hasEnteredReflections: Bool {
        !reflectionApplication.isEmpty || !reflectionSurprise.isEmpty ||
        !reflectionSimplification.isEmpty || !reflectionQuestion.isEmpty
    }

    private var addReflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Show entered reflections preview
            if hasEnteredReflections {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Your reflections")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)

                        Spacer()

                        Button(action: { showAddReflection = true }) {
                            Text("Edit")
                                .font(.system(size: 12, design: .serif))
                                .foregroundStyle(Color.primaryTextColor)
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        if !reflectionApplication.isEmpty {
                            reflectionPreviewRow(icon: "lightbulb", content: reflectionApplication)
                        }
                        if !reflectionSurprise.isEmpty {
                            reflectionPreviewRow(icon: "exclamationmark.circle", content: reflectionSurprise)
                        }
                        if !reflectionSimplification.isEmpty {
                            reflectionPreviewRow(icon: "text.quote", content: reflectionSimplification)
                        }
                        if !reflectionQuestion.isEmpty {
                            reflectionPreviewRow(icon: "questionmark.circle", content: reflectionQuestion)
                        }
                    }
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Button to add reflections
                Button(action: { showAddReflection = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14))
                        Text("Add a reflection")
                            .font(.system(.subheadline, design: .serif))
                    }
                    .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func reflectionPreviewRow(icon: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(Color.secondaryTextColor)
                .frame(width: 14)

            Text(content)
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .lineLimit(2)
        }
    }

    private func reflectionRow(icon: String, label: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Color.secondaryTextColor)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                Text(content)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
            }
        }
    }

    private func ratingButton(title: String, subtitle: String, isPrimary: Bool, result: ReviewResult) -> some View {
        Button(action: {
            recordAndAdvance(result: result)
        }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(isPrimary ? Color.appBackgroundColor : Color.primaryTextColor)

                Text(subtitle)
                    .font(.system(size: 11, design: .serif))
                    .foregroundStyle(isPrimary ? Color.appBackgroundColor.opacity(0.7) : Color.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isPrimary ? Color.primaryTextColor : Color.inputBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.primaryTextColor)

            Text("Session complete!")
                .font(.system(.title2, design: .serif, weight: .medium))
                .foregroundStyle(Color.primaryTextColor)

            Text("You reviewed \(entries.count) learning\(entries.count == 1 ? "" : "s")")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Spacer()

            Button(action: onComplete) {
                Text("Done")
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(Color.appBackgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Actions

    private func recordAndAdvance(result: ReviewResult) {
        guard let entry = currentEntry else { return }

        // Save any reflections entered during review
        if hasEnteredReflections {
            let app = reflectionApplication.trimmingCharacters(in: .whitespacesAndNewlines)
            let sur = reflectionSurprise.trimmingCharacters(in: .whitespacesAndNewlines)
            let sim = reflectionSimplification.trimmingCharacters(in: .whitespacesAndNewlines)
            let que = reflectionQuestion.trimmingCharacters(in: .whitespacesAndNewlines)

            entryStore.updateReflections(
                entry,
                application: app.isEmpty ? nil : app,
                surprise: sur.isEmpty ? nil : sur,
                simplification: sim.isEmpty ? nil : sim,
                question: que.isEmpty ? nil : que
            )
        }

        // Record the review result
        entryStore.recordReview(entry, result: result)

        // Reset reflection state for next entry
        resetReflectionState()

        // Move to next
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
    }

    private func resetReflectionState() {
        showAddReflection = false
        reflectionApplication = ""
        reflectionSurprise = ""
        reflectionSimplification = ""
        reflectionQuestion = ""
        focusedField = nil
    }
}

// MARK: - Reflection Input Sheet

struct ReflectionInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var application: String
    @Binding var surprise: String
    @Binding var simplification: String
    @Binding var question: String

    @State private var isRecording = false
    @State private var currentField: ReflectionFieldType?
    @State private var recordingDuration: TimeInterval = 0
    @FocusState private var focusedField: ReflectionFieldType?

    enum ReflectionFieldType {
        case application, surprise, simplification, question
    }

    private let recorder = VoiceRecorderService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Instructions
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add reflections")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)

                        Text("Deepen your understanding by reflecting on what you've learned.")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    // Reflection fields
                    VStack(spacing: 16) {
                        reflectionField(
                            icon: "lightbulb",
                            title: "Apply",
                            placeholder: "How could you use this?",
                            text: $application,
                            field: .application
                        )

                        reflectionField(
                            icon: "exclamationmark.circle",
                            title: "Surprised",
                            placeholder: "What was unexpected?",
                            text: $surprise,
                            field: .surprise
                        )

                        reflectionField(
                            icon: "text.quote",
                            title: "Simplify",
                            placeholder: "Explain it simply",
                            text: $simplification,
                            field: .simplification
                        )

                        reflectionField(
                            icon: "questionmark.circle",
                            title: "Question",
                            placeholder: "What does this raise?",
                            text: $question,
                            field: .question
                        )
                    }
                    .padding(16)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(16)
            }
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onChange(of: recorder.recordingDuration) { _, newValue in
            if isRecording {
                recordingDuration = newValue
            }
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func reflectionField(icon: String, title: String, placeholder: String, text: Binding<String>, field: ReflectionFieldType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondaryTextColor)

                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            HStack(alignment: .top, spacing: 8) {
                TextField(placeholder, text: text, axis: .vertical)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .focused($focusedField, equals: field)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Color.appBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                // Inline mic button with duration
                VStack(spacing: 4) {
                    Button(action: {
                        if isRecording && currentField == field {
                            stopRecording(for: field)
                        } else {
                            startRecording(for: field)
                        }
                    }) {
                        Image(systemName: isRecording && currentField == field ? "stop.fill" : "mic")
                            .font(.system(size: 14))
                            .foregroundStyle(isRecording && currentField == field ? Color.appBackgroundColor : Color.secondaryTextColor)
                            .frame(width: 40, height: 40)
                            .background(isRecording && currentField == field ? Color.primaryTextColor : Color.appBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    // Recording duration indicator
                    if isRecording && currentField == field {
                        Text(formattedDuration(recordingDuration))
                            .font(.system(size: 11, design: .serif).monospacedDigit())
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
        }
    }

    private func startRecording(for field: ReflectionFieldType) {
        // Reset duration before starting
        recordingDuration = 0

        Task {
            if !recorder.hasPermissions {
                let granted = await recorder.requestPermissions()
                guard granted else { return }
            }

            if let _ = recorder.startRecording() {
                await MainActor.run {
                    isRecording = true
                    currentField = field
                }
            }
        }
    }

    private func stopRecording(for field: ReflectionFieldType) {
        guard let url = recorder.stopRecording() else { return }
        isRecording = false

        Task {
            if let text = await recorder.transcribe(audioURL: url) {
                await MainActor.run {
                    switch field {
                    case .application: application = text
                    case .surprise: surprise = text
                    case .simplification: simplification = text
                    case .question: question = text
                    }
                }
            }
            // Clean up temp audio
            try? FileManager.default.removeItem(at: url)
        }
    }
}

#Preview {
    ReviewSessionView(
        entries: [
            {
                let e = LearningEntry(content: "The best way to learn is to teach others")
                e.application = "Explain concepts to teammates"
                return e
            }(),
            LearningEntry(content: "Spaced repetition beats cramming"),
            LearningEntry(content: "Sleep consolidates memory")
        ],
        onComplete: {}
    )
}
