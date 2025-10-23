import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menuBarController: MenuBarController?
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 PromptSpark is launching...")

        // Hide from Dock
        NSApp.setActivationPolicy(.accessory)

        // Initialize menubar and pass self reference
        Task { @MainActor in
            menuBarController = MenuBarController(appDelegate: self)
            print("✅ MenuBar initialized")
        }

        // Initialize services
        Task { @MainActor in
            _ = AppState.shared
            print("✅ AppState initialized")
        }

        // Initialize hotkey manager
        Task { @MainActor in
            _ = HotkeyManager.shared
            print("✅ HotkeyManager initialized")
        }

        // Request accessibility permission if needed
        checkAccessibilityPermission()

        print("🎉 PromptSpark launched successfully")
    }

    @MainActor
    @objc func openSettings() {
        print("🔧 Opening settings window...")

        if settingsWindow == nil {
            print("🔧 Creating new settings window")
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "PromptSpark Settings"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 650, height: 600))
            window.center()

            settingsWindow = window
        }

        print("🔧 Showing settings window")
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func checkAccessibilityPermission() {
        let accessEnabled = AXIsProcessTrusted()

        if !accessEnabled {
            // Show alert to guide user
            DispatchQueue.main.async {
                self.showAccessibilityPermissionAlert()
            }
        }
    }

    private func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
        PromptSpark needs Accessibility permission to:
        • Listen for global hotkeys (Cmd+Shift+P)
        • Capture and replace selected text

        Click "Open Settings" to grant permission.
        Then restart PromptSpark.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // Open System Preferences
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }
}
