import Foundation

enum PromptSparkError: LocalizedError {
    case noTextSelected
    case apiKeyMissing
    case networkError(Error)
    case timeout
    case invalidResponse
    case rateLimitExceeded
    case accessibilityPermissionDenied
    case configurationError(String)

    var errorDescription: String? {
        switch self {
        case .noTextSelected:
            return "No text selected"
        case .apiKeyMissing:
            return "Please configure your API Key in settings"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timeout. Please check your network or try a different model"
        case .invalidResponse:
            return "Invalid API response"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later"
        case .accessibilityPermissionDenied:
            return "Accessibility permission required for global hotkeys"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        }
    }
}
