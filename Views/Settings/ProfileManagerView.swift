import SwiftUI

struct ProfileManagerView: View {
    @StateObject private var appState = AppState.shared
    @State private var selectedProfile: Profile?
    @State private var showingAddProfile = false

    var body: some View {
        HSplitView {
            // Profile List
            VStack(alignment: .leading, spacing: 0) {
                List(selection: $selectedProfile) {
                    ForEach(appState.profiles) { profile in
                        HStack {
                            Text(profile.name)
                            Spacer()
                            if profile.isActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .tag(profile)
                    }
                }
                .frame(minWidth: 200)

                HStack {
                    Button(action: { showingAddProfile = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)

                    Button(action: deleteSelectedProfile) {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(.borderless)
                    .disabled(selectedProfile == nil || appState.profiles.count <= 1)

                    Spacer()
                }
                .padding(8)
            }

            // Profile Editor
            if let profile = selectedProfile {
                ProfileEditorView(profile: binding(for: profile))
            } else {
                VStack {
                    Text("Select a profile to edit")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingAddProfile) {
            AddProfileView(isPresented: $showingAddProfile)
        }
        .onAppear {
            if selectedProfile == nil, let first = appState.profiles.first {
                selectedProfile = first
            }
        }
    }

    private func binding(for profile: Profile) -> Binding<Profile> {
        guard let index = appState.profiles.firstIndex(where: { $0.id == profile.id }) else {
            return .constant(profile)
        }

        return Binding(
            get: { appState.profiles[index] },
            set: { appState.updateProfile($0) }
        )
    }

    private func deleteSelectedProfile() {
        guard let profile = selectedProfile else { return }
        appState.deleteProfile(profile)
        selectedProfile = appState.profiles.first
    }
}

struct ProfileEditorView: View {
    @Binding var profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile Info Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile Info")
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("Profile Name", text: $profile.name)
                    .textFieldStyle(.roundedBorder)

                Button(profile.isActive ? "Active Profile" : "Set as Active") {
                    AppState.shared.setActiveProfile(profile)
                }
                .buttonStyle(.borderedProminent)
                .disabled(profile.isActive)
            }
            .padding()

            Divider()

            // Meta Prompt Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Meta Prompt")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: resetToDefault) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Default")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .help("Load the latest default meta-prompt")
                }

                Text("This is the system prompt used to transform user input")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $profile.metaPrompt)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resetToDefault() {
        profile.metaPrompt = ConfigService.shared.loadDefaultMetaPrompt()
    }
}

struct AddProfileView: View {
    @Binding var isPresented: Bool
    @State private var profileName: String = ""
    @State private var metaPrompt: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("New Profile")
                .font(.headline)

            Form {
                TextField("Profile Name", text: $profileName)

                TextEditor(text: $metaPrompt)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.2))
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }

                Button("Create") {
                    createProfile()
                }
                .buttonStyle(.borderedProminent)
                .disabled(profileName.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
        .onAppear {
            metaPrompt = ConfigService.shared.loadDefaultMetaPrompt()
        }
    }

    @MainActor
    private func createProfile() {
        let profile = Profile(
            name: profileName,
            metaPrompt: metaPrompt.isEmpty ? ConfigService.shared.loadDefaultMetaPrompt() : metaPrompt
        )

        AppState.shared.addProfile(profile)
        isPresented = false
    }
}
