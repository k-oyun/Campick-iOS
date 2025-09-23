import Foundation

extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) -> String? {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return stringValue
        }
        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }
        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return String(doubleValue)
        }
        return nil
    }

    func decodeFlexibleString(forKeyName name: String) -> String? {
        guard let key = Key(stringValue: name) else { return nil }
        return decodeFlexibleString(forKey: key)
    }
}
