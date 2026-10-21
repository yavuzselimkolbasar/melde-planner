import BackgroundTasks
import SwiftUI
import UserNotifications

/// Background App Refresh task that keeps WebUntis data current.
enum BackgroundRefresh {
    static let identifier = "app.meldeplanner.ios.refresh"
    /// The app's model once its window exists; a pure background launch loads its own.
    static weak var model: AppModel?

    /// Runs when iOS wakes Meldo: plan the next wake-up, then update WebUntis
    /// and Teams if they're due.
    static func run() async {
        schedule()
        let target = Self.model ?? AppModel.makeForLaunch()
        target.reloadFromDisk()
        await target.refreshUntisIfStale()
        await target.refreshTeamsIfStale()
    }

    /// Asks iOS to wake Meldo in about 30 minutes; iOS decides the exact time.
    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: AppModel.untisRefreshInterval)
        try? BGTaskScheduler.shared.submit(request)
    }
}

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
                // While the app is open: check every few minutes, update when 30 minutes old.
                .task {
                    BackgroundRefresh.model = model
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(5 * 60))
                        await model.refreshUntisIfStale()
                    }
                }
        }
        .backgroundTask(.appRefresh(BackgroundRefresh.identifier)) {
            await BackgroundRefresh.run()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { BackgroundRefresh.schedule() }
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
        // A plain tap only opens the app. Storage is touched only for answers,
        // on the main actor, never while the app may still be launching.
        guard let answer = LessonCheckIns.answer(
            actionIdentifier: response.actionIdentifier,
            userInfo: response.notification.request.content.userInfo
        ) else { return }
        await MainActor.run {
            if LessonCheckIns.handle(answer, store: try? LocalStore.standard()) {
                NotificationCenter.default.post(name: .meldeDataChanged, object: nil)
            }
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
