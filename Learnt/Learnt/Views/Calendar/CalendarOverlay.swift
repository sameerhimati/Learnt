//
//  CalendarOverlay.swift
//  Learnt
//

import SwiftUI

struct CalendarOverlay: View {
    let selectedDate: Date
    let datesWithEntries: Set<Date>
    let onDateSelected: (Date) -> Void
    let onDismiss: () -> Void

    @State private var displayedMonth: Date

    init(
        selectedDate: Date,
        datesWithEntries: Set<Date>,
        onDateSelected: @escaping (Date) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.selectedDate = selectedDate
        self.datesWithEntries = datesWithEntries
        self.onDateSelected = onDateSelected
        self.onDismiss = onDismiss
        self._displayedMonth = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current displayed month
                    MonthView(
                        month: displayedMonth,
                        selectedDate: selectedDate,
                        datesWithEntries: datesWithEntries,
                        onDateSelected: onDateSelected
                    )

                    // Next month below
                    MonthView(
                        month: displayedMonth.adding(months: 1),
                        selectedDate: selectedDate,
                        datesWithEntries: datesWithEntries,
                        onDateSelected: onDateSelected
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(Color.appBackgroundColor)
            .navigationTitle(displayedMonth.formattedMonthYear)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { displayedMonth = displayedMonth.adding(months: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.primaryTextColor)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        // Allow navigating up to 1 year into the future
                        let maxFutureMonth = Date().adding(months: 12).startOfMonth
                        Button(action: {
                            displayedMonth = displayedMonth.adding(months: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(
                                    displayedMonth.adding(months: 1).startOfMonth <= maxFutureMonth
                                    ? Color.primaryTextColor
                                    : Color.secondaryTextColor
                                )
                        }
                        .disabled(displayedMonth.adding(months: 1).startOfMonth > maxFutureMonth)

                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.primaryTextColor)
                        }
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Month View

private struct MonthView: View {
    let month: Date
    let selectedDate: Date
    let datesWithEntries: Set<Date>
    let onDateSelected: (Date) -> Void
    var showHeader: Bool = true

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    // Get the first day of month and its weekday offset
    private var firstOfMonth: Date {
        month.startOfMonth
    }

    private var weekdayOffset: Int {
        // Get weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
        let weekday = Calendar.current.component(.weekday, from: firstOfMonth)
        // Convert to Monday-first: Mon=0, Tue=1, ..., Sun=6
        return (weekday + 5) % 7
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month header (optional - hidden for first month since nav shows it)
            if showHeader {
                Text(month.formattedMonthYear)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(Array(Date.weekdaySymbols.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            LazyVGrid(columns: columns, spacing: 8) {
                // Empty cells for days before month starts (use negative IDs to avoid collision)
                ForEach(0..<weekdayOffset, id: \.self) { index in
                    Color.clear
                        .frame(height: 40)
                        .id("empty-\(month.formattedMonthYear)-\(index)")
                }

                // Actual days
                ForEach(1...month.daysInMonth, id: \.self) { day in
                    let date = Calendar.current.date(
                        from: DateComponents(
                            year: Calendar.current.component(.year, from: firstOfMonth),
                            month: Calendar.current.component(.month, from: firstOfMonth),
                            day: day
                        )
                    ) ?? firstOfMonth

                    DayCell(
                        day: day,
                        date: date,
                        isSelected: date.isSameDay(as: selectedDate),
                        isToday: date.isToday,
                        isFuture: date.isFuture,
                        hasEntry: datesWithEntries.contains(date.startOfDay),
                        onTap: { onDateSelected(date) }
                    )
                    .id("day-\(month.formattedMonthYear)-\(day)")
                }
            }
        }
    }
}

// MARK: - Day Cell

private struct DayCell: View {
    let day: Int
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isFuture: Bool
    let hasEntry: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(.body, design: .serif))
                    .fontWeight(isToday ? .semibold : .regular)
                    .foregroundStyle(
                        isFuture ? Color.secondaryTextColor.opacity(0.5) :
                        isToday ? Color.appBackgroundColor :  // White text on black circle
                        Color.primaryTextColor
                    )

                // Activity dot
                Circle()
                    .fill(hasEntry ? (isToday ? Color.appBackgroundColor : Color.primaryTextColor) : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 40, height: 40)
            .background(
                // Today: Always black filled
                isToday ? Color.primaryTextColor :
                // Selected (not today): Grey outline
                isSelected ? Color.clear :
                Color.clear
            )
            .overlay(
                // Selected (not today): Grey stroke outline
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected && !isToday ? Color.secondaryTextColor : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
}

#Preview {
    CalendarOverlay(
        selectedDate: Date(),
        datesWithEntries: [
            Date().startOfDay,
            Date().yesterday.startOfDay,
            Date().adding(days: -3).startOfDay
        ],
        onDateSelected: { _ in },
        onDismiss: {}
    )
}
