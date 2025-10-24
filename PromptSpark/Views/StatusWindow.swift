import Cocoa
import SwiftUI

class StatusWindowController {
    private var window: NSPanel?

    func show(message: String) {
        DispatchQueue.main.async { [weak self] in
            if self?.window == nil {
                self?.createAndShowWindow(message: message)
            } else {
                self?.updateMessage(message)
            }
        }
    }

    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.orderOut(nil)
            self?.window?.close()
            self?.window = nil
        }
    }

    func updateMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            if let window = self?.window,
               let hostingView = window.contentView as? NSHostingView<StatusView> {
                hostingView.rootView = StatusView(message: message)
            }
        }
    }

    private func createAndShowWindow(message: String) {
        // Get mouse location
        let mouseLocation = NSEvent.mouseLocation

        // Create status view
        let statusView = StatusView(message: message)
        let hostingView = NSHostingView(rootView: statusView)
        hostingView.layer?.backgroundColor = .clear

        // Create window - much smaller
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 40),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = NSColor.clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = false
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary]

        // Ensure transparency
        panel.isOpaque = false
        panel.backgroundColor = .clear

        // Position near mouse
        var origin = mouseLocation
        origin.x -= 80 // Center horizontally
        origin.y -= 60 // Position below mouse
        panel.setFrameOrigin(origin)

        panel.orderFrontRegardless()

        self.window = panel
    }
}

struct StatusView: View {
    let message: String
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 6) {
            // Simple animated dot instead of progress spinner
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
                .opacity(isAnimating ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear { isAnimating = true }

            Text(message)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        .compositingGroup()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
