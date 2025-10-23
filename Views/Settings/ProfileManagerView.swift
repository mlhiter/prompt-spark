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
        Form {
            Section {
                TextField("Profile Name", text: $profile.name)

                Button(profile.isActive ? "Active Profile" : "Set as Active") {
                    AppState.shared.setActiveProfile(profile)
                }
                .buttonStyle(.borderedProminent)
                .disabled(profile.isActive)
            } header: {
                Text("Profile Info")
            }

            Section {
                TextEditor(text: $profile.metaPrompt)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)

                Text("This is the system prompt used to transform user input")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Meta Prompt")
            }
        }
        .formStyle(.grouped)
        .padding()
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

    private func createProfile() {
        let profile = Profile(
            name: profileName,
            metaPrompt: metaPrompt.isEmpty ? ConfigService.shared.loadDefaultMetaPrompt() : metaPrompt
        )

        AppState.shared.addProfile(profile)
        isPresented = false
    }
}
