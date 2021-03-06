import Foundation

public enum Weekday: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    /**
     Initialize with sunday starting value (1 is sunday, 2 is monday, ...)
     - parameter mondayStarting: value between 1 and 7
     - throws: `fatalError()` when the value is out of scope
     */
    public init(sundayStarting: Int) {
        self.init(rawValue: sundayStarting)!
    }

    /**
     Initialize with sunday starting value (1 is sunday, 2 is monday, ...)
     - parameter mondayStarting: value between 1 and 7
     - returns: nil when the value is out of scope
     */
    public init?(sundayStartingSafe sundayStarting: Int) {
        self.init(rawValue: sundayStarting)
    }

    /**
     Initialize with monday starting value  (1 is monday, 2 is tuesday, ...)
     - parameter mondayStarting: value between 1 and 7
     - throws: `fatalError()` when the value is out of scope
     */
    public init(mondayStarting: Int) {
        self.init(mondayStartingSafe: mondayStarting)!
    }

    /**
     Initialize with monday starting value (1 is monday, 2 is tuesday, ...)
     - parameter mondayStarting: value between 1 and 7
     - returns: nil when the value is out of scope
     */
    public init?(mondayStartingSafe mondayStarting: Int) {
        switch mondayStarting {
        case 1: self = .monday
        case 2: self = .tuesday
        case 3: self = .wednesday
        case 4: self = .thursday
        case 5: self = .friday
        case 6: self = .saturday
        case 7: self = .sunday
        default: return nil
        }
    }

    /**
     Initialize with specific date, gets current weekday using Calendar
     */
    public init(date: Date, for calendar: Calendar = Calendar.current) {
        self.init(sundayStarting: calendar.component(.weekday, from: date))
    }

    /**
     Weekday for this moment, alias to call `Weekday(date: Date())`
     */
    public static var current: Weekday {
        return Weekday(date: Date())
    }

    /**
     Creates list of all weekdays in week, respects firstWeekday settings in `Calendar.current`
     */
    public static var all: [Weekday] {
        let starting = Calendar.current.firstWeekday

        return (1...7).map {
            let round = starting - 1

            let newValue = $0 + round
            if newValue > 7 {
                return Weekday(rawValue: newValue - 7)!
            } else {
                return Weekday(rawValue: newValue)!
            }
        }
    }

    /**
     Creates list of all standard working weekdays in week
     */
    public static var workingDays: [Weekday] {
        return [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
        ]
    }

    public var next: Weekday {
        var index = Weekday.all.index(of: self)!
        index += 1
        if index > 6 {
            index -= 7
        }
        return Weekday.all[index]
    }

    public var previous: Weekday {
        var index = Weekday.all.index(of: self)!
        index -= 1
        if index < 0 {
            index += 7
        }
        return Weekday.all[index]
    }

    /**
     Searches for first matching weekday with input array
     */
    public func firstNext(from weekdays: [Weekday]) -> Weekday? {
        if weekdays.isEmpty {
            return nil
        }

        let current = self.next
        if weekdays.contains(current) {
            return current
        } else {
            return current.firstNext(from: weekdays)
        }
    }

    public var mondayStartingRawValue: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }

    public var sundayStartingRawValue: Int {
        return rawValue
    }

    /**
     - returns: value that can be used as index to array where first item is Monday
     */
    public var indexValueForMondayStarting: Int {
        return indexValueFor(starting: Weekday.monday.rawValue)
    }

    /**
     - returns: value that can be used as index to array where first item is Sunday
     */
    public var indexValueForSundayStarting: Int {
        return indexValueFor(starting: Weekday.sunday.rawValue)
    }

    /**
     - returns: index value that can be used in arrays returned by Foundation classes like Calendar, DateFormatter, ...
     */
    public var indexValueForCalendar: Int {
        return indexValueForSundayStarting
    }

    public var isToday: Bool {
        return self.isToday(for: Calendar.current)
    }

    public func isToday(for calendar: Calendar) -> Bool {
        let weekdayIndex = calendar.component(.weekday, from: Date())
        return sundayStartingRawValue == weekdayIndex
    }

    public var localizedName: String {
        struct Static {
            static let weekdays = DateFormatter().standaloneWeekdaySymbols!
        }

        return Static.weekdays[self.indexValueForCalendar]
    }

    public var shortLocalizedName: String {
        struct Static {
            static let weekdays = DateFormatter().shortWeekdaySymbols!
        }

        return Static.weekdays[self.indexValueForCalendar]
    }

    public static func compare(_ lhs: Weekday, _ rhs: Weekday) -> Bool {
        let firstday = Calendar.current.firstWeekday

        let lhsAligned = lhs.indexValueFor(starting: firstday)
        let rhsAligned = rhs.indexValueFor(starting: firstday)
        return lhsAligned < rhsAligned
    }

    // MARK: helper internal methods

    func indexValueFor(starting: Int) -> Int {
        let round = starting - 1

        let newValue = self.rawValue - round - 1 // - 1 because of index starts at 0
        if newValue < 0 {
            return newValue + 7
        } else {
            return newValue
        }
    }

    static func compare(_ lhs: Int, _ rhs: Int) -> Bool {
        return compare(Weekday(sundayStarting: lhs), Weekday(sundayStarting: rhs))
    }
}
