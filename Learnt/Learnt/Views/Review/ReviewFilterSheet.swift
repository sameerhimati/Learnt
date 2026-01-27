//
//  ReviewFilterSheet.swift
//  Learnt

import SwiftUI

struct ReviewFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Binding var includeGraduated: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Category filter section
                categorySection

                // Include graduated toggle
                graduatedSection

                Spacer()

                // Clear filters button
                if selectedCategory != nil || includeGraduated {
                    Button(action: clearFilters) {
                        Text("Clear Filters")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.inputBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Color.appBackgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Filter Reviews")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by Category")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            if categories.isEmpty {
                Text("No categories created yet")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All option
                        Button(action: { selectedCategory = nil }) {
                            Text("All")
                                .font(.system(.subheadline, design: .serif, weight: selectedCategory == nil ? .medium : .regular))
                                .foregroundStyle(selectedCategory == nil ? Color.appBackgroundColor : Color.primaryTextColor)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.primaryTextColor : Color.inputBackgroundColor)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        ForEach(categories) { category in
                            Button(action: { selectedCategory = category }) {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 12))
                                    Text(category.name)
                                }
                                .font(.system(.subheadline, design: .serif, weight: selectedCategory == category ? .medium : .regular))
                                .foregroundStyle(selectedCategory == category ? Color.appBackgroundColor : Color.primaryTextColor)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.primaryTextColor : Color.inputBackgroundColor)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Graduated Section

    private var graduatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Re-review Options")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            Button(action: { includeGraduated.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Include graduated learnings")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)

                        Text("Review learnings that have already completed spaced repetition")
                            .font(.system(size: 12, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: includeGraduated ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.primaryTextColor)
                }
                .padding(16)
                .background(Color.inputBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func clearFilters() {
        selectedCategory = nil
        includeGraduated = false
    }
}

#Preview {
    ReviewFilterSheet(
        categories: [],
        selectedCategory: .constant(nil),
        includeGraduated: .constant(false)
    )
}
