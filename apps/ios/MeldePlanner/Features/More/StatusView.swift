import ActivityKit
import SwiftUI
import UserNotifications

/// Shows whether widgets, Live Activities and notifications can work on this
/// install, with one-tap tests. Sideloaded builds differ by signing tool, so
/// this answers "why doesn't X show up?" without guessing.
struct StatusView: View {
    @Environment(AppModel.self) private var model
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var pendingCheckIns = 0
    @State private var message: String?

    var body: some View {
        List {
            Section {
                row(L("Widgets und Melden-Knopf"), ok: model.isSharedWithWidgets,
                    detail: model.isSharedWithWidgets
                        ? L("Verbunden über \(groupName)")
                        : L("Keine App-Gruppe in dieser Installation. Installiere Meldo mit AltStore, dann funktionieren Widgets."))
            } header: {
                Text(L("Widgets"))
            }

            Section {
                row(L("Live-Aktivitäten"), ok: LessonActivity.isAvailable,
                    detail: LessonActivity.isAvailable
                        ? L("Erscheinen während einer Stunde, wenn du Meldo öffnest oder meldest.")
                        : L("In den iOS-Einstellungen für Meldo ausgeschaltet."))
                Button(L("Vorschau anzeigen")) {
                    Task {
                        switch await LessonActivity.preview(model.data, at: model.currentDate, calendar: model.calendar) {
                        case .shown: message = L("Schau auf deinen Sperrbildschirm.")
                        case .disabledInSettings: message = L("Live-Aktivitäten sind in den iOS-Einstellungen aus.")
                        case .noLessons: message = L("Lege zuerst Stunden im Stundenplan an.")
                        case .failed(let reason): message = L("Konnte nicht starten: \(reason)")
                        }
                    }
                }
            } header: {
                Text(L("Live-Aktivität"))
            }

            Section {
                row(L("Mitteilungen erlaubt"), ok: notificationStatus == .authorized || notificationStatus == .provisional,
                    detail: notificationText)
                LabeledContent(L("Geplante Nachfragen"), value: "\(pendingCheckIns)")
                if !model.preferences.askAfterLesson {
                    Button(L("Nach jeder Stunde nachfragen einschalten")) {
                        Task {
                            let allowed = await Reminders.requestAuthorization()
                            model.setAskAfterLesson(allowed)
                            await load()
                        }
                    }
                }
                Button(L("Test-Mitteilung in 5 Sekunden")) {
                    Task { await sendTest() }
                }
            } header: {
                Text(L("Mitteilungen"))
            }

            if let message {
                Section { Text(message) }
            }
        }
        .navigationTitle(L("Status"))
        .task { await load() }
        .refreshable { await load() }
    }

    private var groupName: String { AppGroup.identifier ?? "–" }

    private var notificationText: String {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral: L("Erlaubt.")
        case .denied: L("Abgelehnt. Erlaube sie in den iOS-Einstellungen unter Mitteilungen → Meldo.")
        default: L("Noch nicht gefragt.")
        }
    }

    private func row(_ title: String, ok: Bool, detail: String) -> some View {
        HStack(alignment: .top, spacing: DS.spacingM) {
            Image(systemName: ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(ok ? Color.green : Color.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.semibold))
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func load() async {
        let center = UNUserNotificationCenter.current()
        notificationStatus = await center.notificationSettings().authorizationStatus
        pendingCheckIns = await center.pendingNotificationRequests().filter { $0.identifier.hasPrefix("checkin-") }.count
    }

    private func sendTest() async {
        guard await Reminders.requestAuthorization() else {
            message = L("Mitteilungen sind aus. Erlaube sie in den Einstellungen, damit Erinnerungen ankommen.")
            await load()
            return
        }
        let content = UNMutableNotificationContent()
        content.title = L("Meldo")
        content.body = L("Hast du dich gemeldet?")
        content.sound = .default
        content.categoryIdentifier = LessonCheckIns.category
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)", content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        )
        try? await UNUserNotificationCenter.current().add(request)
        message = L("Sperre jetzt dein iPhone oder wechsle zum Home-Bildschirm.")
        await load()
    }
}
