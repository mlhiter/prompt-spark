import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}
