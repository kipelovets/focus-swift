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

struct PerspectiveView: View {
    
    @ObservedObject var perspective: Perspective
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            ForEach(perspective.tree.root.children) { task in
                TaskTreeView(task: task).environmentObject(self.perspective)
                            .onDrag { () -> NSItemProvider in
                                self.perspective.current = task

                                return NSItemProvider(object: TaskDragData(task: task.model!.dto))
                            }
                .overlay(DropIndicator(visible: self.perspective.dropTarget == task) , alignment: .bottomLeading)
            }
        }
        .overlay(DropIndicator(visible: self.perspective.dropTarget == self.perspective.tree.root), alignment: .topLeading)
        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity, alignment: .topLeading)
        .padding(LIST_PADDING)
        .onDrop(of: TaskDragData.idTypes, delegate: TaskDragDelegate(taskIndexByHeight: { height in
            let dropIndex = Int(((height - LIST_PADDING) / TaskRowView.HEIGHT).rounded(.down))
            return dropIndex
        }, taskList: self.perspective))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static let taskList = Perspective(from: repo, with: .Inbox)
    
    static var previews: some View {
        PerspectiveView(perspective: taskList).environmentObject(taskList)
    }
}
