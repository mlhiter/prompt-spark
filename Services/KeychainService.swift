import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()

    private init() {}

    func save(key: String, value: String) throws {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.Keychain.apiKeyService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw PromptSparkError.configurationError("Failed to save to Keychain")
        }
    }

    func load(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.Keychain.apiKeyService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw PromptSparkError.configurationError("Failed to load from Keychain")
        }

        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Constants.Keychain.apiKeyService,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PromptSparkError.configurationError("Failed to delete from Keychain")
        }
    }

    // Convenience methods for API Key
    func saveAPIKey(_ apiKey: String) throws {
        try save(key: Constants.Keychain.apiKeyAccount, value: apiKey)
    }

    func loadAPIKey() throws -> String? {
        try load(key: Constants.Keychain.apiKeyAccount)
    }

    func deleteAPIKey() throws {
        try delete(key: Constants.Keychain.apiKeyAccount)
    }
}
