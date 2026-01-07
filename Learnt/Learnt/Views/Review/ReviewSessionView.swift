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
    @State private var phase: ReviewPhase = .prompt
    @State private var userRecall = ""
    @State private var completedCount = 0

    @FocusState private var isRecallFocused: Bool

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

    enum ReviewPhase {
        case prompt
        case reveal
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header

                if let entry = currentEntry {
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            switch phase {
                            case .prompt:
                                promptPhase(entry: entry)
                            case .reveal:
                                revealPhase(entry: entry)
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 100)
                    }
                } else {
                    // Session complete
                    completionView
                }
            }
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

    // MARK: - Prompt Phase

    private func promptPhase(entry: LearningEntry) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Instruction
            VStack(alignment: .leading, spacing: 8) {
                Text("What do you remember about...")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                // Show truncated hint
                Text(entry.previewText)
                    .font(.system(.title3, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)
            }

            // Date context
            Text("From \(entry.date.formattedFull)")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Color.secondaryTextColor.opacity(0.7))

            // Recall input
            VStack(alignment: .leading, spacing: 8) {
                Text("Your recall")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                TextField("What do you remember?", text: $userRecall, axis: .vertical)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .focused($isRecallFocused)
                    .lineLimit(4...8)
                    .padding(16)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
                .frame(height: 20)

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        phase = .reveal
                    }
                }) {
                    Text("I remember")
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.appBackgroundColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primaryTextColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        phase = .reveal
                    }
                }) {
                    Text("Forgot")
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isRecallFocused = true
            }
        }
    }

    // MARK: - Reveal Phase

    private func revealPhase(entry: LearningEntry) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Original learning
            VStack(alignment: .leading, spacing: 8) {
                Text("You wrote on \(entry.date.formattedFull):")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                Text(entry.content)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineSpacing(4)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Reflections (if any)
            if entry.hasReflections {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your reflections")
                        .font(.system(.subheadline, design: .serif))
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
            }

            Spacer()
                .frame(height: 20)

            // Self-rating
            VStack(alignment: .leading, spacing: 12) {
                Text("How'd you do?")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                HStack(spacing: 10) {
                    ratingButton(
                        title: "Nailed it",
                        subtitle: "Perfect recall",
                        result: .nailed
                    )

                    ratingButton(
                        title: "Partial",
                        subtitle: "Some gaps",
                        result: .partial
                    )

                    ratingButton(
                        title: "Forgot",
                        subtitle: "Start over",
                        result: .forgot
                    )
                }
            }
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

    private func ratingButton(title: String, subtitle: String, result: ReviewResult) -> some View {
        Button(action: {
            recordAndAdvance(result: result)
        }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)

                Text(subtitle)
                    .font(.system(size: 10, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.inputBackgroundColor)
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

        // Record the review result
        entryStore.recordReview(entry, result: result)

        // Reset state and move to next
        withAnimation(.easeInOut(duration: 0.2)) {
            userRecall = ""
            phase = .prompt
            currentIndex += 1
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
