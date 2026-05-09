//
//  Recipe.swift
//  RecipeClip
//
//  This is the SwiftData model for a saved recipe.
//  SwiftData automatically creates a database table based on this class.
//

import Foundation
import SwiftData

@Model
final class Recipe {
    // Basic info
    var title: String
    var collectionName: String   // e.g. "Dinner Ideas"
    var sourceURL: String        // The original Instagram/TikTok link
    var sourcePlatform: String   // "Instagram", "TikTok", etc.
    var creatorName: String      // The creator's name if known

    // Cooking info
    var baseServings: Int        // The original number of servings from the recipe
    var currentServings: Int     // What the user has adjusted it to
    var cookingTimeMinutes: Int  // How long it takes to cook

    // Content stored as plain text (one item per line)
    var ingredientsText: String   // e.g. "200 g pasta\n150 ml cream"
    var instructionsText: String  // e.g. "Step 1\nStep 2"
    var notes: String             // Extra tips from the recipe
    var uncertaintyNotes: String  // Things the AI wasn't sure about
    var tagsText: String          // e.g. "Dinner,Quick,Vegetarian"

    // Metadata
    var createdAt: Date

    init(
        title: String = "",
        collectionName: String = "",
        sourceURL: String = "",
        sourcePlatform: String = "",
        creatorName: String = "",
        baseServings: Int = 2,
        currentServings: Int = 2,
        cookingTimeMinutes: Int = 0,
        ingredientsText: String = "",
        instructionsText: String = "",
        notes: String = "",
        uncertaintyNotes: String = "",
        tagsText: String = "",
        createdAt: Date = Date()
    ) {
        self.title = title
        self.collectionName = collectionName
        self.sourceURL = sourceURL
        self.sourcePlatform = sourcePlatform
        self.creatorName = creatorName
        self.baseServings = baseServings
        self.currentServings = currentServings
        self.cookingTimeMinutes = cookingTimeMinutes
        self.ingredientsText = ingredientsText
        self.instructionsText = instructionsText
        self.notes = notes
        self.uncertaintyNotes = uncertaintyNotes
        self.tagsText = tagsText
        self.createdAt = createdAt
    }

    // Helper: get ingredients as an array of strings
    var ingredientsArray: [String] {
        ingredientsText.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    // Helper: get instructions as an array of strings
    var instructionsArray: [String] {
        instructionsText.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    // Helper: get tags as an array of strings
    var tagsArray: [String] {
        tagsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    // Helper: emoji icon for the source platform
    var platformIcon: String {
        switch sourcePlatform.lowercased() {
        case "instagram": return "📷"
        case "tiktok":    return "🎵"
        case "youtube":   return "▶️"
        default:          return "🔗"
        }
    }
}
