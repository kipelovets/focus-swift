import SwiftUI

class ProjectSelectorDropState: ObservableObject {
    @Published var project: Project? = nil
}

fileprivate var dropState = ProjectSelectorDropState()

class ProjectSelectorDropDelegate: DropDelegate {
    let project: Project
    
    init(_ project: Project) {
        self.project = project
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        dropState.project = project
        
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        dropState.project = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        commandBus.handle(.SetProject(project))
        
        return true
    }
}

struct ProjectRowView: View {
    @ObservedObject var project: Project
    @ObservedObject var dropState: ProjectSelectorDropState
    @EnvironmentObject var state: ProjectSelectorState
    @EnvironmentObject var space: Space
    
    var body: some View {
        HStack {
            if state.editing && self.isSelectedProject {
                CustomTextField(text: $project.title, isFirstResponder: true)
            } else {
                Text(project.title)
                    .contextMenu {
                        Button(action: {
                            commandBus.handle(.DeleteProject(self.project))
                        }) {
                            Text("Delete")
                        }
                }
                Spacer()
            }
        }
        .onTapGesture(count: 2, perform: {
            self.state.editing.toggle()
        })
            .onTapGesture {
                commandBus.handle(.Focus(.Project(self.project)))
        }
        .background(self.bgColor(for: project))
        .foregroundColor(self.textColor)
        .onDrop(of: TaskDragData.idTypes, delegate: ProjectSelectorDropDelegate(project))
    }
    
    private func bgColor(for project: Project) -> Color {
        if dropState.project == project {
            return Defaults.colors.dropIndicator
        }
        
        return Defaults.colors.focusSelected(self.space.perspective.filter.isProject)
    }
    
    private var textColor: Color {
        switch self.space.perspective.filter {
        case .Project(let project):
            return Defaults.colors.text(project.id == self.project.id)
        default:
            return Defaults.colors.textDefault
        }
    }

    private var isSelectedProject: Bool {
        if case let PerspectiveType.Project(p) = space.perspective.filter, p.id == self.project.id {
            return true
        }

        return false
    }
}

class ProjectSelectorState: ObservableObject {
    @Published var editing: Bool = false
}

struct ProjectSelectorView: View {
    @EnvironmentObject var space: Space
    @EnvironmentObject var state: ProjectSelectorState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                HStack(alignment: .top, spacing: 0) {
                    Button(action: {
                        guard let firstProject = self.space.model.projects.first else {
                            return
                        }
                        commandBus.handle(.Focus(.Project(firstProject)))
                    }) {
                        Text("Projects").font(.headline)
                            .background(Defaults.colors.focusSelected(self.space.perspective.filter.same(as: .Project(Project(id: -1, title: "_")))))
                        Spacer()
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        commandBus.handle(.AddProject)
                    }) {
                        Text("➕")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: -5)
                }
                .padding(5)
                

                ForEach(space.model.projects) { project in
                    ProjectRowView(project: project, dropState: dropState)
                }.padding(.leading, 10)
            }
            .background(Defaults.colors.focusSelected(self.space.perspective.filter.isProject))
            .modifier(FocusSelection(self.space.perspective.filter.isProject))
        }
    }
}

struct ProjectSelectorView_Previews: PreviewProvider {
    private static let space = loadPreviewSpace()
    private static let spaceProject = loadPreviewSpace( .Project(space.model.projects[0]))
    private static let state = ProjectSelectorState()
    
    static var previews: some View {
        Group {
            ProjectSelectorView().environmentObject(space)
            ProjectSelectorView().environmentObject(spaceProject)
        }.environmentObject(state)
    }
}
