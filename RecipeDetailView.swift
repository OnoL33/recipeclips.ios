//
//  RecipeDetailView.swift
//  RecipeClip
//
//  Shows a saved recipe in full detail.
//

import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var recipe: Recipe

    @State private var showingEdit = false
    @State private var showingCooking = false
    @State private var confirmDelete = false

    // Compute scaled ingredients based on current vs base servings
    var scaledIngredients: [String] {
        IngredientScalingHelper.scale(
            ingredients: recipe.ingredientsArray,
            from: recipe.baseServings,
            to: recipe.currentServings
        )
    }

    var body: some View {
        ZStack {
            Color("BackgroundCream").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Title & meta ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))

                        HStack(spacing: 14) {
                            Label(recipe.sourcePlatform.isEmpty ? "Unknown" : recipe.sourcePlatform, systemImage: "link")
                            if recipe.cookingTimeMinutes > 0 {
                                Label("\(recipe.cookingTimeMinutes) min", systemImage: "clock")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        if !recipe.collectionName.isEmpty {
                            Label(recipe.collectionName, systemImage: "folder")
                                .font(.subheadline)
                                .foregroundColor(Color("AccentOrange"))
                        }
                    }

                    // ── Tags ────────────────────────────────────────────
                    if !recipe.tagsArray.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(recipe.tagsArray, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color("AccentOrange").opacity(0.12))
                                        .foregroundColor(Color("AccentOrange"))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    Divider()

                    // ── Servings stepper ────────────────────────────────
                    HStack {
                        Label("Servings", systemImage: "person.2")
                            .font(.headline)
                        Spacer()
                        Stepper(
                            value: $recipe.currentServings,
                            in: 1...20,
                            label: {
                                Text("\(recipe.currentServings)")
                                    .font(.headline)
                                    .frame(minWidth: 32)
                            }
                        )
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // ── Ingredients ─────────────────────────────────────
                    sectionCard(title: "Ingredients", icon: "list.bullet") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(scaledIngredients.enumerated()), id: \.offset) { _, ingredient in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "circle")
                                        .font(.caption2)
                                        .foregroundColor(Color("AccentOrange"))
                                        .padding(.top, 4)
                                    Text(ingredient)
                                        .font(.body)
                                }
                            }
                        }
                    }

                    // ── Instructions ────────────────────────────────────
                    sectionCard(title: "Instructions", icon: "text.alignleft") {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(recipe.instructionsArray.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 22, height: 22)
                                        .background(Color("AccentOrange"))
                                        .clipShape(Circle())
                                    Text(step)
                                        .font(.body)
                                }
                            }
                        }
                    }

                    // ── Notes ───────────────────────────────────────────
                    if !recipe.notes.isEmpty {
                        sectionCard(title: "Notes", icon: "note.text") {
                            Text(recipe.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }

                    // ── Uncertainty notes ───────────────────────────────
                    if !recipe.uncertaintyNotes.isEmpty {
                        sectionCard(title: "AI Uncertainty Notes", icon: "exclamationmark.triangle") {
                            Text(recipe.uncertaintyNotes)
                                .font(.body)
                                .foregroundColor(.orange)
                        }
                    }

                    // ── Start Cooking Mode ──────────────────────────────
                    Button(action: { showingCooking = true }) {
                        Label("Start Cooking Mode", systemImage: "flame.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("AccentOrange"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // ── Open original post ──────────────────────────────
                    if !recipe.sourceURL.isEmpty, let url = URL(string: recipe.sourceURL) {
                        Link(destination: url) {
                            Label("Open Original Post", systemImage: "arrow.up.right.square")
                                .font(.subheadline)
                                .foregroundColor(Color("AccentOrange"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color("AccentOrange").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // ── Delete button ───────────────────────────────────
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Delete Recipe", systemImage: "trash")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.08))
                            .foregroundColor(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer(minLength: 40)
                }
                .padding(20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showingEdit = true }
                    .foregroundColor(Color("AccentOrange"))
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditRecipeView(recipe: recipe)
        }
        .sheet(isPresented: $showingCooking) {
            CookingModeView(steps: recipe.instructionsArray)
        }
        .alert("Delete Recipe?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) {
                modelContext.delete(recipe)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(recipe.title)\".")
        }
    }

    // MARK: - Section card helper

    func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            content()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}
