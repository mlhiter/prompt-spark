import Foundation

class PromptEngine {
    static let shared = PromptEngine()

    private let apiClient: APIClientProtocol

    private init() {
        self.apiClient = OpenAIClient.shared
    }

    @MainActor
    private var appState: AppState {
        AppState.shared
    }

    func processText(_ text: String) async throws -> String {
        guard let activeProfile = await appState.activeProfile else {
            throw PromptSparkError.configurationError("No active profile")
        }

        let config = await appState.apiConfig
        let metaPrompt = activeProfile.metaPrompt

        await MainActor.run {
            appState.isProcessing = true
        }

        defer {
            Task { @MainActor in
                appState.isProcessing = false
            }
        }

        return try await apiClient.optimizePrompt(text, config: config, metaPrompt: metaPrompt)
    }

    func validateConfiguration() async throws {
        guard let _ = try KeychainService.shared.loadAPIKey() else {
            throw PromptSparkError.apiKeyMissing
        }

        let config = await appState.apiConfig
        guard config.isValid else {
            throw PromptSparkError.configurationError("Invalid API configuration")
        }

        let profile = await appState.activeProfile
        guard profile != nil else {
            throw PromptSparkError.configurationError("No active profile")
        }
    }
}
