import Foundation

struct Profile: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var metaPrompt: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        metaPrompt: String,
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.metaPrompt = metaPrompt
        self.isActive = isActive
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    mutating func updateMetaPrompt(_ newPrompt: String) {
        self.metaPrompt = newPrompt
        self.updatedAt = Date()
    }

    mutating func setActive(_ active: Bool) {
        self.isActive = active
        self.updatedAt = Date()
    }
}
