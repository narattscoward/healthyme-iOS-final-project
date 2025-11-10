import SwiftUI
import Combine

final class LanguageManager: ObservableObject {
    @Published var languageCode: String {
        didSet {
            locale = Locale(identifier: languageCode)
        }
    }

    @Published private(set) var locale: Locale

    /// Bundle for current language (falls back to main if missing)
    var bundle: Bundle {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let b = Bundle(path: path) {
            return b
        }
        return .main
    }

    init(initialCode: String = "en") {
        self.languageCode = initialCode
        self.locale = Locale(identifier: initialCode)
    }
}
