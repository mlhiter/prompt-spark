import Foundation
import os.log

enum Logger {
    private static let subsystem = Constants.App.bundleIdentifier
    private static let general = OSLog(subsystem: subsystem, category: "general")
    private static let api = OSLog(subsystem: subsystem, category: "api")
    private static let hotkey = OSLog(subsystem: subsystem, category: "hotkey")

    static func log(_ message: String, category: Category = .general) {
        os_log("%{public}@", log: logger(for: category), type: .info, message)
    }

    static func error(_ message: String, category: Category = .general) {
        os_log("%{public}@", log: logger(for: category), type: .error, message)
    }

    static func debug(_ message: String, category: Category = .general) {
        #if DEBUG
        os_log("%{public}@", log: logger(for: category), type: .debug, message)
        #endif
    }

    private static func logger(for category: Category) -> OSLog {
        switch category {
        case .general: return general
        case .api: return api
        case .hotkey: return hotkey
        }
    }

    enum Category {
        case general
        case api
        case hotkey
    }
}
