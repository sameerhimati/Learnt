//
//  Date+Extensions.swift
//  Learnt
//

import Foundation

extension Date {
    // MARK: - Day Operations

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isFuture: Bool {
        self.startOfDay > Date().startOfDay
    }

    // MARK: - Week Operations (Monday start)

    var startOfWeek: Date {
        let calendar = Calendar.current
        // Get weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
        let weekday = calendar.component(.weekday, from: self)
        // Calculate days to subtract to get to Monday
        // Sunday(1) -> subtract 6, Monday(2) -> subtract 0, Tuesday(3) -> subtract 1, etc.
        let daysToSubtract = weekday == 1 ? 6 : weekday - 2
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfDay) ?? startOfDay
    }

    var endOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)!
    }

    var weekDays: [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    var dayOfWeekIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: self)
        // Convert Sunday=1...Saturday=7 to Monday=0...Sunday=6
        return weekday == 1 ? 6 : weekday - 2
    }

    // MARK: - Month Operations

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 30
    }

    var firstWeekdayOfMonth: Int {
        // Get the weekday of the first day of the month (1=Sun, 2=Mon, ..., 7=Sat)
        let weekday = Calendar.current.component(.weekday, from: startOfMonth)
        // Convert to Monday-first index (Mon=0, Tue=1, ..., Sun=6)
        // Sunday (1) -> 6, Monday (2) -> 0, Tuesday (3) -> 1, etc.
        let mondayFirstIndex = (weekday + 5) % 7
        return mondayFirstIndex
    }

    // MARK: - Navigation

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    var yesterday: Date {
        adding(days: -1)
    }

    var tomorrow: Date {
        adding(days: 1)
    }

    // MARK: - Formatting

    var formattedFull: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: self)
    }

    var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }

    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    static var weekdaySymbols: [String] {
        // Monday-first ordering
        ["M", "T", "W", "T", "F", "S", "S"]
    }
}
