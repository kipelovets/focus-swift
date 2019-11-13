import SwiftUI

struct ChildrenMarkerView: View {
    let childrenCount: Int

    var body: some View {
        Text("children: \(childrenCount)")
                .font(.system(size: 10))
                .foregroundColor(Defaults.colors.text)
                .background(Defaults.colors.lightBackground)
    }
}

struct TaskRowView: View {
    public static let HEIGHT: CGFloat = 30
    public static let CHILD_OFFSET: CGFloat = 20

    @EnvironmentObject var space: Space
    @ObservedObject var task: TaskTreeNode

    var body: some View {
        HStack {
            Defaults.colors.selectable(space.perspective.current == task).frame(width: 8, height: TaskRowView.HEIGHT)
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
                
                if self.task.dueAt != nil {
                    Text(self.task.dueAt!.formatted)
                        .foregroundColor(Defaults.colors.text)
                }

            }.padding(5)
            .overlay(
                Group {
                    if !self.perspective.filter.allowsHierarchy {
                        ChildrenMarkerView(childrenCount: self.task.children.count)
                    }
                }.offset(x: 30), alignment: .bottomLeading
            )
        }
        .border(Defaults.colors.selected, width: self.space.perspective.current == task ? 2 : 0)
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
    private static var space = loadPreviewSpace()
    private static var perspective = space.perspective
    private static var perspectiveDue = Perspective(from: space.space, with: .Due(Date(from: "2019-11-11")))

    static var previews: some View {
        Group {
            Group {
                TaskRowView(task: perspective.tree.root.children[0])
                TaskRowView(task: perspective.tree.root.children[1])
                TaskRowView(task: perspective.tree.root.children[2])
            }.environmentObject(perspective)
            
            Group {
                TaskRowView(task: perspectiveDue.tree.find(by: 5)!)
            }.environmentObject(perspectiveDue)
        }
    }
}
