import SwiftUI

struct HierarchyMarkerView: View {
    let text: String

    var body: some View {
        Text(text)
                .font(.system(size: 9))
            .foregroundColor(Color(white: 0.4))
            .background(Defaults.colors.background)
    }
}

struct TaskButtonView: View {
    @ObservedObject var task: TaskNode
    
    var body: some View {
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
    }
}

struct TaskRowView: View {
    public static let HEIGHT: CGFloat = 34
    public static let CHILD_OFFSET: CGFloat = 20

    @EnvironmentObject var space: Space
    @ObservedObject var task: TaskNode

    var body: some View {
        HStack {
            Defaults.colors.selectable(space.perspective.current == task).frame(width: 8, height: TaskRowView.HEIGHT)
            Spacer().frame(width: 16, height: TaskRowView.CHILD_OFFSET)
            HStack {

                TaskButtonView(task: task)

                if space.perspective.editMode && space.perspective.current == task {
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
                
                Group {
                    if self.task.project != nil {
                        Text(self.task.project!.title)
                            .foregroundColor(Defaults.colors.textDimmed)
                    }
                    Spacer()
                }.frame(width: 70, height: 20)
                
                Group {
                    if self.task.dueAt != nil {
                        Text(self.task.dueAt!.formatted)
                            .foregroundColor(Defaults.colors.textDimmed)
                    }
                    Spacer()
                }.frame(width: 70, height: 20)

            }.padding(7)
            .overlay(
                Group {
                    if !self.space.perspective.filter.allowsHierarchy && self.task.children.count > 0{
                        HierarchyMarkerView(text: "↳  \(self.task.children.count)")
                    }
                }.offset(x: 35), alignment: .bottomLeading
            )
            .overlay(
                Group {
                    if !self.space.perspective.filter.allowsHierarchy && self.task.parent != nil && !self.task.parent!.isRoot {
                        HierarchyMarkerView(text: "↱ " +  self.task.parent!.title)
                    }
                }.offset(x: 35), alignment: .topLeading
            )
        }
        .border(Defaults.colors.selected, width: self.space.perspective.current == task ? 2 : 0)
        .background(Defaults.colors.background)
        .onDrag { () -> NSItemProvider in
            inputHandler.send(.Select(self.task.id))

            return NSItemProvider(object: TaskDragData(task: self.task.model!.dto))
        }
        .overlay(
            DropIndicator(visible: self.space.perspective.dropTarget == task)
                .offset(x: TaskRowView.CHILD_OFFSET * CGFloat(self.space.perspective.dropDepth - self.task.depth))
            , alignment: .bottomLeading)
    }

}

struct TaskRow_Previews: PreviewProvider {
    private static var space = loadPreviewSpace()
    private static var spaceDue = loadPreviewSpace(.Due(.CurrentMonthDay(Date().dayOfMonth)))

    static var previews: some View {
        Group {
            Group {
                TaskRowView(task: space.perspective.tree.root.children[0])
                TaskRowView(task: space.perspective.tree.root.children[1])
                TaskRowView(task: space.perspective.tree.root.children[2])
            }.environmentObject(space)
            
            Group {
                TaskRowView(task: spaceDue.perspective.tree.find(by: 5)!)
            }.environmentObject(spaceDue)
        }
    }
}
