//
//  CoachMarkView.swift
//  Learnt
//

import SwiftUI

enum CoachMarkArrowDirection: Equatable {
    case up, down, left, right, none
}

// MARK: - Coach Mark View

struct CoachMarkView: View {
    let title: String
    let message: String
    let arrowDirection: CoachMarkArrowDirection
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    // Use consistent colors regardless of system theme - always dark bubble
    private var bubbleBackground: Color {
        Color(hex: "1A1A1A")
    }

    private var bubbleText: Color {
        Color(hex: "FAFAFA")
    }

    private var buttonBackground: Color {
        Color(hex: "FAFAFA")
    }

    private var buttonText: Color {
        Color(hex: "1A1A1A")
    }

    // Border color for visibility on dark backgrounds
    private var borderColor: Color {
        Color(hex: "3A3A3A")
    }

    var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .up {
                arrowWithBorder
                    .rotationEffect(.degrees(0))
                    .padding(.bottom, -1)
            }

            HStack {
                if arrowDirection == .left {
                    arrowWithBorder
                        .rotationEffect(.degrees(-90))
                        .padding(.trailing, -1)
                }

                content

                if arrowDirection == .right {
                    arrowWithBorder
                        .rotationEffect(.degrees(90))
                        .padding(.leading, -1)
                }
            }

            if arrowDirection == .down {
                arrowWithBorder
                    .rotationEffect(.degrees(180))
                    .padding(.top, -1)
            }
        }
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 8)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.body, design: .serif, weight: .semibold))
                .foregroundStyle(bubbleText)
                .fixedSize(horizontal: false, vertical: true)

            Text(message)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(bubbleText.opacity(0.9))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onDismiss) {
                Text("Got it")
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(buttonText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(buttonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(20)
        .frame(minWidth: 260, maxWidth: 300)
        .background(bubbleBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    private var arrow: some View {
        Triangle()
            .fill(bubbleBackground)
            .frame(width: 16, height: 10)
    }

    private var arrowWithBorder: some View {
        Triangle()
            .fill(bubbleBackground)
            .overlay(
                Triangle()
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .frame(width: 20, height: 12)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Global Coach Mark Coordinator

@Observable
final class CoachMarkCoordinator {
    static let shared = CoachMarkCoordinator()

    var currentMark: CoachMarkService.Mark?
    var isShowingOverlay = false

    private init() {}

    func showMark(_ mark: CoachMarkService.Mark) {
        guard CoachMarkService.shared.shouldShowMark(mark) else { return }
        withAnimation(.easeOut(duration: 0.3)) {
            currentMark = mark
            isShowingOverlay = true
        }
    }

    func dismissCurrent() {
        guard let mark = currentMark else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            isShowingOverlay = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            CoachMarkService.shared.markAsSeen(mark)
            self.currentMark = nil
        }
    }
}

// MARK: - Coach Mark Registration (marks a view as a coach mark target)

struct CoachMarkTargetModifier: ViewModifier {
    let mark: CoachMarkService.Mark
    let title: String
    let message: String
    let arrowDirection: CoachMarkArrowDirection

    @State private var hasTriggered = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                // Delay to ensure view is laid out
                guard !hasTriggered else { return }
                hasTriggered = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if CoachMarkService.shared.shouldShowMark(mark) {
                        CoachMarkCoordinator.shared.showMark(mark)
                    }
                }
            }
    }
}

// MARK: - Global Coach Mark Overlay

struct GlobalCoachMarkOverlay: View {
    @State private var coordinator = CoachMarkCoordinator.shared
    private let coachService = CoachMarkService.shared

    var body: some View {
        ZStack {
            if coordinator.isShowingOverlay, let mark = coordinator.currentMark {
                // Full screen dimming
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        coordinator.dismissCurrent()
                    }
                    .transition(.opacity)

                // Coach mark centered
                VStack {
                    Spacer()

                    CoachMarkView(
                        title: titleFor(mark),
                        message: messageFor(mark),
                        arrowDirection: arrowFor(mark),
                        onDismiss: {
                            coordinator.dismissCurrent()
                        }
                    )
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: coordinator.isShowingOverlay)
        .onReceive(NotificationCenter.default.publisher(for: .coachMarkDismissed)) { _ in
            // When a mark is dismissed, check if another should show
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                checkForNextMark()
            }
        }
    }

    private func checkForNextMark() {
        // This will be triggered by individual view modifiers
    }

    private func titleFor(_ mark: CoachMarkService.Mark) -> String {
        switch mark {
        case .addLearning: return "Add a Learning"
        case .expandCard: return "Tap to Expand"
        case .navigateDays: return "Browse Your History"
        case .reviewDue: return "Spaced Repetition"
        case .reflections: return "Add Reflections"
        }
    }

    private func messageFor(_ mark: CoachMarkService.Mark) -> String {
        switch mark {
        case .addLearning: return "Tap here to capture something you learned today. Use voice or text."
        case .expandCard: return "Tap any card to see details, edit, or add reflections."
        case .navigateDays: return "Swipe left or right to see previous days, or tap the calendar icon."
        case .reviewDue: return "Review learnings at optimal intervals to move them into long-term memory."
        case .reflections: return "Add notes about how to apply what you learned or questions that arose."
        }
    }

    private func arrowFor(_ mark: CoachMarkService.Mark) -> CoachMarkArrowDirection {
        switch mark {
        case .navigateDays: return .none
        default: return .none  // Centered overlay doesn't need arrows
        }
    }
}

// MARK: - View Extension

extension View {
    func coachMark(
        _ mark: CoachMarkService.Mark,
        title: String,
        message: String,
        arrowDirection: CoachMarkArrowDirection = .up,
        alignment: Alignment = .bottom,
        offset: CGSize = .zero
    ) -> some View {
        modifier(CoachMarkTargetModifier(
            mark: mark,
            title: title,
            message: message,
            arrowDirection: arrowDirection
        ))
    }

    func withCoachMarks() -> some View {
        self.overlay {
            GlobalCoachMarkOverlay()
        }
    }
}

#Preview {
    ZStack {
        Color.appBackgroundColor
            .ignoresSafeArea()

        VStack(spacing: 40) {
            CoachMarkView(
                title: "Add a Learning",
                message: "Tap here to capture something you learned today.",
                arrowDirection: .down,
                onDismiss: {}
            )

            CoachMarkView(
                title: "Expand to See More",
                message: "Tap any card to see details, add reflections, or share.",
                arrowDirection: .up,
                onDismiss: {}
            )

            CoachMarkView(
                title: "Navigate Days",
                message: "Swipe left or right to browse your past learnings.",
                arrowDirection: .none,
                onDismiss: {}
            )
        }
        .padding()
    }
}
