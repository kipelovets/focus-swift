import SwiftUI

struct TaskRow: View {
    public static let HEIGHT: CGFloat = 30

    @EnvironmentObject var perspective: Perspective
    @ObservedObject var task: TaskTreeNode

    var body: some View {
        HStack {
            Color(perspective.current == task ? .gray : .darkGray).frame(width: 8, height: TaskRow.HEIGHT)
            Spacer().frame(width: 16, height: 20)
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
                        self.perspective.edit(node: self.task)
                    }) {
                        Text(task.title)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

            }.padding(5)
        }
        .border(Color(.gray), width: perspective.current == task ? 2 : 0)
        .background(Color(white: 0.2))
    }

}

struct TaskRow_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static var perspective = Perspective(from: repo, with: .Inbox)

    static var previews: some View {
        Group {
            TaskRow(task: perspective.tree.root.children[0])
            TaskRow(task: perspective.tree.root.children[1])
            TaskRow(task: perspective.tree.root.children[2])
        }.environmentObject(perspective)
    }
}
