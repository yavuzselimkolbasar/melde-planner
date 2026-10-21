import Foundation

/// In-app language switching (German default, Turkish, English).
///
/// Strings live in Localizable.xcstrings with German source keys. Lookups go
/// through the selected language's .lproj bundle, so the app language can
/// differ from the device language without restarting.
enum Localization {
    private(set) static var bundle: Bundle = .main
    private(set) static var locale = Locale(identifier: AppLanguage.german.rawValue)

    static func apply(_ language: AppLanguage) {
        locale = Locale(identifier: language.rawValue)
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            bundle = languageBundle
        } else {
            bundle = .main
        }
    }
}

/// Localized string in the app language.
func L(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: Localization.bundle, locale: Localization.locale)
}
