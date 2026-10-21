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
            }
            Section {
                NavigationLink { SettingsView() } label: {
                    Label(L("Einstellungen"), systemImage: "gearshape")
                }
                NavigationLink { AboutView() } label: {
                    Label(L("Über Melde Planner"), systemImage: "info.circle")
                }
            }
        }
        .navigationTitle(L("Mehr"))
    }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var editingGoal = false

    var body: some View {
        Form {
            Section(L("Sprache")) {
                Picker(L("Sprache"), selection: Binding(get: { model.preferences.language }, set: { model.setLanguage($0) })) {
                    ForEach(AppLanguage.allCases) { Text($0.nativeName).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
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
                Text(L("Melde Planner zählt deine Beteiligung und berechnet Durchschnitte. Offizielle Noten vergibt allein deine Schule."))
                    .font(.subheadline)
            }
        }
        .navigationTitle(L("Über Melde Planner"))
    }
}
