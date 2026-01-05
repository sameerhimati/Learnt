//
//  WeekActivityRow.swift
//  Learnt
//

import SwiftUI

struct WeekActivityRow: View {
    let selectedDate: Date
    let datesWithEntries: Set<Date>
    let onDateSelected: (Date) -> Void
    let onWeekChange: (Int) -> Void  // -1 for previous week, +1 for next week

    private let weekDays = Date.weekdaySymbols
    private var weekDates: [Date] {
        selectedDate.weekDays
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(zip(weekDays.indices, weekDays)), id: \.0) { index, dayLabel in
                let date = weekDates[index]
                DayColumn(
                    label: dayLabel,
                    date: date,
                    isSelected: date.isSameDay(as: selectedDate),
                    isToday: date.isToday,
                    hasEntry: datesWithEntries.contains(date.startOfDay),
                    onTap: { onDateSelected(date) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(Rectangle())  // Make entire area tappable/swipeable
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontal = value.translation.width
                    if horizontal > 0 {
                        // Swipe right = previous week
                        onWeekChange(-1)
                    } else if horizontal < 0 {
                        // Swipe left = next week
                        onWeekChange(1)
                    }
                }
        )
    }
}

private struct DayColumn: View {
    let label: String
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEntry: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Day letter with indicators
                ZStack {
                    // Today: Black filled circle (always visible)
                    if isToday {
                        Circle()
                            .fill(Color.primaryTextColor)
                    }
                    // Selected but not today: Grey outline
                    else if isSelected {
                        Circle()
                            .stroke(Color.secondaryTextColor, lineWidth: 1.5)
                    }

                    Text(label)
                        .font(.system(.caption, design: .serif))
                        .fontWeight(isToday ? .semibold : .regular)
                        .foregroundStyle(
                            isToday ? Color.appBackgroundColor :  // White text on black circle
                            isSelected ? Color.primaryTextColor :  // Black text when selected
                            Color.secondaryTextColor               // Grey text otherwise
                        )
                }
                .frame(width: 28, height: 28)

                // Activity dot - only shown if has entry
                Circle()
                    .fill(hasEntry ? Color.primaryTextColor : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        WeekActivityRow(
            selectedDate: Date(),
            datesWithEntries: [Date().startOfDay, Date().yesterday.startOfDay],
            onDateSelected: { _ in },
            onWeekChange: { _ in }
        )

        WeekActivityRow(
            selectedDate: Date().yesterday,
            datesWithEntries: [Date().startOfDay],
            onDateSelected: { _ in },
            onWeekChange: { _ in }
        )
    }
    .padding()
    .background(Color.appBackgroundColor)
}
