//
//  ShareCategoryPicker.swift
//  LearntShare
//
//  Category picker for share extension

import SwiftUI

/// Category picker for share extension
struct ShareCategoryPicker: View {
    let categories: [ShareCategory]
    @Binding var selectedIDs: Set<UUID>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    categoryButton(for: category)
                }
            }
        }
    }

    private func categoryButton(for category: ShareCategory) -> some View {
        let isSelected = selectedIDs.contains(category.id)

        return Button {
            if isSelected {
                selectedIDs.remove(category.id)
            } else {
                selectedIDs.insert(category.id)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.name)
                    .font(.system(size: 13, design: .serif))
            }
            .foregroundStyle(isSelected
                ? Color(light: Color(hex: "FAFAFA"), dark: Color(hex: "1A1A1A"))
                : Color(light: Color(hex: "1A1A1A"), dark: Color(hex: "FAFAFA")))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected
                ? Color(light: Color(hex: "1A1A1A"), dark: Color(hex: "FAFAFA"))
                : Color(light: Color(hex: "F5F5F5"), dark: Color(hex: "252525")))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        ShareCategoryPicker(
            categories: [
                ShareCategory(id: UUID(), name: "Personal", icon: "person"),
                ShareCategory(id: UUID(), name: "Work", icon: "briefcase"),
                ShareCategory(id: UUID(), name: "Learning", icon: "book"),
                ShareCategory(id: UUID(), name: "Relationships", icon: "heart")
            ],
            selectedIDs: .constant([])
        )
    }
    .padding()
}
