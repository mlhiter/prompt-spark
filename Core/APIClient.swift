import Foundation

protocol APIClientProtocol {
    func optimizePrompt(_ userInput: String, config: APIConfig, metaPrompt: String) async throws -> String
}

class OpenAIClient: APIClientProtocol {
    static let shared = OpenAIClient()

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }

    func optimizePrompt(_ userInput: String, config: APIConfig, metaPrompt: String) async throws -> String {
        guard let apiKey = try KeychainService.shared.loadAPIKey(), !apiKey.isEmpty else {
            throw PromptSparkError.apiKeyMissing
        }

        let url = URL(string: "\(config.baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = config.timeout

        let messages: [[String: String]] = [
            ["role": "system", "content": metaPrompt],
            ["role": "user", "content": userInput]
        ]

        let body: [String: Any] = [
            "model": config.model,
            "messages": messages,
            "max_tokens": config.maxTokens,
            "temperature": config.temperature
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw PromptSparkError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                guard let content = result.choices.first?.message.content else {
                    throw PromptSparkError.invalidResponse
                }
                return content

            case 429:
                throw PromptSparkError.rateLimitExceeded

            default:
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    throw PromptSparkError.networkError(
                        NSError(domain: "OpenAI", code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message])
                    )
                }
                throw PromptSparkError.invalidResponse
            }
        } catch is CancellationError {
            throw PromptSparkError.timeout
        } catch let error as PromptSparkError {
            throw error
        } catch {
            throw PromptSparkError.networkError(error)
        }
    }
}

// MARK: - Response Models

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let role: String
        let content: String
    }
}

struct OpenAIErrorResponse: Codable {
    let error: ErrorDetail

    struct ErrorDetail: Codable {
        let message: String
        let type: String?
        let code: String?
    }
}
