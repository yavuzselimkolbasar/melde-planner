import MeldeCore
import SwiftUI

/// Calendar with timetable integration: pick any date to see its lessons
/// (with holidays applied) and the Meldungen recorded that day.
/// Homework due that day is listed too. On iPad the picker and the day sit side by side.
struct CalendarView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    /// The day the student picked; today (by the model's clock) until they pick one.
    @State private var picked: Date?

    private var date: Date { picked ?? model.currentDate }

    var body: some View {
        let layout = sizeClass == .regular
            ? AnyLayout(HStackLayout(alignment: .top, spacing: DS.spacingL))
            : AnyLayout(VStackLayout(spacing: DS.spacingL))
        ScrollView {
            layout {
                Card {
                    DatePicker(L("Datum"), selection: Binding(get: { date }, set: { picked = $0 }), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Localization.locale)
                }
                .frame(maxWidth: sizeClass == .regular ? 420 : .infinity)
                VStack(spacing: DS.spacingL) {
                    dayDetails
                }
            }
            .padding(DS.spacingL)
        }
        .background(ThemedBackground())
        .navigationTitle(L("Kalender"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(L("Heute")) { picked = nil }
            }
        }
    }

    @ViewBuilder
    private var dayDetails: some View {
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
}
