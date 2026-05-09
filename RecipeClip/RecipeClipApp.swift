//
//  RecipeClipApp.swift
//  RecipeClip
//
//  This is the app entry point. It sets up SwiftData storage.
//

import SwiftUI
import SwiftData

@main
struct RecipeClipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // This line sets up the SwiftData database for our Recipe model
        .modelContainer(for: Recipe.self)
    }
}
