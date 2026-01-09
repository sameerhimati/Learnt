//
//  AddCategoryView.swift
//  Learnt
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss

    let onCreate: (String, String) -> Void

    @State private var name = ""
    @State private var selectedIcon = "tag"

    private let availableIcons = [
        "tag", "star", "heart", "bolt", "flame",
        "leaf", "globe", "house", "building.2", "car",
        "airplane", "book", "music.note", "camera", "gamecontroller",
        "fork.knife", "cup.and.saucer", "figure.walk", "dumbbell", "brain"
    ]

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.secondaryTextColor)

                        TextField("Category name", text: $name)
                            .font(.system(.body, design: .serif))
                            .padding(16)
                            .background(Color.inputBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Icon picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.secondaryTextColor)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(
                                            selectedIcon == icon
                                                ? Color.appBackgroundColor
                                                : Color.primaryTextColor
                                        )
                                        .frame(width: 48, height: 48)
                                        .background(
                                            selectedIcon == icon
                                                ? Color.primaryTextColor
                                                : Color.inputBackgroundColor
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(.body, design: .serif))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name.trimmingCharacters(in: .whitespacesAndNewlines), selectedIcon)
                        dismiss()
                    }
                    .font(.system(.body, design: .serif, weight: .medium))
                    .disabled(!canCreate)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    AddCategoryView { _, _ in }
}
