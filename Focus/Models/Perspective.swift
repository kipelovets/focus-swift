import Foundation
import Combine

class Perspective: ObservableObject {
    let tree: TaskNodeTree
    let filter: PerspectiveType
    @Published var current: TaskNode? = nil
    @Published var dropTarget: TaskNode? = nil

    private let space: SpaceModel

    init(from space: SpaceModel, with filter: PerspectiveType) {
        self.space = space
        self.filter = filter
        self.tree = TaskNodeTree(from: self.space, with: filter)
        self.current = self.tree.root.children.first
    }

    var dropDepth: Int = 0 {
        didSet {
            guard let target = dropTarget else {
                return
            }
            let targetDepth = target.depth
            
            let maxDepth = targetDepth + 1
            var minDepth = maxDepth
            
            if target.children.count == 0 {
                minDepth = targetDepth
            }
            
            var node: TaskNode? = target
            while node != nil && node?.isRoot != true {
                if node?.isLastChild != true {
                    break
                }
                minDepth -= 1
                node = node?.parent
            }
            
            dropDepth = min(maxDepth, max(minDepth, dropDepth))
        }
    }
    
    @Published var editMode: Bool = false {
        didSet {
            if editMode {
                return
            }
        }
    }

    func next() {
        guard let current = self.current else {
            self.current = self.tree.root.children.first
            return
        }
        
        self.current = current.succeeding ?? current
    }
    
    func prev() {
        guard let current = self.current else {
            self.current = self.tree.root.children.first
            return
        }
        
        self.current = current.preceding ?? current
        if self.current == self.tree.root {
            self.current = current
        }
    }
    
    func remove() {
        guard let current = self.current else {
            return
        }
        
        self.current = current.succeeding ?? current.preceding
        current.parent?.remove(child: current)
        editMode = false
        self.current = nil
    }
    
    func insert() {
        if editMode {
            editMode = false
        }
        let newTask = Task(id: self.space.nextId, title: "")
        let child = TaskNode(from: newTask, childOf: current ?? self.tree.root)
        if let current = self.current {
            if current.children.count > 0 {
                current.add(child: child, at: 0)
            } else {
                current.parent?.add(child: child, after: current)
            }
        } else {
            self.tree.root.add(child: child, at: 0)
        }
        self.current = child
        editMode = true
    }
    
    func edit(node: TaskNode) {
        current = node
        editMode = true
    }
    
    func indent() {
        guard let current = self.current else {
            return
        }
        
        current.indent()
        updateView()
    }
    
    func outdent() {
        guard let current = self.current else {
            return
        }
        
        if current.parent == self.tree.root {
            return
        }
        
        current.outdent()
        updateView()
    }

    func drop() {
        guard let target = self.dropTarget, let current = self.current else {
            return
        }

        self.dropTarget = nil

        if target.isRoot {
            target.add(child: current, at: 0)
            return
        }
        
        if target == current && dropDepth >= target.depth {
            return
        }
        var p: TaskNode? = target.parent
        while p?.isRoot != true {
            if p == current {
                return
            }
            p = p?.parent
        }

        if dropDepth > target.depth {
            target.add(child: current, at: 0)
            return
        }
        var sibling: TaskNode? = target
        let steps = target.depth - dropDepth
        if steps > 0 {
            for _ in 0..<steps {
                sibling = sibling?.parent
            }
        }
        guard sibling != nil else {
            return
        }
        sibling!.insert(sibling: current)
        
    }

    func updateView() {
        objectWillChange.send()
    }
}
