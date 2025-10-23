import SwiftUI

struct GeneralSettingsView: View {
    @StateObject private var appState = AppState.shared
    @State private var showSaveConfirmation: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle("Show in Dock", isOn: $appState.showInDock)

                Text("Show the app icon in the Dock. You can still access the app from the menu bar.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Appearance")
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
    }

    private func saveConfiguration() {
        appState.saveConfiguration()

        showSaveConfirmation = true

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSaveConfirmation = false
        }
    }
}
