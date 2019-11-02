import SwiftUI

fileprivate func dayOfMonth(_ number: Int) -> Date? {
    let cal = Calendar.current
    let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date())))!
    let firstDayWeekDay = cal.component(.weekday, from: firstDay)

    let fixedNumber = number - firstDayWeekDay + 2
    guard fixedNumber >= 0 else {
        return nil
    }

    let myDay = cal.date(byAdding: .day, value: fixedNumber, to: firstDay)!
    guard cal.component(.month, from: myDay) == cal.component(.month, from: firstDay) else {
        return nil
    }

    return myDay
}

fileprivate func day(_ date: Date?) -> String? {
    return date == nil ? nil : String(Calendar.current.component(.day, from: date!))
}

struct CalendarDayView: View {
    let dayNumber: Int
    let taskCount: String
    
    init(dayNumber: Int, space: Space) {
        self.dayNumber = dayNumber
        let taskCount = space.due(date: dayOfMonth(dayNumber)).count
        self.taskCount = taskCount == 0 ? "" : String(taskCount)
    }
    
    var body: some View {
        Text(taskCount)
        .frame(width: 30, height: 30)
        .border(Color(.gray))
        .overlay(
            Text(day(dayOfMonth(dayNumber)) ?? "")
                .font(.system(size: 7))
            .offset(x: -1, y: 1)
            , alignment: .topTrailing)
    }
}

struct CalendarView: View {
    @EnvironmentObject var space: Space
    
    var body: some View {
        VStack {
            ForEach(0..<5) { i in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<7) { j in
                        CalendarDayView(dayNumber: i * 7 + j, space: self.space)
                    }
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static let space = Space(repo)
    private static var perspective = space.perspective!
    
    static var previews: some View {
        CalendarView().environmentObject(space)
    }
}
