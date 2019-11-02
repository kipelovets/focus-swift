import SwiftUI

struct SpaceView: View {
    @ObservedObject var space: Space
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
            }
            PerspectiveView(perspective: space.perspective!)
        }
    }
}
