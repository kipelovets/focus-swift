import Foundation

class TaskNodeTree {
    let filter: PerspectiveType
    let root: TaskNode
    
    private var originalTasks: [Task]

    init(from space: SpaceModel, with perspectiveType: PerspectiveType) {
        var tasks = space.tasks.filter({ perspectiveType.accepts(task: $0) }).sorted(by: { $0.position < $1.position })
        if perspectiveType.allowsHierarchy {
            tasks = tasks.filter({ $0.parent == nil })
        }

        let nodes = tasks.map({ TaskNode(from: $0, childOf: nil) })
        if perspectiveType.allowsHierarchy {
            var parents: [TaskNode] = nodes
            while parents.count > 0 {
                var newParents: [TaskNode] = []
                for parent in parents {
                    guard parent.model!.children.count != 0 else {
                        continue
                    }
                    parent.children = parent.model!.children.map({ TaskNode(from: $0, childOf: parent) })
                    newParents = newParents + parent.children
                }
                parents = newParents
            }
        } else {
            for node in nodes {
                if node.model?.parent != nil {
                    TaskNode(from: node.model!.parent!, childOf: nil).add(child: node, at: 0)
                }
                if node.model!.children.count > 0 {
                    for child in node.model!.children {
                        node.add(lastChild: TaskNode(from: child, childOf: node))
                    }
                }
            }
        }

        // TODO: forbid drag&drop & indentation if perspective type doesn't allow hierarchy

        self.root = TaskNode(rootFor: nodes, allowingHierarchy: perspectiveType.allowsHierarchy)
        self.filter = perspectiveType
        self.originalTasks = root.flattenChildren.map { $0.model! }
    }

    func nth(_ n: Int) -> TaskNode? {
        var counter = -1
        var node: TaskNode? = root
        while counter < n, node != nil {
            node = node?.succeeding
            counter += 1
        }

        return node
    }
    
    func commit(to space: SpaceModel) {
        let currentTasks = self.root.flattenChildren.map { $0.model! }
        
        for task in currentTasks {
            if !originalTasks.contains(task) {
                space.tasks.append(task)
            }
        }
        
        if filter.allowsHierarchy {
            root.reindexChildren()
        } else {
            var pos = 0
            var node = root.succeeding
            try! safeWhile({
                switch filter {
                case .Due(_):
                    node?.model?.duePosition = pos
                case .Tag(let tag):
                    node?.model?.position(at: pos, in: tag)
                default:
                    break
                }
                pos += 1
                let s = node?.nextSibling
                node = s
                
                return node != nil
            }, count: root.flattenChildren.count + 1)
        }
        
        for task in originalTasks {
            if !currentTasks.contains(task) {
                space.tasks.remove(at: space.tasks.firstIndex(of: task)!)
            }
        }
        originalTasks = root.flattenChildren.map { $0.model! }
    }
    
    func find(by id: Int) -> TaskNode? {
        var tasks = root.children
        while tasks.count > 0 {
            var newTasks: [TaskNode] = []
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

