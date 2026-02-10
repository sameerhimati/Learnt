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
    @State private var reflectionText = ""
    @State private var skippedCount = 0
    @State private var reviewedCount = 0
    @State private var graduatedDuringSession = 0
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
                header

                if let entry = currentEntry {
                    ScrollView {
                        learningCard(entry: entry)
                            .padding(16)
                            .padding(.bottom, 100)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .id(currentIndex) // Force view recreation for each card
                } else {
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
                        .frame(width: 44, height: 44)
                        .background(Color.inputBackgroundColor)
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(min(currentIndex + 1, entries.count)) of \(entries.count)")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.dividerColor)
                        .frame(height: 3)

                    Rectangle()
                        .fill(Color.primaryTextColor)
                        .frame(width: geo.size.width * progress, height: 3)
                        .animation(.easeInOut(duration: 0.3), value: progress)
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

            // Always-visible reflection field
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.hasReflection ? "Your reflection" : "Add a reflection")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                TextField("How does this connect to what you know?", text: $reflectionText, axis: .vertical)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .focused($isReflectionFocused)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(Color.inputBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
                .frame(height: 16)

            // Rating
            VStack(alignment: .leading, spacing: 12) {
                Text("How well do you know this?")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                HStack(spacing: 12) {
                    ratingButton(
                        title: "Got it",
                        subtitle: rememberSubtitle(for: entry),
                        isPrimary: true,
                        action: { recordAndAdvance(result: .gotIt) }
                    )

                    ratingButton(
                        title: "Still learning",
                        subtitle: "Review tomorrow",
                        isPrimary: false,
                        action: { recordAndAdvance(result: .reviewAgain) }
                    )
                }

                Button(action: skipAndAdvance) {
                    Text("Skip")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            reflectionText = entry.reflection ?? ""
        }
    }

    private func rememberSubtitle(for entry: LearningEntry) -> String {
        let days = entryStore.nextIntervalDays(for: entry)
        if days == 0 {
            return "Graduates"
        }
        return "Next in \(days) days"
    }

    private func ratingButton(title: String, subtitle: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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

            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("Reviewed \(reviewedCount)")
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    if skippedCount > 0 {
                        Text("· Skipped \(skippedCount)")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                }

                if graduatedDuringSession > 0 {
                    VStack(spacing: 6) {
                        Text("\(graduatedDuringSession) learning\(graduatedDuringSession == 1 ? "" : "s") graduated!")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.primaryTextColor)

                        // First-time graduation explanation
                        if !OnboardingProgressService.shared.hasSeenFirstGraduation {
                            Text("Graduated means you've proven you know this.\nIt won't appear in reviews anymore.")
                                .font(.system(.caption, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                    }
                }
            }

            if let nextDate = nextReviewAfterSession {
                Text("Next review \(nextDate.relativeDescription)")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    .padding(.top, 8)
            }

            Spacer()

            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onComplete()
            }) {
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

    private var nextReviewAfterSession: Date? {
        entries
            .compactMap { $0.nextReviewDate }
            .filter { $0 > Date() }
            .min()
    }

    // MARK: - Actions

    private func recordAndAdvance(result: ReviewResult) {
        guard let entry = currentEntry else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != (entry.reflection ?? "") {
            entryStore.updateReflection(entry, reflection: trimmed)
        }

        let willGraduate = result == .gotIt &&
            (entry.reviewCount + 1) >= SettingsService.shared.graduationThreshold

        entryStore.recordReview(entry, result: result)
        reviewedCount += 1

        if willGraduate {
            graduatedDuringSession += 1
            OnboardingProgressService.shared.reach(.firstGraduation)
        }

        reflectionText = ""
        isReflectionFocused = false

        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
    }

    private func skipAndAdvance() {
        if let entry = currentEntry {
            let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && trimmed != (entry.reflection ?? "") {
                entryStore.updateReflection(entry, reflection: trimmed)
            }
        }

        skippedCount += 1
        reflectionText = ""
        isReflectionFocused = false

        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex += 1
        }
    }
}

// MARK: - Date Relative Description

private extension Date {
    var relativeDescription: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "later today"
        } else if calendar.isDateInTomorrow(self) {
            return "tomorrow"
        } else if let days = calendar.dateComponents([.day], from: Date().startOfDay, to: self.startOfDay).day {
            return "in \(days) days"
        }
        return "soon"
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
