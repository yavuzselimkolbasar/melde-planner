import SwiftUI

enum AppTab: Hashable {
    case home, timetable, calendar, statistics, more
}

/// Five primary destinations in a native Liquid Glass tab bar. The Melde button
/// lives in the bottom accessory so it is one tap away from every tab.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
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
        // Sidebar on iPad (switchable to a top tab bar), tab bar on iPhone.
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            MeldeAccessory()
        }
        .overlay(alignment: .bottomTrailing) {
            // iPad: the sidebar layout has no guaranteed bottom accessory, so Melden floats here.
            if sizeClass == .regular {
                FloatingMeldenButton { pickingSubject = true }
                    .padding(DS.spacingXL)
            }
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

/// Large glass Melden button for iPad. Same one-tap logic as the iPhone accessory.
private struct FloatingMeldenButton: View {
    @Environment(AppModel.self) private var model
    var needsSubject: () -> Void
    @State private var confirmed = false

    var body: some View {
        Button {
            switch model.recordParticipation() {
            case .recorded:
                confirmed = true
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    confirmed = false
                }
            case .needsSubject:
                needsSubject()
            }
        } label: {
            Label(confirmed ? L("Gemeldet") : L("Melden"), systemImage: confirmed ? "checkmark" : "hand.raised.fill")
                .font(.title3.weight(.semibold))
                .contentTransition(.symbolEffect(.replace))
                .padding(.horizontal, DS.spacingL)
                .padding(.vertical, DS.spacingM)
        }
        .buttonStyle(.glassProminent)
        .sensoryFeedback(.success, trigger: confirmed) { _, new in new && model.preferences.haptics }
        .accessibilityLabel(L("Meldung erfassen"))
        .keyboardShortcut("m", modifiers: .command)
    }
}
