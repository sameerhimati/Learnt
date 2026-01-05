//
//  EntryCard.swift
//  Learnt
//

import SwiftUI

struct EntryCard: View {
    let entry: LearningEntry
    let onEdit: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // Voice indicator
                if entry.isVoiceEntry {
                    Image(systemName: "mic")
                        .font(.system(.caption))
                        .foregroundStyle(Color.secondaryTextColor)
                }

                // Content
                Text(isExpanded ? entry.content : entry.previewText)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(isExpanded ? nil : 1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Expand indicator
                if !isExpanded && entry.content.count > 50 {
                    Image(systemName: "chevron.down")
                        .font(.system(.caption))
                        .foregroundStyle(Color.secondaryTextColor)
                }
            }

            // Timestamp and edit button (only when expanded)
            if isExpanded {
                HStack {
                    Text(entry.createdAt, style: .time)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Spacer()

                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(.body))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
        .onLongPressGesture {
            onEdit()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        EntryCard(
            entry: {
                let entry = LearningEntry(content: "Short learning")
                return entry
            }(),
            onEdit: {}
        )

        EntryCard(
            entry: {
                let entry = LearningEntry(
                    content: "Today I learned about SwiftUI animations and how they can make the user interface feel more responsive and polished.",
                    isVoiceEntry: true
                )
                return entry
            }(),
            onEdit: {}
        )
    }
    .padding()
    .background(Color.appBackgroundColor)
}
