import Foundation

/// Unified AI quote generator service (Gemini) that returns text + author.
final class QuoteAIService {
    static let shared = QuoteAIService()
    private init() {}

    // Use a cheap, available model from your ListModels response.
    private let modelName = "models/gemini-2.5-flash-lite"

    // MARK: Public API

    struct QuoteResult: Equatable {
        let text: String
        let author: String
    }

    /// Returns a motivational quote tailored to the unchecked habits.
    /// Tries Gemini first; if it can’t return both text+author, falls back to local quotes.
    func fetchQuote(forUnchecked habits: [Habit]) async throws -> QuoteResult {
        guard let apiKey = readGeminiKey() else {
            throw QuoteError.missingKey
        }

        // Build compact prompt
        let titles = habits
            .map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let prompt: String
        if titles.isEmpty {
            prompt = """
            Return a JSON object with keys "text" and "author" for a short (<= 18 words)
            real-world motivational quote by a real person. No emojis.
            Example:
            {"text":"Believe you can and you're halfway there.","author":"Theodore Roosevelt"}
            """
        } else {
            let joined = titles.joined(separator: ", ")
            prompt = """
            The user is working on: \(joined).
            Return a JSON object with keys "text" and "author" for a short (<= 18 words)
            real-world motivational quote by a real person that fits these habits. No emojis.
            Only output JSON, e.g.:
            {"text":"It always seems impossible until it's done.","author":"Nelson Mandela"}
            """
        }

        return try await callGeminiJSON(prompt: prompt, apiKey: apiKey)
    }

    // MARK: - Key reading

    private func readGeminiKey() -> String? {
        if let v = Bundle.main.object(forInfoDictionaryKey: "GeminiAPIKey") as? String,
           !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return v
        }
        if let v = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return v
        }
        return nil
    }

    // MARK: - Gemini (JSON) call

    /// Ask Gemini to respond strictly as JSON and parse it.
    private func callGeminiJSON(prompt: String, apiKey: String) async throws -> QuoteResult {
        let base = "https://generativelanguage.googleapis.com/v1beta"
        let urlString = "\(base)/\(modelName):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw QuoteError.badResponse }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // "response_mime_type": "application/json" nudges Gemini to give clean JSON back.
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "temperature": 0.6,
                "maxOutputTokens": 60,
                "response_mime_type": "application/json"
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        for attempt in 1...2 {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw QuoteError.badResponse }
            // print("🌐 Gemini status:", http.statusCode, "attempt:", attempt)

            if http.statusCode == 200 {
                // Gemini wraps JSON in its own envelope; pull the text first.
                let envelope = try JSONDecoder().decode(GeminiEnvelope.self, from: data)
                guard let raw = envelope.candidates?.first?.content?.parts?.first?.text else {
                    throw QuoteError.emptyAIResult
                }

                // raw should be a JSON object string => decode into QuotePayload
                guard let jsonData = raw.data(using: .utf8) else { throw QuoteError.badResponse }
                if let payload = try? JSONDecoder().decode(QuotePayload.self, from: jsonData) {
                    let text = sanitize(payload.text)
                    let author = payload.author.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty && !author.isEmpty {
                        return QuoteResult(text: text, author: author)
                    }
                }

                // If JSON was malformed or missing author, fall back locally.
                return Self.localFallback()
            }

            if attempt == 1, http.statusCode == 429 || (500...599).contains(http.statusCode) {
                try? await Task.sleep(nanoseconds: 400_000_000)
                continue
            }

            // Non-retryable: fallback
            return Self.localFallback()
        }

        return Self.localFallback()
    }

    // MARK: - Fallback real quotes (text + author)

    private static func localFallback() -> QuoteResult {
        let pool: [QuoteResult] = [
            .init(text: "Believe you can and you’re halfway there.", author: "Theodore Roosevelt"),
            .init(text: "The future depends on what you do today.", author: "Mahatma Gandhi"),
            .init(text: "Well done is better than well said.", author: "Benjamin Franklin"),
            .init(text: "What we think, we become.", author: "Buddha"),
            .init(text: "Act as if what you do makes a difference. It does.", author: "William James"),
            .init(text: "Quality is not an act, it is a habit.", author: "Aristotle"),
            .init(text: "It always seems impossible until it’s done.", author: "Nelson Mandela")
        ]
        return pool.randomElement()!
    }

    // MARK: - Helpers

    private func sanitize(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("\"") && s.hasSuffix("\"") && s.count >= 2 {
            s.removeFirst()
            s.removeLast()
        }
        return s.replacingOccurrences(of: "\n", with: " ")
    }

    // MARK: - Errors

    enum QuoteError: LocalizedError {
        case missingKey, badResponse, emptyAIResult, httpStatus(code: Int), rateLimited
        var errorDescription: String? {
            switch self {
            case .missingKey: return "Missing GeminiAPIKey in Info.plist."
            case .badResponse: return "Invalid response from Gemini API."
            case .emptyAIResult: return "Gemini returned an empty response."
            case .httpStatus(let code): return "Gemini API HTTP error \(code)."
            case .rateLimited: return "Gemini API rate limit exceeded. Try again later."
            }
        }
    }
}

// MARK: - Gemini envelope DTOs

private struct GeminiEnvelope: Codable {
    struct Candidate: Codable {
        let content: Content?
    }
    struct Content: Codable {
        let parts: [Part]?
    }
    struct Part: Codable {
        let text: String?
    }
    let candidates: [Candidate]?
}

/// The JSON we ask Gemini to return as plain text (then we decode this).
private struct QuotePayload: Codable {
    let text: String
    let author: String
}
