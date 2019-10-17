import Foundation

enum TaskFilter {
    case Inbox
    case Tag(Tag)
    case Project(Project)
    case Due(Date)

    func accepts(task: Task) -> Bool {
        switch (self) {
        case .Inbox:
            return task.parent == nil && task.project == nil
        case .Tag(let tag):
            return task.tagPositions.contains(where: { $0.tag == tag })
        case .Project(let project):
            return task.project == project && task.parent == nil
        case .Due(let date):
            guard task.dueAt != nil else {
                return false
            }
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.none
            dateFormatter.dateStyle = DateFormatter.Style.short

            return dateFormatter.string(from: date) == dateFormatter.string(from: task.dueAt!)
        }
    }
    
    var allowsHierarchy: Bool {
        get {
            switch (self) {
            case .Inbox, .Project(_):
                return true
            default:
                return false
            }
        }
    }
}

fileprivate func flattenTree(root: TaskTreeNode) -> [TaskTreeNode] {
    var nodes = root.children
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

class TaskTree {
    let filter: TaskFilter
    let root: TaskTreeNode
    
    private let originalTasks: [Task]

    init(from space: TaskSpace, with filter: TaskFilter) {
        let tasks = space.tasks.filter({ filter.accepts(task: $0) })
        let root = TaskTreeNode(rootFor: tasks, with: filter)
        
        self.root = root
        self.filter = filter
        self.originalTasks = flattenTree(root: root).map { $0.model! }
    }

    func nth(_ n: Int) -> TaskTreeNode? {
        var counter = 0
        var node = root.children.first
        while counter < n, node != nil {
            node = node?.succeeding
            counter += 1
        }

        return node
    }
    
    var flatten: [TaskTreeNode] {
        get {
            return flattenTree(root: self.root)
        }
    }
    
    func commit(to space: TaskSpace) {
        let currentTasks = flatten.map { $0.model! }
        
        for task in currentTasks {
            if !originalTasks.contains(task) {
                space.tasks.append(task)
            }
        }
        
        for task in originalTasks {
            if !currentTasks.contains(task) {
                space.tasks.remove(at: space.tasks.firstIndex(of: task)!)
            }
        }
    }
    
    func find(by id: Int) -> TaskTreeNode? {
        var tasks = root.children
        while tasks.count > 0 {
            var newTasks: [TaskTreeNode] = []
            for task in tasks {
                if task.id == id {
                    return task
                }
                newTasks += task.children
            }
            tasks = newTasks
        }
        
        return nil
    }
}

class TaskTreeNode: Hashable, Identifiable, ObservableObject {
    static func == (lhs: TaskTreeNode, rhs: TaskTreeNode) -> Bool {
        return lhs.id == rhs.id
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
    @Published var position: Int = 0 {
        didSet {
            model?.position = position
        }
    }
    
    private(set) var parent: TaskTreeNode? {
        didSet {
            guard parent?.parent != nil else {
                return
            }
            model?.parent = parent?.model
        }
    }

    public let model: Task?

    init(from model:Task, filter: TaskFilter, parent: TaskTreeNode) {
        self.id = model.id
        self.model = model
        self.title = model.title
        self.notes = model.notes
        self.createdAt = model.createdAt
        self.dueAt = model.dueAt
        self.done = model.done
        self.project = model.project
        self.tagPositions = model.tagPositions
        self.position = model.position
        let children = model.children
        self.children = []
        self.parent = parent
        
        switch (filter) {
        case .Inbox, .Project:
            self.children = children.map({ TaskTreeNode(from: $0, filter: filter, parent: self) })
        default:
            self.children = []
        }
    }
    
    init(rootFor tasks: [Task], with filter: TaskFilter) {
        self.id = -1
        self.model = Task(id: -1, title: "_root")
        self.title = "_root"
        self.createdAt = Date()
        self.children = []
        
        self.children = tasks.map({ TaskTreeNode(from: $0, filter: filter, parent: self) })
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
        node.parent?.remove(child: node)
        self.children.insert(node, at: position)
        node.parent = self
    }
    
    func add(child node: TaskTreeNode, after: TaskTreeNode) {
        guard let index = self.children.firstIndex(of: after) else {
            return
        }
        self.add(child: node, at: index + 1)
    }
    
    func insert(sibling node: TaskTreeNode) {
        self.parent?.add(child: node, after: self)
        let myChildren = children
        children = []
        node.children.append(contentsOf: myChildren)
        myChildren.forEach { $0.parent = node }
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
        guard parent != nil else {
            return
        }
        let myIndex = parent!.children.firstIndex(of: self)!
        if myIndex > 0 {
            parent!.add(child: self, at: myIndex - 1)
        } else {
            guard parent!.parent != nil else {
                return
            }
            let parentIndex = parent!.parent!.children.firstIndex(of: parent!)!
            parent!.parent!.add(child: self, at: parentIndex)
        }
    }
    
    func moveDown() {
        
    }
}
