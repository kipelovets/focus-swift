import SwiftUI

struct TaskTreeView: View {
    @ObservedObject var task: TaskNode
    @EnvironmentObject var space: Space
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TaskRowView(task: task)
            
            if space.perspective.filter.allowsHierarchy {
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
}

struct TaskTree_Previews: PreviewProvider {
    private static var spaceAll = loadPreviewSpace()
    private static var spaceDue = loadPreviewSpace(.Due(.CurrentMonthDay(11)))
    
    static var previews: some View {
        Group {
            TaskTreeView(task: spaceAll.perspective.tree.find(by: 1)!).environmentObject(spaceAll)
            TaskTreeView(task: spaceDue.perspective.tree.find(by: 5)!).environmentObject(spaceDue)
        }
    }
}
