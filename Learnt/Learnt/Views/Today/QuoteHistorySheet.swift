//
//  QuoteHistorySheet.swift
//  Learnt

import SwiftUI

struct QuoteHistorySheet: View {
    @Environment(\.dismiss) private var dismiss

    private let quoteService = QuoteService.shared

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Today's quote
                    todaySection

                    // Previous quotes
                    previousSection
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.appBackgroundColor)
            .scrollBounceBehavior(.basedOnSize)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Quote History")
                        .font(.system(.subheadline, design: .serif, weight: .medium))
                        .foregroundStyle(Color.primaryTextColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 32, height: 32)
                            .foregroundStyle(Color.primaryTextColor)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            quoteCard(quoteService.quoteOfTheDay, isToday: true)
        }
    }

    // MARK: - Previous Section

    private var previousSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Previous Days")
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(Color.secondaryTextColor)

            VStack(spacing: 12) {
                ForEach(quoteService.previousQuotes, id: \.date) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.date.formattedShort)
                            .font(.system(size: 11, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.7))

                        quoteCard(item.quote, isToday: false)
                    }
                }
            }
        }
    }

    // MARK: - Quote Card

    private func quoteCard(_ quote: Quote, isToday: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.system(isToday ? .body : .subheadline, design: .serif))
                .italic()
                .foregroundStyle(Color.primaryTextColor)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("— \(quote.author)")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    QuoteHistorySheet()
}
