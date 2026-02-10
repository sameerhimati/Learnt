//
//  QuoteCard.swift
//  Learnt

import SwiftUI

struct QuoteCard: View {
    let quote: Quote
    let onHide: () -> Void

    @State private var showHistory = false
    @State private var showCopied = false

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

                    // Copy to clipboard
                    Button(action: copyQuote) {
                        HStack(spacing: 4) {
                            Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 11, weight: .medium))
                            if showCopied {
                                Text("Copied")
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                            }
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

    private func copyQuote() {
        let formatted = "\"\(quote.text)\" — \(quote.author)"
        UIPasteboard.general.string = formatted
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopied = false
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        QuoteCard(
            quote: Quote(text: "The obstacle is the way.", author: "Marcus Aurelius"),
            onHide: {}
        )

        QuoteCard(
            quote: Quote(
                text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
                author: "Aristotle"
            ),
            onHide: {}
        )
    }
    .padding()
    .background(Color.appBackgroundColor)
}
