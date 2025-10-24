import Cocoa

class PasteboardService {
    static let shared = PasteboardService()

    private let pasteboard = NSPasteboard.general

    private init() {}

    func saveContent() -> String? {
        pasteboard.string(forType: .string)
    }

    func restoreContent(_ content: String?) {
        guard let content = content else { return }
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }

    func clear() {
        pasteboard.clearContents()
    }

    func write(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func read() -> String? {
        pasteboard.string(forType: .string)
    }
}
