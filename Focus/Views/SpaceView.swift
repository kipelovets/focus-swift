import SwiftUI

struct SpaceView: View {
    @ObservedObject var space: Space
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    self.space.focus(on: .Inbox)
                }) {
                    Text("Inbox").font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
                CalendarView(space: space)
            }
            PerspectiveView(perspective: space.perspective!)
        }
    }
}
