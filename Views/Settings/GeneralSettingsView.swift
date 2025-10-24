import SwiftUI
import KeyboardShortcuts

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
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "arrow.triangle.swap")
                                .foregroundColor(.accentColor)
                            Text("Replace Mode")
                                .fontWeight(.medium)
                        }
                        Text("Optimize and replace selected text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        KeyboardShortcuts.Recorder("", name: .replaceMode)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .foregroundColor(.accentColor)
                            Text("Display Mode")
                                .fontWeight(.medium)
                        }
                        Text("Summarize and display in window")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        KeyboardShortcuts.Recorder("", name: .displayMode)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Global Hotkeys")
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
