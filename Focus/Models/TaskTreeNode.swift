import Foundation

class TaskTreeNode: Hashable, Identifiable, ObservableObject {
    static func == (lhs: TaskTreeNode, rhs: TaskTreeNode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: Int
    @Published var title: String {
        didSet {
            model?.title = title
        }
    }
    @Published var notes: String = "" {
        didSet {
            model?.notes = notes
        }
    }
    var createdAt: Date
    @Published var dueAt: Date? = nil {
        didSet {
            model?.dueAt = dueAt
        }
    }
    @Published var done: Bool = false {
        didSet {
            model?.done = done
        }
    }
    @Published var project: Project? = nil {
        didSet {
            if (self.isRoot && self.project != nil) ||
                (!self.isRoot && !self.parent!.isRoot && self.project != nil)
            {
                self.project = nil
                return
            }
            model?.project = project
        }
    }
    @Published var tagPositions: [TaskTagPosition] = [] {
        didSet {
            model?.tagPositions = tagPositions
        }
    }
    @Published var children: [TaskTreeNode] = [] {
        didSet {
            model?.children = children.map { $0.model! }
        }
    }

    private(set) var parent: TaskTreeNode? {
        didSet {
            if parent?.isRoot == true {
                model?.parent = nil
                return
            }
            model?.parent = parent?.model
        }
    }

    public let model: Task?

    var indexInParent: Int {
        if parent == nil {
            return 0
        }
        return parent!.children.firstIndex(of: self)!
    }

    var isRoot: Bool {
        parent == nil
    }

    var depth: Int {
        if isRoot {
            return -1
        }
        return 1 + parent!.depth
    }

    var isLastChild: Bool {
        if parent == nil {
            return true
        }
        return indexInParent == parent!.children.count - 1
    }

    init(from model: Task, childOf parent: TaskTreeNode?) {
        self.id = model.id
        self.model = model
        self.title = model.title
        self.notes = model.notes
        self.createdAt = model.createdAt
        self.dueAt = model.dueAt
        self.done = model.done
        self.project = model.project
        self.tagPositions = model.tagPositions
        let modelChildren = model.children
        self.children = []
        let modelParent = model.parent
        self.parent = parent

        if parent == nil {
            model.parent = modelParent
        }

        self.children = modelChildren.map({ TaskTreeNode(from: $0, childOf: self) })
    }

    convenience init(rootFor tasks: [TaskTreeNode]) {
        self.init(from: Task(id: -1, title: "_root"), childOf: nil)
        self.children = tasks
        self.children.forEach({ child in child.parent = self})
    }

    var flattenChildren: [TaskTreeNode] {
        var nodes = self.children
        var parents = nodes
        while parents.count != 0 {
            var newParents: [TaskTreeNode] = []
            for parent in parents {
                newParents += parent.children
            }
            nodes += newParents
            parents = newParents
        }

        return nodes
    }

    var preceding: TaskTreeNode? {
        get {
            guard parent != nil else {
                return nil
            }

            let myIndex = parent!.children.firstIndex(of: self)!
            if myIndex == 0 {
                return parent
            }

            var node: TaskTreeNode? = parent!.children[myIndex - 1]
            while node!.children.count > 0 {
                node = node?.children.last
            }

            return node
        }
    }

    var succeeding: TaskTreeNode? {
        get {
            if self.children.count > 0 {
                return self.children.first
            }

            if parent == nil {
                return nil
            }

            var t = self
            while t.parent != nil {
                let index = t.parent!.children.firstIndex(of: t)!
                if t.parent!.children.count > index + 1 {
                    return t.parent!.children[index + 1]
                }
                t = t.parent!
            }

            return nil
        }
    }

    func remove(child node: TaskTreeNode) {
        guard let index = self.children.firstIndex(of: node) else {
            return
        }
        self.children.remove(at: index)
    }

    func add(child node: TaskTreeNode, at position: Int) {
        var fixedPosition = position
        if node.parent == self {
            if let i = children.firstIndex(of: node), position >= i {
                fixedPosition -= 1
            }
        }
        if fixedPosition < 0 {
            fixedPosition = 0
        }
        node.parent?.remove(child: node)
        self.children.insert(node, at: fixedPosition)
        node.parent = self
    }

    func add(child node: TaskTreeNode, after: TaskTreeNode) {
        guard let index = self.children.firstIndex(of: after) else {
            return
        }
        self.add(child: node, at: index + 1)
    }

    func add(lastChild node: TaskTreeNode) {
        self.add(child: node, at: self.children.endIndex)
    }

    func insert(sibling node: TaskTreeNode) {
        self.parent?.add(child: node, after: self)
    }

    var precedingSibling: TaskTreeNode? {
        get {
            guard self.parent != nil else {
                return nil
            }
            let index = self.parent!.children.firstIndex(of: self)!
            guard index > 0 else {
                return nil
            }
            return self.parent?.children[index - 1]
        }
    }

    func indent() {
        guard let precedingChild = self.precedingSibling else {
            return
        }

        self.parent?.remove(child: self)
        precedingChild.add(child: self, at: precedingChild.children.count)
    }

    func outdent() {
        guard parent?.parent != nil else {
            return
        }

        let oldParent = parent!
        let myPosition = parent!.children.firstIndex(of: self)!
        parent!.parent!.add(child: self, after: parent!)
        let newChildren = oldParent.children[myPosition...]
        oldParent.children.removeSubrange(myPosition...)
        self.children.append(contentsOf: newChildren)
        newChildren.forEach { $0.parent = self }
    }

    func moveUp() {
        guard !isRoot else {
            return
        }
        let indexInParent = self.indexInParent
        if indexInParent != 0 {
            parent!.add(child: self, at: indexInParent - 1)
            return
        }
        if parent!.isRoot {
            return
        }
        parent!.parent!.add(child: self, at: indexInParent)
    }

    func moveDown() {
        guard !isRoot else {
            return
        }
        let indexInParent = self.indexInParent
        if indexInParent < parent!.children.count - 1 {
            parent!.add(child: self, at: indexInParent + 1)
            return
        }
        if parent!.isRoot {
            return
        }
        parent!.parent!.add(child: self, after: parent!)
    }

    func reindexChildren() {
        for (index, child) in children.enumerated() {
            child.model?.position = index
            if child.children.count > 0 {
                child.reindexChildren()
            }
        }
    }
}
