import Foundation
import Combine

class Perspective: ObservableObject {
    let tree: TaskTree
    @Published var current: TaskTreeNode? = nil
    @Published var dropTarget: TaskTreeNode? = nil
    let space: TaskSpace
    
    @Published var editMode: Bool = false {
        didSet {
            if editMode {
                return
            }
            save()
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
        save()
        self.current = nil
    }
    
    func insert() {
        if editMode {
            editMode = false
        }
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
        editMode = true
        save()
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
        save()
        objectWillChange.send()
    }
    
    func outdent() {
        guard let current = self.current else {
            return
        }
        
        if current.parent == self.tree.root {
            return
        }
        
        current.outdent()
        save()
        objectWillChange.send()
    }

    func drop() {
        guard let target = self.dropTarget, let current = self.current else {
            return
        }

        self.dropTarget = nil

        if target.isRoot {
            target.add(child: current, at: 0)
            save()
            return
        }

        target.insert(sibling: current)
        save()
    }

    private func save() {
        print("Before commit")
        dumpTree(node: tree.root)
        tree.commit(to: space)
        print("After commit")
        dumpTree(node: tree.root)
        repo.Save(space: space.dto)
    }
}
