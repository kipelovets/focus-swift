import SwiftUI

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
        let taskCount = space.model.findDue(date: Date(fromDayOnCalendar: dayNumber)).count
        self.taskCount = taskCount == 0 ? "" : String(taskCount)
        self.dropState = dropState
    }
    
    var body: some View {
        Button(action: {
            guard let date = Date(fromDayOnCalendar: self.dayNumber) else {
                return
            }
            inputHandler.send(.Focus(.Due(.CurrentMonthDay(date.dayOfMonth))))
        }) {
            Text(taskCount)
                .frame(width: 30, height: 30)
                .background(self.bgColor)
        }
        .buttonStyle(PlainButtonStyle())
        
        .border(Defaults.colors.selectable)
        .overlay(
            Text(day(Date(fromDayOnCalendar: dayNumber)) ?? "")
                .font(.system(size: 7))
                .offset(x: -1, y: 1)
                .foregroundColor(self.dayTextColor)
            , alignment: .topTrailing)
        .onDrop(of: TaskDragData.idTypes, delegate: CalendarDropDelegate(dayNumber))
    }
    
    private var dayTextColor: Color {
        let date = Date(fromDayOnCalendar: dayNumber) ?? Date()
        if date.same(as: Date()) {
            return Color.blue
        }
        
        switch space.perspective.filter {
        case .Due(let dueType):
            return Defaults.colors.text(dueType.matches(date: date))
        default:
            return Defaults.colors.textDefault
        }
    }
    
    private var bgColor: Color {
        if self.dropState.dayNumber == self.dayNumber {
            return Defaults.colors.dropIndicator
        }
        
        guard let dom = Date(fromDayOnCalendar: self.dayNumber) else {
            return Defaults.colors.focusSelected(false)
        }
        
        return Defaults.colors.focusSelected(space.perspective.filter == .Due(.CurrentMonthDay(dom.dayOfMonth)))
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
        inputHandler.send(.SetDue(Date(fromDayOnCalendar: self.dayNumber)))
        
        return true
    }
}

struct CalendarView: View {
    @EnvironmentObject var space: Space
    
    var body: some View {
        VStack {
            Button(action: {
                inputHandler.send(.Focus(.Due(.Past)))
            }) {
                Text("Past").padding(5).font(.headline)
                .foregroundColor(Defaults.colors.text(space.perspective.filter == .Due(.Past)))
            }.buttonStyle(PlainButtonStyle())
            
            Text(Date().month).font(.caption)
            ForEach(0..<5) { i in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<7) { j in
                        CalendarDayView(dayNumber: i * 7 + j, space: self.space, dropState: dropState)
                    }
                }
            }
            Button(action: {
                inputHandler.send(.Focus(.Due(.Future)))
            }) {
                Text("Future").padding(5).font(.headline)
                .foregroundColor(Defaults.colors.text(space.perspective.filter == .Due(.Future)))
            }.buttonStyle(PlainButtonStyle())
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
    private static let space = Space(repo, with: .Due(.CurrentMonthDay(Date().dayOfMonth)
        ))
    
    static var previews: some View {
        CalendarView().environmentObject(space)
    }
}
