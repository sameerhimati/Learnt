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

    enum Mark: String, CaseIterable, Hashable {
        case addLearning = "coachMark_addLearning"
        case expandCard = "coachMark_expandCard"
        case navigateDays = "coachMark_navigateDays"
        case reviewDue = "coachMark_reviewDue"
        case reflections = "coachMark_reflections"

        /// Marks that must be seen before this one can show
        var prerequisites: [Mark] {
            switch self {
            case .expandCard:
                return [.navigateDays]  // Show after "Browse Your History"
            case .addLearning:
                return [.navigateDays]  // Show after "Browse Your History"
            default:
                return []
            }
        }
    }

    // MARK: - Check & Mark as Seen

    func hasSeenMark(_ mark: Mark) -> Bool {
        UserDefaults.standard.bool(forKey: mark.rawValue)
    }

    func markAsSeen(_ mark: Mark) {
        UserDefaults.standard.set(true, forKey: mark.rawValue)
        // Notify that a mark was dismissed so dependent marks can check
        NotificationCenter.default.post(name: .coachMarkDismissed, object: mark)
    }

    func shouldShowMark(_ mark: Mark) -> Bool {
        // Don't show if already seen
        guard !hasSeenMark(mark) else { return false }

        // Check if all prerequisites have been seen
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
