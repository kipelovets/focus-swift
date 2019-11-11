import Combine
import Foundation

class Space: ObservableObject {
    private let repo: TaskSpaceRepository
    let space: TaskSpace
    @Published private(set) var perspective: Perspective?
    
    init(_ repo: TaskSpaceRepository, with filter: TaskFilter) {
        self.repo = repo
        self.space = TaskSpace(from: repo.Load())
        self.perspective = Perspective(from: self, with: filter)
    }
    
    init(_ repo: TaskSpaceRepository) {
        self.repo = repo
        self.space = TaskSpace(from: repo.Load())
        self.perspective = Perspective(from: self, with: .All)
    }
    
    func save() {
        self.perspective?.tree.commit(to: self.space)
        self.repo.Save(space: self.space.dto)
    }
    
    func focus(on filter: TaskFilter) {
        self.perspective = Perspective(from: self, with: filter)
        objectWillChange.send()
        print("CHANGE")
    }
}
