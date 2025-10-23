import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let optimizePrompt = Self("optimizePrompt")
}

class HotkeyManager {
    static let shared = HotkeyManager()

    private let textCaptureService = TextCaptureService.shared
    private let promptEngine = PromptEngine.shared
    private let notificationService = NotificationService.shared
    private let statusWindow = StatusWindowController()

    private init() {
        print("🔑 Initializing HotkeyManager...")
        setupHotkeys()
        print("🔑 Hotkey setup complete")
    }

    private func setupHotkeys() {
        // Set default shortcut if not already set
        if KeyboardShortcuts.getShortcut(for: .optimizePrompt) == nil {
            KeyboardShortcuts.setShortcut(.init(.p, modifiers: [.command, .shift]), for: .optimizePrompt)
            print("🔑 Default shortcut set: Cmd+Shift+P")
        } else {
            let shortcut = KeyboardShortcuts.getShortcut(for: .optimizePrompt)
            print("🔑 Shortcut already configured: \(String(describing: shortcut))")
        }

        KeyboardShortcuts.onKeyUp(for: .optimizePrompt) { [weak self] in
            print("⌨️  HOTKEY TRIGGERED! Cmd+Shift+P pressed")
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleOptimizePrompt()
            }
        }
        print("🔑 Hotkey listener registered")
    }

    @MainActor
    private func handleOptimizePrompt() async {
        print("🔄 Starting prompt optimization...")

        // Show status window
        statusWindow.show(message: "Preparing...")

        do {
            // Check configuration first
            print("🔍 Validating configuration...")
            statusWindow.updateMessage("Validating configuration...")
            try await promptEngine.validateConfiguration()
            print("✅ Configuration valid")

            // Capture selected text
            print("📋 Capturing selected text...")
            statusWindow.updateMessage("Capturing text...")
            let selectedText = try await textCaptureService.captureSelectedText()
            print("✅ Captured text (\(selectedText.count) chars): \(selectedText.prefix(50))...")

            guard !selectedText.isEmpty else {
                print("❌ No text selected")
                statusWindow.hide()
                throw PromptSparkError.noTextSelected
            }

            // Process with AI
            print("🤖 Sending to AI...")
            statusWindow.updateMessage("Optimizing with AI...")
            let optimizedText = try await promptEngine.processText(selectedText)
            print("✅ Received optimized text (\(optimizedText.count) chars): \(optimizedText.prefix(50))...")

            // Replace with optimized text
            print("📝 Replacing text...")
            statusWindow.updateMessage("Replacing...")

            // Delay to ensure UI is ready
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms

            try await textCaptureService.replaceWithOptimizedText(optimizedText)
            print("✅ Text replaced successfully")

            // Show success and hide quickly
            statusWindow.updateMessage("Done! ✨")
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 second

            // Hide the window
            statusWindow.hide()
            print("✅ Status window hidden")

            // Show success notification
            notificationService.showNotification(
                title: "PromptSpark",
                message: "Prompt optimized successfully! ✨"
            )

        } catch {
            print("❌ Error: \(error.localizedDescription)")
            statusWindow.hide()
            notificationService.showError(error)
        }
    }

    func registerProfileHotkey(for profile: Profile, name: KeyboardShortcuts.Name) {
        KeyboardShortcuts.onKeyUp(for: name) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleProfileOptimization(profile: profile)
            }
        }
    }

    @MainActor
    private func handleProfileOptimization(profile: Profile) async {
        // Set active profile temporarily for this operation
        let originalProfile = AppState.shared.activeProfile
        AppState.shared.activeProfile = profile

        await handleOptimizePrompt()

        // Restore original profile
        AppState.shared.activeProfile = originalProfile
    }
}
