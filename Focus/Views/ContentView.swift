import SwiftUI

fileprivate let LIST_PADDING: CGFloat = 20

struct DropIndicator: View {
    let visible: Bool
    
    var body: some View {
        Group {
            if visible {
                Color(.systemBlue)
                    .frame(width: 200, height: 2)
                    .shadow(color: .blue, radius: 2, x: 0, y: 0)
            }
        }
    }
}

struct ContentView: View {
    
    @EnvironmentObject var taskList: TaskListState
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach(taskList.tasks) { task in
                TaskRow(taskId: task.id, highlighted: task == self.taskList.currentTask, editing: task == self.taskList.currentTask && self.taskList.editing)
                .onDrag { () -> NSItemProvider in
                    self.taskList.currentTaskIndex = self.taskList.taskIndex(for: task.id)!
                    
                    return NSItemProvider(object: TaskDragData(task:task))
                }
                .overlay(DropIndicator(visible: self.taskList.taskIndex(for: task.id)! + 1 == self.taskList.dropTargetIndex), alignment: .bottomLeading)
            }
        }
        .overlay(DropIndicator(visible: self.taskList.dropTargetIndex == 0), alignment: .topLeading)
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .topLeading)
        .padding(LIST_PADDING)
        .onDrop(of: TaskDragData.idTypes, delegate: TaskDragDelegate(taskIndexByHeight: { height in
            let dropIndex = Int(((height - LIST_PADDING) / TaskRow.HEIGHT).rounded(.down))
            return dropIndex
        }, taskList: self.taskList))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    
    static var previews: some View {
        ContentView().environmentObject(TaskListState(repo: TaskSpaceRepository(filename: file!.path)))
    }
}
