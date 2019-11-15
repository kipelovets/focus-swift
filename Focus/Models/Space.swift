import Combine
import Foundation
import SwiftUI

class Space: ObservableObject {
    private let repo: TaskSpaceRepository
    let space: SpaceModel
    @Published private(set) var perspective: Perspective
    
    init(_ repo: TaskSpaceRepository, with filter: PerspectiveType) {
        self.repo = repo
        let space = SpaceModel(from: repo.Load())
        self.space = space
        self.perspective = Perspective(from: space, with: filter)
        
        self.subscribeToPerspectiveChange()
    }
    
    convenience init(_ repo: TaskSpaceRepository) {
        self.init(repo, with: .All)
    }
    
    func save() {
        self.perspective.tree.commit(to: self.space)
        self.repo.Save(space: self.space.dto)
    }
    
    func focus(on filter: PerspectiveType) {
        self.perspective = Perspective(from: self.space, with: filter)
        self.subscribeToPerspectiveChange()
    }
    
    private var subscription: AnyCancellable?
    private func subscribeToPerspectiveChange() {
        self.subscription = self.perspective.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        })
    }
}
