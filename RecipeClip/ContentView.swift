//
//  ContentView.swift
//  RecipeClip
//
//  Home screen. Handles opening the Import screen automatically
//  when the app is launched from the Share Extension.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]

    @State private var searchText = ""
    @State private var selectedCollection: String? = nil
    @State private var showingImport = false

    // Passed in from RecipeClipApp when Share Extension opens the app
    @Binding var pendingURL: String
    @Binding var pendingText: String
    @Binding var showImportFromShare: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    searchBar
                    collectionChips

                    if filteredRecipes.isEmpty {
                        emptyState
                    } else {
                        recipeList
                    }
                }
            }
            // Normal import (user taps + button)
            .sheet(isPresented: $showingImport) {
                ImportRecipeView()
            }
            // Share Extension import (pre-filled with URL and text)
            .sheet(isPresented: $showImportFromShare, onDismiss: {
                // Clear pending data after sheet is dismissed
                pendingURL = ""
                pendingText = ""
            }) {
                // Capture values at the moment the sheet opens
                let urlToImport = pendingURL
                let textToImport = pendingText
                ImportRecipeView(
                    initialURL: urlToImport,
                    initialText: textToImport
                )
            }
            .onAppear {
                loadSamplesIfNeeded()
            }
            // Every time the app comes to the foreground, check if
            // there's a pending URL waiting to be imported
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification)
            ) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    print("👀 ContentView checking pendingURL: '\(pendingURL)'")
                    if !pendingURL.isEmpty && !showImportFromShare {
                        showImportFromShare = true
                    }
                }
            }
        }
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("RecipeClip")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color("AccentOrange"))
                Text("\(recipes.count) recipes saved")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { showingImport = true }) {
                Label("Import", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color("AccentOrange"))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Search bar

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search recipes...", text: $searchText)
                .autocorrectionDisabled()
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Collection chips

    var allCollections: [String] {
        let names = recipes.compactMap { $0.collectionName.isEmpty ? nil : $0.collectionName }
        return Array(Set(names)).sorted()
    }

    var collectionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                collectionChip(label: "All", isSelected: selectedCollection == nil) {
                    selectedCollection = nil
                }
                ForEach(allCollections, id: \.self) { name in
                    collectionChip(label: name, isSelected: selectedCollection == name) {
                        selectedCollection = (selectedCollection == name) ? nil : name
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
    }

    func collectionChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color("AccentOrange") : Color.white.opacity(0.8))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
                )
        }
    }

    // MARK: - Recipe list

    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.tagsText.localizedCaseInsensitiveContains(searchText)
            let matchesCollection = selectedCollection == nil ||
                recipe.collectionName == selectedCollection
            return matchesSearch && matchesCollection
        }
    }

    var recipeList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Empty state

    var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🍜")
                .font(.system(size: 64))
            Text("No recipes yet")
                .font(.title2.bold())
            Text("Tap Import to save your first recipe from Instagram or TikTok.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: { showingImport = true }) {
                Label("Import Recipe", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Color("AccentOrange"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Spacer()
        }
    }

    // MARK: - Sample data

    func loadSamplesIfNeeded() {
        let key = "hasLoadedSampleRecipes"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        for recipe in SampleRecipes.all() {
            modelContext.insert(recipe)
        }
        UserDefaults.standard.set(true, forKey: key)
    }
}

// MARK: - Recipe Card

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(recipe.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
                Text(recipe.platformIcon)
                    .font(.title3)
            }
            HStack(spacing: 12) {
                if !recipe.collectionName.isEmpty {
                    Label(recipe.collectionName, systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(Color("AccentOrange"))
                }
                if recipe.cookingTimeMinutes > 0 {
                    Label("\(recipe.cookingTimeMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Label("\(recipe.currentServings) servings", systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if !recipe.tagsArray.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recipe.tagsArray, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color("AccentOrange").opacity(0.12))
                                .foregroundColor(Color("AccentOrange"))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    ContentView(
        pendingURL: .constant(""),
        pendingText: .constant(""),
        showImportFromShare: .constant(false)
    )
    .modelContainer(for: Recipe.self, inMemory: true)
}
