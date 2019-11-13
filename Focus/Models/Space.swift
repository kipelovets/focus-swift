import Combine
import Foundation

class Space: ObservableObject {
    private let repo: TaskSpaceRepository
    let space: SpaceModel
    @Published private(set) var perspective: Perspective

    init(_ repo: TaskSpaceRepository, with filter: PerspectiveType) {
        self.repo = repo
        let space = SpaceModel(from: repo.Load())
        self.space = space
        self.perspective = Perspective(from: space, with: filter)
    }
    
    init(_ repo: TaskSpaceRepository) {
        self.repo = repo
        let space = SpaceModel(from: repo.Load())
        self.space = space
        self.perspective = Perspective(from: space, with: .All)
    }
    
    func save() {
        self.perspective.tree.commit(to: self.space)
        self.repo.Save(space: self.space.dto)
    }
    
    func focus(on filter: PerspectiveType) {
        self.perspective = Perspective(from: self.space, with: filter)
        objectWillChange.send()
    }
}
