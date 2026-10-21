import SwiftUI

/// Banner for the timetable and calendar: "Herbstferien · 19.10.–01.11.".
struct HolidayBanner: View {
    let holiday: Holiday

    var body: some View {
        HStack(spacing: DS.spacingM) {
            Image(systemName: "lock.fill")
                .font(.title3)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(holiday.name).font(.headline)
                Text(HolidayText.range(holiday))
                    .font(.subheadline)
                    .monospacedDigit()
                    .opacity(0.85)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(DS.spacingM)
        // Blue like WebUntis, so holidays look the same everywhere.
        .background(Color.untisHoliday, in: .rect(cornerRadius: DS.rowRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// Mehr → Ferien: the school's holidays, past ones dimmed.
struct HolidayListView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let today = model.calendar.startOfDay(for: model.currentDate)
        List {
            if model.data.holidays.isEmpty {
                ContentUnavailableView {
                    Label(L("Keine Ferien eingetragen"), systemImage: "sun.horizon")
                } description: {
                    Text(L("Verbinde WebUntis, dann erscheinen hier die Ferien deiner Schule. In den Ferien fragt Meldo nicht nach Meldungen."))
                }
            } else {
                Section {
                    ForEach(model.data.holidays.sorted { $0.firstDay < $1.firstDay }) { holiday in
                        let over = model.calendar.startOfDay(for: holiday.lastDay) < today
                        let now = model.holiday(on: today)?.id == holiday.id
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(holiday.name).font(.body.weight(.semibold))
                                Text(HolidayText.range(holiday))
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if now { Badge(text: L("Jetzt"), color: .meldoOrange) }
                        }
                        .opacity(over ? 0.45 : 1)
                    }
                } footer: {
                    Text(L("In den Ferien fallen alle Stunden aus und Meldo fragt nicht nach Meldungen."))
                }
            }
        }
        .navigationTitle(L("Ferien"))
    }
}
