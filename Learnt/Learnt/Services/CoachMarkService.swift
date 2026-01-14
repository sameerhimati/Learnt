//
//  CoachMarkService.swift
//  Learnt
//

import Foundation

@Observable
final class CoachMarkService {
    static let shared = CoachMarkService()

    // MARK: - Coach Mark Keys

    enum Mark: String, CaseIterable {
        case addLearning = "coachMark_addLearning"
        case expandCard = "coachMark_expandCard"
        case navigateDays = "coachMark_navigateDays"
        case reviewDue = "coachMark_reviewDue"
        case yourMonth = "coachMark_yourMonth"
        case reflections = "coachMark_reflections"
    }

    // MARK: - Check & Mark as Seen

    func hasSeenMark(_ mark: Mark) -> Bool {
        UserDefaults.standard.bool(forKey: mark.rawValue)
    }

    func markAsSeen(_ mark: Mark) {
        UserDefaults.standard.set(true, forKey: mark.rawValue)
    }

    func shouldShowMark(_ mark: Mark) -> Bool {
        !hasSeenMark(mark)
    }

    // MARK: - Reset (for testing)

    func resetAllMarks() {
        for mark in Mark.allCases {
            UserDefaults.standard.removeObject(forKey: mark.rawValue)
        }
    }

    private init() {}
}
