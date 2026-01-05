//
//  InsightsView.swift
//  Learnt
//

import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \LearningEntry.date, order: .reverse) private var entries: [LearningEntry]

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    entriesList
                }
            }
            .background(Color.appBackgroundColor)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No learnings yet")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
            Text("Your insights will appear here")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
            Spacer()
        }
    }

    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groupedEntries, id: \.0) { date, dayEntries in
                    Section {
                        ForEach(dayEntries) { entry in
                            entryRow(entry)
                        }
                    } header: {
                        Text(date.formattedFull)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.primaryTextColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    private func entryRow(_ entry: LearningEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.content)
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)
                .lineLimit(3)

            Text(entry.createdAt, style: .time)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var groupedEntries: [(Date, [LearningEntry])] {
        let grouped = Dictionary(grouping: entries) { $0.date.startOfDay }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.createdAt > $1.createdAt }) }
            .sorted { $0.0 > $1.0 }
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: LearningEntry.self, inMemory: true)
}
