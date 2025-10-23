import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let replaceMode = Self("replaceMode")
    static let displayMode = Self("displayMode")
}

enum HotkeyMode {
    case replace
    case display
}

class HotkeyManager {
    static let shared = HotkeyManager()

    private let textCaptureService = TextCaptureService.shared
    private let promptEngine = PromptEngine.shared
    private let notificationService = NotificationService.shared
    private let statusWindow = StatusWindowController()
    private let resultWindow = ResultWindowController()

    private init() {
        print("🔑 Initializing HotkeyManager...")
        setupHotkeys()
        print("🔑 Hotkey setup complete")
    }

    private func setupHotkeys() {
        if KeyboardShortcuts.getShortcut(for: .replaceMode) == nil {
            KeyboardShortcuts.setShortcut(.init(.p, modifiers: [.command, .shift]), for: .replaceMode)
            print("🔑 Default replace shortcut set: Cmd+Shift+P")
        }

        if KeyboardShortcuts.getShortcut(for: .displayMode) == nil {
            KeyboardShortcuts.setShortcut(.init(.i, modifiers: [.command, .shift]), for: .displayMode)
            print("🔑 Default display shortcut set: Cmd+Shift+I")
        }

        KeyboardShortcuts.onKeyUp(for: .replaceMode) { [weak self] in
            print("⌨️  REPLACE MODE TRIGGERED!")
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleHotkey(mode: .replace)
            }
        }

        KeyboardShortcuts.onKeyUp(for: .displayMode) { [weak self] in
            print("⌨️  DISPLAY MODE TRIGGERED!")
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleHotkey(mode: .display)
            }
        }

        print("🔑 Hotkey listeners registered")
    }

    @MainActor
    private func handleHotkey(mode: HotkeyMode) async {
        print("🔄 Starting \(mode == .replace ? "replace" : "display") mode...")

        statusWindow.show(message: "Preparing...")

        do {
            print("🔍 Validating configuration...")
            statusWindow.updateMessage("Validating configuration...")
            try await promptEngine.validateConfiguration()
            print("✅ Configuration valid")

            print("📋 Capturing selected text...")
            statusWindow.updateMessage("Capturing text...")
            let selectedText = try await textCaptureService.captureSelectedText()
            print("✅ Captured text (\(selectedText.count) chars): \(selectedText.prefix(50))...")

            guard !selectedText.isEmpty else {
                print("❌ No text selected")
                statusWindow.hide()
                throw PromptSparkError.noTextSelected
            }

            print("🤖 Sending to AI...")
            statusWindow.updateMessage(mode == .replace ? "Optimizing with AI..." : "Summarizing with AI...")

            let result: String
            if mode == .replace {
                result = try await promptEngine.processText(selectedText)
            } else {
                result = try await promptEngine.summarizeText(selectedText)
            }

            print("✅ Received result (\(result.count) chars): \(result.prefix(50))...")

            switch mode {
            case .replace:
                print("📝 Replacing text...")
                statusWindow.updateMessage("Replacing...")
                try? await Task.sleep(nanoseconds: 200_000_000)
                try await textCaptureService.replaceWithOptimizedText(result)
                print("✅ Text replaced successfully")

                statusWindow.updateMessage("Done! ✨")
                try? await Task.sleep(nanoseconds: 800_000_000)
                statusWindow.hide()

                notificationService.showNotification(
                    title: "PromptSpark",
                    message: "Prompt optimized successfully! ✨"
                )

            case .display:
                statusWindow.hide()
                print("📺 Showing result window...")
                resultWindow.show(originalText: selectedText, result: result)
                print("✅ Result window displayed")
            }

        } catch {
            print("❌ Error: \(error.localizedDescription)")
            statusWindow.hide()
            notificationService.showError(error)
        }
    }
}
