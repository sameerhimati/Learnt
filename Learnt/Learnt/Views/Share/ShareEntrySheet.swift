//
//  ShareEntrySheet.swift
//  Learnt
//

import SwiftUI
import UIKit

/// Sheet for sharing a single learning entry as a visual card
struct ShareEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: LearningEntry

    @State private var useDarkMode = true
    @State private var isSharing = false
    @State private var shareAsText = false

    // Card is designed at full export size, preview is scaled down
    private let cardSize = CGSize(width: 1080, height: 1920)
    private var previewScale: CGFloat { 200.0 / 1080.0 }

    private var textToShare: String {
        var text = "\(entry.date.formattedFull)\n\n"
        text += "\"\(entry.content)\"\n\n"

        if !entry.categories.isEmpty {
            text += "Categories: \(entry.categories.map { $0.name }.joined(separator: ", "))\n\n"
        }

        text += "— Learnt"
        return text
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode toggle (Image / Text)
                HStack(spacing: 0) {
                    modeButton(label: "Image", isSelected: !shareAsText) {
                        shareAsText = false
                    }
                    modeButton(label: "Text", isSelected: shareAsText) {
                        shareAsText = true
                    }
                }
                .padding(.top, 16)

                Spacer()

                if shareAsText {
                    // Text preview
                    ScrollView {
                        Text(textToShare)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(Color.inputBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                } else {
                    // Card preview (scaled down from full size)
                    shareableCard(darkMode: useDarkMode)
                        .frame(width: cardSize.width, height: cardSize.height)
                        .scaleEffect(previewScale)
                        .frame(width: cardSize.width * previewScale, height: cardSize.height * previewScale)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                }

                Spacer()

                // Share button
                Button {
                    if shareAsText {
                        shareText()
                    } else {
                        shareCard()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSharing {
                            ProgressView()
                                .tint(Color.appBackgroundColor)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text("Share")
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
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !shareAsText {
                        Button(action: { useDarkMode.toggle() }) {
                            Image(systemName: useDarkMode ? "sun.max" : "moon")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.primaryTextColor)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Share")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
        }
    }

    private func modeButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular, design: .serif))
                .foregroundStyle(isSelected ? Color.primaryTextColor : Color.secondaryTextColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? Color.inputBackgroundColor : Color.clear)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shareable Card (designed at 1080x1920)

    @ViewBuilder
    private func shareableCard(darkMode: Bool) -> some View {
        let bgColor = darkMode ? Color(red: 0.08, green: 0.08, blue: 0.08) : Color(red: 0.98, green: 0.98, blue: 0.98)
        let primaryColor = darkMode ? Color.white : Color(red: 0.1, green: 0.1, blue: 0.1)
        let secondaryColor = darkMode ? Color(red: 0.5, green: 0.5, blue: 0.5) : Color(red: 0.5, green: 0.5, blue: 0.5)
        let borderColor = darkMode ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.85, green: 0.85, blue: 0.85)
        let cardBgColor = darkMode ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.95, green: 0.95, blue: 0.95)

        ZStack {
            // Background
            bgColor

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Date header
                Text(entry.date.formattedFull.uppercased())
                    .font(.system(size: 36, weight: .medium, design: .serif))
                    .foregroundColor(secondaryColor)
                    .tracking(4)

                Spacer().frame(height: 80)

                // Learning content - the hero
                Text("\"\(entry.content)\"")
                    .font(.system(size: 56, weight: .regular, design: .serif))
                    .foregroundColor(primaryColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(16)
                    .padding(.horizontal, 80)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 80)

                // Categories
                if !entry.categories.isEmpty {
                    HStack(spacing: 24) {
                        ForEach(entry.categories.prefix(3)) { category in
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 28))
                                Text(category.name)
                                    .font(.system(size: 32, weight: .medium, design: .serif))
                            }
                            .foregroundColor(primaryColor)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 20)
                            .background(cardBgColor)
                            .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                // Footer
                Text("Learnt")
                    .font(.system(size: 36, weight: .medium, design: .serif))
                    .foregroundColor(secondaryColor)
                    .padding(.bottom, 60)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 48))
        .overlay(
            RoundedRectangle(cornerRadius: 48)
                .stroke(borderColor, lineWidth: 2)
        )
    }

    // MARK: - Share

    private func shareCard() {
        isSharing = true

        // Render the card at full size
        let cardView = shareableCard(darkMode: useDarkMode)
            .frame(width: cardSize.width, height: cardSize.height)

        Task { @MainActor in
            if let image = ShareImageService.shared.renderToImage(cardView, size: cardSize) {
                ShareImageService.shared.shareImage(image)
            }
            isSharing = false
        }
    }

    private func shareText() {
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    ShareEntrySheet(entry: LearningEntry(content: "The best way to learn is to teach."))
}
