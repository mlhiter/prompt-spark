import SwiftUI

struct SettingsView: View {
    @StateObject private var appState = AppState.shared

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            APISettingsView()
                .tabItem {
                    Label("API", systemImage: "network")
                }

            ProfileManagerView()
                .tabItem {
                    Label("Profiles", systemImage: "list.bullet")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 650, height: 600)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("PromptSpark")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Bridge the gap between casual input and expert-level AI output.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)

            Spacer()

            Text("© 2025 PromptSpark. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
