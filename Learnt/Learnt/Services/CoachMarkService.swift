//
//  CoachMarkService.swift
//  Learnt
//

import Foundation

extension Notification.Name {
    static let coachMarkDismissed = Notification.Name("coachMarkDismissed")
}

@Observable
final class CoachMarkService {
    static let shared = CoachMarkService()

    // MARK: - Coach Mark Keys
    // Only keep marks that are NOT self-evident.
    // Removed: addLearning (entry bar is obvious), expandCard (chevron is sufficient),
    //          navigateDays (arrows are universal), reflections (handled by inline nudge)

    enum Mark: String, CaseIterable, Hashable {
        case reviewDue = "coachMark_reviewDue"
        case reflectionStartsReview = "coachMark_reflectionStartsReview"

        var prerequisites: [Mark] {
            []  // Milestone-based now, no prerequisite chains
        }
    }

    // MARK: - Check & Mark as Seen

    func hasSeenMark(_ mark: Mark) -> Bool {
        UserDefaults.standard.bool(forKey: mark.rawValue)
    }

    func markAsSeen(_ mark: Mark) {
        UserDefaults.standard.set(true, forKey: mark.rawValue)
        NotificationCenter.default.post(name: .coachMarkDismissed, object: mark)
    }

    func shouldShowMark(_ mark: Mark) -> Bool {
        guard !hasSeenMark(mark) else { return false }

        for prerequisite in mark.prerequisites {
            if !hasSeenMark(prerequisite) {
                return false
            }
        }

        return true
    }

    // MARK: - Reset (for testing)

    func resetAllMarks() {
        for mark in Mark.allCases {
            UserDefaults.standard.removeObject(forKey: mark.rawValue)
        }
    }

    private init() {}
}
