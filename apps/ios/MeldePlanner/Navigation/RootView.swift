import SwiftUI

enum AppTab: Hashable {
    case home, timetable, calendar, tasks, exams, statistics, more
}

/// Main navigation. Aufgaben and Prüfungen are top-level tabs so the features
/// are visible at a glance. iPhone shows five tabs (Kalender and Statistik
/// live under Mehr); iPad's sidebar shows every destination. The floating
/// Melden button sits on every tab.
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
                    Tab(value: AppTab.home) { screen(DashboardView()) } label: { Label(L("Start"), systemImage: "house") }
                    Tab(value: AppTab.timetable) { screen(TimetableView()) } label: { Label(L("Stundenplan"), systemImage: "tablecells") }
                    Tab(value: AppTab.tasks) { screen(TaskListView()) } label: { Label(L("Aufgaben"), systemImage: "checklist") }
                    Tab(value: AppTab.exams) { screen(ExamListView()) } label: { Label(L("Prüfungen"), systemImage: "doc.viewfinder") }
                    Tab(value: AppTab.calendar) { screen(CalendarView()) } label: { Label(L("Kalender"), systemImage: "calendar") }
                    Tab(value: AppTab.statistics) { screen(StatisticsView()) } label: { Label(L("Statistik"), systemImage: "chart.bar") }
                    Tab(value: AppTab.more) { screen(MoreView()) } label: { Label(L("Mehr"), systemImage: "ellipsis.circle") }
                }
                // Sidebar on iPad (switchable to a top tab bar).
                .tabViewStyle(.sidebarAdaptable)
            } else {
                TabView(selection: $tab) {
                    Tab(value: AppTab.home) { screen(DashboardView()) } label: { Label(L("Start"), systemImage: "house") }
                    Tab(value: AppTab.timetable) { screen(TimetableView()) } label: { Label(L("Stundenplan"), systemImage: "tablecells") }
                    Tab(value: AppTab.tasks) { screen(TaskListView()) } label: { Label(L("Aufgaben"), systemImage: "checklist") }
                    Tab(value: AppTab.exams) { screen(ExamListView()) } label: { Label(L("Prüfungen"), systemImage: "doc.viewfinder") }
                    Tab(value: AppTab.more) { screen(MoreView()) } label: { Label(L("Mehr"), systemImage: "ellipsis.circle") }
                }
                .tabBarMinimizeBehavior(.onScrollDown)
            }
        }
        .onChange(of: sizeClass) { _, newClass in
            // Kalender and Statistik have no iPhone tab; land on Mehr instead.
            if newClass == .compact, [.calendar, .statistics].contains(tab) { tab = .more }
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

    /// One tab's content: its own navigation stack plus the floating Melden button.
    private func screen(_ content: some View) -> some View {
        NavigationStack { content }
            .overlay(alignment: .bottomTrailing) { MeldenButton() }
            // Room under the last row so the floating button never covers content.
            .contentMargins(.bottom, 88, for: .scrollContent)
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
