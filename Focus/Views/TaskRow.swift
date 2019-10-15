import SwiftUI

struct TaskRow: View {
    public static let HEIGHT: CGFloat = 30

    @EnvironmentObject var taskData: TaskList
    @ObservedObject var task: Task

    var body: some View {
        HStack {
            Color(taskData.currentTask == task ? .gray : .darkGray).frame(width: 8, height: TaskRow.HEIGHT)
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

                if taskData.editing && taskData.currentTask == task {
                    CustomTextField(text: $task.title, isFirstResponder: true)
                } else {
                    Button(action: {
                        self.taskData.edit(task: self.task)
                    }) {
                        Text(task.title)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

            }.padding(5)
        }
        .border(Color(.gray), width: taskData.currentTask == task ? 2 : 0)
        .background(Color(white: 0.2))
    }

}

struct TaskRow_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    @State private static var taskList = TaskList(repo: repo)

    static var previews: some View {
        Group {
            TaskRow(task: taskList.tasks[0])
            TaskRow(task: taskList.tasks[1])
            TaskRow(task: taskList.tasks[2])
        }.environmentObject(taskList)
    }
}
