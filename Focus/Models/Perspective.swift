import Foundation

class Perspective {
    let tree: TaskTree
    var current: TaskTreeNode? = nil
    let dropTarget: TaskTreeNode? = nil
    let space: TaskSpace
    
    var editMode: Bool = false {
        didSet {
            if editMode {
                return
            }
            tree.commit(to: space)
            repo.Save(space: space.dto)
        }
    }
    
    private let repo: TaskSpaceRepository
    private let filter: TaskFilter
    
    init(from repo: TaskSpaceRepository, with filter: TaskFilter) {
        self.repo = repo
        self.space = TaskSpace(from: repo.Load())
        self.filter = filter
        self.tree = TaskTree(from: self.space, with: filter)
        self.current = self.tree.root.children.first
    }
    
    func next() {
        guard let current = self.current else {
            self.current = self.tree.root.children.first
            return
        }
        
        self.current = current.preceding ?? current
    }
    
    func prev() {
        guard let current = self.current else {
            self.current = self.tree.root.children.first
            return
        }
        
        self.current = current.succeeding ?? current
        if self.current == self.tree.root {
            self.current = current
        }
    }
    
    func remove() {
        guard let current = self.current else {
            return
        }
        
        current.parent?.remove(child: current)
        editMode = false
    }
    
    func insert() {
        let newTask = Task(id: self.space.nextId, title: "")
        let child = TaskTreeNode(from: newTask, filter: self.filter, parent: current ?? self.tree.root)
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
        editMode = false
    }
    
    func edit(node: TaskTreeNode) {
        current = node
        editMode = true
    }
    
    func indent() {
        guard let current = self.current else {
            return
        }
        
        current.indent()
    }
    
    func outdent() {
        guard let current = self.current else {
            return
        }
        
        if current.parent == self.tree.root {
            return
        }
        
        current.outdent()
    }
}
