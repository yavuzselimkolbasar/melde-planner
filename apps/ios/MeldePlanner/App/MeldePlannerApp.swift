import SwiftUI

@main
struct MeldePlannerApp: App {
    @State private var model: AppModel = {
        let store = try? LocalStore.standard()
        return AppModel(store: store)
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(model.preferences.theme.tint)
                .preferredColorScheme(model.preferences.theme.colorScheme)
                .environment(\.locale, Localization.locale)
                // Rebuild the hierarchy when the language changes so every string re-resolves.
                .id(model.preferences.language)
        }
    }
}
