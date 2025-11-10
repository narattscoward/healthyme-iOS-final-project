import Foundation

@inline(__always)
func L(_ key: String, _ bundle: Bundle) -> String {
    bundle.localizedString(forKey: key, value: key, table: nil)
}
