//
//  RecipeDraft.swift
//  RecipeClip
//
//  RecipeDraft holds a recipe that came from the AI but hasn't been saved yet.
//  It's used in the Review screen. When the user taps Save, we convert it to a Recipe.
//

import Foundation

struct RecipeDraft {
    var title: String = ""
    var collectionName: String = ""
    var sourceURL: String = ""
    var sourcePlatform: String = ""
    var creatorName: String = ""
    var baseServings: Int = 2
    var currentServings: Int = 2
    var cookingTimeMinutes: Int = 0
    var ingredientsText: String = ""
    var instructionsText: String = ""
    var notes: String = ""
    var uncertaintyNotes: String = ""
    var tagsText: String = ""

    // Convert this draft into a real Recipe that can be saved to SwiftData
    func toRecipe() -> Recipe {
        Recipe(
            title: title,
            collectionName: collectionName,
            sourceURL: sourceURL,
            sourcePlatform: sourcePlatform,
            creatorName: creatorName,
            baseServings: baseServings,
            currentServings: currentServings,
            cookingTimeMinutes: cookingTimeMinutes,
            ingredientsText: ingredientsText,
            instructionsText: instructionsText,
            notes: notes,
            uncertaintyNotes: uncertaintyNotes,
            tagsText: tagsText
        )
    }
}
