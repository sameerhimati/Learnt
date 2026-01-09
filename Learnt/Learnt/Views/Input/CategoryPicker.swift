//
//  CategoryPicker.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct CategoryPicker: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @Binding var selectedCategories: [Category]
    @State private var showAddCategory = false

    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Categories")
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(Color.secondaryTextColor)

                Spacer()

                Text("optional")
                    .font(.system(size: 11, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
            }

            // Wrap grid layout
            FlowLayout(spacing: 8) {
                ForEach(categories) { category in
                    categoryChip(category: category)
                }

                // Add new button
                Button {
                    showAddCategory = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11))
                        Text("New")
                            .font(.system(size: 13, design: .serif))
                    }
                    .foregroundStyle(Color.secondaryTextColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.inputBackgroundColor)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.dividerColor, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView { name, icon in
                let service = CategoryService(modelContext: modelContext)
                service.createCategory(name: name, icon: icon)
            }
        }
        .onAppear {
            let service = CategoryService(modelContext: modelContext)
            service.ensurePresetsExist()
        }
    }

    private func categoryChip(category: Category) -> some View {
        let isSelected = selectedCategories.contains { $0.id == category.id }

        return Button {
            if isSelected {
                selectedCategories.removeAll { $0.id == category.id }
            } else {
                selectedCategories.append(category)
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: category.icon)
                    .font(.system(size: 11))
                Text(category.name)
                    .font(.system(size: 13, design: .serif))
            }
            .foregroundStyle(isSelected ? Color.appBackgroundColor : Color.primaryTextColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryTextColor : Color.inputBackgroundColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (Wrap Grid)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return (positions, CGSize(width: totalWidth, height: totalHeight))
    }
}

#Preview {
    CategoryPicker(selectedCategories: .constant([]))
        .padding()
        .modelContainer(for: [LearningEntry.self, Category.self], inMemory: true)
}
