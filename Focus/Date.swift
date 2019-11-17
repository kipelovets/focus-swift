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
    
    func same(as other: Date) -> Bool {
        return self.formatted == other.formatted
    }
    
    // Day on calendar
    
    init?(fromDayOnCalendar dayOnCalendar: Int) {
        let cal = Calendar.current
        let firstDayWeekDay = cal.component(.weekday, from: Date.firstDayOfMonth)

        let fixedNumber = dayOnCalendar - firstDayWeekDay + 2
        guard fixedNumber >= 0 else {
            return nil
        }

        let myDay = cal.date(byAdding: .day, value: fixedNumber, to: Date.firstDayOfMonth)!
        guard cal.component(.month, from: myDay) == cal.component(.month, from: Date.firstDayOfMonth) else {
            return nil
        }

        self.init(timeIntervalSince1970: myDay.timeIntervalSince1970)
    }
    
    var dayOnCalendar: Int {
        let cal = Calendar.current
        let firstDayWeekDay = cal.component(.weekday, from: Date.firstDayOfMonth)

        return cal.component(.day, from: self) + firstDayWeekDay - 3
    }
    
    static var firstDayOfMonth: Date {
        let cal = Calendar.current
        
        return cal.date(from: cal.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
    }
}
