import Foundation

class UndoBuffer {
    let space: Space
    var undoSnapshots: [TaskSpaceDto]
    var redoSnapshots: [TaskSpaceDto]
    
    init(space: Space) {
        self.space = space
        undoSnapshots = []
        redoSnapshots = []
    }
    
    func saveSnapshot() {
        undoSnapshots.append(space.model.dto)
    }
    
    func undo() {
        guard let lastSnapshot = undoSnapshots.popLast() else {
            return
        }
        
        redoSnapshots.append(space.model.dto)
        // TODO: apply snapshot
    }
    
    func redo() {
        guard let lastSnapshot = redoSnapshots.popLast() else {
            return
        }
        
        undoSnapshots.append(space.model.dto)
        // TODO: apply snapshot
    }
    
    
    func clear() {
        undoSnapshots = []
        redoSnapshots = []
    }
}
