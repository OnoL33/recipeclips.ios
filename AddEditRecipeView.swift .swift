//
//  AddEditRecipeView.swift
//  RecipeClip
//
//  Lets the user manually edit a saved recipe.
//

import SwiftUI
import SwiftData

struct AddEditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var recipe: Recipe

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()
                Form {
                    Section("Basic Info") {
                        TextField("Title", text: $recipe.title)
                        TextField("Collection", text: $recipe.collectionName)
                        TextField("Creator name", text: $recipe.creatorName)
                    }
                    Section("Cooking") {
                        Stepper("Servings: \(recipe.baseServings)", value: $recipe.baseServings, in: 1...20)
                        TextField("Cooking time (minutes)", value: $recipe.cookingTimeMinutes, format: .number)
                            .keyboardType(.numberPad)
                    }
                    Section("Ingredients (one per line)") {
                        TextEditor(text: $recipe.ingredientsText)
                            .frame(minHeight: 120)
                    }
                    Section("Instructions (one per line)") {
                        TextEditor(text: $recipe.instructionsText)
                            .frame(minHeight: 120)
                    }
                    Section("Notes") {
                        TextEditor(text: $recipe.notes)
                            .frame(minHeight: 60)
                    }
                    Section("Tags (comma separated)") {
                        TextField("Dinner, Quick, Vegetarian", text: $recipe.tagsText)
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AccentOrange"))
                }
            }
        }
    }
}
