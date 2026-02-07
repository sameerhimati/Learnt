//
//  ShareExtensionView.swift
//  LearntShare
//
//  SwiftUI-based share extension UI

import SwiftUI
import UIKit

/// Main share extension view
struct ShareExtensionView: View {
    let extractedText: String?
    let extractedURL: String?
    let categories: [ShareCategory]
    let onSave: (String, [UUID]) -> Void
    let onCancel: () -> Void

    @State private var note: String = ""
    @State private var selectedCategoryIDs: Set<UUID> = []
    @State private var state: ShareState = .ready

    private var previewContent: String {
        if let url = extractedURL, !url.isEmpty {
            return url
        } else if let text = extractedText, !text.isEmpty {
            return text
        }
        return ""
    }

    private var hasContent: Bool {
        !previewContent.isEmpty || !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(light: Color(hex: "FAFAFA"), dark: Color(hex: "1A1A1A"))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Preview card
                        if !previewContent.isEmpty {
                            previewCard
                        }

                        // Note input
                        noteSection

                        // Category picker
                        if !categories.isEmpty {
                            categorySection
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Learning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color(light: Color(hex: "6B6B6B"), dark: Color(hex: "9B9B9B")))
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(hasContent ? Color(light: Color(hex: "1A1A1A"), dark: Color(hex: "FAFAFA")) : Color(light: Color(hex: "6B6B6B"), dark: Color(hex: "9B9B9B")))
                    .disabled(!hasContent || state == .saving)
                }
            }
        }
    }

    // MARK: - Preview Card

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label
            HStack(spacing: 6) {
                Image(systemName: extractedURL != nil ? "link" : "doc.text")
                    .font(.system(size: 12))
                Text(extractedURL != nil ? "Shared Link" : "Shared Text")
                    .font(.system(size: 12, design: .serif))
            }
            .foregroundStyle(Color(light: Color(hex: "6B6B6B"), dark: Color(hex: "9B9B9B")))

            // Content
            Text(previewContent)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color(light: Color(hex: "1A1A1A"), dark: Color(hex: "FAFAFA")))
                .lineLimit(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(light: Color(hex: "F5F5F5"), dark: Color(hex: "252525")))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Note Section

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add a note")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color(light: Color(hex: "6B6B6B"), dark: Color(hex: "9B9B9B")))

            TextField("What did you learn?", text: $note, axis: .vertical)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color(light: Color(hex: "1A1A1A"), dark: Color(hex: "FAFAFA")))
                .lineLimit(3...6)
                .padding(16)
                .background(Color(light: Color(hex: "F5F5F5"), dark: Color(hex: "252525")))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color(light: Color(hex: "6B6B6B"), dark: Color(hex: "9B9B9B")))

            ShareCategoryPicker(
                categories: categories,
                selectedIDs: $selectedCategoryIDs
            )
        }
    }

    // MARK: - Actions

    private func save() {
        state = .saving

        // Build final content
        var content = note.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add extracted content
        if let text = extractedText, !text.isEmpty {
            if !content.isEmpty {
                content += "\n\n"
            }
            content += text
        }

        if let url = extractedURL, !url.isEmpty {
            if !content.isEmpty {
                content += "\n\n"
            }
            content += url
        }

        onSave(content, Array(selectedCategoryIDs))
    }
}

// MARK: - Color Extension for Share Extension

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ShareExtensionView(
        extractedText: nil,
        extractedURL: "https://example.com/article/swift-tips",
        categories: [
            ShareCategory(id: UUID(), name: "Personal", icon: "person"),
            ShareCategory(id: UUID(), name: "Work", icon: "briefcase"),
            ShareCategory(id: UUID(), name: "Learning", icon: "book"),
            ShareCategory(id: UUID(), name: "Relationships", icon: "heart")
        ],
        onSave: { _, _ in },
        onCancel: {}
    )
}
