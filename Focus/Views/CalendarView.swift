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
        let taskCount = space.space.findDue(date: Date(fromDayOnCalendar: dayNumber)).count
        self.taskCount = taskCount == 0 ? "" : String(taskCount)
        self.dropState = dropState
    }
    
    var body: some View {
        Button(action: {
            guard let date = Date(fromDayOnCalendar: self.dayNumber) else {
                return
            }
            inputHandler.send(.Focus(.Due(date)))
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
                .foregroundColor((Date(fromDayOnCalendar: dayNumber) ?? Date()).same(as: Date()) ? Color.blue : Color.white)
            , alignment: .topTrailing)
        .onDrop(of: TaskDragData.idTypes, delegate: CalendarDropDelegate(dayNumber))
    }
    
    private var bgColor: Color {
        if self.dropState.dayNumber == self.dayNumber {
            return Defaults.colors.dropIndicator
        }
        
        if let dom = Date(fromDayOnCalendar: self.dayNumber) {
            switch space.perspective.filter {
            case .Due(let date):
                if date.same(as: dom) {
                    return Defaults.colors.background
                }
            default:
                break
            }
        }
        
        return Defaults.colors.lightBackground

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
        CalendarView().environmentObject(space)
    }
}
