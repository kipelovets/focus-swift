import SwiftUI

struct TaskRowView: View {
    public static let HEIGHT: CGFloat = 30
    public static let CHILD_OFFSET: CGFloat = 20

    @EnvironmentObject var perspective: Perspective
    @ObservedObject var task: TaskTreeNode

    var body: some View {
        HStack {
            Defaults.colors.selectable(perspective.current == task).frame(width: 8, height: TaskRowView.HEIGHT)
            Spacer().frame(width: 16, height: TaskRowView.CHILD_OFFSET)
            HStack {

                Button(action: {
                    self.task.done.toggle()
                }) {
                    ZStack {
                        Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Defaults.colors.checkbox(task.done))
                                .overlay(
                                        Circle().foregroundColor(Defaults.colors.background)
                                                .frame(width: 16, height: 16)
                                )
                        if task.done {
                            Text("✔").foregroundColor(Defaults.colors.checkbox(task.done))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                if perspective.editMode && perspective.current == task {
                    CustomTextField(text: $task.title, isFirstResponder: true)
                        .frame(width: 200, height: 20)
                } else {
                    Button(action: {
                        inputHandler.send(.Edit(self.task.id))
                    }) {
                        HStack {
                            Text(task.title)
                            Spacer()
                        }
                        .frame(width: 300, height: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(format(date:self.task.dueAt))
                    .foregroundColor(Defaults.colors.text)

            }.padding(5)
        }
        .border(Defaults.colors.selected, width: perspective.current == task ? 2 : 0)
        .background(Defaults.colors.background)
        .onDrag { () -> NSItemProvider in
            inputHandler.send(.Select(self.task.id))

            return NSItemProvider(object: TaskDragData(task: self.task.model!.dto))
        }
        .overlay(
            DropIndicator(visible: self.perspective.dropTarget == task)
                .offset(x: TaskRowView.CHILD_OFFSET * CGFloat(self.perspective.dropDepth - self.task.depth))
            , alignment: .bottomLeading)
    }

}

struct TaskRow_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static var perspective = Space(repo).perspective!

    static var previews: some View {
        Group {
            TaskRowView(task: perspective.tree.root.children[0])
            TaskRowView(task: perspective.tree.root.children[1])
            TaskRowView(task: perspective.tree.root.children[2])
        }.environmentObject(perspective)
    }
}
