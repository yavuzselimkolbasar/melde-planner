import MeldeCore
import SwiftUI

/// Untis-style timetable: a time grid with period numbers and bell times,
/// blocks as long as the lessons, breaks between them, and color for changes
/// (exam yellow, room change green, cancelled red, Vertretung orange,
/// holidays blue). Swipe through weeks, or switch to single days.
struct TimetableView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    @AppStorage("timetable.mode") private var mode = TimetableMode.week
    @State private var weekPage = 0
    @State private var dayPage = 0
    @State private var selected: TimetableBlock?
    @State private var creating = false
    @State private var managingSubjects = false
    @State private var homeworkFor: HomeworkPrefill?
    @State private var forward = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Pages before and after today that can be swiped to.
    private let weekRange = -26...52
    private let dayRange = -150...300

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, DS.spacingL)
                .padding(.bottom, DS.spacingS)
            ZStack {
                switch mode {
                case .week:
                    TimetableWeekPage(monday: monday(weekOffset: weekPage), onSelect: { selected = $0 })
                        .id("week-\(weekPage)")
                        .transition(pageTransition)
                case .day:
                    TimetableDayPage(date: schoolDay(offset: dayPage), onSelect: { selected = $0 })
                        .id("day-\(dayPage)")
                        .transition(pageTransition)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .clipped()
            .contentShape(.rect)
            .simultaneousGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        // Horizontal swipes only, so vertical scrolling stays untouched.
                        guard abs(value.translation.width) > abs(value.translation.height) * 1.5,
                              abs(value.translation.width) > 60 else { return }
                        step(value.translation.width < 0 ? 1 : -1)
                    }
            )
            .overlay {
                if model.lessons.isEmpty && model.data.untisTimetable == nil {
                    emptyState
                }
            }
            TimetableLegend()
                .padding(.horizontal, DS.spacingL)
                .padding(.vertical, DS.spacingS)
        }
        .background(ThemedBackground())
        .navigationTitle(L("Stundenplan"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L("Fächer"), systemImage: "books.vertical") { managingSubjects = true }
            }
            ToolbarItem(placement: .principal) {
                Picker(L("Ansicht"), selection: $mode) {
                    Text(L("Woche")).tag(TimetableMode.week)
                    Text(L("Tag")).tag(TimetableMode.day)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(L("Stunde hinzufügen"), systemImage: "plus") { creating = true }
                    .disabled(model.subjects.isEmpty)
            }
        }
        .sheet(item: $selected) { block in
            TimetableBlockSheet(block: block) { subjectID in
                selected = nil
                homeworkFor = HomeworkPrefill(subjectID: subjectID)
            }
        }
        .sheet(isPresented: $creating) {
            LessonEditorView(lesson: nil, weekday: model.calendar.mondayIndex(of: currentDate))
        }
        .sheet(item: $homeworkFor) { prefill in
            TaskEditorView(task: nil, kind: .homework, subjectID: prefill.subjectID)
        }
        .sheet(isPresented: $managingSubjects) {
            NavigationStack { SubjectListView() }
        }
    }

    /// First steps when there is nothing to show yet.
    private var emptyState: some View {
        ContentUnavailableView {
            Label(L("Keine Stunden"), systemImage: "tablecells")
        } description: {
            if model.subjects.isEmpty {
                Text(L("Lege zuerst unter „Fächer“ deine Fächer an."))
            } else {
                let day = WeekdayText.full(model.calendar.mondayIndex(of: currentDate) % 7)
                Text(L("Füge die Stunden für \(day) hinzu."))
            }
        } actions: {
            if model.subjects.isEmpty {
                Button(L("Fächer"), systemImage: "books.vertical") { managingSubjects = true }
                    .buttonStyle(.glassProminent)
            } else {
                Button(L("Stunde hinzufügen"), systemImage: "plus") { creating = true }
                    .buttonStyle(.glassProminent)
            }
        }
        .background(.regularMaterial, in: .rect(cornerRadius: DS.cardRadius))
        .padding(DS.spacingXL)
    }

    private var currentDate: Date {
        mode == .week ? monday(weekOffset: weekPage) : schoolDay(offset: dayPage)
    }

    private var header: some View {
        HStack(spacing: DS.spacingS) {
            Button(L("Zurück"), systemImage: "chevron.left") { step(-1) }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.headline).monospacedDigit()
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary).monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentTransition(.numericText())
            Button(L("Heute")) {
                forward = weekPage < 0 || dayPage < 0
                withAnimation(reduceMotion ? nil : .snappy(duration: 0.3)) { weekPage = 0; dayPage = 0 }
            }
            .buttonStyle(.glass)
            .disabled(weekPage == 0 && dayPage == 0)
            Button(L("Weiter"), systemImage: "chevron.right") { step(1) }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
        }
    }

    /// Slides in from the side the student swiped towards.
    private var pageTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
            )
    }

    private func step(_ delta: Int) {
        forward = delta > 0
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.3)) {
            switch mode {
            case .week: weekPage = min(max(weekPage + delta, weekRange.lowerBound), weekRange.upperBound)
            case .day: dayPage = min(max(dayPage + delta, dayRange.lowerBound), dayRange.upperBound)
            }
        }
    }

    private var title: String {
        switch mode {
        case .week:
            let week = model.calendar.component(.weekOfYear, from: monday(weekOffset: weekPage))
            return L("KW \(week)")
        case .day:
            return schoolDay(offset: dayPage).formatted(.dateTime.weekday(.wide).locale(Localization.locale))
        }
    }

    private var subtitle: String {
        switch mode {
        case .week:
            let first = monday(weekOffset: weekPage)
            let last = model.calendar.date(byAdding: .day, value: 4, to: first) ?? first
            let style = Date.FormatStyle(locale: Localization.locale).day().month(.abbreviated)
            return "\(first.formatted(style)) – \(last.formatted(style))"
        case .day:
            return schoolDay(offset: dayPage).formatted(.dateTime.day().month(.wide).year().locale(Localization.locale))
        }
    }

    /// Monday of the week `offset` weeks from this one.
    private func monday(weekOffset offset: Int) -> Date {
        let today = model.calendar.startOfDay(for: model.currentDate)
        let thisMonday = model.calendar.date(byAdding: .day, value: -model.calendar.mondayIndex(of: today), to: today) ?? today
        return model.calendar.date(byAdding: .day, value: offset * 7, to: thisMonday) ?? thisMonday
    }

    /// The school day `offset` school days from today (weekends skipped;
    /// Saturday counts when the student has Saturday lessons).
    private func schoolDay(offset: Int) -> Date {
        let calendar = model.calendar
        let saturdays = model.lessons.contains { $0.weekday == 5 }
        func isSchoolDay(_ d: Date) -> Bool {
            let index = calendar.mondayIndex(of: d)
            return index < 5 || (index == 5 && saturdays)
        }
        var day = calendar.startOfDay(for: model.currentDate)
        while !isSchoolDay(day) { day = calendar.date(byAdding: .day, value: 1, to: day) ?? day }
        var remaining = abs(offset)
        let direction = offset < 0 ? -1 : 1
        while remaining > 0 {
            day = calendar.date(byAdding: .day, value: direction, to: day) ?? day
            if isSchoolDay(day) { remaining -= 1 }
        }
        return day
    }
}

enum TimetableMode: String {
    case week, day
}

/// Subject to preselect when adding homework from a lesson.
private struct HomeworkPrefill: Identifiable {
    let id = UUID()
    let subjectID: UUID?
}

// MARK: - Grid

/// Vertical scale of the grid: which minutes are shown and how tall they are.
private struct GridMetrics {
    var start: Int
    var end: Int
    var pointsPerMinute: CGFloat

    func y(_ minute: Int) -> CGFloat { CGFloat(minute - start) * pointsPerMinute }
    var height: CGFloat { y(end) }

    /// From the first bell to the last block of the shown days (at least six periods).
    @MainActor static func make(model: AppModel, days: [Date], pointsPerMinute: CGFloat) -> GridMetrics {
        let bells = model.bellSchedule
        let blocks = days.flatMap { model.timetableBlocks(on: $0) }
        let first = min(bells.first?.startMinute ?? 8 * 60, blocks.map(\.startMinute).min() ?? 8 * 60)
        let sixth = bells.prefix(6).last?.endMinute ?? 13 * 60
        let last = max(sixth, blocks.map(\.endMinute).max() ?? sixth)
        return GridMetrics(start: first, end: last, pointsPerMinute: pointsPerMinute)
    }
}

private struct TimetableWeekPage: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    let monday: Date
    var onSelect: (TimetableBlock) -> Void

    private var days: [Date] {
        let count = model.lessons.contains { $0.weekday == 5 } ? 6 : 5
        return (0..<count).compactMap { model.calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    var body: some View {
        let metrics = GridMetrics.make(model: model, days: days, pointsPerMinute: sizeClass == .regular ? 1.5 : 1.25)
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                // Fixed height: a bare Color.clear takes all free height and pushed the grid down.
                Color.clear.frame(width: TimeAxis.width, height: 1)
                ForEach(days, id: \.self) { day in
                    DayHeader(date: day, compact: sizeClass != .regular)
                        .frame(maxWidth: .infinity)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, DS.spacingXS)
            ScrollView {
                HStack(alignment: .top, spacing: 2) {
                    TimeAxis(metrics: metrics, compact: sizeClass != .regular)
                    ForEach(days, id: \.self) { day in
                        DayGrid(date: day, metrics: metrics, detail: sizeClass == .regular ? .medium : .compact, onSelect: onSelect)
                    }
                }
                .padding(.bottom, DS.spacingL)
            }
            .overlay {
                if let limit = model.untisVisibleUntil, monday > limit {
                    LimitNotice(limit: limit)
                }
            }
        }
        .padding(.horizontal, DS.spacingS)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

private struct TimetableDayPage: View {
    @Environment(AppModel.self) private var model
    let date: Date
    var onSelect: (TimetableBlock) -> Void

    var body: some View {
        let metrics = GridMetrics.make(model: model, days: [date], pointsPerMinute: 1.7)
        ScrollView {
            HStack(alignment: .top, spacing: DS.spacingS) {
                TimeAxis(metrics: metrics, compact: false)
                DayGrid(date: date, metrics: metrics, detail: .full, onSelect: onSelect)
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.bottom, DS.spacingL)
        }
        .overlay {
            if let limit = model.untisVisibleUntil, date > limit {
                LimitNotice(limit: limit)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

/// The school only lets students see the timetable up to a certain day.
private struct LimitNotice: View {
    let limit: Date

    var body: some View {
        ContentUnavailableView {
            Label(L("Noch nicht freigegeben"), systemImage: "lock")
        } description: {
            let day = limit.formatted(.dateTime.day().month(.wide).locale(Localization.locale))
            Text(L("Deine Schule zeigt den Stundenplan nur bis \(day)."))
        }
        .background(.regularMaterial, in: .rect(cornerRadius: DS.cardRadius))
        .padding(DS.spacingXL)
    }
}

private struct DayHeader: View {
    @Environment(AppModel.self) private var model
    let date: Date
    let compact: Bool

    var body: some View {
        let isToday = model.calendar.isDate(date, inSameDayAs: model.currentDate)
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.weekday(compact ? .abbreviated : .wide).locale(Localization.locale)))
                .font(.caption)
            Text(date.formatted(.dateTime.day()))
                .font(.headline)
                .monospacedDigit()
        }
        .foregroundStyle(isToday ? Color.accentColor : .primary)
        .padding(.vertical, DS.spacingXS)
        .frame(maxWidth: .infinity)
        .background(isToday ? Color.accentColor.opacity(0.12) : .clear, in: .rect(cornerRadius: 10))
    }
}

/// Period numbers with their bell times, like the left column in Untis.
private struct TimeAxis: View {
    static let width: CGFloat = 46
    @Environment(AppModel.self) private var model
    let metrics: GridMetrics
    let compact: Bool

    var body: some View {
        ZStack(alignment: .top) {
            let bells = model.bellSchedule
            ForEach(Array(bells.enumerated()), id: \.offset) { index, bell in
                let next = index + 1 < bells.count ? bells[index + 1].startMinute : nil
                if bell.startMinute >= metrics.start, bell.endMinute <= metrics.end {
                    VStack(spacing: 0) {
                        Text(TimeText.clock(bell.startMinute))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                        Text(bell.name)
                            .font(.subheadline.weight(.semibold))
                        Spacer(minLength: 0)
                        if next != bell.endMinute {
                            Text(TimeText.clock(bell.endMinute))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .monospacedDigit()
                    .frame(width: Self.width, height: metrics.y(bell.endMinute) - metrics.y(bell.startMinute))
                    .offset(y: metrics.y(bell.startMinute))
                }
            }
        }
        .frame(width: Self.width, height: metrics.height, alignment: .top)
    }
}

enum BlockDetail {
    case compact, medium, full
}

/// One day as a column: break bands, lesson blocks, holidays in blue and a
/// line for the current time.
private struct DayGrid: View {
    @Environment(AppModel.self) private var model
    let date: Date
    let metrics: GridMetrics
    let detail: BlockDetail
    var onSelect: (TimetableBlock) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Color.clear
                ForEach(gridLines, id: \.self) { minute in
                    Rectangle()
                        .fill(Color.secondary.opacity(0.18))
                        .frame(height: 0.5)
                        .offset(y: metrics.y(minute))
                }
                if detail == .full {
                    ForEach(breaks, id: \.self) { gap in
                        BreakBand(minutes: gap.end - gap.start, showLabel: true)
                            .frame(height: metrics.y(gap.end) - metrics.y(gap.start))
                            .offset(y: metrics.y(gap.start))
                    }
                }
                if let holiday = model.holiday(on: date) {
                    HolidayColumn(holiday: holiday, detail: detail)
                } else {
                    ForEach(model.timetableBlocks(on: date)) { block in
                        let laneWidth = geo.size.width / CGFloat(block.lanes)
                        Button { onSelect(block) } label: {
                            TimetableBlockView(block: block, detail: detail)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint(L("Zum Bearbeiten tippen"))
                        .frame(width: max(laneWidth - 2, 10), height: max(metrics.y(block.endMinute) - metrics.y(block.startMinute) - 2, 18))
                        .offset(x: laneWidth * CGFloat(block.lane), y: metrics.y(block.startMinute) + 1)
                    }
                }
                TimelineView(.everyMinute) { _ in
                    let now = model.currentDate
                    let minute = model.calendar.component(.hour, from: now) * 60 + model.calendar.component(.minute, from: now)
                    if model.calendar.isDate(now, inSameDayAs: date), minute >= metrics.start, minute <= metrics.end {
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 2)
                            .offset(y: metrics.y(minute))
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .frame(height: metrics.height)
        .frame(maxWidth: .infinity)
    }

    /// A line at every period start and end inside the shown range.
    private var gridLines: [Int] {
        let minutes = model.bellSchedule.flatMap { [$0.startMinute, $0.endMinute] }
        return Array(Set(minutes)).filter { $0 >= metrics.start && $0 <= metrics.end }.sorted()
    }

    struct Gap: Hashable {
        var start: Int
        var end: Int
    }

    /// Gaps between consecutive bells that are within the shown range.
    private var breaks: [Gap] {
        let bells = model.bellSchedule
        guard bells.count > 1 else { return [] }
        return zip(bells, bells.dropFirst()).compactMap { a, b in
            let gap = b.startMinute - a.endMinute
            guard gap >= 10, a.endMinute >= metrics.start, b.startMinute <= metrics.end else { return nil }
            return Gap(start: a.endMinute, end: b.startMinute)
        }
    }
}

private struct BreakBand: View {
    let minutes: Int
    let showLabel: Bool

    var body: some View {
        Color.clear
            .overlay {
                if showLabel {
                    Text(L("Pause · \(minutes) min"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityHidden(!showLabel)
    }
}

/// Holidays fill the whole column in blue, like WebUntis.
private struct HolidayColumn: View {
    let holiday: Holiday
    let detail: BlockDetail

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.untisHoliday)
            .overlay {
                VStack(spacing: DS.spacingXS) {
                    Image(systemName: "lock.fill")
                    Text(holiday.name)
                        .font(detail == .compact ? .caption2.weight(.semibold) : .headline)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                    if detail != .compact {
                        Text(HolidayText.range(holiday))
                            .font(.caption)
                            .monospacedDigit()
                    }
                }
                .foregroundStyle(.white)
                .padding(DS.spacingXS)
            }
            .accessibilityElement(children: .combine)
    }
}

/// A lesson block; its color says what changed.
private struct TimetableBlockView: View {
    @Environment(AppModel.self) private var model
    let block: TimetableBlock
    let detail: BlockDetail

    var body: some View {
        let subjectColor = model.subject(block.subjectID)?.color.color ?? .gray
        let style = BlockStyle(kind: block.kind, subjectColor: subjectColor)
        HStack(spacing: 0) {
            Rectangle().fill(style.stripe).frame(width: 4)
            VStack(alignment: .leading, spacing: 1) {
                Text(detail == .full ? block.subjectName : block.shortTitle)
                    .font(detail == .compact ? .caption.weight(.bold) : .subheadline.weight(.bold))
                    .strikethrough(block.kind == .cancelled)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !block.teacher.isEmpty {
                    Text(block.teacher)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .strikethrough(block.kind == .cancelled)
                        .lineLimit(1)
                }
                if let room = block.room {
                    Text(room)
                        .font(.caption2.weight(block.kind == .roomChange ? .bold : .regular))
                        .padding(.horizontal, block.kind == .roomChange ? 3 : 0)
                        .foregroundStyle(block.kind == .roomChange ? Color.white : Color.primary)
                        .background(block.kind == .roomChange ? Color.untisChange : .clear, in: .rect(cornerRadius: 3))
                        .strikethrough(block.kind == .cancelled)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                if detail == .full, let info = block.info {
                    Text(info)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, detail == .compact ? 3 : 6)
            .padding(.vertical, 3)
            Spacer(minLength: 0)
            if !block.alternatives.isEmpty {
                // Parallel courses: tap to choose yours.
                Image(systemName: "square.stack.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.accentColor)
                    .padding(3)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .accessibilityHidden(true)
            } else if block.info != nil, detail != .full {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(3)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .background(style.fill, in: .rect(cornerRadius: 6, style: .continuous))
        .overlay {
            if let border = style.border {
                RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(border, lineWidth: 2)
            }
        }
        .clipShape(.rect(cornerRadius: 6, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts = [block.subjectName, TimeText.range(block.startMinute, block.endMinute)]
        if !block.teacher.isEmpty { parts.append(block.teacher) }
        if let room = block.room { parts.append(room) }
        if let status = BlockStyle.label(for: block.kind) { parts.append(status) }
        if !block.alternatives.isEmpty { parts.append(L("Parallele Kurse zur Auswahl")) }
        return parts.joined(separator: ", ")
    }
}

/// Colors per change, shared with the legend.
struct BlockStyle {
    var fill: Color
    var stripe: Color
    var border: Color?

    /// Like WebUntis: every lesson the same grey, only changes in color
    /// (exam yellow, change green, cancelled red). `subjectColor` is kept for
    /// callers but no longer tints lessons.
    init(kind: TimetableBlock.Kind, subjectColor: Color = .gray) {
        switch kind {
        case .regular:
            fill = .untisLesson; stripe = Color.secondary.opacity(0.5); border = nil
        case .roomChange, .substitution:
            fill = .untisLesson; stripe = .untisChange; border = .untisChange
        case .exam:
            fill = .untisExam.opacity(0.28); stripe = .untisExam; border = .untisExam
        case .cancelled:
            fill = .untisCancelled.opacity(0.12); stripe = .untisCancelled; border = .untisCancelled
        }
    }

    static func label(for kind: TimetableBlock.Kind) -> String? {
        switch kind {
        case .regular: nil
        case .roomChange: L("Raumänderung")
        case .exam: L("Prüfung")
        case .cancelled: L("Entfall")
        case .substitution: L("Änderung")
        }
    }
}

extension Color {
    /// Lesson grey, adapting to light and dark mode.
    static let untisLesson = Color(.tertiarySystemFill)
    /// WebUntis' change colors.
    static let untisChange = Color(red: 0.0, green: 0.62, blue: 0.47)
    static let untisExam = Color(red: 0.98, green: 0.76, blue: 0.0)
    static let untisCancelled = Color(red: 0.90, green: 0.21, blue: 0.37)
    /// The blue WebUntis uses for holidays.
    static let untisHoliday = Color(red: 0.42, green: 0.52, blue: 0.77)
}

/// What the colors mean, like the bar at the bottom of Untis.
private struct TimetableLegend: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: DS.spacingM) {
                item(.untisExam, L("Prüfung"))
                item(.untisChange, L("Änderung"))
                item(.untisCancelled, L("Entfall"))
                item(.untisHoliday, L("Ferien"))
            }
            .font(.caption)
            .fixedSize()
            HStack(spacing: DS.spacingS) {
                item(.untisExam, L("Prüfung"))
                item(.untisChange, L("Änderung"))
                item(.untisCancelled, L("Entfall"))
                item(.untisHoliday, L("Ferien"))
            }
            .font(.caption2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private func item(_ color: Color, _ text: String) -> some View {
        HStack(spacing: DS.spacingXS) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 12, height: 12)
            Text(text)
        }
    }
}

// MARK: - Detail

private struct TimetableBlockSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let block: TimetableBlock
    var onHomework: (UUID?) -> Void
    @State private var editingLesson: Lesson?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: DS.spacingM) {
                        SubjectIcon(subject: model.subject(block.subjectID), size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(block.subjectName).font(.title3.weight(.semibold))
                            Text(block.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Localization.locale)))
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let status = BlockStyle.label(for: block.kind) {
                        let style = BlockStyle(kind: block.kind, subjectColor: .gray)
                        Label(status, systemImage: "exclamationmark.circle.fill")
                            .foregroundStyle(style.border ?? .primary)
                    }
                }
                Section {
                    LabeledContent(L("Zeit"), value: TimeText.range(block.startMinute, block.endMinute))
                    if !block.teacher.isEmpty {
                        LabeledContent(L("Lehrkraft"), value: block.teacher)
                    }
                    if let room = block.room {
                        if let original = block.originalRoom {
                            LabeledContent(L("Raum"), value: L("\(room) statt \(original)"))
                        } else {
                            LabeledContent(L("Raum"), value: room)
                        }
                    }
                    if let info = block.info {
                        Text(info)
                    }
                }
                if !block.alternatives.isEmpty {
                    Section {
                        ForEach([block] + block.alternatives) { option in
                            Button {
                                model.chooseCourse(option, among: [block] + block.alternatives)
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(option.subjectName).foregroundStyle(.primary)
                                        Text([option.teacher, option.room ?? ""].filter { !$0.isEmpty }.joined(separator: " · "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if option.id == block.id {
                                        Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(L("Parallele Kurse"))
                    } footer: {
                        Text(L("Wähle deinen Kurs. Meldo zeigt ihn ab jetzt jede Woche zu dieser Zeit."))
                    }
                }
                Section {
                    Button(L("Hausaufgabe eintragen"), systemImage: "book") { onHomework(block.subjectID) }
                    if let id = block.lessonID, let lesson = model.lessons.first(where: { $0.id == id }) {
                        Button(L("Bearbeiten"), systemImage: "pencil") { editingLesson = lesson }
                    }
                }
            }
            .navigationTitle(block.shortTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("Fertig")) { dismiss() }
                }
            }
            .sheet(item: $editingLesson) { LessonEditorView(lesson: $0, weekday: $0.weekday) }
        }
        .presentationDetents([.medium, .large])
    }
}
