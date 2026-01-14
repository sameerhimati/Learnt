//
//  CoachMarkView.swift
//  Learnt
//

import SwiftUI

enum CoachMarkArrowDirection {
    case up, down, left, right, none
}

struct CoachMarkView: View {
    let title: String
    let message: String
    let arrowDirection: CoachMarkArrowDirection
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .up {
                arrow
                    .rotationEffect(.degrees(0))
                    .padding(.bottom, -1)
            }

            HStack {
                if arrowDirection == .left {
                    arrow
                        .rotationEffect(.degrees(-90))
                        .padding(.trailing, -1)
                }

                content

                if arrowDirection == .right {
                    arrow
                        .rotationEffect(.degrees(90))
                        .padding(.leading, -1)
                }
            }

            if arrowDirection == .down {
                arrow
                    .rotationEffect(.degrees(180))
                    .padding(.top, -1)
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.subheadline, design: .serif, weight: .semibold))
                .foregroundStyle(Color.appBackgroundColor)

            Text(message)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(Color.appBackgroundColor.opacity(0.9))
                .lineSpacing(2)

            Button(action: onDismiss) {
                Text("Got it")
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundStyle(Color.primaryTextColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.primaryTextColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var arrow: some View {
        Triangle()
            .fill(Color.primaryTextColor)
            .frame(width: 16, height: 10)
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

// MARK: - Coach Mark Overlay Modifier

struct CoachMarkOverlay: ViewModifier {
    let mark: CoachMarkService.Mark
    let title: String
    let message: String
    let arrowDirection: CoachMarkArrowDirection
    let alignment: Alignment
    let offset: CGSize

    @State private var isVisible = false
    private let coachService = CoachMarkService.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if isVisible {
                    CoachMarkView(
                        title: title,
                        message: message,
                        arrowDirection: arrowDirection,
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                coachService.markAsSeen(mark)
                                isVisible = false
                            }
                        }
                    )
                    .offset(offset)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(1000)
                }
            }
            .onAppear {
                // Delay slightly so the view is fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if coachService.shouldShowMark(mark) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isVisible = true
                        }
                    }
                }
            }
    }
}

extension View {
    func coachMark(
        _ mark: CoachMarkService.Mark,
        title: String,
        message: String,
        arrowDirection: CoachMarkArrowDirection = .up,
        alignment: Alignment = .bottom,
        offset: CGSize = .zero
    ) -> some View {
        modifier(CoachMarkOverlay(
            mark: mark,
            title: title,
            message: message,
            arrowDirection: arrowDirection,
            alignment: alignment,
            offset: offset
        ))
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
