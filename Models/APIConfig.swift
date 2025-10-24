import Foundation

struct APIConfig: Codable {
    var baseURL: String
    var model: String
    var maxTokens: Int
    var temperature: Double
    var timeout: TimeInterval

    init(
        baseURL: String = Constants.API.defaultBaseURL,
        model: String = Constants.API.defaultModel,
        maxTokens: Int = Constants.API.defaultMaxTokens,
        temperature: Double = Constants.API.defaultTemperature,
        timeout: TimeInterval = Constants.API.defaultTimeout
    ) {
        self.baseURL = baseURL
        self.model = model
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.timeout = timeout
    }

    var isValid: Bool {
        !baseURL.isEmpty && !model.isEmpty && maxTokens > 0
    }
}
