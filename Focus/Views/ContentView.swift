import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var taskList: TaskListState
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach(taskList.tasks) { task in
                TaskRow(taskId: task.id, highlighted: task == self.taskList.currentTask, editing: task == self.taskList.currentTask && self.taskList.editing)
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    
    static var previews: some View {
        ContentView().environmentObject(TaskListState(repo: TaskSpaceRepository(filename: file!.path)))
    }
}
