import SwiftUI

struct FocusSelection: ViewModifier {
    let visible: Bool

    init(_ visible: Bool) {
        self.visible = visible
    }

    func body(content: Content) -> some View {
        content
                .overlay(
                        Group {
                            RoundedRectangle(cornerRadius: 7).stroke(Defaults.colors.focusSelected(visible), lineWidth: 5)
                        }.offset(x: -2)
                )
                .overlay(
                        Defaults.colors.focusSelected(visible)
                                .frame(width: 10)
                        .padding(-2.5)
                        .offset(x: -2.7)
                        ,
                        alignment: .trailing
                )
    }
}

struct FilterSelector: View {
    @EnvironmentObject var space: Space
    
    let filter: TaskFilter
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 0) {
                Button(action: {
                    self.space.focus(on: self.filter)
                }) {
                    Text(filter.description).font(.headline)
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 10, alignment: .leading)
                        .background(Defaults.colors.focusSelected(self.space.perspective!.filter.same(as: filter)))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(5)
        }
        .background(Defaults.colors.focusSelected(self.space.perspective!.filter.same(as: filter)))
        .modifier(FocusSelection(self.space.perspective!.filter.same(as: filter)))
    }
}

struct SpaceView: View {
    @ObservedObject var space: Space

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Defaults.colors.lightBackground.frame(width: 20)
            Group {
                VStack(alignment: .leading, spacing: 5) {
                    FilterSelector(filter: .All).padding(.top, 20)
                    FilterSelector(filter: .Inbox)

                    HStack {
                        HStack {
                            CalendarView(space: space)
                            Spacer()
                        }.padding(5)
                            .background(Defaults.colors.focusSelected(self.space.perspective!.filter.same(as: .Due(Date()))))
                    }
                    .modifier(FocusSelection(self.space.perspective!.filter.same(as: .Due(Date()))))
                    Spacer()
                }
            }
            .background(Defaults.colors.lightBackground)
            PerspectiveView(perspective: space.perspective!)
        }
        .background(Defaults.colors.background)
    }
}

struct SpaceView_Previews: PreviewProvider {
    private static let file = Bundle.main.url(forResource: "taskData.json", withExtension: nil)
    private static let repo = TaskSpaceRepositoryFile(filename: file!.path)
    private static let space = Space(repo)
    private static let spaceDue = Space(repo, with: .Due(Date()))
    
    static var previews: some View {
        Group {
            SpaceView(space: space).environmentObject(space)
            SpaceView(space: spaceDue).environmentObject(spaceDue)
        }
    }
}
