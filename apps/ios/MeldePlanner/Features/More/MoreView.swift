import MeldeCore
import SwiftUI

/// iPhone's Mehr tab. The iPad sidebar lists the same destinations directly.
struct MoreView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        List {
            // On iPhone these have no tab of their own (iPad shows them in the sidebar).
            if sizeClass != .regular {
                Section {
                    NavigationLink { CalendarView() } label: {
                        Label(L("Kalender"), systemImage: "calendar")
                    }
                    NavigationLink { StatisticsView() } label: {
                        Label(L("Statistik"), systemImage: "chart.bar")
                    }
                }
            }
            Section(L("Schule")) {
                NavigationLink { GradesView() } label: {
                    Label(L("Noten"), systemImage: "graduationcap")
                }
                NavigationLink { AbsencesView() } label: {
                    Label(L("Abwesenheiten"), systemImage: "person.crop.circle.badge.clock")
                }
                NavigationLink { HolidayListView() } label: {
                    Label(L("Ferien"), systemImage: "sun.horizon")
                }
                NavigationLink { UntisConnectView() } label: {
                    Label(L("WebUntis"), systemImage: "arrow.triangle.2.circlepath")
                }
                NavigationLink { TeamsConnectView() } label: {
                    Label(L("Microsoft Teams"), systemImage: "person.3")
                }
            }
            Section(L("App")) {
                NavigationLink { SubjectListView() } label: {
                    Label(L("Fächer"), systemImage: "books.vertical")
                }
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
                    Label(L("Startseite anpassen"), systemImage: "rectangle.3.group")
                }
                NavigationLink { AppIconPicker() } label: {
                    Label(L("App-Symbol"), systemImage: "app.badge")
                }
            }
            Section(L("Design")) {
                HStack(spacing: DS.spacingM) {
                    Text(L("Farbe"))
                    Spacer()
                    ForEach(AppTheme.allCases) { theme in
                        let selected = model.preferences.theme == theme
                        Button {
                            model.setTheme(theme)
                        } label: {
                            Circle()
                                .fill(theme.tint)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    if selected {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(3)
                                .overlay(Circle().strokeBorder(selected ? theme.tint : .clear, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(theme.localizedName)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                Picker(L("Darstellung"), selection: Binding(get: { model.preferences.appearance }, set: { model.setAppearance($0) })) {
                    ForEach(AppearanceChoice.allCases) { Text($0.localizedName).tag($0) }
                }
                .pickerStyle(.segmented)
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

/// The Start cards as a list: show, hide, sort and size them. Same layout as
/// "Anpassen" on the Start screen, easier with VoiceOver.
struct DashboardCardsView: View {
    @Environment(AppModel.self) private var model

    private var layout: [CardSlot<DashboardCard>] { model.preferences.homeLayout }

    private var hidden: [DashboardCard] {
        DashboardCard.allCases.filter { kind in !layout.contains { $0.kind == kind } }
    }

    var body: some View {
        List {
            Section {
                ForEach(layout, id: \.kind) { slot in
                    HStack {
                        Label(DashboardView.title(slot.kind), systemImage: DashboardView.symbol(slot.kind))
                        Spacer()
                        Picker(L("Größe"), selection: Binding(
                            get: { slot.size },
                            set: { size in
                                var list = layout
                                if let i = list.firstIndex(where: { $0.kind == slot.kind }) { list[i].size = size }
                                model.setHomeLayout(list)
                            }
                        )) {
                            ForEach(CardSize.allCases) { Text($0.title).tag($0) }
                        }
                        .labelsHidden()
                    }
                }
                .onMove { from, to in
                    var list = layout
                    list.move(fromOffsets: from, toOffset: to)
                    model.setHomeLayout(list)
                }
                .onDelete { offsets in
                    var list = layout
                    list.remove(atOffsets: offsets)
                    model.setHomeLayout(list)
                }
            } header: {
                Text(L("Sichtbar"))
            } footer: {
                Text(L("Ziehen zum Sortieren. Tipp: Auf der Startseite kannst du Karten auch mit „Anpassen“ verschieben."))
            }
            if !hidden.isEmpty {
                Section(L("Ausgeblendet")) {
                    ForEach(hidden) { kind in
                        Button {
                            model.setHomeLayout(layout + [CardSlot(kind: kind, size: .medium)])
                        } label: {
                            Label(DashboardView.title(kind), systemImage: DashboardView.symbol(kind))
                        }
                    }
                }
            }
            Section {
                Button(L("Standard wiederherstellen")) {
                    model.setHomeLayout(CardSlot<DashboardCard>.defaultHome)
                }
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle(L("Startseite anpassen"))
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
