import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var profiles: [Profile] = []
    @Published var activeProfile: Profile?
    @Published var apiConfig: APIConfig = APIConfig()
    @Published var isProcessing: Bool = false
    @Published var showInDock: Bool = false

    private let configService: ConfigService

    private init() {
        self.configService = ConfigService.shared
        loadConfiguration()
    }

    func loadConfiguration() {
        // Load API config
        self.apiConfig = configService.loadAPIConfig()

        // Load profiles
        self.profiles = configService.loadProfiles()

        // Load show in dock setting
        self.showInDock = configService.loadShowInDock()

        // Set active profile
        if let activeIDString = configService.activeProfileID,
           let activeID = UUID(uuidString: activeIDString),
           let active = profiles.first(where: { $0.id == activeID }) {
            self.activeProfile = active
        } else if let first = profiles.first {
            self.activeProfile = first
            configService.setActiveProfileID(first.id.uuidString)
        }
    }

    func saveConfiguration() {
        configService.saveAPIConfig(apiConfig)
        configService.saveProfiles(profiles)
        configService.saveShowInDock(showInDock)
        if let activeID = activeProfile?.id {
            configService.setActiveProfileID(activeID.uuidString)
        }
    }

    func addProfile(_ profile: Profile) {
        profiles.append(profile)
        saveConfiguration()
    }

    func updateProfile(_ profile: Profile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            if activeProfile?.id == profile.id {
                activeProfile = profile
            }
            saveConfiguration()
        }
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }
        if activeProfile?.id == profile.id {
            activeProfile = profiles.first
        }
        saveConfiguration()
    }

    func setActiveProfile(_ profile: Profile) {
        // Deactivate all profiles
        for index in profiles.indices {
            profiles[index].isActive = false
        }

        // Activate selected profile
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index].isActive = true
            activeProfile = profiles[index]
        }

        saveConfiguration()
    }
}
