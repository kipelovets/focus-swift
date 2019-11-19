import SwiftUI

struct ProjectSelectorView: View {
    @EnvironmentObject var space: Space
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                HStack(alignment: .top, spacing: 0) {
                    Button(action: {
                        // inputHandler.send(.Focus(self.filter))
                    }) {
                        Text("Projects").font(.headline)
                            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 10, alignment: .leading)
                            .background(Defaults.colors.focusSelected(self.space.perspective.filter.same(as: .Project(Project(id: -1, title: "_")))))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(5)
                
                ForEach(space.space.projects) { project in
                    Text(project.title)
                }.offset(x: 10, y: 0)
            }
            .background(Defaults.colors.focusSelected(self.space.perspective.filter.isProject))
            .modifier(FocusSelection(self.space.perspective.filter.isProject))
        }
    }
}

struct ProjectSelectorView_Previews: PreviewProvider {
    private static let space = loadPreviewSpace()
    private static let spaceProject = loadPreviewSpace( .Project(space.space.projects[0]))
    
    static var previews: some View {
        Group {
            ProjectSelectorView().environmentObject(space)
            ProjectSelectorView().environmentObject(spaceProject)
        }
    }
}
