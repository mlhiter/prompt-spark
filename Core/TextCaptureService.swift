import Cocoa
import CoreGraphics

class TextCaptureService {
    static let shared = TextCaptureService()

    private let pasteboardService = PasteboardService.shared

    private init() {}

    func captureSelectedText() async throws -> String {
        // Save current pasteboard content
        let originalContent = pasteboardService.saveContent()

        // Clear pasteboard
        pasteboardService.clear()

        // Simulate Cmd+C
        try await simulateCommandC()

        // Wait for the pasteboard to update
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Read captured text
        guard let capturedText = pasteboardService.read(), !capturedText.isEmpty else {
            // Restore original content if capture failed
            pasteboardService.restoreContent(originalContent)
            throw PromptSparkError.noTextSelected
        }

        // Restore original content
        pasteboardService.restoreContent(originalContent)

        return capturedText
    }

    func replaceWithOptimizedText(_ optimizedText: String) async throws {
        // Save current pasteboard
        let originalContent = pasteboardService.saveContent()

        // Write optimized text to pasteboard
        pasteboardService.write(optimizedText)

        // Wait a bit
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms

        // Simulate Cmd+V
        try await simulateCommandV()

        // Wait for paste to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms

        // Restore original pasteboard
        pasteboardService.restoreContent(originalContent)
    }

    private func simulateCommandC() async throws {
        try simulateKeyPress(keyCode: 0x08, modifiers: .maskCommand) // C key
    }

    private func simulateCommandV() async throws {
        try simulateKeyPress(keyCode: 0x09, modifiers: .maskCommand) // V key
    }

    private func simulateKeyPress(keyCode: CGKeyCode, modifiers: CGEventFlags) throws {
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            throw PromptSparkError.accessibilityPermissionDenied
        }

        // Key down
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) else {
            throw PromptSparkError.configurationError("Failed to create key event")
        }
        keyDown.flags = modifiers
        keyDown.post(tap: .cghidEventTap)

        // Small delay between down and up
        usleep(10_000) // 10ms

        // Key up
        guard let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            throw PromptSparkError.configurationError("Failed to create key event")
        }
        keyUp.flags = modifiers
        keyUp.post(tap: .cghidEventTap)
    }
}
