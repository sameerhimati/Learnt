//
//  StreakShareSheet.swift
//  Learnt
//

import SwiftUI

/// Sheet for sharing streak as a visual card
struct StreakShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    let streakDays: Int
    let totalLearnings: Int

    @State private var isSharing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview of the shareable card
                StreakShareCard(streakDays: streakDays, totalLearnings: totalLearnings)
                    .frame(width: 280, height: 380)
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
            .navigationTitle("Share Streak")
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
        let cardView = StreakShareCard(streakDays: streakDays, totalLearnings: totalLearnings)
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
    StreakShareSheet(streakDays: 14, totalLearnings: 42)
}
