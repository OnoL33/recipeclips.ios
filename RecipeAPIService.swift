//
//  RecipeAPIService.swift
//  RecipeClip
//
//  This service sends a recipe URL to our backend and gets back a structured recipe.
//  Part 3 will fill this in fully — for now it returns a fake recipe for testing.
//

import Foundation

// This struct matches the JSON our backend will return
struct RecipeAPIResponse: Codable {
    var title: String
    var collectionName: String
    var sourceURL: String
    var sourcePlatform: String
    var creatorName: String
    var baseServings: Int
    var currentServings: Int
    var cookingTimeMinutes: Int
    var ingredients: [IngredientItem]
    var instructions: [String]
    var notes: String
    var uncertaintyNotes: [String]
    var tags: [String]
}

struct IngredientItem: Codable {
    var amount: Double
    var unit: String
    var name: String
    var originalText: String
}

class RecipeAPIService {
    // The URL of your backend server
    // When running on iPhone Simulator, use localhost
    // When running on a real iPhone, use your Mac's local IP address (e.g. 192.168.1.x)
    static let backendURL = "http://localhost:3000/analyze-recipe"

    /// Send a URL/text to the backend and get back a RecipeDraft.
    /// In Part 1, this returns a placeholder so we can test the UI.
    static func analyzeRecipe(
        sourceURL: String,
        sharedText: String,
        collectionName: String
    ) async throws -> RecipeDraft {

        // ⚠️ PLACEHOLDER: In Part 3 we'll connect to the real backend.
        // For now, simulate a delay and return a fake recipe.
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay

        // Return a fake recipe draft for testing the UI
        var draft = RecipeDraft()
        draft.title = "Test Recipe from URL"
        draft.collectionName = collectionName.isEmpty ? "My Recipes" : collectionName
        draft.sourceURL = sourceURL
        draft.sourcePlatform = sourceURL.contains("tiktok") ? "TikTok" : "Instagram"
        draft.creatorName = ""
        draft.baseServings = 2
        draft.currentServings = 2
        draft.cookingTimeMinutes = 15
        draft.ingredientsText = "200 g pasta\n150 ml cream\n2 garlic cloves\n1 tbsp olive oil\nsalt to taste"
        draft.instructionsText = "Cook the pasta.\nFry garlic in olive oil.\nAdd cream and simmer.\nMix with pasta and serve."
        draft.notes = "This is a placeholder recipe — connect the backend in Part 3."
        draft.uncertaintyNotes = "Amount of cream was estimated."
        draft.tagsText = "Test,Placeholder"
        return draft
    }

    /// Convert a RecipeAPIResponse into a RecipeDraft
    static func toDraft(_ response: RecipeAPIResponse) -> RecipeDraft {
        var draft = RecipeDraft()
        draft.title = response.title
        draft.collectionName = response.collectionName
        draft.sourceURL = response.sourceURL
        draft.sourcePlatform = response.sourcePlatform
        draft.creatorName = response.creatorName
        draft.baseServings = response.baseServings
        draft.currentServings = response.currentServings
        draft.cookingTimeMinutes = response.cookingTimeMinutes

        // Convert ingredient array to multiline text
        draft.ingredientsText = response.ingredients
            .map { $0.originalText }
            .joined(separator: "\n")

        // Convert instruction array to multiline text
        draft.instructionsText = response.instructions.joined(separator: "\n")

        draft.notes = response.notes
        draft.uncertaintyNotes = response.uncertaintyNotes.joined(separator: "\n")
        draft.tagsText = response.tags.joined(separator: ",")
        return draft
    }
}
