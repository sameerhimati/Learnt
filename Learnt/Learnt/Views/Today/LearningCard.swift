//
//  LearningCard.swift
//  Learnt
//

import SwiftUI

struct LearningCard: View {
    let entry: LearningEntry
    let onEdit: () -> Void
    let onAddReflection: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void
    let onToggleFavorite: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content row
            mainContent

            // Expanded content
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                // Learning content
                Text(isExpanded ? entry.content : entry.previewText)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(isExpanded ? nil : 2)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Meta row: time + categories + reflection count
                HStack(spacing: 8) {
                    Text(entry.createdAt, style: .time)
                        .font(.system(size: 11, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.7))

                    if !entry.categories.isEmpty {
                        Text("·")
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                        HStack(spacing: 4) {
                            ForEach(entry.categories.prefix(2)) { category in
                                Image(systemName: category.icon)
                                    .font(.system(size: 9))
                            }
                            if entry.categories.count > 2 {
                                Text("+\(entry.categories.count - 2)")
                                    .font(.system(size: 9, design: .serif))
                            }
                        }
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    }

                    if entry.hasReflections {
                        Text("·")
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                        Text("\(entry.reflectionCount) reflection\(entry.reflectionCount == 1 ? "" : "s")")
                            .font(.system(size: 11, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    }

                    if entry.contentAudioFileName != nil {
                        Text("·")
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                        Image(systemName: "waveform")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
                    }
                }
            }

            // Favorite indicator + expand indicator
            VStack(spacing: 8) {
                if entry.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                    .rotationEffect(.degrees(isExpanded ? -180 : 0))
            }
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Divider
            Rectangle()
                .fill(Color.dividerColor)
                .frame(height: 1)
                .padding(.top, 12)

            // Content audio playback (if has audio)
            if entry.contentAudioURL != nil {
                HStack(spacing: 8) {
                    Text("Voice memo")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                    AudioPlaybackButton(audioURL: entry.contentAudioURL)
                }
            }

            // Existing reflections
            if entry.hasReflections {
                reflectionsSection
            }

            // Action buttons
            HStack(spacing: 16) {
                Button(action: onAddReflection) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text(entry.hasReflections ? "Add more" : "Add reflection")
                            .font(.system(size: 13, design: .serif))
                    }
                    .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)

                Spacer()

                // Favorite button
                Button(action: onToggleFavorite) {
                    Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)

                // Share button
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Text("Delete")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)

                Button(action: onEdit) {
                    Text("Edit")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Reflections Section

    private var reflectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let application = entry.application {
                reflectionRow(
                    icon: "lightbulb",
                    label: "Apply",
                    content: application
                )
            }

            if let surprise = entry.surprise {
                reflectionRow(
                    icon: "exclamationmark.circle",
                    label: "Surprised",
                    content: surprise
                )
            }

            if let simplification = entry.simplification {
                reflectionRow(
                    icon: "text.quote",
                    label: "Simply",
                    content: simplification
                )
            }

            if let question = entry.question {
                reflectionRow(
                    icon: "questionmark.circle",
                    label: "Question",
                    content: question
                )
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
                    .lineSpacing(2)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            // Simple entry
            LearningCard(
                entry: {
                    let entry = LearningEntry(content: "Short learning without reflections")
                    return entry
                }(),
                onEdit: {},
                onAddReflection: {},
                onDelete: {},
                onShare: {},
                onToggleFavorite: {}
            )

            // Entry with reflections
            LearningCard(
                entry: {
                    let entry = LearningEntry(
                        content: "Today I learned about SwiftUI animations and how they can make the user interface feel more responsive and polished."
                    )
                    entry.application = "Use spring animations in the next feature I build"
                    entry.question = "How do animations affect app performance?"
                    return entry
                }(),
                onEdit: {},
                onAddReflection: {},
                onDelete: {},
                onShare: {},
                onToggleFavorite: {}
            )

            // Favorited entry
            LearningCard(
                entry: {
                    let entry = LearningEntry(
                        content: "The Feynman technique for learning: If you can't explain something simply, you don't understand it well enough."
                    )
                    entry.isFavorite = true
                    return entry
                }(),
                onEdit: {},
                onAddReflection: {},
                onDelete: {},
                onShare: {},
                onToggleFavorite: {}
            )
        }
        .padding()
    }
    .background(Color.appBackgroundColor)
}
