import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private var isAvailable = false

    private init() {
        // Check if running in proper app bundle (not debug build)
        if Bundle.main.bundleIdentifier != nil {
            requestAuthorization()
            isAvailable = true
        } else {
            print("⚠️  Notification service disabled (running in development mode)")
            isAvailable = false
        }
    }

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func showNotification(title: String, message: String) {
        // In development mode, just print to console
        if !isAvailable {
            print("💬 [Notification] \(title): \(message)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }

    func showError(_ error: Error) {
        print("❌ Error: \(error.localizedDescription)")
        showNotification(
            title: "PromptSpark Error",
            message: error.localizedDescription
        )
    }

    func showSuccess(message: String = "Prompt optimized successfully") {
        print("✅ Success: \(message)")
        showNotification(
            title: "Success",
            message: message
        )
    }
}
