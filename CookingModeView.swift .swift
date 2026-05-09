//
//  CookingModeView.swift
//  RecipeClip
//
//  Shows one cooking step at a time in a large, readable view.
//

import SwiftUI

struct CookingModeView: View {
    @Environment(\.dismiss) private var dismiss

    let steps: [String]

    // Which step we're on (0-indexed)
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            Color("AccentOrange").ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text("Cooking Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    // Invisible spacer to balance
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Step counter
                Text("Step \(currentIndex + 1) of \(steps.count)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))

                // Step content
                if currentIndex < steps.count {
                    Text(steps[currentIndex])
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 20) {
                    // Previous button
                    Button(action: {
                        if currentIndex > 0 { currentIndex -= 1 }
                    }) {
                        Label("Previous", systemImage: "chevron.left")
                            .font(.headline)
                            .foregroundColor(currentIndex == 0 ? .white.opacity(0.3) : .white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(currentIndex == 0)

                    // Next / Done button
                    if currentIndex < steps.count - 1 {
                        Button(action: { currentIndex += 1 }) {
                            Label("Next", systemImage: "chevron.right")
                                .font(.headline)
                                .foregroundColor(Color("AccentOrange"))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        Button(action: { dismiss() }) {
                            Label("Done!", systemImage: "checkmark")
                                .font(.headline)
                                .foregroundColor(Color("AccentOrange"))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    CookingModeView(steps: [
        "Boil a large pot of salted water.",
        "Cook the pasta for 8-10 minutes until al dente.",
        "Fry garlic in olive oil for 1-2 minutes.",
        "Add cream and parmesan. Stir well.",
        "Drain pasta and toss with the sauce. Serve hot."
    ])
}
