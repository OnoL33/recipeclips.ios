//
//  RecipeClipApp.swift
//  RecipeClip
//

import SwiftUI
import SwiftData

@main
struct RecipeClipApp: App {

    let appGroupID = "group.com.onolee.RecipeClip"

    @State private var pendingURL: String = ""
    @State private var pendingText: String = ""
    @State private var showImportFromShare: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView(
                pendingURL: $pendingURL,
                pendingText: $pendingText,
                showImportFromShare: $showImportFromShare
            )
            .onOpenURL { url in
                print("🔗 onOpenURL fired: \(url.absoluteString)")
                handleIncomingURL(url)
            }
            // This fires every time the app comes to the foreground
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification)
            ) { _ in
                print("📱 App became active — checking for pending import")
                checkForPendingImport()
            }
        }
        .modelContainer(for: Recipe.self)
    }

    // ─────────────────────────────────────────────────────────
    // Check App Group storage every time app becomes active
    // This catches the case where onOpenURL doesn't fire
    // ─────────────────────────────────────────────────────────
    func checkForPendingImport() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Could not open App Group: \(appGroupID)")
            return
        }

        let hasPending = defaults.bool(forKey: "hasPendingImport")
        print("📦 hasPendingImport: \(hasPending)")

        guard hasPending else { return }

        let savedURL  = defaults.string(forKey: "pendingURL")  ?? ""
        let savedText = defaults.string(forKey: "pendingText") ?? ""

        print("✅ Found pending import — URL: \(savedURL)")

        // Clear immediately so it doesn't trigger again
        defaults.set(false, forKey: "hasPendingImport")
        defaults.removeObject(forKey: "pendingURL")
        defaults.removeObject(forKey: "pendingText")
        defaults.synchronize()

        // Small delay to let the app finish launching before showing the sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pendingURL          = savedURL
            pendingText         = savedText
            showImportFromShare = true
        }
    }

    // ─────────────────────────────────────────────────────────
    // Also handle direct URL scheme (backup)
    // ─────────────────────────────────────────────────────────
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "recipeclip" else { return }
        print("🔗 onOpenURL fired: \(url.absoluteString)")

        // First check App Group storage
        checkForPendingImport()

        // Also try reading URL from query parameter directly
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let urlParam = components.queryItems?.first(where: { $0.name == "url" })?.value,
           !urlParam.isEmpty,
           !showImportFromShare {
            print("✅ URL from query param: \(urlParam)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                pendingURL          = urlParam
                pendingText         = ""
                showImportFromShare = true
            }
        }
    }
}
