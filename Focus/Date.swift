import Foundation

fileprivate func createDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = DateFormatter.Style.none
    dateFormatter.dateStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter
}

extension Date {
    init(from string: String) {
        let date = createDateFormatter().date(from: string)!
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    // Due formatting
    
    var formatted: String {
        return createDateFormatter().string(from: self)
    }
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "MMMM"
        
        return dateFormatter.string(from: self)
    }
    
    func same(as other: Date) -> Bool {
        return self.formatted == other.formatted
    }
    
    // Day on calendar
    
    init?(fromDayOnCalendar dayOnCalendar: Int) {
        let cal = Calendar.current
        let firstDayWeekDay = cal.component(.weekday, from: Date().firstDayOfMonth)

        let fixedNumber = dayOnCalendar - firstDayWeekDay + 2
        guard fixedNumber >= 0 else {
            return nil
        }

        let myDay = cal.date(byAdding: .day, value: fixedNumber, to: Date().firstDayOfMonth)!
        guard cal.component(.month, from: myDay) == cal.component(.month, from: Date().firstDayOfMonth) else {
            return nil
        }

        self.init(timeIntervalSince1970: myDay.timeIntervalSince1970)
    }
    
    init(fromDayOfMonth day: Int) {
        let firstDayOfMonth = Date().firstDayOfMonth
        let date = Calendar.current.date(bySetting: .day, value: day, of: firstDayOfMonth)!
        
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    var dayOnCalendar: Int {
        let cal = Calendar.current
        let firstDayWeekDay = cal.component(.weekday, from: firstDayOfMonth)

        return cal.component(.day, from: self) + firstDayWeekDay - 3
    }
    
    var firstDayOfMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    var lastDayOfMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!
    }
    
    var dayOfMonth: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var dueFilter: DueType {
        if self < Date().firstDayOfMonth {
            return .Past
        }
        
        if self > Date().lastDayOfMonth {
            return .Future
        }
        
        return .CurrentMonthDay(dayOfMonth)
    }
}
