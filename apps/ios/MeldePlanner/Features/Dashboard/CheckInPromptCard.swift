import SwiftUI

/// One-time suggestion on the start screen to turn on "Hast du dich gemeldet?"
/// after each lesson. Disappears once answered either way.
struct CheckInPromptCard: View {
    @Environment(AppModel.self) private var model
    @State private var denied = false

    var body: some View {
        if !model.preferences.askAfterLesson, !model.preferences.checkInPromptDismissed, !model.lessons.isEmpty {
            Card(title: L("Nie mehr vergessen"), systemImage: "bell.badge") {
                HStack(alignment: .center, spacing: DS.spacingM) {
                    Mascot(mood: .wave, size: 56)
                    Text(L("Soll ich dich nach jeder Stunde fragen, ob du dich gemeldet hast? Du antwortest direkt in der Mitteilung."))
                        .foregroundStyle(.secondary)
                }
                if denied {
                    Text(L("Mitteilungen sind aus. Erlaube sie in den Einstellungen, damit Erinnerungen ankommen."))
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
                HStack {
                    Button(L("Ja, einschalten")) {
                        Task {
                            let allowed = await Reminders.requestAuthorization()
                            denied = !allowed
                            if allowed { model.setAskAfterLesson(true) }
                        }
                    }
                    .buttonStyle(.glassProminent)
                    Button(L("Später")) { model.dismissCheckInPrompt() }
                        .buttonStyle(.glass)
                }
            }
        }
    }
}
