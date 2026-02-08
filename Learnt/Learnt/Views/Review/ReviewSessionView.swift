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
    @State private var reflectionText = ""
    @FocusState private var isReflectionFocused: Bool

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

            // Reflection
            if let reflection = entry.reflection {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your reflection")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text(reflection)
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .lineSpacing(2)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else if showAddReflection {
                // Inline reflection input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a reflection")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    TextField("Any thoughts on this?", text: $reflectionText, axis: .vertical)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .focused($isReflectionFocused)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Color.inputBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showAddReflection = true
                        isReflectionFocused = true
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

        // Save reflection if entered during review
        let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            entryStore.updateReflection(entry, reflection: trimmed)
        }

        // Record the review result
        entryStore.recordReview(entry, result: result)

        // Reset state for next entry
        showAddReflection = false
        reflectionText = ""
        isReflectionFocused = false

        // Move to next
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
    }
}

#Preview {
    ReviewSessionView(
        entries: [
            {
                let e = LearningEntry(content: "The best way to learn is to teach others")
                e.reflection = "I should try explaining concepts to teammates more often"
                return e
            }(),
            LearningEntry(content: "Spaced repetition beats cramming"),
            LearningEntry(content: "Sleep consolidates memory")
        ],
        onComplete: {}
    )
}
