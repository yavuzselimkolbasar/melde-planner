import MeldeCore
import SwiftUI

/// Home: adapts to the time of day and to what the student has set up.
struct DashboardView: View {
    @Environment(AppModel.self) private var model
    @State private var addingSubject = false
    @State private var addingLesson = false

    var body: some View {
        TimelineView(.everyMinute) { context in
            ScrollView {
                VStack(spacing: DS.spacingL) {
                    if model.subjects.isEmpty {
                        GettingStartedCard(addSubject: { addingSubject = true })
                    } else {
                        TodayCard(now: context.date, addLesson: { addingLesson = true })
                        WeekParticipationCard(now: context.date)
                        HomeworkCard(now: context.date)
                    }
                }
                .padding(DS.spacingL)
            }
            .background(ThemedBackground())
            .navigationTitle(greeting(for: context.date))
        }
        .sheet(isPresented: $addingSubject) { SubjectEditorView(subject: nil) }
        .sheet(isPresented: $addingLesson) { LessonEditorView(lesson: nil, weekday: model.calendar.mondayIndex(of: model.currentDate)) }
    }

    private func greeting(for date: Date) -> String {
        switch model.calendar.component(.hour, from: date) {
        case 5..<11: L("Guten Morgen")
        case 11..<17: L("Hallo")
        case 17..<22: L("Guten Abend")
        default: L("Gute Nacht")
        }
    }
}

private struct GettingStartedCard: View {
    var addSubject: () -> Void

    var body: some View {
        Card(title: L("Los geht's"), systemImage: "sparkles") {
            Text(L("Lege deine Fächer und deinen Stundenplan an. Danach ordnet Melde Planner jede Meldung automatisch der laufenden Stunde zu."))
                .foregroundStyle(.secondary)
            Button(action: addSubject) {
                Label(L("Erstes Fach anlegen"), systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

private struct TodayCard: View {
    @Environment(AppModel.self) private var model
    var now: Date
    var addLesson: () -> Void

    var body: some View {
        let today = model.occurrences(on: now)
        let current = model.currentLesson(at: now)
        Card(title: now.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Localization.locale)), systemImage: "sun.max") {
            if today.isEmpty {
                if let next = model.nextLesson(after: now) {
                    let name = model.subject(for: next)?.name ?? L("Unbekanntes Fach")
                    let day = nextDayText(next)
                    let time = TimeText.clock(next.startMinute)
                    VStack(alignment: .leading, spacing: DS.spacingXS) {
                        Text(L("Heute kein Unterricht."))
                            .font(.headline)
                        Text(L("Nächste Stunde: \(name), \(day) \(time)"))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(L("Noch keine Stunden im Stundenplan."))
                        .foregroundStyle(.secondary)
                    Button(L("Stunde hinzufügen"), systemImage: "plus", action: addLesson)
                        .buttonStyle(.glass)
                }
            } else {
                VStack(spacing: DS.spacingM) {
                    ForEach(today, id: \.lessonId) { occurrence in
                        LessonRow(
                            occurrence: occurrence,
                            subject: model.subject(for: occurrence),
                            isCurrent: occurrence.lessonId == current?.lessonId
                        )
                        .opacity(isOver(occurrence) ? 0.5 : 1)
                    }
                }
            }
        }
    }

    private func isOver(_ o: FfiOccurrence) -> Bool {
        let minute = model.calendar.component(.hour, from: now) * 60 + model.calendar.component(.minute, from: now)
        return Int(o.endMinute) <= minute
    }

    private func nextDayText(_ next: FfiOccurrence) -> String {
        guard let date = next.date.date(in: model.calendar) else { return "" }
        if model.calendar.isDateInTomorrow(date) { return L("morgen") }
        return date.formatted(.dateTime.weekday(.wide).locale(Localization.locale))
    }
}

private struct WeekParticipationCard: View {
    @Environment(AppModel.self) private var model
    var now: Date
    @State private var editingGoal = false

    var body: some View {
        let summary = model.weekSummary(containing: now)
        let total = Int(summary?.total ?? 0)
        let goal = model.preferences.weeklyGoal
        Card(title: L("Meldungen diese Woche"), systemImage: "hand.raised") {
            HStack(spacing: DS.spacingXL) {
                ZStack {
                    ProgressRing(progress: goal.map { Double(total) / Double(max($0, 1)) } ?? 0)
                    VStack(spacing: 0) {
                        Text(total, format: .number)
                            .font(.title.weight(.bold))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        if let goal {
                            Text(L("von \(goal)"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(width: 96, height: 96)

                VStack(alignment: .leading, spacing: DS.spacingS) {
                    let streak = model.streak(asOf: now)
                    Label(L("\(streak) Schultage in Folge"), systemImage: "flame")
                        .foregroundStyle(streak > 0 ? .orange : .secondary)
                    if let goal {
                        let remaining = max(goal - total, 0)
                        Text(remaining == 0 ? L("Wochenziel erreicht.") : L("Noch \(remaining) bis zum Wochenziel."))
                            .foregroundStyle(.secondary)
                    }
                    Button(goal == nil ? L("Wochenziel festlegen") : L("Ziel ändern")) { editingGoal = true }
                        .buttonStyle(.glass)
                        .controlSize(.small)
                }
                .font(.subheadline)
            }
            Text(L("Meldungen zählen deine Beteiligung. Die mündliche Note vergibt deine Lehrkraft."))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .sheet(isPresented: $editingGoal) { WeeklyGoalSheet(now: now) }
    }
}

struct WeeklyGoalSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var now: Date
    @State private var goal = 10

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $goal, in: 1...200) {
                        Text(L("\(goal) Meldungen pro Woche"))
                    }
                } footer: {
                    if let suggestion = model.suggestedWeeklyGoal(asOf: now) {
                        Text(L("Vorschlag aus deinen letzten Wochen: \(suggestion)"))
                    } else {
                        Text(L("Nach einer Woche mit Meldungen schlagen wir dir ein realistisches Ziel vor."))
                    }
                }
                if let suggestion = model.suggestedWeeklyGoal(asOf: now), suggestion != goal {
                    Button(L("Vorschlag übernehmen")) { goal = suggestion }
                }
                if model.preferences.weeklyGoal != nil {
                    Button(L("Ziel entfernen"), role: .destructive) {
                        model.setWeeklyGoal(nil)
                        dismiss()
                    }
                }
            }
            .navigationTitle(L("Wochenziel"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("Abbrechen"), role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("Sichern")) {
                        model.setWeeklyGoal(goal)
                        dismiss()
                    }
                }
            }
            .onAppear {
                goal = model.preferences.weeklyGoal ?? model.suggestedWeeklyGoal(asOf: now) ?? 10
            }
        }
        .presentationDetents([.medium])
    }
}

extension Calendar {
    /// Monday-first weekday index, 0…6.
    func mondayIndex(of date: Date) -> Int {
        (component(.weekday, from: date) + 5) % 7
    }
}
