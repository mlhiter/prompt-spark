import Foundation

enum Constants {
    enum App {
        static let name = "PromptSpark"
        static let bundleIdentifier = "com.promptspark.app"
    }

    enum UserDefaults {
        static let apiBaseURL = "apiBaseURL"
        static let apiModel = "apiModel"
        static let maxTokens = "maxTokens"
        static let temperature = "temperature"
        static let timeout = "timeout"
        static let activeProfileID = "activeProfileID"
    }

    enum Keychain {
        static let apiKeyService = "PromptSpark"
        static let apiKeyAccount = "openai-api-key"
    }

    enum Files {
        static let profilesFileName = "profiles.json"
        static let defaultMetaPromptFileName = "DefaultMetaPrompt.txt"
    }

    enum API {
        static let defaultBaseURL = "https://api.openai.com/v1"
        static let defaultModel = "gpt-4o-mini"
        static let defaultMaxTokens = 500
        static let defaultTemperature = 0.7
        static let defaultTimeout: TimeInterval = 10.0
    }
}
