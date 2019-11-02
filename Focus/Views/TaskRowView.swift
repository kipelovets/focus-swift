import SwiftUI

struct TaskRowView: View {
    public static let HEIGHT: CGFloat = 30
    public static let CHILD_OFFSET: CGFloat = 20

    @EnvironmentObject var perspective: Perspective
    @ObservedObject var task: TaskTreeNode

    var body: some View {
        HStack {
            Color(perspective.current == task ? .gray : .darkGray).frame(width: 8, height: TaskRowView.HEIGHT)
            Spacer().frame(width: 16, height: TaskRowView.CHILD_OFFSET)
            HStack {

                Button(action: {
                    self.task.done.toggle()
                }) {
                    ZStack {
                        Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.yellow)
                                .overlay(
                                        Circle().foregroundColor(Color(white: 0.2))
                                                .frame(width: 16, height: 16)
                                )
                        if task.done {
                            Text("✔").foregroundColor(.yellow)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                if perspective.editMode && perspective.current == task {
                    CustomTextField(text: $task.title, isFirstResponder: true)
                } else {
                    Button(action: {
                        inputHandler.send(.Edit(self.task.id))
                    }) {
                        Text(task.title)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

            }.padding(5)
        }
        .border(Color(.gray), width: perspective.current == task ? 2 : 0)
        .background(Color(white: 0.2))
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
