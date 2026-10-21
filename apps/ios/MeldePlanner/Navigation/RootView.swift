import SwiftUI

enum AppTab: Hashable {
    case home, timetable, calendar, statistics, more
}

/// Five primary destinations in a native Liquid Glass tab bar. The Melde button
/// lives in the bottom accessory so it is one tap away from every tab.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: AppTab = .home
    /// Opened by the widget's Melden link outside lessons.
    @State private var pickingSubject = false

    var body: some View {
        TabView(selection: $tab) {
            Tab(value: AppTab.home) {
                NavigationStack { DashboardView() }
            } label: {
                Label(L("Start"), systemImage: "house")
            }
            Tab(value: AppTab.timetable) {
                NavigationStack { TimetableView() }
            } label: {
                Label(L("Stundenplan"), systemImage: "tablecells")
            }
            Tab(value: AppTab.calendar) {
                NavigationStack { CalendarView() }
            } label: {
                Label(L("Kalender"), systemImage: "calendar")
            }
            Tab(value: AppTab.statistics) {
                NavigationStack { StatisticsView() }
            } label: {
                Label(L("Statistik"), systemImage: "chart.bar")
            }
            Tab(value: AppTab.more) {
                NavigationStack { MoreView() }
            } label: {
                Label(L("Mehr"), systemImage: "ellipsis.circle")
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            MeldeAccessory()
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

    private func open(_ url: URL) {
        guard url.scheme == DeepLink.scheme else { return }
        switch url.host() {
        case "melden":
            tab = .home
            if case .needsSubject = model.recordParticipation() { pickingSubject = true }
        case "hausaufgaben":
            tab = .more
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
