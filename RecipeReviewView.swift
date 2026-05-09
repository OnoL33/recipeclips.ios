//
//  RecipeReviewView.swift
//  RecipeClip
//
//  Shows the AI-generated recipe for the user to review and edit before saving.
//

import SwiftUI
import SwiftData

struct RecipeReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // The draft recipe from the AI (passed in from ImportRecipeView)
    @State var draft: RecipeDraft

    // Whether to show a save confirmation
    @State private var saved = false

    // Navigate back to root after saving
    @Environment(\.dismiss) private var dismissView

    var body: some View {
        ZStack {
            Color("BackgroundCream").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    // ── Header ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Review Recipe")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text("Edit anything before saving")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // ── Uncertainty warning ─────────────────────────────
                    if !draft.uncertaintyNotes.isEmpty {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Notes")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                                Text(draft.uncertaintyNotes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // ── Title ───────────────────────────────────────────
                    editSection(title: "Title", icon: "fork.knife") {
                        TextField("Recipe title", text: $draft.title)
                    }

                    // ── Collection ──────────────────────────────────────
                    editSection(title: "Collection", icon: "folder") {
                        TextField("e.g. Dinner Ideas", text: $draft.collectionName)
                    }

                    // ── Servings + Time ─────────────────────────────────
                    HStack(spacing: 16) {
                        editSection(title: "Servings", icon: "person.2") {
                            Stepper("\(draft.baseServings)", value: $draft.baseServings, in: 1...20)
                        }
                        editSection(title: "Time (min)", icon: "clock") {
                            TextField("20", value: $draft.cookingTimeMinutes, format: .number)
                                .keyboardType(.numberPad)
                        }
                    }

                    // ── Ingredients ─────────────────────────────────────
                    editSection(title: "Ingredients (one per line)", icon: "list.bullet") {
                        TextField("200 g pasta\n150 ml cream", text: $draft.ingredientsText, axis: .vertical)
                            .lineLimit(4...12)
                    }

                    // ── Instructions ────────────────────────────────────
                    editSection(title: "Instructions (one per line)", icon: "text.alignleft") {
                        TextField("Cook the pasta.\nFry garlic...", text: $draft.instructionsText, axis: .vertical)
                            .lineLimit(4...12)
                    }

                    // ── Notes ───────────────────────────────────────────
                    editSection(title: "Notes", icon: "note.text") {
                        TextField("Optional tips...", text: $draft.notes, axis: .vertical)
                            .lineLimit(2...5)
                    }

                    // ── Tags ────────────────────────────────────────────
                    editSection(title: "Tags (comma separated)", icon: "tag") {
                        TextField("Dinner, Quick, Vegetarian", text: $draft.tagsText)
                    }

                    // ── Save button ─────────────────────────────────────
                    Button(action: saveRecipe) {
                        Label("Save Recipe", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("AccentOrange"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Cancel button
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }

                    Spacer(minLength: 40)
                }
                .padding(24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Recipe Saved! 🎉", isPresented: $saved) {
            Button("Great!") {
                // Dismiss all the way back to the home screen
                dismiss()
            }
        } message: {
            Text("\"\(draft.title)\" has been added to your recipe book.")
        }
    }

    // MARK: - Edit section helper

    func editSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            content()
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        }
    }

    // MARK: - Save

    func saveRecipe() {
        // Convert the draft to a real Recipe and insert into SwiftData
        let recipe = draft.toRecipe()
        modelContext.insert(recipe)
        saved = true
    }
}

#Preview {
    NavigationStack {
        RecipeReviewView(draft: {
            var d = RecipeDraft()
            d.title = "Creamy Garlic Noodles"
            d.collectionName = "Dinner Ideas"
            d.ingredientsText = "200 g noodles\n150 ml cream"
            d.instructionsText = "Cook noodles.\nMake sauce.\nCombine."
            d.uncertaintyNotes = "Cream amount was estimated."
            d.tagsText = "Dinner,Quick"
            return d
        }())
    }
    .modelContainer(for: Recipe.self, inMemory: true)
}
