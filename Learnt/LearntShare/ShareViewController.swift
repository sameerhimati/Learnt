//
//  ShareViewController.swift
//  LearntShare
//
//  SwiftUI-based share extension controller

import UIKit
import SwiftUI

class ShareViewController: UIViewController {

    private let appGroupIdentifier = "group.com.sameer.Learnt"
    private let pendingSharesKey = "PendingShares"  // Array format for multiple shares
    private let categoriesKey = "SharedCategories"

    private var hostingController: UIHostingController<ShareExtensionView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Validate App Group access
        guard UserDefaults(suiteName: appGroupIdentifier) != nil else {
            showError("App Group not configured. Please reinstall the app.")
            return
        }

        // Start loading content
        loadContent()
    }

    private func loadContent() {
        Task {
            // Extract content from attachments
            let extracted = await ContentExtractor.extract(from: extensionContext)

            // Load categories from App Group
            let categories = loadCategories()

            await MainActor.run {
                showShareUI(
                    extractedText: extracted.text,
                    extractedURL: extracted.url,
                    categories: categories
                )
            }
        }
    }

    private func showShareUI(extractedText: String?, extractedURL: String?, categories: [ShareCategory]) {
        let shareView = ShareExtensionView(
            extractedText: extractedText,
            extractedURL: extractedURL,
            categories: categories,
            onSave: { [weak self] content, categoryIDs in
                self?.savePendingShare(text: content, categoryIDs: categoryIDs)
                self?.completeRequest()
            },
            onCancel: { [weak self] in
                self?.cancelRequest()
            }
        )

        let hostingController = UIHostingController(rootView: shareView)
        self.hostingController = hostingController

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.cancelRequest()
        })
        present(alert, animated: true)
    }

    // MARK: - App Group Data

    private func loadCategories() -> [ShareCategory] {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: categoriesKey),
              let categories = try? JSONDecoder().decode([ShareCategory].self, from: data) else {
            // Return preset categories as fallback
            return [
                ShareCategory(id: UUID(), name: "Personal", icon: "person"),
                ShareCategory(id: UUID(), name: "Work", icon: "briefcase"),
                ShareCategory(id: UUID(), name: "Learning", icon: "book"),
                ShareCategory(id: UUID(), name: "Relationships", icon: "heart")
            ]
        }
        return categories
    }

    private func savePendingShare(text: String, categoryIDs: [UUID]) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        // Load existing shares array
        var existingShares: [[String: Any]] = []
        if let data = defaults.data(forKey: pendingSharesKey),
           let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            existingShares = array
        }

        // Create V2 format share with categories
        let share: [String: Any] = [
            "version": 2,
            "text": text,
            "categoryIds": categoryIDs.map { $0.uuidString },
            "timestamp": Date().timeIntervalSince1970
        ]

        // Append to array
        existingShares.append(share)

        // Save array back
        if let encoded = try? JSONSerialization.data(withJSONObject: existingShares) {
            defaults.set(encoded, forKey: pendingSharesKey)
        }
    }

    // MARK: - Extension Lifecycle

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func cancelRequest() {
        extensionContext?.cancelRequest(withError: NSError(domain: "com.sameer.Learnt", code: 0, userInfo: nil))
    }
}
