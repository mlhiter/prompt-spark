import SwiftUI

struct APISettingsView: View {
    @StateObject private var appState = AppState.shared
    @State private var apiKey: String = ""
    @State private var showAPIKey: Bool = false
    @State private var showSaveConfirmation: Bool = false

    var body: some View {
        Form {
            Section {
                HStack {
                    if showAPIKey {
                        TextField("sk-...", text: $apiKey)
                    } else {
                        SecureField("sk-...", text: $apiKey)
                    }

                    Button(action: { showAPIKey.toggle() }) {
                        Image(systemName: showAPIKey ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                }

                Text("Your API key is stored securely in the macOS Keychain")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("API Key")
            }

            Section {
                TextField("Base URL", text: $appState.apiConfig.baseURL, prompt: Text("https://api.openai.com/v1"))

                TextField("Model", text: $appState.apiConfig.model, prompt: Text("gpt-4o-mini"))

                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("", value: $appState.apiConfig.maxTokens, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Temperature")
                    Spacer()
                    TextField("", value: $appState.apiConfig.temperature, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                    Text("(0-2)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Timeout (seconds)")
                    Spacer()
                    TextField("", value: $appState.apiConfig.timeout, format: .number)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("API Configuration")
            } footer: {
                Text("You can use any OpenAI-compatible API endpoint and model name")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Button("Save Configuration") {
                    saveConfiguration()
                }
                .buttonStyle(.borderedProminent)

                if showSaveConfirmation {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Configuration saved successfully")
                            .font(.caption)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollIndicators(.hidden)
        .onAppear {
            loadAPIKey()
        }
    }

    private func loadAPIKey() {
        if let key = try? KeychainService.shared.loadAPIKey() {
            apiKey = key
        }
    }

    private func saveConfiguration() {
        do {
            if !apiKey.isEmpty {
                try KeychainService.shared.saveAPIKey(apiKey)
            }

            appState.saveConfiguration()

            showSaveConfirmation = true

            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveConfirmation = false
            }
        } catch {
            NotificationService.shared.showError(error)
        }
    }
}
