//
//  ShareEntrySheet.swift
//  Learnt
//

import SwiftUI

/// Sheet for sharing a single learning entry as a visual card
struct ShareEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: LearningEntry

    @State private var isSharing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview of the shareable card
                LearningShareCard(entry: entry)
                    .frame(width: 300, height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)

                Text("Preview")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                Spacer()

                // Share button
                Button {
                    shareCard()
                } label: {
                    HStack(spacing: 8) {
                        if isSharing {
                            ProgressView()
                                .tint(Color.appBackgroundColor)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text("Share to Stories")
                    }
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(Color.appBackgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isSharing)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .padding(.top, 32)
            .background(Color.appBackgroundColor)
            .navigationTitle("Share Learning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func shareCard() {
        isSharing = true

        // Create the shareable card view at story size
        let cardView = LearningShareCard(entry: entry)
            .frame(width: ShareImageService.storySize.width, height: ShareImageService.storySize.height)

        // Render to image
        Task { @MainActor in
            if let image = ShareImageService.shared.renderToImage(cardView, size: ShareImageService.storySize) {
                ShareImageService.shared.shareImage(image)
            }
            isSharing = false
        }
    }
}

#Preview {
    ShareEntrySheet(entry: LearningEntry(content: "The best way to learn is to teach."))
}
