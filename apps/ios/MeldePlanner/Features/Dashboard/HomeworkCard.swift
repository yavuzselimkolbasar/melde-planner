import SwiftUI

/// Homework due soon, check-off in place, and the homework streak.
struct HomeworkCard: View {
    @Environment(AppModel.self) private var model
    var now: Date
    @State private var adding = false

    var body: some View {
        let upcoming = model.upcomingHomework(today: now)
        let streak = model.homeworkStreak(asOf: now)
        Card(title: L("Hausaufgaben"), systemImage: "book") {
            if upcoming.isEmpty {
                Text(L("Für heute und morgen ist alles erledigt."))
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(upcoming) { task in
                        TaskRow(task: task, today: now) {}
                    }
                }
            }
            HStack {
                Label(L("\(streak) Tage pünktlich in Folge"), systemImage: "flame")
                    .foregroundStyle(streak > 0 ? Color.orange : Color.secondary)
                    .font(.subheadline)
                Spacer()
                NavigationLink(L("Alle")) { TaskListView() }
                    .font(.subheadline.weight(.semibold))
            }
            Button(L("Hausaufgabe eintragen"), systemImage: "plus") { adding = true }
                .buttonStyle(.glass)
                .controlSize(.small)
        }
        .sheet(isPresented: $adding) { TaskEditorView(task: nil, kind: .homework) }
    }
}
