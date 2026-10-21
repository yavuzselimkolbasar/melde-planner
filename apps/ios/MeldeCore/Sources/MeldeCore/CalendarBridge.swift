import Foundation

// Conversions between Foundation dates and the Rust core's local wall-clock values.
// The core never sees time zones: Swift resolves `Date` in the user's calendar first.

public extension FfiDate {
    init(_ date: Date, calendar: Calendar = .current) {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: Int32(c.year ?? 1970), month: UInt8(c.month ?? 1), day: UInt8(c.day ?? 1))
    }

    /// Midnight of this date in `calendar`'s time zone.
    func date(in calendar: Calendar = .current) -> Date? {
        calendar.date(from: DateComponents(year: Int(year), month: Int(month), day: Int(day)))
    }
}

public extension FfiDateTime {
    init(_ date: Date, calendar: Calendar = .current) {
        let c = calendar.dateComponents([.hour, .minute], from: date)
        self.init(
            date: FfiDate(date, calendar: calendar),
            minuteOfDay: UInt16((c.hour ?? 0) * 60 + (c.minute ?? 0))
        )
    }
}

public extension FfiWeekday {
    /// Monday-first index, 0…6.
    init(mondayIndex: Int) {
        switch mondayIndex {
        case 0: self = .monday
        case 1: self = .tuesday
        case 2: self = .wednesday
        case 3: self = .thursday
        case 4: self = .friday
        case 5: self = .saturday
        default: self = .sunday
        }
    }

    var mondayIndex: Int {
        switch self {
        case .monday: 0
        case .tuesday: 1
        case .wednesday: 2
        case .thursday: 3
        case .friday: 4
        case .saturday: 5
        case .sunday: 6
        }
    }
}
