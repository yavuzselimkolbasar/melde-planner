import MeldeCore
import SwiftUI

/// Weekly timetable: swipe between days or tap a weekday; the current lesson is highlighted.
struct TimetableView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var weekday = 0
    @State private var editing: Lesson?
    @State private var creating = false
    @State private var managingSubjects = false
    @State private var homeworkFor: HomeworkPrefill?

    /// Monday–Friday, plus Saturday when the student has Saturday lessons.
    private var days: [Int] {
        model.lessons.contains { $0.weekday == 5 } ? Array(0...5) : Array(0...4)
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                // iPad / wide windows: the whole week side by side.
                WeekGrid(
                    days: days,
                    onSelect: { editing = $0 },
                    onAdd: { day in weekday = day; creating = true },
                    onHomework: { homeworkFor = HomeworkPrefill(subjectID: $0.subjectID) }
                )
            } else {
                VStack(spacing: 0) {
                    WeekdayBar(days: days, selection: $weekday)
                        .padding(.horizontal, DS.spacingL)
                        .padding(.vertical, DS.spacingS)
                    TabView(selection: $weekday) {
                        ForEach(days, id: \.self) { day in
                            DayColumn(weekday: day, onSelect: { editing = $0 }, onAdd: { creating = true }, onHomework: { homeworkFor = HomeworkPrefill(subjectID: $0.subjectID) })
                                .tag(day)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        }
        .background(ThemedBackground())
        .navigationTitle(L("Stundenplan"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L("Fächer"), systemImage: "books.vertical") { managingSubjects = true }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(L("Stunde hinzufügen"), systemImage: "plus") { creating = true }
                    .disabled(model.subjects.isEmpty)
            }
        }
        .onAppear {
            let today = model.calendar.mondayIndex(of: model.currentDate)
            weekday = days.contains(today) ? today : 0
        }
        .sheet(item: $editing) { LessonEditorView(lesson: $0, weekday: $0.weekday) }
        .sheet(isPresented: $creating) { LessonEditorView(lesson: nil, weekday: weekday) }
        .sheet(item: $homeworkFor) { prefill in
            TaskEditorView(task: nil, kind: .homework, subjectID: prefill.subjectID)
        }
        .sheet(isPresented: $managingSubjects) {
            NavigationStack { SubjectListView() }
        }
    }
}

/// Subject to preselect when adding homework from a lesson.
private struct HomeworkPrefill: Identifiable {
    let id = UUID()
    let subjectID: UUID
}

/// Glass weekday selector; the selected day morphs between positions.
private struct WeekdayBar: View {
    let days: [Int]
    @Binding var selection: Int
    @Namespace private var glass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GlassEffectContainer(spacing: DS.spacingS) {
            HStack(spacing: DS.spacingS) {
                ForEach(days, id: \.self) { day in
                    Button {
                        withAnimation(reduceMotion ? nil : .spring(duration: 0.35)) { selection = day }
                    } label: {
                        Text(WeekdayText.short(day))
                            .font(.subheadline.weight(selection == day ? .bold : .regular))
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(selection == day ? .regular.tint(.accentColor.opacity(0.35)).interactive() : .identity, in: .capsule)
                    .glassEffectID(day, in: glass)
                    .accessibilityLabel(WeekdayText.full(day))
                    .accessibilityAddTraits(selection == day ? .isSelected : [])
                }
            }
        }
    }
}

private struct DayColumn: View {
    @Environment(AppModel.self) private var model
    let weekday: Int
    var onSelect: (Lesson) -> Void
    var onAdd: () -> Void
    var onHomework: (Lesson) -> Void

    var body: some View {
        let lessons = model.lessons(onWeekday: weekday)
        TimelineView(.everyMinute) { _ in
            let isToday = model.calendar.mondayIndex(of: model.currentDate) == weekday
            let current = isToday ? model.currentLesson(at: model.currentDate) : nil
            ScrollView {
                VStack(spacing: DS.spacingS) {
                    if lessons.isEmpty {
                        ContentUnavailableView {
                            Label(L("Keine Stunden"), systemImage: "tablecells")
                        } description: {
                            Text(model.subjects.isEmpty
                                 ? L("Lege zuerst unter „Fächer“ deine Fächer an.")
                                 : L("Füge die Stunden für \(WeekdayText.full(weekday)) hinzu."))
                        } actions: {
                            if !model.subjects.isEmpty {
                                Button(L("Stunde hinzufügen"), action: onAdd)
                                    .buttonStyle(.glassProminent)
                            }
                        }
                        .padding(.top, DS.spacingXL)
                    }
                    ForEach(lessons) { lesson in
                        Button { onSelect(lesson) } label: {
                            LessonCard(lesson: lesson, isCurrent: current?.lessonId == lesson.id.uuidString)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(L("Hausaufgabe eintragen"), systemImage: "book") { onHomework(lesson) }
                            Button(L("Bearbeiten"), systemImage: "pencil") { onSelect(lesson) }
                            Button(L("Löschen"), systemImage: "trash", role: .destructive) {
                                model.deleteLesson(lesson.id)
                            }
                        }
                    }
                }
                .padding(DS.spacingL)
            }
        }
    }
}

private struct LessonCard: View {
    @Environment(AppModel.self) private var model
    let lesson: Lesson
    let isCurrent: Bool

    var body: some View {
        let subject = model.subject(lesson.subjectID)
        let color = subject?.color.color ?? .gray
        HStack(spacing: DS.spacingM) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(color)
                .frame(width: 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(subject?.name ?? L("Unbekanntes Fach"))
                    .font(.headline)
                HStack(spacing: DS.spacingS) {
                    Text(TimeText.range(lesson.startMinute, lesson.endMinute)).monospacedDigit()
                    if !lesson.room.isEmpty { Text(verbatim: "· \(lesson.room)") }
                    if lesson.parity != .every {
                        Badge(text: lesson.parity == .a ? L("A-Woche") : L("B-Woche"), color: .secondary)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if isCurrent { Badge(text: L("Jetzt"), color: color) }
            SubjectIcon(subject: subject, size: 32)
        }
        .padding(DS.spacingM)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: .rect(cornerRadius: DS.rowRadius, style: .continuous)
        )
        .overlay {
            if isCurrent {
                RoundedRectangle(cornerRadius: DS.rowRadius, style: .continuous)
                    .strokeBorder(color, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(L("Zum Bearbeiten tippen"))
    }
}

/// All school days as columns (iPad). Same cards and actions as the phone's day pages.
private struct WeekGrid: View {
    @Environment(AppModel.self) private var model
    let days: [Int]
    var onSelect: (Lesson) -> Void
    var onAdd: (Int) -> Void
    var onHomework: (Lesson) -> Void

    var body: some View {
        TimelineView(.everyMinute) { _ in
            let today = model.calendar.mondayIndex(of: model.currentDate)
            let current = model.currentLesson(at: model.currentDate)
            ScrollView {
                HStack(alignment: .top, spacing: DS.spacingM) {
                    ForEach(days, id: \.self) { day in
                        VStack(alignment: .leading, spacing: DS.spacingS) {
                            HStack {
                                Text(WeekdayText.full(day))
                                    .font(.headline)
                                    .foregroundStyle(day == today ? Color.accentColor : Color.primary)
                                Spacer()
                                Button(L("Stunde hinzufügen"), systemImage: "plus") { onAdd(day) }
                                    .labelStyle(.iconOnly)
                                    .disabled(model.subjects.isEmpty)
                            }
                            .padding(.horizontal, DS.spacingXS)
                            ForEach(model.lessons(onWeekday: day)) { lesson in
                                Button { onSelect(lesson) } label: {
                                    LessonCard(lesson: lesson, isCurrent: day == today && current?.lessonId == lesson.id.uuidString)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(L("Hausaufgabe eintragen"), systemImage: "book") { onHomework(lesson) }
                                    Button(L("Bearbeiten"), systemImage: "pencil") { onSelect(lesson) }
                                    Button(L("Löschen"), systemImage: "trash", role: .destructive) { model.deleteLesson(lesson.id) }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                }
                .padding(DS.spacingL)
            }
        }
    }
}
