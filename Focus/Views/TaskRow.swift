import SwiftUI

struct TaskRow: View {
    public static let HEIGHT: CGFloat = 30
    
    @EnvironmentObject var taskData: TaskListState
    var taskId: Int
    var highlighted = false
    var editing = false
    
    var taskIndex: Int? {
        taskData.taskIndex(for: taskId)
    }
    
    var body: some View {
        HStack {
            Color(highlighted ? .gray : .darkGray).frame(width: 8, height: TaskRow.HEIGHT)
            Spacer().frame(width: 16, height: 20)
            HStack {
                
                Button(action: {
                    if let i = self.taskIndex {
                        self.taskData.tasks[i].done.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.yellow)
                            .overlay(
                                Circle().foregroundColor(Color(white:0.2))
                                    .frame(width: 16, height: 16)
                        )
                        if taskIndex != nil && taskData.tasks[taskIndex ?? 0].done {
                            Text("✔").foregroundColor(.yellow)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if taskIndex != nil {
                    if editing {
                        CustomTextField(text: $taskData.tasks[taskIndex ?? 0].title, isFirstResponder: true)
                    } else {
                        Button(action: {
                            if self.taskData.currentTaskIndex != self.taskIndex {
                                self.taskData.currentTaskIndex = self.taskIndex ?? 0
                            }
                            if !self.taskData.editing {
                                inputHandler.send(.ToggleEditing)
                            }
                        }) {
                            Text(taskData.tasks[taskIndex ?? 0].title)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
            }.padding(5)
        }.border(Color(.gray), width: highlighted ? 2 : 0)
            .background(Color(white: 0.2))
    }
    
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TaskRow(taskId:1, highlighted: true)
            TaskRow(taskId:2)
            TaskRow(taskId:3, editing: true)
        }
    }
}
