import Cocoa
import SwiftUI

class ResultWindowController {
    private var window: NSPanel?

    func show(originalText: String, result: String) {
        DispatchQueue.main.async { [weak self] in
            self?.createAndShowWindow(originalText: originalText, result: result)
        }
    }

    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.orderOut(nil)
            self?.window?.close()
            self?.window = nil
        }
    }

    private func createAndShowWindow(originalText: String, result: String) {
        let resultView = ResultView(originalText: originalText, result: result) {
            self.hide()
        }
        let hostingView = NSHostingView(rootView: resultView)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.title = "AI Summary"
        panel.contentView = hostingView
        panel.level = .floating
        panel.isOpaque = true
        panel.backgroundColor = NSColor.windowBackgroundColor
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.center()
        panel.orderFrontRegardless()

        self.window = panel
    }
}

struct ResultView: View {
    let originalText: String
    let result: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Original Text", systemImage: "doc.text")
                            .font(.headline)

                        Text(originalText)
                            .font(.system(size: 13))
                            .textSelection(.enabled)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Label("AI Summary", systemImage: "sparkles")
                            .font(.headline)

                        Text(result)
                            .font(.system(size: 13))
                            .textSelection(.enabled)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(20)
            }

            Divider()

            HStack(spacing: 12) {
                Button("Copy Summary") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(result, forType: .string)
                }

                Spacer()

                Button("Close") {
                    onClose()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
    }
}
