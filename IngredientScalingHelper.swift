//
//  IngredientScalingHelper.swift
//  RecipeClip
//
//  This helper scales ingredient amounts when the user changes servings.
//  Example: base=2, current=4 → "200 g pasta" becomes "400 g pasta"
//

import Foundation

struct IngredientScalingHelper {

    /// Scale a list of ingredient lines from baseServings to currentServings.
    /// Lines that don't start with a number are returned unchanged.
    static func scale(
        ingredients: [String],
        from baseServings: Int,
        to currentServings: Int
    ) -> [String] {
        // If servings haven't changed, return as-is
        guard baseServings > 0, currentServings != baseServings else {
            return ingredients
        }

        let ratio = Double(currentServings) / Double(baseServings)

        return ingredients.map { line in
            scaleLine(line, by: ratio)
        }
    }

    /// Scale a single ingredient line.
    /// Example: "200 g pasta" with ratio 2.0 → "400 g pasta"
    private static func scaleLine(_ line: String, by ratio: Double) -> String {
        // We use a regex to find a number at the start of the line
        // This matches: 200, 1.5, 0.5, etc.
        let pattern = #"^(\d+\.?\d*)"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line),
              let originalNumber = Double(line[range])
        else {
            // No number found at the start — return unchanged
            // This handles lines like "salt to taste" or "a handful of spinach"
            return line
        }

        let scaledNumber = originalNumber * ratio

        // Format the number nicely:
        // - If it's a whole number, show without decimal (e.g. 400, not 400.0)
        // - If it has a decimal, show up to 1 decimal place (e.g. 1.5)
        let formatted: String
        if scaledNumber.truncatingRemainder(dividingBy: 1) == 0 {
            formatted = String(Int(scaledNumber))
        } else {
            formatted = String(format: "%.1f", scaledNumber)
        }

        // Replace just the number part at the start of the line
        return line.replacingCharacters(in: range, with: formatted)
    }
}
