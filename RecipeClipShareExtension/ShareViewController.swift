//
//  ShareViewController.swift
//  RecipeClipShareExtension
//

import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    // ⚠️ MUST match exactly what's in Signing & Capabilities and RecipeClipApp.swift
    let appGroupID   = "group.com.onolee.RecipeClip"
    let appURLScheme = "recipeclip"

    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedContent()
    }

    func extractSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            cancelWithError("No items shared.")
            return
        }

        var foundURL  = ""
        var foundText = ""
        let group = DispatchGroup()

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            for attachment in attachments {

                // Try to get a URL
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { data, _ in
                        defer { group.leave() }
                        if let url = data as? URL {
                            foundURL = url.absoluteString
                        }
                    }
                }

                // Try to get plain text
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                        defer { group.leave() }
                        if let text = data as? String {
                            if text.hasPrefix("http") && foundURL.isEmpty {
                                foundURL = text
                            } else {
                                foundText = text
                            }
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            self.saveAndOpenApp(url: foundURL, text: foundText)
        }
    }

    func saveAndOpenApp(url: String, text: String) {
        // Save to App Group shared storage
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            // App Group not working — open app anyway with URL encoded in the scheme
            openAppDirectly(url: url)
            return
        }

        defaults.set(url,  forKey: "pendingURL")
        defaults.set(text, forKey: "pendingText")
        defaults.set(true, forKey: "hasPendingImport")

        // Open the main app
        openAppDirectly(url: url)
    }

    func openAppDirectly(url: String) {
        // Encode the URL directly in the scheme as a fallback
        // so even if App Group fails, the URL still gets through
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let appURLString = "\(appURLScheme)://import?url=\(encodedURL)"

        guard let appURL = URL(string: appURLString) else {
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        // Open the main app
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(appURL, options: [:], completionHandler: nil)
                break
            }
            responder = responder?.next
        }

        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    func cancelWithError(_ message: String) {
        extensionContext?.cancelRequest(withError: NSError(
            domain: "RecipeClipShareExtension",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: message]
        ))
    }
}
