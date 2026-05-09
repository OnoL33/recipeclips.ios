//
//  SampleRecipes.swift
//  RecipeClip
//
//  Sample recipes to show in the app for testing/preview.
//

import Foundation

struct SampleRecipes {
    static func all() -> [Recipe] {
        [
            Recipe(
                title: "Creamy Garlic Noodles",
                collectionName: "Dinner Ideas",
                sourceURL: "https://www.tiktok.com/@foodie/video/123",
                sourcePlatform: "TikTok",
                creatorName: "@foodie",
                baseServings: 2,
                currentServings: 2,
                cookingTimeMinutes: 20,
                ingredientsText: "200 g noodles\n150 ml heavy cream\n4 garlic cloves, minced\n50 g parmesan, grated\n1 tbsp olive oil\n0.5 tsp salt\nblack pepper to taste",
                instructionsText: "Cook noodles according to package instructions.\nHeat olive oil in a pan over medium heat.\nAdd garlic and fry for 1-2 minutes until fragrant.\nPour in cream and bring to a gentle simmer.\nAdd parmesan and stir until melted.\nDrain noodles and toss with the sauce.\nSeason with salt and pepper.",
                notes: "Use pasta water to loosen the sauce if it gets too thick.",
                uncertaintyNotes: "Cream amount was estimated from the video.",
                tagsText: "Dinner,Quick,Pasta"
            ),
            Recipe(
                title: "Avocado Toast with Poached Egg",
                collectionName: "Breakfast",
                sourceURL: "https://www.instagram.com/p/abc123",
                sourcePlatform: "Instagram",
                creatorName: "@brunchlife",
                baseServings: 1,
                currentServings: 1,
                cookingTimeMinutes: 10,
                ingredientsText: "2 slices sourdough bread\n1 ripe avocado\n2 eggs\n1 tbsp white vinegar\n0.5 tsp red pepper flakes\nsalt to taste\nlemon juice to taste",
                instructionsText: "Toast the sourdough bread.\nMash the avocado with salt and lemon juice.\nBring a pot of water to a gentle simmer and add vinegar.\nCrack eggs into a small cup and slide into the water.\nPoach for 3 minutes.\nSpread avocado on toast and top with the poached eggs.\nSprinkle with red pepper flakes.",
                notes: "Fresh eggs poach better than older ones.",
                uncertaintyNotes: "",
                tagsText: "Breakfast,Healthy,Vegetarian"
            ),
            Recipe(
                title: "Mango Smoothie Bowl",
                collectionName: "Breakfast",
                sourceURL: "https://www.tiktok.com/@healthyeats/video/456",
                sourcePlatform: "TikTok",
                creatorName: "@healthyeats",
                baseServings: 1,
                currentServings: 1,
                cookingTimeMinutes: 5,
                ingredientsText: "200 g frozen mango chunks\n100 ml coconut milk\n1 banana\n1 tbsp honey\ntoppings: granola, fresh fruit, coconut flakes",
                instructionsText: "Blend frozen mango, banana, coconut milk, and honey until thick and smooth.\nPour into a bowl.\nTop with granola, fresh fruit, and coconut flakes.",
                notes: "Use less liquid for a thicker bowl.",
                uncertaintyNotes: "Exact honey amount not shown — estimated.",
                tagsText: "Breakfast,Vegan,Quick,Healthy"
            )
        ]
    }
}
