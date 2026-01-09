//
//  ShareImageService.swift
//  Learnt
//

import SwiftUI
import UIKit

@MainActor
final class ShareImageService {
    static let shared = ShareImageService()

    private init() {}

    /// Renders a SwiftUI view to a UIImage for sharing
    @MainActor
    func renderToImage<V: View>(_ view: V, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    /// Standard Instagram Story size (1080x1920)
    static let storySize = CGSize(width: 1080, height: 1920)

    /// Square post size (1080x1080)
    static let squareSize = CGSize(width: 1080, height: 1080)

    /// Compact card size for sharing single entries
    static let cardSize = CGSize(width: 1080, height: 1350)

    /// Shares an image using the system share sheet
    func shareImage(_ image: UIImage, from viewController: UIViewController? = nil) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        if let vc = viewController ?? topViewController() {
            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = vc.view
                popover.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            vc.present(activityVC, animated: true)
        }
    }

    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var topVC = window.rootViewController else {
            return nil
        }

        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        return topVC
    }
}
