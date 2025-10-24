import Cocoa
import SwiftUI

@MainActor
class MenuBarController {
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var menuDelegate: MenuDelegate?
    private weak var appDelegate: AppDelegate?

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        setupMenuBar()
        setupMenu()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "PromptSpark")
            button.image?.isTemplate = true
        }
    }

    private func setupMenu() {
        menu = NSMenu()

        // Active Profile
        let profileMenu = NSMenuItem(title: "Active Profile", action: nil, keyEquivalent: "")
        let profileSubmenu = NSMenu()
        updateProfileSubmenu(profileSubmenu)
        profileMenu.submenu = profileSubmenu
        menu?.addItem(profileMenu)

        menu?.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu?.addItem(settingsItem)

        menu?.addItem(NSMenuItem.separator())

        // About
        let aboutItem = NSMenuItem(
            title: "About PromptSpark",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu?.addItem(aboutItem)

        menu?.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit PromptSpark",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu?.addItem(quitItem)

        statusItem?.menu = menu

        // Setup menu delegate with strong reference
        menuDelegate = MenuDelegate(controller: self)
        menu?.delegate = menuDelegate
    }

    fileprivate func updateProfileSubmenu(_ submenu: NSMenu) {
        submenu.removeAllItems()

        let profiles = AppState.shared.profiles

        for profile in profiles {
            let item = NSMenuItem(
                title: profile.name,
                action: #selector(selectProfile(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = profile.id
            item.state = profile.isActive ? .on : .off
            submenu.addItem(item)
        }

        if !profiles.isEmpty {
            submenu.addItem(NSMenuItem.separator())
        }

        let manageItem = NSMenuItem(
            title: "Manage Profiles...",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        manageItem.target = self
        submenu.addItem(manageItem)
    }

    @objc fileprivate func selectProfile(_ sender: NSMenuItem) {
        guard let profileID = sender.representedObject as? UUID,
              let profile = AppState.shared.profiles.first(where: { $0.id == profileID }) else {
            return
        }

        AppState.shared.setActiveProfile(profile)
    }

    @objc fileprivate func openSettings() {
        print("⚙️  Settings menu clicked")
        if let appDelegate = appDelegate {
            print("⚙️  AppDelegate found, calling openSettings")
            appDelegate.openSettings()
        } else {
            print("❌ AppDelegate not found!")
        }
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "PromptSpark"
        alert.informativeText = """
        Version 1.0.0

        Bridge the gap between casual input and expert-level AI output.

        © 2025 PromptSpark
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Menu Delegate

class MenuDelegate: NSObject, NSMenuDelegate {
    weak var controller: MenuBarController?

    init(controller: MenuBarController) {
        self.controller = controller
    }

    @MainActor
    func menuWillOpen(_ menu: NSMenu) {
        // Update profile submenu when menu opens
        if let profileItem = menu.items.first(where: { $0.title == "Active Profile" }),
           let submenu = profileItem.submenu {
            controller?.updateProfileSubmenu(submenu)
        }
    }
}
