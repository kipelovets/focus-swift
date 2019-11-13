import SwiftUI

struct TaskTreeView: View {
    @ObservedObject var task: TaskTreeNode
    @EnvironmentObject var perspective: Perspective
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TaskRowView(task: task)
            
            if perspective.filter.allowsHierarchy {
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
    private static var space = loadPreviewSpace()
    private static var perspectiveAll = Perspective(from: space.space, with: .All)
    private static var perspectiveDue = Perspective(from: space.space, with: .Due(Date(from: "2019-11-11")))
    
    static var previews: some View {
        Group {
            TaskTreeView(task: perspectiveAll.tree.find(by: 1)!).environmentObject(perspectiveAll)
            TaskTreeView(task: perspectiveDue.tree.find(by: 5)!).environmentObject(perspectiveDue)
        }
    }
}
