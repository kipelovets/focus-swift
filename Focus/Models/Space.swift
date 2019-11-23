import Combine
import Foundation
import SwiftUI

class Space: ObservableObject {
    private let repo: TaskSpaceRepository
    let model: SpaceModel
    @Published private(set) var perspective: Perspective
    
    init(_ repo: TaskSpaceRepository, with filter: PerspectiveType) {
        self.repo = repo
        let space = SpaceModel(from: repo.Load())
        self.model = space
        self.perspective = Perspective(from: space, with: filter)
        
        self.subscribeToPerspectiveChange()
    }
    
    convenience init(_ repo: TaskSpaceRepository) {
        self.init(repo, with: .All)
    }
    
    func save() {
        self.perspective.tree.commit(to: self.model)
        self.repo.Save(space: self.model.dto)
    }
    
    func focus(on filter: PerspectiveType) {
        subscription?.cancel()
        perspective = Perspective(from: model, with: filter)
        subscribeToPerspectiveChange()
    }
    
    private var subscription: AnyCancellable?
    private func subscribeToPerspectiveChange() {
        self.subscription = self.perspective.objectWillChange.sink(receiveValue: { _ in
            self.objectWillChange.send()
        })
    }
}
