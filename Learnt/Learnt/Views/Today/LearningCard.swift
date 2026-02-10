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
    let onToggleFavorite: () -> Void
    var onExpansionChanged: ((Bool) -> Void)? = nil

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tappable content area — expands/collapses card
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    onExpansionChanged?(isExpanded)
                }
            }) {
                tappableContent
            }
            .buttonStyle(.plain)

            // Reflection prompt (collapsed, no reflection) — separate tap target
            if !isExpanded && !entry.hasReflection {
                Button(action: {
                    CoachMarkCoordinator.shared.showMark(.reflectionStartsReview)
                    onAddReflection()
                }) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.secondaryTextColor.opacity(0.3))
                            .frame(width: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 1))

                        Text("Reflect on this")
                            .font(.system(size: 13, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .padding(.leading, 8)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                            .padding(.leading, 4)
                    }
                    .padding(.vertical, 6)
                    .padding(.top, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            // Expanded content
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Tappable Content (expands card)

    private var tappableContent: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // Learning content
                Text(isExpanded ? entry.content : entry.previewText)
                    .font(.system(size: 17, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(isExpanded ? nil : 2)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Reflection preview (collapsed, has reflection)
                if !isExpanded, let reflection = entry.reflection {
                    Text(reflection)
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .lineLimit(1)
                }

                // Meta row
                metaRow
            }

            // Favorite indicator + expand chevron
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
        .contentShape(Rectangle())
    }

    // MARK: - Meta Row

    private var metaRow: some View {
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

            if entry.hasReflection {
                Text("·")
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                Text("reflected")
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

            // Review progress
            if entry.isGraduated {
                Text("·")
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
            } else if entry.reviewCount > 0 {
                Text("·")
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.5))
                Text("\(entry.reviewCount)/\(SettingsService.shared.graduationThreshold)")
                    .font(.system(size: 10, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.7))
            }
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(Color.dividerColor)
                .frame(height: 1)
                .padding(.top, 12)

            // Reflection (promoted to top)
            if let reflection = entry.reflection {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reflection")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Text(reflection)
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .lineSpacing(2)
                }
            }

            // Audio
            if entry.contentAudioURL != nil {
                HStack(spacing: 8) {
                    Text("Voice memo")
                        .font(.system(size: 11, weight: .medium, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                    AudioPlaybackButton(audioURL: entry.contentAudioURL)
                }
            }

            // Actions
            HStack(spacing: 16) {
                Button(action: onAddReflection) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                        Text(entry.hasReflection ? "Edit reflection" : "Add reflection")
                            .font(.system(size: 13, design: .serif))
                    }
                    .foregroundStyle(Color.secondaryTextColor)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onToggleFavorite) {
                    Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Text("Delete")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: onEdit) {
                    Text("Edit")
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            LearningCard(
                entry: {
                    let entry = LearningEntry(content: "Short learning without reflections")
                    return entry
                }(),
                onEdit: {},
                onAddReflection: {},
                onDelete: {},
                onToggleFavorite: {}
            )

            LearningCard(
                entry: {
                    let entry = LearningEntry(
                        content: "Today I learned about SwiftUI animations and how they can make the user interface feel more responsive and polished."
                    )
                    entry.reflection = "Could use spring animations in my next feature build."
                    return entry
                }(),
                onEdit: {},
                onAddReflection: {},
                onDelete: {},
                onToggleFavorite: {}
            )
        }
        .padding()
    }
    .background(Color.appBackgroundColor)
}
