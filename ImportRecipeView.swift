//
//  ImportRecipeView.swift
//  RecipeClip
//
//  Import screen. Can be opened manually or pre-filled from the Share Extension.
//

import SwiftUI

struct ImportRecipeView: View {
    @Environment(\.dismiss) private var dismiss

    // These can be pre-filled when coming from the Share Extension
    // They default to empty when opened manually
    var initialURL: String = ""
    var initialText: String = ""

    @State private var urlText: String = ""
    @State private var sharedText: String = ""
    @State private var collectionName: String = ""
    @State private var isAnalyzing = false
    @State private var errorMessage: String? = nil
    @State private var recipeDraft: RecipeDraft? = nil
    @State private var navigateToReview = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Import Recipe")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            Text("Paste a link from Instagram or TikTok")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // Show a banner if we came from the Share Extension
                        if !initialURL.isEmpty || !initialText.isEmpty {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Link received from share sheet!")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                            .padding(12)
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        fieldSection(title: "Post URL", icon: "link") {
                            TextField("https://www.tiktok.com/...", text: $urlText)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                        }

                        fieldSection(title: "Caption / Text (optional)", icon: "text.quote") {
                            TextField("Paste the post caption here if you have it...",
                                      text: $sharedText, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        fieldSection(title: "Save to Collection", icon: "folder") {
                            TextField("e.g. Dinner Ideas, Breakfast...", text: $collectionName)
                        }

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

                        Button(action: analyzeRecipe) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView().tint(.white)
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
                                urlText.isEmpty && sharedText.isEmpty
                                ? Color.gray.opacity(0.4)
                                : Color("AccentOrange")
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled((urlText.isEmpty && sharedText.isEmpty) || isAnalyzing)

                        Spacer(minLength: 40)
                    }
                    .padding(24)
                }

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
            // Pre-fill fields when the view first appears
            .onAppear {
                if urlText.isEmpty { urlText = initialURL }
                if sharedText.isEmpty { sharedText = initialText }
                print("📋 ImportRecipeView appeared — initialURL: '\(initialURL)'")
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

    // MARK: - Analyze

    func analyzeRecipe() {
        errorMessage = nil
        isAnalyzing = true

        Task {
            do {
                let draft = try await RecipeAPIService.analyzeRecipe(
                    sourceURL: urlText,
                    sharedText: sharedText,
                    collectionName: collectionName
                )
                await MainActor.run {
                    recipeDraft = draft
                    isAnalyzing = false
                    navigateToReview = true
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ImportRecipeView()
}
