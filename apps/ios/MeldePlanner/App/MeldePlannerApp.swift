import SwiftUI
import UserNotifications

@main
struct MeldePlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: AppModel = .makeForLaunch()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(model.preferences.theme.tint)
                .preferredColorScheme(model.preferences.theme.colorScheme)
                .environment(\.locale, Localization.locale)
                // Rebuild the hierarchy when the language changes so every string re-resolves.
                .id(model.preferences.language)
                .onReceive(NotificationCenter.default.publisher(for: .meldeDataChanged)) { _ in
                    model.reloadFromDisk()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            // Pick up Meldungen logged from widgets or the Lock Screen and re-plan reminders.
            guard phase == .active else { return }
            model.reloadFromDisk()
            model.refreshSchedules()
            Task {
                await model.refreshUntisIfStale()
                await model.refreshTeamsIfStale()
            }
        }
    }
}

/// Notification categories and handling "Ja, einmal / zweimal" without opening the app.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        LessonCheckIns.registerCategory()
        return true
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let changed = LessonCheckIns.handle(
            actionIdentifier: response.actionIdentifier,
            userInfo: response.notification.request.content.userInfo,
            store: try? LocalStore.standard()
        )
        if changed {
            await MainActor.run { NotificationCenter.default.post(name: .meldeDataChanged, object: nil) }
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
