import SwiftUI

struct TaskTreeView: View {
    @ObservedObject var task: TaskTreeNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TaskRowView(task: task)
            if task.children.count > 0 {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(task.children) { child in
                        TaskTreeView(task: child)
                    }
                }.offset(x: 30)
            }
        }
    }
}
struct TaskTree_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static var taskList = Perspective(from: repo, with: .Inbox)
    
    static var previews: some View {
        TaskTreeView(task: taskList.tree.find(by: 4)!).environmentObject(taskList)
    }
}
