import Foundation

class ConfigService {
    static let shared = ConfigService()

    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default

    private var appSupportDirectory: URL {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appDir = paths[0].appendingPathComponent(Constants.App.name)

        if !fileManager.fileExists(atPath: appDir.path) {
            try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        }

        return appDir
    }

    private var profilesFileURL: URL {
        appSupportDirectory.appendingPathComponent(Constants.Files.profilesFileName)
    }

    private init() {}

    // MARK: - API Config

    func loadAPIConfig() -> APIConfig {
        let baseURL = userDefaults.string(forKey: Constants.UserDefaults.apiBaseURL)
            ?? Constants.API.defaultBaseURL
        let model = userDefaults.string(forKey: Constants.UserDefaults.apiModel)
            ?? Constants.API.defaultModel
        let maxTokens = userDefaults.integer(forKey: Constants.UserDefaults.maxTokens)
        let temperature = userDefaults.double(forKey: Constants.UserDefaults.temperature)
        let timeout = userDefaults.double(forKey: Constants.UserDefaults.timeout)

        return APIConfig(
            baseURL: baseURL,
            model: model,
            maxTokens: maxTokens > 0 ? maxTokens : Constants.API.defaultMaxTokens,
            temperature: temperature > 0 ? temperature : Constants.API.defaultTemperature,
            timeout: timeout > 0 ? timeout : Constants.API.defaultTimeout
        )
    }

    func saveAPIConfig(_ config: APIConfig) {
        userDefaults.set(config.baseURL, forKey: Constants.UserDefaults.apiBaseURL)
        userDefaults.set(config.model, forKey: Constants.UserDefaults.apiModel)
        userDefaults.set(config.maxTokens, forKey: Constants.UserDefaults.maxTokens)
        userDefaults.set(config.temperature, forKey: Constants.UserDefaults.temperature)
        userDefaults.set(config.timeout, forKey: Constants.UserDefaults.timeout)
    }

    // MARK: - Profiles

    func loadProfiles() -> [Profile] {
        guard fileManager.fileExists(atPath: profilesFileURL.path),
              let data = try? Data(contentsOf: profilesFileURL),
              let profiles = try? JSONDecoder().decode([Profile].self, from: data) else {
            return createDefaultProfile()
        }

        return profiles.isEmpty ? createDefaultProfile() : profiles
    }

    func saveProfiles(_ profiles: [Profile]) {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        try? data.write(to: profilesFileURL)
    }

    private func createDefaultProfile() -> [Profile] {
        let defaultMetaPrompt = loadDefaultMetaPrompt()
        let profile = Profile(
            name: "Default",
            metaPrompt: defaultMetaPrompt,
            isActive: true
        )
        return [profile]
    }

    func loadDefaultMetaPrompt() -> String {
        if let url = Bundle.main.url(forResource: "DefaultMetaPrompt", withExtension: "txt"),
           let content = try? String(contentsOf: url) {
            return content
        }

        return """
You are an expert prompt engineer. Your task is to transform the user's casual, vague input into a well-structured, detailed prompt that will produce high-quality AI responses.

Analyze the user's intent and:
1. Identify the core task or question
2. Add necessary context and constraints
3. Specify the desired output format
4. Include relevant technical requirements
5. Add placeholders for missing information using [brackets]

Keep the tone professional but natural. Preserve the user's original goal while enhancing clarity and completeness.

User's original input:
"""
    }

    func loadDefaultSummaryPrompt() -> String {
        if let url = Bundle.main.url(forResource: "DefaultSummaryPrompt", withExtension: "txt"),
           let content = try? String(contentsOf: url) {
            return content
        }

        return """
You are an expert content analyzer and summarizer. Your task is to read the provided content and create a clear, concise, and easy-to-understand summary.

Provide a well-structured summary that:
- Captures the main ideas and key points
- Uses simple, clear language
- Maintains the original meaning
- Highlights important facts or conclusions

Your summary MUST be in the same language as the input content.

Content to summarize:
"""
    }

    // MARK: - Active Profile

    var activeProfileID: String? {
        userDefaults.string(forKey: Constants.UserDefaults.activeProfileID)
    }

    func setActiveProfileID(_ id: String) {
        userDefaults.set(id, forKey: Constants.UserDefaults.activeProfileID)
    }

    // MARK: - Dock Icon

    func loadShowInDock() -> Bool {
        if userDefaults.object(forKey: Constants.UserDefaults.showInDock) == nil {
            return true
        }
        return userDefaults.bool(forKey: Constants.UserDefaults.showInDock)
    }

    func saveShowInDock(_ show: Bool) {
        userDefaults.set(show, forKey: Constants.UserDefaults.showInDock)
    }
}
