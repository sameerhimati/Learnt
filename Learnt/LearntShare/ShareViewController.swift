//
//  ShareViewController.swift
//  LearntShare
//
//  Created by Sameer Himati on 1/26/26.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    private let appGroupIdentifier = "group.com.sameer.Learnt"
    private let pendingShareKey = "PendingSharedContent"

    private var sharedText: String?
    private var sharedURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        placeholder = "Add a note..."
        extractSharedContent()
    }

    override func isContentValid() -> Bool {
        return sharedText != nil || sharedURL != nil || !contentText.isEmpty
    }

    override func didSelectPost() {
        var finalContent = contentText ?? ""

        if let text = sharedText, !text.isEmpty {
            if !finalContent.isEmpty {
                finalContent += "\n\n"
            }
            finalContent += text
        }

        savePendingShare(text: finalContent, url: sharedURL)
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }

    private func extractSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] item, _ in
                        if let url = item as? URL {
                            DispatchQueue.main.async {
                                self?.sharedURL = url.absoluteString
                                self?.validateContent()
                            }
                        }
                    }
                }

                if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, _ in
                        if let text = item as? String {
                            DispatchQueue.main.async {
                                self?.sharedText = text
                                self?.validateContent()
                            }
                        }
                    }
                }
            }
        }
    }

    private func savePendingShare(text: String, url: String?) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        let share: [String: Any] = [
            "text": text,
            "url": url as Any,
            "timestamp": Date().timeIntervalSince1970
        ]

        if let encoded = try? JSONSerialization.data(withJSONObject: share) {
            defaults.set(encoded, forKey: pendingShareKey)
        }
    }
}
