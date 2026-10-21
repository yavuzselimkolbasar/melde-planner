import MeldeCore
import SwiftUI

/// Calendar with timetable integration: pick any date to see its lessons
/// (with holidays applied) and the Meldungen recorded that day.
/// Exams, homework and events are added in Phase 4.
struct CalendarView: View {
    @Environment(AppModel.self) private var model
    @State private var date = Date.now

    var body: some View {
        ScrollView {
            VStack(spacing: DS.spacingL) {
                Card {
                    DatePicker(L("Datum"), selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Localization.locale)
                }
                let occurrences = model.occurrences(on: date)
                Card(title: date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Localization.locale)), systemImage: "tablecells") {
                    if occurrences.isEmpty {
                        Text(L("Kein Unterricht an diesem Tag."))
                            .foregroundStyle(.secondary)
                    } else {
                        VStack(spacing: DS.spacingM) {
                            ForEach(occurrences, id: \.lessonId) { occurrence in
                                LessonRow(occurrence: occurrence, subject: model.subject(for: occurrence))
                            }
                        }
                    }
                }
                let due = model.tasks(dueOn: date)
                if !due.isEmpty {
                    Card(title: L("Fällig"), systemImage: "book") {
                        ForEach(due) { task in
                            TaskRow(task: task, today: model.currentDate) {}
                        }
                    }
                }
                let entries = model.entries(on: date)
                if !entries.isEmpty {
                    Card(title: L("Meldungen"), systemImage: "hand.raised") {
                        ForEach(entries) { entry in
                            HStack {
                                SubjectIcon(subject: model.subject(entry.subjectID), size: 28)
                                Text(model.subject(entry.subjectID)?.name ?? L("Ohne Fach"))
                                Spacer()
                                Text(entry.recordedAt, format: .dateTime.hour().minute())
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                            .contextMenu {
                                Button(L("Löschen"), systemImage: "trash", role: .destructive) {
                                    model.deleteParticipation(entry.id)
                                }
                            }
                        }
                    }
                }
            }
            .padding(DS.spacingL)
        }
        .background(ThemedBackground())
        .navigationTitle(L("Kalender"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(L("Heute")) { date = .now }
            }
        }
    }
}
