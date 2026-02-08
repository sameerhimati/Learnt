//
//  OnboardingProgressService.swift
//  Learnt
//

import Foundation

@Observable
final class OnboardingProgressService {
    static let shared = OnboardingProgressService()

    // MARK: - Milestones

    enum Milestone: String, CaseIterable {
        case firstEntry = "milestone_firstEntry"
        case firstReflection = "milestone_firstReflection"
        case firstReviewSeen = "milestone_firstReviewSeen"
        case firstGraduation = "milestone_firstGraduation"
        case notificationPromptShown = "milestone_notificationPrompt"
    }

    // MARK: - First Session Flag

    private static let isFirstSessionKey = "onboarding_isFirstSession"

    var isFirstSession: Bool {
        get { UserDefaults.standard.bool(forKey: Self.isFirstSessionKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.isFirstSessionKey) }
    }

    // MARK: - Milestone Tracking

    func hasReached(_ milestone: Milestone) -> Bool {
        UserDefaults.standard.bool(forKey: milestone.rawValue)
    }

    func reach(_ milestone: Milestone) {
        guard !hasReached(milestone) else { return }
        UserDefaults.standard.set(true, forKey: milestone.rawValue)
    }

    // MARK: - Convenience Checks

    /// Whether the user has ever created an entry
    var hasCreatedFirstEntry: Bool { hasReached(.firstEntry) }

    /// Whether the user has ever added a reflection
    var hasAddedFirstReflection: Bool { hasReached(.firstReflection) }

    /// Whether the user has seen the review tab with due items
    var hasSeenFirstReview: Bool { hasReached(.firstReviewSeen) }

    /// Whether the user has experienced graduation
    var hasSeenFirstGraduation: Bool { hasReached(.firstGraduation) }

    /// Whether we've already prompted for notifications
    var hasPromptedNotifications: Bool { hasReached(.notificationPromptShown) }

    // MARK: - Reset (for testing)

    func resetAll() {
        for milestone in Milestone.allCases {
            UserDefaults.standard.removeObject(forKey: milestone.rawValue)
        }
        UserDefaults.standard.removeObject(forKey: Self.isFirstSessionKey)
    }

    private init() {}
}
