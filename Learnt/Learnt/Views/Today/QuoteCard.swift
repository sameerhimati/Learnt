//
//  QuoteCard.swift
//  Learnt

import SwiftUI

struct QuoteCard: View {
    let quote: Quote
    let onAddToEntry: (String) -> Void
    let onHide: () -> Void

    @State private var showHistory = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quote icon + label
            HStack(spacing: 6) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.6))

                Text("Today's thought")
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            // Quote text
            Text(quote.text)
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(Color.primaryTextColor)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Author and actions
            HStack {
                Text("— \(quote.author)")
                    .font(.system(size: 13, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                Spacer()

                HStack(spacing: 16) {
                    // Hide button
                    Button(action: onHide) {
                        Text("Hide")
                            .font(.system(size: 12, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                    }
                    .buttonStyle(.plain)

                    // Add to entry button
                    Button(action: { onAddToEntry(formatQuoteAsEntry()) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .medium))
                            Text("Save")
                                .font(.system(size: 12, weight: .medium, design: .serif))
                        }
                        .foregroundStyle(Color.primaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.dividerColor, lineWidth: 1)
                )
        )
        .onTapGesture {
            showHistory = true
        }
        .sheet(isPresented: $showHistory) {
            QuoteHistorySheet()
        }
    }

    private func formatQuoteAsEntry() -> String {
        "\"\(quote.text)\" — \(quote.author)"
    }
}

#Preview {
    VStack(spacing: 16) {
        QuoteCard(
            quote: Quote(text: "The obstacle is the way.", author: "Marcus Aurelius"),
            onAddToEntry: { _ in },
            onHide: {}
        )

        QuoteCard(
            quote: Quote(
                text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
                author: "Aristotle"
            ),
            onAddToEntry: { _ in },
            onHide: {}
        )
    }
    .padding()
    .background(Color.appBackgroundColor)
}
