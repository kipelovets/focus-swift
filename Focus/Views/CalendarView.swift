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
    date == nil ? nil : String(Calendar.current.component(.day, from: date!))
}

class CalendarDropState: ObservableObject {
    @Published var dayNumber: Int?
}

fileprivate var dropState = CalendarDropState()

struct CalendarDayView: View {
    let dayNumber: Int
    let taskCount: String
    @ObservedObject var dropState: CalendarDropState
    @EnvironmentObject var space: Space
    
    init(dayNumber: Int, space: Space, dropState: CalendarDropState) {
        self.dayNumber = dayNumber
        let taskCount = space.space.findDue(date: dayOfMonth(dayNumber)).count
        self.taskCount = taskCount == 0 ? "" : String(taskCount)
        self.dropState = dropState
    }
    
    var body: some View {
        Button(action: {
            guard let date = dayOfMonth(self.dayNumber) else {
                return
            }
            self.space.focus(on: .Due(date))
        }) {
            Text(taskCount)
                .frame(width: 30, height: 30)
                .background(self.dropState.dayNumber == self.dayNumber ?
                Defaults.colors.dropIndicator :
                dayOfMonth(self.dayNumber) != nil && space.perspective!.filter == .Due(dayOfMonth(self.dayNumber)!) ? Defaults.colors.background : Defaults.colors.lightBackground)
        }
        .buttonStyle(PlainButtonStyle())
        
        .border(Defaults.colors.selectable)
        .overlay(
            Text(day(dayOfMonth(dayNumber)) ?? "")
                .font(.system(size: 7))
                .offset(x: -1, y: 1)
                .foregroundColor(format(date: dayOfMonth(dayNumber) ?? Date()) == format(date:Date()) ? Color.blue : Color.white)
            , alignment: .topTrailing)
        .onDrop(of: TaskDragData.idTypes, delegate: CalendarDropDelegate(dayNumber))
        
    }
}

class CalendarDropDelegate: DropDelegate {
    let dayNumber: Int
    
    init(_ dayNumber: Int) {
        self.dayNumber = dayNumber
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        dropState.dayNumber = self.dayNumber
        
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        dropState.dayNumber = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        inputHandler.send(.SetDue(dayOfMonth(self.dayNumber)))
        
        return true
    }
}

struct CalendarView: View {
    @ObservedObject var space: Space
    
    var body: some View {
        VStack {
            ForEach(0..<5) { i in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<7) { j in
                        CalendarDayView(dayNumber: i * 7 + j, space: self.space, dropState: dropState)
                    }
                }
            }
        }
    }
}

struct CalendarDayView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static let space = Space(repo)
    
    static var previews: some View {
        CalendarDayView(dayNumber: 5, space: space, dropState: dropState).environmentObject(space)
    }
}

struct CalendarView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static let space = Space(repo, with: .Due(Date()))
    
    static var previews: some View {
        CalendarView(space: space).environmentObject(space)
    }
}
