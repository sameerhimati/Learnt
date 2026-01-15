//
//  ShareSheetView.swift
//  Learnt
//

import SwiftUI
import SwiftData
import UIKit

struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [LearningEntry]

    private let date: Date

    @State private var useDarkMode = true
    @State private var isSharing = false
    @State private var shareAsText = false

    // Card is designed at full export size, preview is scaled down
    private let cardSize = CGSize(width: 1080, height: 1920)
    private var previewScale: CGFloat { 200.0 / 1080.0 }  // Scale to fit ~200pt width

    init(initialDate: Date) {
        self.date = initialDate
    }

    private var entriesForDate: [LearningEntry] {
        allEntries
            .filter { $0.date.isSameDay(as: date) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var textToShare: String {
        var text = "\(date.formattedFull)\n\n"
        text += "\(entriesForDate.count) \(entriesForDate.count == 1 ? "Learning" : "Learnings")\n\n"

        for entry in entriesForDate {
            text += "• \(entry.content)\n"
        }

        text += "\n— Learnt"
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
                .disabled(isSharing || entriesForDate.isEmpty)
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
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 28, height: 28)
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
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 28, height: 28)
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
                Text(date.formattedFull.uppercased())
                    .font(.system(size: 42, weight: .medium, design: .serif))
                    .foregroundColor(secondaryColor)
                    .tracking(4)

                Spacer().frame(height: 60)

                // Main stat - HUGE number
                Text("\(entriesForDate.count)")
                    .font(.system(size: 220, weight: .bold, design: .serif))
                    .foregroundColor(primaryColor)

                Text(entriesForDate.count == 1 ? "Learning" : "Learnings")
                    .font(.system(size: 48, weight: .regular, design: .serif))
                    .foregroundColor(secondaryColor)

                Spacer().frame(height: 80)

                // Learnings list in styled box
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(Array(entriesForDate.prefix(4).enumerated()), id: \.offset) { _, entry in
                        Text(entry.content)
                            .font(.system(size: 36, weight: .regular, design: .serif))
                            .foregroundColor(primaryColor)
                            .lineSpacing(8)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    let remaining = entriesForDate.count - 4
                    if remaining > 0 {
                        Text("+ \(remaining) more")
                            .font(.system(size: 32, weight: .regular, design: .serif))
                            .foregroundColor(secondaryColor)
                    }
                }
                .padding(48)
                .frame(maxWidth: .infinity)
                .background(cardBgColor)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .padding(.horizontal, 60)

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
    ShareSheetView(initialDate: Date())
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
