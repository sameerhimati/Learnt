//
//  StreakService.swift
//  Learnt
//

import Foundation

/// Service for tracking streaks and milestones
@Observable
final class StreakService {
    static let shared = StreakService()

    /// Milestone day counts that trigger celebrations
    static let milestones: [Int] = [3, 7, 14, 30, 60, 90, 180, 365]

    /// UserDefaults key for tracking last celebrated milestone
    private let lastCelebratedKey = "lastCelebratedMilestone"
    private let lastCelebratedDateKey = "lastCelebratedMilestoneDate"

    private init() {}

    // MARK: - Milestone Checking

    /// Check if the given streak count has reached a new milestone
    func checkForNewMilestone(currentStreak: Int) -> Int? {
        let lastCelebrated = UserDefaults.standard.integer(forKey: lastCelebratedKey)
        let lastCelebratedDate = UserDefaults.standard.object(forKey: lastCelebratedDateKey) as? Date

        // Reset if it's been more than a day (streak was broken and rebuilt)
        if let date = lastCelebratedDate, !Calendar.current.isDateInToday(date) && !Calendar.current.isDateInYesterday(date) {
            // Streak was broken, reset celebrations
            if currentStreak < lastCelebrated {
                UserDefaults.standard.set(0, forKey: lastCelebratedKey)
                UserDefaults.standard.removeObject(forKey: lastCelebratedDateKey)
            }
        }

        // Find the highest milestone we've reached
        let reachedMilestones = Self.milestones.filter { $0 <= currentStreak }
        guard let highestReached = reachedMilestones.last else { return nil }

        // Check if we need to celebrate
        if highestReached > lastCelebrated {
            return highestReached
        }

        return nil
    }

    /// Mark a milestone as celebrated
    func markMilestoneCelebrated(_ milestone: Int) {
        UserDefaults.standard.set(milestone, forKey: lastCelebratedKey)
        UserDefaults.standard.set(Date(), forKey: lastCelebratedDateKey)
    }

    /// Get the next milestone to reach
    func nextMilestone(after currentStreak: Int) -> Int? {
        Self.milestones.first { $0 > currentStreak }
    }

    /// Get days remaining until next milestone
    func daysUntilNextMilestone(currentStreak: Int) -> Int? {
        guard let next = nextMilestone(after: currentStreak) else { return nil }
        return next - currentStreak
    }

    // MARK: - Milestone Display Info

    /// Get a celebratory message for a milestone
    func celebrationMessage(for milestone: Int) -> String {
        switch milestone {
        case 3:
            return "You're building momentum!"
        case 7:
            return "One week strong!"
        case 14:
            return "Two weeks of growth!"
        case 30:
            return "A month of learning!"
        case 60:
            return "Two months dedicated!"
        case 90:
            return "A quarter of wisdom!"
        case 180:
            return "Half a year of insights!"
        case 365:
            return "A year of transformation!"
        default:
            return "Amazing progress!"
        }
    }

    /// Get the SF Symbol for a milestone
    func milestoneIcon(for milestone: Int) -> String {
        switch milestone {
        case 3:
            return "flame"
        case 7:
            return "star"
        case 14:
            return "sparkles"
        case 30:
            return "moon.stars"
        case 60:
            return "crown"
        case 90:
            return "trophy"
        case 180:
            return "medal"
        case 365:
            return "laurel.leading"
        default:
            return "flame"
        }
    }
}
