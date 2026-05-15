//
//  RecipeAPIService.swift
//  RecipeClip
//
//  Sends recipe URLs to the backend and gets structured recipes back.
//  The backend calls Claude AI — the API key never lives in this file.
//

import Foundation

// MARK: - Response models (match the backend's JSON exactly)

struct RecipeAPIResponse: Codable {
    var title: String
    var collectionName: String
    var sourceURL: String
    var sourcePlatform: String
    var creatorName: String
    var baseServings: Int
    var currentServings: Int
    var cookingTimeMinutes: Int
    var ingredients: [IngredientItem]
    var instructions: [String]
    var notes: String
    var uncertaintyNotes: [String]
    var tags: [String]
}

struct IngredientItem: Codable {
    var amount: Double
    var unit: String
    var name: String
    var originalText: String
}

// MARK: - Custom errors with friendly messages

enum RecipeAPIError: LocalizedError {
    case noURLOrText
    case serverUnreachable
    case serverError(String)
    case invalidResponse
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .noURLOrText:
            return "Please enter a URL or paste some text from the post."
        case .serverUnreachable:
            return "Cannot reach the RecipeClip server. Make sure it's running on your Mac:\n\ncd recipeclip-backend\nnode server.js"
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .decodingFailed(let detail):
            return "Could not read the recipe data. Detail: \(detail)"
        }
    }
}

// MARK: - API Service

class RecipeAPIService {

    // ──────────────────────────────────────────────────────────
    // 🔧 CONFIGURATION
    //
    // For iPhone Simulator:  use "localhost"
    // For real iPhone:       use your Mac's IP, e.g. "192.168.1.42"
    //
    // To find your Mac's IP:
    //   System Settings → Wi-Fi → Details → IP Address
    // ──────────────────────────────────────────────────────────
    static let serverHost = "localhost"   // ← change to your IP for real device
    static let serverPort = 3000
    static var backendURL: String {
        "http://\(serverHost):\(serverPort)/analyze-recipe"
    }

    // ──────────────────────────────────────────────────────────
    // Main function: analyze a recipe from a URL and/or text
    // ──────────────────────────────────────────────────────────
    static func analyzeRecipe(
        sourceURL: String,
        sharedText: String,
        collectionName: String
    ) async throws -> RecipeDraft {

        // Validate input
        guard !sourceURL.isEmpty || !sharedText.isEmpty else {
            throw RecipeAPIError.noURLOrText
        }

        // Build the URL object
        guard let url = URL(string: backendURL) else {
            throw RecipeAPIError.serverUnreachable
        }

        // Build the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set a 30-second timeout (Claude can take a few seconds)
        request.timeoutInterval = 30

        // Build the request body — matches what server.js expects
        let body: [String: String] = [
            "sourceURL":      sourceURL,
            "sharedText":     sharedText,
            "collectionName": collectionName
        ]

        // Convert the dictionary to JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // ── Send the request ────────────────────────────────
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError {
            // Network-level errors (server not running, wrong IP, etc.)
            switch urlError.code {
            case .cannotConnectToHost, .networkConnectionLost, .notConnectedToInternet:
                throw RecipeAPIError.serverUnreachable
            case .timedOut:
                throw RecipeAPIError.serverError("Request timed out. The server took too long to respond.")
            default:
                throw RecipeAPIError.serverUnreachable
            }
        }

        // ── Check HTTP status code ──────────────────────────
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeAPIError.invalidResponse
        }

        // If the server returned an error, extract the message
        if httpResponse.statusCode != 200 {
            // Try to read the error message from the response body
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorBody["error"] as? String {
                throw RecipeAPIError.serverError(errorMessage)
            }
            throw RecipeAPIError.serverError("HTTP \(httpResponse.statusCode)")
        }

        // ── Decode the JSON response ────────────────────────
        let decoder = JSONDecoder()
        let apiResponse: RecipeAPIResponse

        do {
            apiResponse = try decoder.decode(RecipeAPIResponse.self, from: data)
        } catch let decodingError {
            // Print the raw response to the Xcode console for debugging
            if let rawString = String(data: data, encoding: .utf8) {
                print("⚠️ RecipeAPIService: Failed to decode response:")
                print(rawString)
            }
            throw RecipeAPIError.decodingFailed(decodingError.localizedDescription)
        }

        // ── Convert to RecipeDraft ──────────────────────────
        return toDraft(apiResponse)
    }

    // ──────────────────────────────────────────────────────────
    // Convert API response → RecipeDraft
    // ──────────────────────────────────────────────────────────
    static func toDraft(_ response: RecipeAPIResponse) -> RecipeDraft {
        var draft = RecipeDraft()
        draft.title            = response.title
        draft.collectionName   = response.collectionName
        draft.sourceURL        = response.sourceURL
        draft.sourcePlatform   = response.sourcePlatform
        draft.creatorName      = response.creatorName
        draft.baseServings     = response.baseServings
        draft.currentServings  = response.currentServings
        draft.cookingTimeMinutes = response.cookingTimeMinutes

        // Convert ingredient array → multiline text (one per line)
        // We use originalText so the line looks natural, e.g. "200g pasta"
        draft.ingredientsText = response.ingredients
            .map { $0.originalText.isEmpty ? "\($0.amount) \($0.unit) \($0.name)".trimmingCharacters(in: .whitespaces) : $0.originalText }
            .joined(separator: "\n")

        // Convert instruction array → multiline text
        draft.instructionsText = response.instructions
            .joined(separator: "\n")

        draft.notes = response.notes

        // Join uncertainty notes into one multiline string
        draft.uncertaintyNotes = response.uncertaintyNotes
            .joined(separator: "\n")

        // Join tags with commas
        draft.tagsText = response.tags.joined(separator: ",")

        return draft
    }
}
