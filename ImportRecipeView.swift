//
//  ImportRecipeView.swift
//  RecipeClip
//
//  The Import screen where the user pastes a recipe URL.
//  After tapping Analyze, it calls the backend and navigates to the Review screen.
//

import SwiftUI

struct ImportRecipeView: View {
    // To close this sheet when done
    @Environment(\.dismiss) private var dismiss

    // The URL the user types or pastes
    @State private var urlText = ""

    // Optional caption/text that was shared (from the Share Extension)
    @State private var sharedText = ""

    // Which collection to save this recipe in
    @State private var collectionName = ""

    // Whether we're currently analyzing (showing loading state)
    @State private var isAnalyzing = false

    // If an error happens, store the message here
    @State private var errorMessage: String? = nil

    // When we have a result from the API, store it here and navigate to review
    @State private var recipeDraft: RecipeDraft? = nil

    // Whether to navigate to the review screen
    @State private var navigateToReview = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // ── Title ───────────────────────────────────────
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Import Recipe")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            Text("Paste a link from Instagram or TikTok")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // ── URL field ───────────────────────────────────
                        fieldSection(title: "Post URL", icon: "link") {
                            TextField("https://www.tiktok.com/...", text: $urlText)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                        }

                        // ── Shared text (optional) ──────────────────────
                        fieldSection(title: "Caption / Text (optional)", icon: "text.quote") {
                            TextField("Paste the post caption here if you have it...", text: $sharedText, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        // ── Collection picker ───────────────────────────
                        fieldSection(title: "Save to Collection", icon: "folder") {
                            TextField("e.g. Dinner Ideas, Breakfast...", text: $collectionName)
                        }

                        // ── Error message ───────────────────────────────
                        if let error = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                Text(error)
                                    .font(.subheadline)
                            }
                            .foregroundColor(.red)
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // ── Analyze button ──────────────────────────────
                        Button(action: analyzeRecipe) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .tint(.white)
                                    Text("Analyzing recipe...")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Analyze Recipe")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                urlText.isEmpty
                                ? Color.gray.opacity(0.4)
                                : Color("AccentOrange")
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(urlText.isEmpty || isAnalyzing)

                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }

                // Hidden NavigationLink that fires when we have a draft
                NavigationLink(
                    destination: RecipeReviewView(draft: recipeDraft ?? RecipeDraft()),
                    isActive: $navigateToReview
                ) { EmptyView() }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Field section helper

    func fieldSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            content()
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        }
    }

    // MARK: - Analyze action

    func analyzeRecipe() {
        // Clear any previous error
        errorMessage = nil
        isAnalyzing = true

        Task {
            do {
                // Call the API service (placeholder in Part 1, real in Part 3)
                let draft = try await RecipeAPIService.analyzeRecipe(
                    sourceURL: urlText,
                    sharedText: sharedText,
                    collectionName: collectionName
                )
                // Store the result and navigate to the review screen
                await MainActor.run {
                    recipeDraft = draft
                    isAnalyzing = false
                    navigateToReview = true
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = "Could not analyze the recipe. Please check your internet connection and try again.\n\nError: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ImportRecipeView()
}
