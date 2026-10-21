import SwiftUI

enum AppTab: Hashable {
    case home, timetable, calendar, tasks, exams, statistics, more
    case absences, holidays, untis, teams, subjects, settings, status, about
}

/// Main navigation. iPhone shows five tabs (the rest lives under Mehr); the
/// iPad sidebar lists every destination directly, grouped into Schule and App.
/// The floating Melden button only appears where you'd use it in class:
/// Start and Stundenplan.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var tab: AppTab = .home
    /// Opened by the widget's Melden link outside lessons.
    @State private var pickingSubject = false

    var body: some View {
        Group {
            if sizeClass == .regular {
                TabView(selection: $tab) {
                    Tab(value: AppTab.home) { screen(DashboardView(), melden: true) } label: { Label(L("Start"), systemImage: "house") }
                    Tab(value: AppTab.timetable) { screen(TimetableView(), melden: true) } label: { Label(L("Stundenplan"), systemImage: "tablecells") }
                    Tab(value: AppTab.tasks) { screen(TaskListView()) } label: { Label(L("Aufgaben"), systemImage: "checklist") }
                    Tab(value: AppTab.exams) { screen(ExamListView()) } label: { Label(L("Prüfungen"), systemImage: "doc.viewfinder") }
                    Tab(value: AppTab.calendar) { screen(CalendarView()) } label: { Label(L("Kalender"), systemImage: "calendar") }
                    Tab(value: AppTab.statistics) { screen(StatisticsView()) } label: { Label(L("Statistik"), systemImage: "chart.bar") }
                    TabSection(L("Schule")) {
                        Tab(value: AppTab.absences) { screen(AbsencesView()) } label: { Label(L("Abwesenheiten"), systemImage: "person.crop.circle.badge.clock") }
                            .tabPlacement(.sidebarOnly)
                        Tab(value: AppTab.holidays) { screen(HolidayListView()) } label: { Label(L("Ferien"), systemImage: "sun.horizon") }
                            .tabPlacement(.sidebarOnly)
                        Tab(value: AppTab.untis) { screen(UntisConnectView()) } label: { Label(L("WebUntis"), systemImage: "arrow.triangle.2.circlepath") }
                            .tabPlacement(.sidebarOnly)
                        Tab(value: AppTab.teams) { screen(TeamsConnectView()) } label: { Label(L("Microsoft Teams"), systemImage: "person.3") }
                            .tabPlacement(.sidebarOnly)
                    }
                    TabSection(L("App")) {
                        Tab(value: AppTab.subjects) { screen(SubjectListView()) } label: { Label(L("Fächer"), systemImage: "books.vertical") }
                            .tabPlacement(.sidebarOnly)
                        Tab(value: AppTab.settings) { screen(SettingsView()) } label: { Label(L("Einstellungen"), systemImage: "gearshape") }
                            .tabPlacement(.sidebarOnly)
                        Tab(value: AppTab.status) { screen(StatusView()) } label: { Label(L("Status"), systemImage: "stethoscope") }
                            .tabPlacement(.sidebarOnly)
                        Tab(value: AppTab.about) { screen(AboutView()) } label: { Label(L("Über Meldo"), systemImage: "info.circle") }
                            .tabPlacement(.sidebarOnly)
                    }
                }
                // Sidebar on iPad (switchable to a top tab bar).
                .tabViewStyle(.sidebarAdaptable)
            } else {
                TabView(selection: $tab) {
                    Tab(value: AppTab.home) { screen(DashboardView(), melden: true) } label: { Label(L("Start"), systemImage: "house") }
                    Tab(value: AppTab.timetable) { screen(TimetableView(), melden: true) } label: { Label(L("Stundenplan"), systemImage: "tablecells") }
                    Tab(value: AppTab.tasks) { screen(TaskListView()) } label: { Label(L("Aufgaben"), systemImage: "checklist") }
                    Tab(value: AppTab.exams) { screen(ExamListView()) } label: { Label(L("Prüfungen"), systemImage: "doc.viewfinder") }
                    Tab(value: AppTab.more) { screen(MoreView()) } label: { Label(L("Mehr"), systemImage: "ellipsis.circle") }
                }
                .tabBarMinimizeBehavior(.onScrollDown)
            }
        }
        .onChange(of: sizeClass) { _, newClass in
            // Sidebar-only destinations have no iPhone tab; land on Mehr instead.
            let phoneTabs: [AppTab] = [.home, .timetable, .tasks, .exams, .more]
            if newClass == .compact, !phoneTabs.contains(tab) { tab = .more }
            if newClass == .regular, tab == .more { tab = .settings }
        }
        .overlay(alignment: .top) {
            if let problem = model.storageProblem {
                StorageBanner(message: problem)
            }
        }
        .onOpenURL(perform: open)
        .sheet(isPresented: $pickingSubject) {
            SubjectPickerSheet { subjectID in
                model.recordParticipation(subjectID: subjectID)
            }
        }
    }

    /// One tab's content in its own navigation stack. With `melden`, the root
    /// screen gets the floating Melden button; screens pushed from it don't.
    @ViewBuilder
    private func screen(_ content: some View, melden: Bool = false) -> some View {
        if melden {
            NavigationStack {
                content
                    .overlay(alignment: .bottomTrailing) { MeldenButton() }
                    // Room under the last row so the floating button never covers content.
                    .contentMargins(.bottom, 88, for: .scrollContent)
            }
        } else {
            NavigationStack { content }
        }
    }

    private func open(_ url: URL) {
        guard url.scheme == DeepLink.scheme else { return }
        switch url.host() {
        case "melden":
            tab = .home
            if case .needsSubject = model.recordParticipation() { pickingSubject = true }
        case "hausaufgaben":
            tab = .tasks
        default:
            break
        }
    }
}

private struct StorageBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote.weight(.medium))
            .padding(DS.spacingM)
            .glassEffect(.regular.tint(.orange.opacity(0.3)), in: .rect(cornerRadius: DS.rowRadius))
            .padding(.horizontal, DS.spacingL)
            .accessibilityAddTraits(.isStaticText)
    }
}
