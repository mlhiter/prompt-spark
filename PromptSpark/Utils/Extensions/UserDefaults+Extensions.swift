import Foundation

extension UserDefaults {
    func setOptional<T>(_ value: T?, forKey key: String) {
        if let value = value {
            set(value, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
}
