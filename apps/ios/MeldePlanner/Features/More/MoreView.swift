import MeldeCore
import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            Section {
                NavigationLink { TaskListView() } label: {
                    Label(L("Aufgaben"), systemImage: "checklist")
                }
                NavigationLink { ExamListView() } label: {
                    Label(L("Prüfungen & Scans"), systemImage: "doc.viewfinder")
                }
                NavigationLink { SubjectListView() } label: {
                    Label(L("Fächer"), systemImage: "books.vertical")
                }
                NavigationLink { UntisConnectView() } label: {
                    Label(L("WebUntis"), systemImage: "arrow.triangle.2.circlepath")
                }
            }
            Section {
                NavigationLink { SettingsView() } label: {
                    Label(L("Einstellungen"), systemImage: "gearshape")
                }
                NavigationLink { StatusView() } label: {
                    Label(L("Status: Widgets, Mitteilungen"), systemImage: "stethoscope")
                }
                NavigationLink { AboutView() } label: {
                    Label(L("Über Meldo"), systemImage: "info.circle")
                }
            }
        }
        .navigationTitle(L("Mehr"))
    }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var editingGoal = false
    @State private var notificationsDenied = false

    var body: some View {
        Form {
            Section(L("Sprache")) {
                Picker(L("Sprache"), selection: Binding(get: { model.preferences.language }, set: { model.setLanguage($0) })) {
                    ForEach(AppLanguage.allCases) { Text($0.nativeName).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section(L("Anpassen")) {
                Toggle(L("Meldo anzeigen"), isOn: Binding(get: { model.preferences.showMascot }, set: { model.setShowMascot($0) }))
                Toggle(L("Haptisches Feedback"), isOn: Binding(get: { model.preferences.haptics }, set: { model.setHaptics($0) }))
                NavigationLink { DashboardCardsView() } label: {
                    Label(L("Startseite anordnen"), systemImage: "rectangle.3.group")
                }
                NavigationLink { AppIconPicker() } label: {
                    Label(L("App-Symbol"), systemImage: "app.badge")
                }
            }
            Section(L("Design")) {
                Picker(L("Design"), selection: Binding(get: { model.preferences.theme }, set: { model.setTheme($0) })) {
                    ForEach(AppTheme.allCases) { theme in
                        Label {
                            Text(theme.localizedName)
                        } icon: {
                            Circle().fill(theme.wash ?? .secondary).frame(width: 14, height: 14)
                        }
                        .tag(theme)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            Section {
                Toggle(L("A/B-Wochen verwenden"), isOn: Binding(
                    get: { model.preferences.weekAReference != nil },
                    set: { model.setWeekAReference($0 ? model.currentDate : nil) }
                ))
                if model.preferences.weekAReference != nil {
                    Picker(L("Diese Woche ist"), selection: Binding(
                        get: { model.isWeekA(model.currentDate) },
                        set: { model.setCurrentWeekIsA($0) }
                    )) {
                        Text(L("A-Woche")).tag(true)
                        Text(L("B-Woche")).tag(false)
                    }
                }
            } header: {
                Text(L("Stundenplan"))
            } footer: {
                Text(L("Für Stunden, die nur jede zweite Woche stattfinden."))
            }
            Section(L("Melde Tracker")) {
                Button {
                    editingGoal = true
                } label: {
                    LabeledContent(L("Wochenziel"), value: model.preferences.weeklyGoal.map { "\($0)" } ?? L("Keins"))
                }
                .foregroundStyle(.primary)
            }
            Section {
                Toggle(L("Nach jeder Stunde nachfragen"), isOn: Binding(
                    get: { model.preferences.askAfterLesson },
                    set: { on in
                        guard on else { return model.setAskAfterLesson(false) }
                        Task {
                            let allowed = await Reminders.requestAuthorization()
                            notificationsDenied = !allowed
                            model.setAskAfterLesson(allowed)
                        }
                    }
                ))
                Toggle(L("Live-Aktivität während der Stunde"), isOn: Binding(
                    get: { model.preferences.liveActivities },
                    set: { model.setLiveActivities($0) }
                ))
            } header: {
                Text(L("Mitteilungen"))
            } footer: {
                if notificationsDenied {
                    Text(L("Mitteilungen sind aus. Erlaube sie in den Einstellungen, damit Erinnerungen ankommen."))
                } else {
                    Text(L("Fragt kurz nach dem Klingeln „Hast du dich gemeldet?“. Antworte direkt in der Mitteilung. Stunden mit Meldung werden übersprungen."))
                }
            }
            if !model.isSharedWithWidgets {
                Section(L("Widgets")) {
                    Label(L("Widgets und der Melden-Knopf brauchen eine App-Gruppe. Installiere Meldo mit AltStore, damit sie deine Daten sehen."), systemImage: "info.circle")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle(L("Einstellungen"))
        .sheet(isPresented: $editingGoal) { WeeklyGoalSheet(now: model.currentDate) }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                LabeledContent(L("Version"), value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–")
                LabeledContent(L("Rust-Kern"), value: coreVersion())
            }
            Section(L("Datenschutz")) {
                Text(L("Deine Daten bleiben auf diesem Gerät. Es gibt keine Werbung und kein Tracking. Die Synchronisierung mit einem Konto folgt in einer späteren Version und ist freiwillig."))
                    .font(.subheadline)
            }
            Section(L("Hinweis")) {
                Text(L("Meldo zählt deine Beteiligung und berechnet Durchschnitte. Offizielle Noten vergibt allein deine Schule."))
                    .font(.subheadline)
            }
        }
        .navigationTitle(L("Über Meldo"))
    }
}

/// Choose which home cards appear and in which order.
struct DashboardCardsView: View {
    @Environment(AppModel.self) private var model

    private var cards: [DashboardCard] {
        let visible = model.preferences.dashboardCards
        return visible + DashboardCard.allCases.filter { !visible.contains($0) }
    }

    var body: some View {
        List {
            Section {
                ForEach(cards) { card in
                    Toggle(isOn: Binding(
                        get: { model.preferences.dashboardCards.contains(card) },
                        set: { on in
                            var visible = model.preferences.dashboardCards
                            if on { visible.append(card) } else { visible.removeAll { $0 == card } }
                            model.setDashboardCards(visible)
                        }
                    )) {
                        Label(Self.title(card), systemImage: Self.symbol(card))
                    }
                }
                .onMove { from, to in
                    var ordered = cards
                    ordered.move(fromOffsets: from, toOffset: to)
                    let visible = Set(model.preferences.dashboardCards)
                    model.setDashboardCards(ordered.filter(visible.contains))
                }
            } footer: {
                Text(L("Ziehen zum Sortieren, Schalter zum Ein- und Ausblenden."))
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle(L("Startseite anordnen"))
    }

    static func title(_ card: DashboardCard) -> String {
        switch card {
        case .today: L("Heute")
        case .participation: L("Meldungen diese Woche")
        case .homework: L("Hausaufgaben")
        }
    }

    static func symbol(_ card: DashboardCard) -> String {
        switch card {
        case .today: "sun.max"
        case .participation: "hand.raised"
        case .homework: "book"
        }
    }
}

/// Alternate app icons, rendered from the same Meldo artwork.
struct AppIconPicker: View {
    @Environment(AppModel.self) private var model
    @State private var problem: String?

    var body: some View {
        List {
            ForEach(AppIconChoice.allCases) { choice in
                Button {
                    Task { await apply(choice) }
                } label: {
                    HStack {
                        Text(Self.title(choice)).foregroundStyle(.primary)
                        Spacer()
                        if model.preferences.appIcon == choice {
                            Image(systemName: "checkmark").foregroundStyle(.tint)
                        }
                    }
                }
            }
            if let problem {
                Text(problem).foregroundStyle(.red)
            }
        }
        .navigationTitle(L("App-Symbol"))
    }

    private func apply(_ choice: AppIconChoice) async {
        guard UIApplication.shared.supportsAlternateIcons else {
            problem = L("Dieses Gerät unterstützt keine anderen App-Symbole.")
            return
        }
        do {
            try await UIApplication.shared.setAlternateIconName(choice.assetName)
            model.setAppIcon(choice)
            problem = nil
        } catch {
            problem = L("Das App-Symbol konnte nicht geändert werden.")
        }
    }

    static func title(_ choice: AppIconChoice) -> String {
        switch choice {
        case .standard: L("Indigo (Standard)")
        case .orange: L("Orange")
        case .night: L("Nacht")
        }
    }
}
